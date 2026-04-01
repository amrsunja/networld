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
    const padded = base64.padEnd(base64.length + ((4 - (base64.length % 4)) % 4), "=");
    const payload = JSON.parse(atob(padded));
    return payload.sub ?? null;
  } catch {
    return null;
  }
}

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  try {
    const authHeader = req.headers.get("Authorization") ?? req.headers.get("authorization") ?? "";
    const userId = getUserIdFromJWT(authHeader);

    if (!userId) {
      return jsonResponse({ success: false, error: "unauthorized" }, 401);
    }

    const body = await req.json();
    const claimType = body.claim_type as string | undefined;

    if (!claimType) {
      return jsonResponse({ success: false, error: "claim_type_required" }, 400);
    }

    if (claimType === "survey_gift") {
      const pollId = body.poll_id as string | undefined;
      if (!pollId) {
        return jsonResponse({ success: false, error: "poll_id_required" }, 400);
      }

      // 1. Fetch poll
      const { data: poll, error: pollError } = await supabaseAdmin
        .from("admin_polls")
        .select("id, scheduled_for, reset_hour, is_active")
        .eq("id", pollId)
        .eq("is_active", true)
        .maybeSingle();

      if (pollError || !poll) {
        return jsonResponse({ success: false, error: "poll_not_found" }, 400);
      }

      // 2. Check poll not expired: now > scheduled_for at reset_hour
      const now = new Date();
      const scheduled = new Date(poll.scheduled_for);
      const resetHour: number = poll.reset_hour ?? 20;
      scheduled.setHours(resetHour, 0, 0, 0);
      if (now > scheduled) {
        return jsonResponse({ success: false, error: "poll_expired" }, 400);
      }

      // 3. Check user voted
      const { data: vote, error: voteError } = await supabaseAdmin
        .from("votes")
        .select("id")
        .eq("poll_id", pollId)
        .eq("user_id", userId)
        .maybeSingle();

      if (voteError) throw voteError;
      if (!vote) {
        return jsonResponse({ success: false, error: "must_vote_first" }, 400);
      }

      // 4. Insert into poll_gift_claims with credits_awarded = 0
      const { error: insertError } = await supabaseAdmin
        .from("poll_gift_claims")
        .insert({
          poll_id: pollId,
          user_id: userId,
          credits_awarded: 0,
        });

      if (insertError) {
        // Duplicate primary key → already claimed today
        if ((insertError as any).code === "23505") {
          return jsonResponse({ success: false, error: "already_claimed_today" }, 400);
        }
        throw insertError;
      }

      // 5. Random credits between 100 and 500 (inclusive)
      const creditsAwarded = Math.floor(Math.random() * 401) + 100;

      const { error: updateClaimError } = await supabaseAdmin
        .from("poll_gift_claims")
        .update({ credits_awarded: creditsAwarded })
        .eq("poll_id", pollId)
        .eq("user_id", userId);

      if (updateClaimError) throw updateClaimError;

      // 6. Credit profile and ledger as normal
      const { data: profile, error: profileError } = await supabaseAdmin
        .from("profiles")
        .select("credits")
        .eq("id", userId)
        .single();

      if (profileError || !profile) throw profileError;

      const newCredits = (profile.credits ?? 0) + creditsAwarded;

      const { error: profileUpdateError } = await supabaseAdmin
        .from("profiles")
        .update({ credits: newCredits })
        .eq("id", userId);

      if (profileUpdateError) throw profileUpdateError;

      const { error: ledgerError } = await supabaseAdmin
        .from("credit_transactions")
        .insert({
          user_id: userId,
          amount: creditsAwarded,
          reason: "survey_gift",
        });

      if (ledgerError) throw ledgerError;

      return jsonResponse({
        success: true,
        error: null,
        credits_awarded: creditsAwarded,
      });
    }

    // Placeholder: keep existing missions / streak logic unchanged.
    // If you already have an implementation elsewhere, merge it here.
    return jsonResponse({ success: false, error: "unsupported_claim_type" }, 400);
  } catch (err) {
    const message = (err as any)?.message ?? String(err);
    return jsonResponse({ success: false, error: message }, 500);
  }
});

