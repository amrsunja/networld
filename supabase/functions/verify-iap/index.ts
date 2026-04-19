// supabase/functions/verify-iap/index.ts
// Validates App Store + Google Play purchases; credits consumables; updates subscription tier + expiry.
// Never trust the client — always validate with Apple / Google APIs.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/** Consumable credit packs — keep in sync with App Store Connect + Play Console. */
const CREDIT_PACKS: Record<string, number> = {
  "com.brokies.credits_1000": 1000,
  "com.brokies.credits_5000": 5000,
  "com.brokies.credits_15000": 15000,
  "com.brokies.credits_50000": 50000,
  "com.brokies.credits_150000": 150000,
};

/** Auto-renewing subscriptions — tier stored in DB (weekly credits via SQL cron). */
const SUBSCRIPTION_TIERS: Record<string, "silver" | "gold" | "diamond"> = {
  "com.brokies.sub.silver": "silver",
  "com.brokies.sub.gold": "gold",
  "com.brokies.sub.diamond": "diamond",
};

type Kind = "consumable" | "subscription";

/** JSON body + correct HTTP status so Supabase logs show failures (not only 200). */
function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  console.log(
    JSON.stringify({
      fn: "verify-iap",
      http: status,
      success: body.success,
      error: body.error ?? null,
      detail: body.detail ?? null,
    }),
  );
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const authHeader = req.headers.get("Authorization")!;
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
    if (authError || !user) {
      return jsonResponse({ success: false, error: "unauthorized" }, 401);
    }

    const body = await req.json();
    const platform = body.platform as "ios" | "android";
    const kind = (body.kind ?? "consumable") as Kind;
    const product_id = body.product_id as string;
    const transaction_id = String(body.transaction_id ?? "");
    const receipt_data = body.receipt_data as string;

    if (!platform || !product_id || !transaction_id || !receipt_data) {
      return jsonResponse({ success: false, error: "missing_fields" }, 400);
    }

    if (kind === "consumable") {
      return await handleConsumable(
        supabase,
        user.id,
        platform,
        product_id,
        transaction_id,
        receipt_data,
      );
    }

    if (kind === "subscription") {
      return await handleSubscription(
        supabase,
        user.id,
        platform,
        product_id,
        transaction_id,
        receipt_data,
      );
    }

    return jsonResponse({ success: false, error: "invalid_kind" }, 400);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return jsonResponse({ success: false, error: message }, 500);
  }
});

async function handleConsumable(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  platform: "ios" | "android",
  product_id: string,
  transaction_id: string,
  receipt_data: string,
) {
  const creditsToGrant = CREDIT_PACKS[product_id];
  if (!creditsToGrant) {
    return jsonResponse({ success: false, error: "unknown_product" }, 400);
  }

  let resolvedTransactionId = transaction_id;

  if (platform === "ios") {
    const ios = await validateIosConsumable(product_id, transaction_id, receipt_data);
    if (!ios.ok) {
      return jsonResponse(
        {
          success: false,
          error: "receipt_validation_failed",
          detail: ios.detail ?? undefined,
        },
        400,
      );
    }
    resolvedTransactionId = ios.resolvedTransactionId;
  } else if (platform === "android") {
    const ok = await validateAndroidConsumable(product_id, receipt_data);
    if (!ok) {
      return jsonResponse({ success: false, error: "receipt_validation_failed" }, 400);
    }
  } else {
    return jsonResponse({ success: false, error: "invalid_platform" }, 400);
  }

  const { data: existingTx } = await supabase
    .from("credit_transactions")
    .select("id")
    .eq("iap_transaction_id", resolvedTransactionId)
    .maybeSingle();

  if (existingTx) {
    return jsonResponse({ success: false, error: "transaction_already_processed" }, 409);
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("credits")
    .eq("id", userId)
    .single();

  const newBalance = (profile?.credits ?? 0) + creditsToGrant;

  await supabase
    .from("profiles")
    .update({ credits: newBalance })
    .eq("id", userId);

  await supabase.from("credit_transactions").insert({
    user_id: userId,
    amount: creditsToGrant,
    reason: "iap_purchase",
    ref_id: null,
    iap_transaction_id: resolvedTransactionId,
  });

  return jsonResponse({
    success: true,
    credits_granted: creditsToGrant,
    balance: newBalance,
  });
}

type IosConsumableResult =
  | { ok: true; resolvedTransactionId: string }
  | { ok: false; detail?: string };

function collectIosReceiptTransactions(
  appleData: Record<string, unknown>,
): Array<Record<string, string>> {
  const receipt = appleData.receipt as Record<string, unknown> | undefined;
  const inApp = (receipt?.in_app as Array<Record<string, string>>) ?? [];
  const latest = (appleData.latest_receipt_info as Array<Record<string, string>>) ?? [];
  const byTx = new Map<string, Record<string, string>>();
  for (const t of [...inApp, ...latest]) {
    const id = String(t.transaction_id ?? "");
    if (id && !byTx.has(id)) byTx.set(id, t);
  }
  return [...byTx.values()];
}

async function validateIosConsumable(
  product_id: string,
  transaction_id: string,
  receipt_data: string,
): Promise<IosConsumableResult> {
  const appleSharedSecret = Deno.env.get("APPLE_SHARED_SECRET");
  if (!appleSharedSecret) {
    return { ok: false, detail: "missing_apple_shared_secret" };
  }

  let lastAppleStatus: number | undefined;

  for (const appleUrl of [
    "https://buy.itunes.apple.com/verifyReceipt",
    "https://sandbox.itunes.apple.com/verifyReceipt",
  ]) {
    const appleRes = await fetch(appleUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        "receipt-data": receipt_data,
        password: appleSharedSecret,
        "exclude-old-transactions": false,
      }),
    });
    const appleData = (await appleRes.json()) as Record<string, unknown>;
    const status = Number(appleData.status);
    lastAppleStatus = status;

    // 21007 = sandbox receipt sent to production URL — try next URL
    if (status === 21007) continue;
    if (status !== 0) continue;

    const all = collectIosReceiptTransactions(appleData);
    const candidates = all.filter((t) => t.product_id === product_id);
    if (candidates.length === 0) {
      continue;
    }

    const byClientId = candidates.find(
      (t) =>
        String(t.transaction_id) === String(transaction_id) ||
        String(t.original_transaction_id) === String(transaction_id),
    );
    if (byClientId?.transaction_id) {
      return { ok: true, resolvedTransactionId: String(byClientId.transaction_id) };
    }

    const sorted = [...candidates].sort(
      (a, b) =>
        parseInt(String(b.purchase_date_ms ?? 0), 10) -
        parseInt(String(a.purchase_date_ms ?? 0), 10),
    );
    const best = sorted[0];
    if (best?.transaction_id) {
      return { ok: true, resolvedTransactionId: String(best.transaction_id) };
    }
  }

  return {
    ok: false,
    detail: lastAppleStatus !== undefined ? `apple_status_${lastAppleStatus}` : "no_valid_receipt",
  };
}

async function validateAndroidConsumable(
  product_id: string,
  receipt_data: string,
): Promise<boolean> {
  let packageName: string;
  let purchaseToken: string;
  try {
    const parsed = JSON.parse(receipt_data);
    packageName = parsed.packageName;
    purchaseToken = parsed.purchaseToken;
  } catch {
    return false;
  }
  const token = Deno.env.get("GOOGLE_PLAY_ACCESS_TOKEN");
  if (!token) return false;

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}` +
    `/purchases/products/${product_id}/tokens/${encodeURIComponent(purchaseToken)}`;

  const googleRes = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!googleRes.ok) return false;
  const googleData = await googleRes.json();
  return googleData.purchaseState === 0;
}

async function handleSubscription(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  platform: "ios" | "android",
  product_id: string,
  transaction_id: string,
  receipt_data: string,
) {
  const tier = SUBSCRIPTION_TIERS[product_id];
  if (!tier) {
    return jsonResponse({ success: false, error: "unknown_subscription" }, 400);
  }

  let expiresAtIso: string | null = null;
  let storeTransactionKey = transaction_id;

  if (platform === "ios") {
    const parsed = await validateIosSubscription(product_id, receipt_data);
    if (!parsed) {
      return jsonResponse({ success: false, error: "receipt_validation_failed" }, 400);
    }
    expiresAtIso = parsed.expiresAtIso;
    storeTransactionKey = parsed.originalTransactionId ?? transaction_id;
  } else if (platform === "android") {
    const parsed = await validateAndroidSubscription(product_id, receipt_data);
    if (!parsed) {
      return jsonResponse({ success: false, error: "receipt_validation_failed" }, 400);
    }
    expiresAtIso = parsed.expiresAtIso;
    // Stable key for idempotent audit rows (token persists for the subscription).
    storeTransactionKey = parsed.purchaseToken;
  } else {
    return jsonResponse({ success: false, error: "invalid_platform" }, 400);
  }

  if (!expiresAtIso || new Date(expiresAtIso).getTime() <= Date.now()) {
    return jsonResponse({ success: false, error: "subscription_not_active" }, 400);
  }

  await supabase.from("iap_subscription_events").upsert(
    {
      user_id: userId,
      platform,
      store_transaction: storeTransactionKey,
      product_id,
      tier,
      expires_at: expiresAtIso,
    },
    { onConflict: "platform,store_transaction" },
  );

  await supabase
    .from("profiles")
    .update({
      subscription_tier: tier,
      subscription_expires_at: expiresAtIso,
    })
    .eq("id", userId);

  return jsonResponse({
    success: true,
    tier,
    subscription_expires_at: expiresAtIso,
  });
}

async function validateIosSubscription(
  product_id: string,
  receipt_data: string,
): Promise<{ expiresAtIso: string; originalTransactionId?: string } | null> {
  const appleSharedSecret = Deno.env.get("APPLE_SHARED_SECRET");
  if (!appleSharedSecret) return null;

  for (const appleUrl of [
    "https://buy.itunes.apple.com/verifyReceipt",
    "https://sandbox.itunes.apple.com/verifyReceipt",
  ]) {
    const appleRes = await fetch(appleUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        "receipt-data": receipt_data,
        password: appleSharedSecret,
        "exclude-old-transactions": false,
      }),
    });
    const appleData = await appleRes.json();
    if (appleData.status !== 0) continue;

    const infos = appleData.latest_receipt_info as Array<Record<string, string>> | undefined;
    if (!Array.isArray(infos) || infos.length === 0) continue;

    const matches = infos.filter((t) => t.product_id === product_id);
    if (matches.length === 0) continue;

    let best: Record<string, string> | null = null;
    let bestMs = 0;
    for (const t of matches) {
      const ms = parseInt(t.expires_date_ms ?? "0", 10);
      if (ms > bestMs) {
        bestMs = ms;
        best = t;
      }
    }
    if (!best) continue;

    return {
      expiresAtIso: new Date(bestMs).toISOString(),
      originalTransactionId: best.original_transaction_id,
    };
  }
  return null;
}

async function validateAndroidSubscription(
  product_id: string,
  receipt_data: string,
): Promise<{ expiresAtIso: string; purchaseToken: string; orderId?: string } | null> {
  let packageName: string;
  let purchaseToken: string;
  try {
    const parsed = JSON.parse(receipt_data);
    packageName = parsed.packageName;
    purchaseToken = parsed.purchaseToken;
  } catch {
    return null;
  }
  const token = Deno.env.get("GOOGLE_PLAY_ACCESS_TOKEN");
  if (!token) return null;

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}` +
    `/purchases/subscriptions/${encodeURIComponent(product_id)}` +
    `/tokens/${encodeURIComponent(purchaseToken)}`;

  const googleRes = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!googleRes.ok) return null;
  const googleData = await googleRes.json();
  const expiryMs = parseInt(googleData.expiryTimeMillis ?? "0", 10);
  if (!expiryMs) return null;
  return {
    expiresAtIso: new Date(expiryMs).toISOString(),
    purchaseToken,
    orderId: googleData.orderId as string | undefined,
  };
}
