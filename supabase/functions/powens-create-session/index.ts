// supabase/functions/powens-create-session/index.ts
// Creates a Powens user session and returns the webview URL for bank connection.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function getUserIdFromJWT(authHeader: string): string | null {
  try {
    const token = authHeader.replace("Bearer ", "");
    const parts = token.split(".");
    if (parts.length !== 3) return null;
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(
      base64.length + ((4 - (base64.length % 4)) % 4),
      "="
    );
    const payload = JSON.parse(atob(padded));
    return payload.sub ?? null;
  } catch {
    return null;
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response("ok", { headers: corsHeaders });

  const authHeader = req.headers.get("Authorization") ?? "";
  const userId = getUserIdFromJWT(authHeader);
  if (!userId) {
    return new Response(
      JSON.stringify({ success: false, error: "unauthorized" }),
      {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }

  const POWENS_DOMAIN = Deno.env.get("POWENS_DOMAIN") ?? "https://partner-api.powens.com";
  const baseUrl = POWENS_DOMAIN.startsWith("http")
    ? POWENS_DOMAIN
    : `https://${POWENS_DOMAIN}`;
  const CLIENT_ID = Deno.env.get("POWENS_CLIENT_ID")!;
  const CLIENT_SECRET = Deno.env.get("POWENS_CLIENT_SECRET")!;
  const REDIRECT_URI = "networld://powens-callback";

  if (!CLIENT_ID || !CLIENT_SECRET) {
    return new Response(
      JSON.stringify({ success: false, error: "server_config" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }

  try {
    // 1. Get app token (client_credentials)
    const tokenRes = await fetch(`${baseUrl}/2.0/auth/token/new`, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
      }),
    });
    const tokenData = await tokenRes.json();
    const appToken = tokenData.access_token;
    if (!appToken) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "powens_app_token",
          details: tokenData,
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 2. Create a user token (linked to our userId via state in webview)
    const userRes = await fetch(`${baseUrl}/2.0/auth/token/new`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        Authorization: `Bearer ${appToken}`,
      },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
      }),
    });
    const userData = await userRes.json();
    const userToken = userData.access_token;
    if (!userToken) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "powens_user_token",
          details: userData,
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 3. Build webview URL (state = userId for callback)
    const webviewUrl =
      `${baseUrl}/auth/webview/connect` +
      `?client_id=${encodeURIComponent(CLIENT_ID)}` +
      `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}` +
      `&response_type=code` +
      `&state=${encodeURIComponent(userId)}` +
      `&token=${encodeURIComponent(userToken)}`;

    return new Response(
      JSON.stringify({
        success: true,
        webview_url: webviewUrl,
        user_token: userToken,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({
        success: false,
        error: "powens_error",
        message: err?.message ?? String(err),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
