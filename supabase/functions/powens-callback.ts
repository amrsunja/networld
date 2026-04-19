// supabase/functions/powens-callback/index.ts
// Webhook appelé par Powens après connexion bancaire réussie.
// Reçoit les données bancaires, calcule le net worth réel, met à jour le profil.
// URL à configurer dans le dashboard Powens : https://<project>.supabase.co/functions/v1/powens-callback

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Powens envoie un webhook signé — on vérifie la signature
    const powensWebhookSecret = Deno.env.get("POWENS_WEBHOOK_SECRET")!;
    const signature = req.headers.get("X-Powens-Signature");

    const body = await req.text();

    // Vérification HMAC-SHA256 de la signature Powens
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(powensWebhookSecret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const signatureBuffer = await crypto.subtle.sign("HMAC", key, encoder.encode(body));
    const expectedSignature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer)));

    if (signature !== expectedSignature) {
      return new Response(JSON.stringify({ error: "invalid_signature" }), {
        status: 401, headers: { "Content-Type": "application/json" },
      });
    }

    const payload = JSON.parse(body);
    // Payload Powens contient : user_id (notre user Supabase stocké dans metadata Powens)
    // et les données financières agrégées

    const { supabase_user_id, access_token } = payload;

    if (!supabase_user_id || !access_token) {
      return new Response(JSON.stringify({ error: "missing_fields" }), {
        status: 400, headers: { "Content-Type": "application/json" },
      });
    }

    // 1. Récupère les données de patrimoine via l'API Powens
    const powensBaseUrl = Deno.env.get("POWENS_BASE_URL") ?? "https://partner-api.powens.com";

    const [accountsRes, loansRes] = await Promise.all([
      fetch(`${powensBaseUrl}/2.0/users/me/accounts`, {
        headers: { Authorization: `Bearer ${access_token}` },
      }),
      fetch(`${powensBaseUrl}/2.0/users/me/loans`, {
        headers: { Authorization: `Bearer ${access_token}` },
      }),
    ]);

    const accountsData = await accountsRes.json();
    const loansData = await loansRes.json();

    // 2. Calcule le net worth : somme des comptes - dettes
    const totalAssets: number = (accountsData.accounts ?? []).reduce(
      (sum: number, acc: any) => sum + (acc.balance ?? 0), 0
    );
    const totalDebts: number = (loansData.loans ?? []).reduce(
      (sum: number, loan: any) => sum + (loan.balance ?? 0), 0
    );
    const netWorth = totalAssets - totalDebts;

    // 3. Met à jour le profil (les triggers T4+T5 s'exécutent automatiquement)
    const { error: updateError } = await supabase
      .from("profiles")
      .update({
        net_worth: netWorth,
        net_worth_input_method: "powens",
        onboarding_completed: true,
      })
      .eq("id", supabase_user_id);

    if (updateError) throw updateError;

    return new Response(
      JSON.stringify({ success: true, net_worth: netWorth }),
      { headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
