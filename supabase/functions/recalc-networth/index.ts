// supabase/functions/recalc-networth/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function getUserIdFromJWT(authHeader: string): string | null {
  try {
    const token = authHeader.replace("Bearer ", "");
    const parts = token.split(".");
    if (parts.length !== 3) return null;
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(base64.length + (4 - base64.length % 4) % 4, "=");
    const payload = JSON.parse(atob(padded));
    return payload.sub ?? null;
  } catch { return null; }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const authHeader = req.headers.get("Authorization") ?? req.headers.get("authorization") ?? "";
    const userId = getUserIdFromJWT(authHeader);

    if (!userId) {
      return new Response(
        JSON.stringify({ success: false, error: "unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body = await req.json();
    const { method, net_worth: manualNetWorth, powens_permanent_token } = body;

    // 1. Profil
    const { data: profile, error: profileError } = await supabaseAdmin
      .from("profiles")
      .select("credits, next_free_calc_at, onboarding_completed")
      .eq("id", userId)
      .single();

    if (profileError) throw profileError;

    const isFree = !profile.onboarding_completed || new Date(profile.next_free_calc_at) <= new Date();
    const COST = 1000;

    if (!isFree && profile.credits < COST) {
      return new Response(
        JSON.stringify({ success: false, error: "insufficient_credits", required: COST, current: profile.credits }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let newNetWorth: number;
    let detectedCurrency = "EUR"; // défaut

    if (method === "manual") {
      if (typeof manualNetWorth !== "number") {
        return new Response(
          JSON.stringify({ success: false, error: "net_worth_required" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      if (manualNetWorth > 25000) {
        return new Response(
          JSON.stringify({ success: false, error: "manual_amount_limit_use_powens" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      newNetWorth = manualNetWorth;
      // Pour manual: on garde la devise déjà en base (pas de changement)
      detectedCurrency = "KEEP"; // signal pour ne pas écraser la devise existante

    } else if (method === "powens") {
      if (!powens_permanent_token) {
        return new Response(
          JSON.stringify({ success: false, error: "powens_permanent_token_required" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const DOMAIN = Deno.env.get("POWENS_DOMAIN")!;

      const accountsRes = await fetch(`https://${DOMAIN}/2.0/users/me/accounts`, {
        headers: { Authorization: `Bearer ${powens_permanent_token}` },
      });

      if (!accountsRes.ok) {
        throw new Error(`powens_accounts_failed: ${await accountsRes.text()}`);
      }

      const accountsData = await accountsRes.json();
      const activeAccounts = (accountsData.accounts ?? []).filter((acc: any) => !acc.disabled);

      // Calcule net worth
      newNetWorth = activeAccounts.reduce((sum: number, acc: any) => sum + (acc.balance ?? 0), 0);

      // Détecte la devise principale (la plus fréquente parmi les comptes)
      // Powens retourne currency comme string directement (ex: "EUR", "USD")
      const currencyCounts: Record<string, number> = {};
      for (const acc of activeAccounts) {
        const cur = (typeof acc.currency === "string" ? acc.currency : acc.currency?.id) ?? "EUR";
        currencyCounts[cur] = (currencyCounts[cur] ?? 0) + 1;
      }
      detectedCurrency = Object.entries(currencyCounts)
        .sort((a, b) => b[1] - a[1])[0]?.[0] ?? "EUR";

    } else {
      return new Response(
        JSON.stringify({ success: false, error: "invalid_method" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Met à jour le profil
    const updates: Record<string, unknown> = {
      net_worth: newNetWorth,
      net_worth_input_method: method,
      onboarding_completed: true,
      is_verified: method === "powens",
      ...(!isFree && { credits: profile.credits - COST }),
      ...(detectedCurrency !== "KEEP" && { currency: detectedCurrency }),
    };

    const { error: updateError } = await supabaseAdmin.from("profiles").update(updates).eq("id", userId);
    if (updateError) throw updateError;

    if (!isFree) {
      await supabaseAdmin.from("credit_transactions").insert({ user_id: userId, amount: -COST, reason: "networth_recalc" });
    }

    // Supprime l'utilisateur Powens pour libérer le slot sandbox
    if (method === "powens" && powens_permanent_token) {
      const DOMAIN = Deno.env.get("POWENS_DOMAIN")!;
      try {
        await fetch(`https://${DOMAIN}/2.0/users/me`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${powens_permanent_token}` },
        });
      } catch (_) {
        console.error("Failed to delete Powens user — not critical");
      }
    }

    const { data: updated } = await supabaseAdmin
      .from("profiles")
      .select("rank_tier, credits, next_free_calc_at, currency")
      .eq("id", userId)
      .single();

    return new Response(
      JSON.stringify({
        success: true,
        net_worth: newNetWorth,
        was_free: isFree,
        rank_tier: updated?.rank_tier,
        credits: updated?.credits,
        next_free_calc_at: updated?.next_free_calc_at,
        currency: updated?.currency ?? "EUR",
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});