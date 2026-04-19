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
    // base64url → base64
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(base64.length + (4 - base64.length % 4) % 4, "=");
    const payload = JSON.parse(atob(padded));
    return payload.sub ?? null;
  } catch {
    return null;
  }
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
    const {
      method,
      net_worth: manualNetWorth,
      powens_access_token,
      powens_code,
      powens_user_token,
    } = body;

    // 1. Récupère le profil
    const { data: profile, error: profileError } = await supabaseAdmin
      .from("profiles")
      .select("credits, next_free_calc_at, onboarding_completed")
      .eq("id", userId)
      .single();

    if (profileError) throw profileError;

    const isFree =
      !profile.onboarding_completed ||
      new Date(profile.next_free_calc_at) <= new Date();

    const COST = 1000;

    if (!isFree && profile.credits < COST) {
      return new Response(
        JSON.stringify({ success: false, error: "insufficient_credits", required: COST, current: profile.credits }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let newNetWorth: number;

    if (method === "manual") {
      if (typeof manualNetWorth !== "number") {
        return new Response(
          JSON.stringify({ success: false, error: "net_worth_required" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      if (manualNetWorth > 25000) {
        return new Response(
          JSON.stringify({ success: false, error: "manual_limit_25000_use_powens" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      newNetWorth = manualNetWorth;

    } else if (method === "powens") {
      let accessToken: string;
      const powensBaseUrl = Deno.env.get("POWENS_BASE_URL") ?? "https://partner-api.powens.com";
      const CLIENT_ID = Deno.env.get("POWENS_CLIENT_ID")!;
      const CLIENT_SECRET = Deno.env.get("POWENS_CLIENT_SECRET")!;
      const REDIRECT_URI = "networld://powens-callback";

      if (powens_code) {
        // OAuth flow: exchange authorization code for access_token
        const tokenRes = await fetch(`${powensBaseUrl}/2.0/auth/token/access`, {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body: new URLSearchParams({
            grant_type: "authorization_code",
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            code: powens_code,
            redirect_uri: REDIRECT_URI,
          }),
        });
        const tokenData = await tokenRes.json();
        accessToken = tokenData.access_token;
        if (!accessToken) {
          return new Response(
            JSON.stringify({ success: false, error: "powens_token_exchange_failed", details: tokenData }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }
      } else if (powens_access_token) {
        accessToken = powens_access_token;
      } else {
        return new Response(
          JSON.stringify({ success: false, error: "powens_access_token_required" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const [accountsRes, loansRes] = await Promise.all([
        fetch(`${powensBaseUrl}/2.0/users/me/accounts`, { headers: { Authorization: `Bearer ${accessToken}` } }),
        fetch(`${powensBaseUrl}/2.0/users/me/loans`, { headers: { Authorization: `Bearer ${accessToken}` } }),
      ]);
      if (!accountsRes.ok) {
        return new Response(JSON.stringify({ success: false, error: "powens_api_error" }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
      }
      const accountsData = await accountsRes.json();
      const loansData = loansRes.ok ? await loansRes.json() : { loans: [] };
      const totalAssets: number = (accountsData.accounts ?? []).reduce((sum: number, acc: any) => sum + (acc.balance ?? 0), 0);
      const totalDebts: number = (loansData.loans ?? []).reduce((sum: number, loan: any) => sum + (loan.balance ?? 0), 0);
      newNetWorth = totalAssets - totalDebts;

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
      ...(!isFree && { credits: profile.credits - COST }),
    };

    const { error: updateError } = await supabaseAdmin.from("profiles").update(updates).eq("id", userId);
    if (updateError) throw updateError;

    if (!isFree) {
      await supabaseAdmin.from("credit_transactions").insert({ user_id: userId, amount: -COST, reason: "networth_recalc" });
    }

    const { data: updated } = await supabaseAdmin.from("profiles").select("rank_tier, credits, next_free_calc_at").eq("id", userId).single();

    return new Response(
      JSON.stringify({
        success: true,
        net_worth: newNetWorth,
        was_free: isFree,
        rank_tier: updated?.rank_tier,
        credits: updated?.credits,
        next_free_calc_at: updated?.next_free_calc_at,
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
