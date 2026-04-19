// Supabase Edge Function: permanently deletes the signed-in user's account.
// Deletes related Storage files first, then auth user (ON DELETE CASCADE on public tables).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function getUserIdFromJWT(authHeader: string): string | null {
  try {
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
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

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const authHeader =
      req.headers.get("Authorization") ?? req.headers.get("authorization") ?? "";
    const userId = getUserIdFromJWT(authHeader);

    if (!userId) {
      return new Response(
        JSON.stringify({ success: false, error: "unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const body = await req.json().catch(() => ({} as Record<string, unknown>));
    if (body.confirm !== true) {
      return new Response(
        JSON.stringify({ success: false, error: "confirmation_required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 1. Storage cleanup (not covered by FK)
    try {
      const folders = [`posts/${userId}`, `avatars/${userId}`, `polls/${userId}`];
      for (const folder of folders) {
        const { data: files } = await supabase.storage.from("images").list(folder);
        if (files && files.length > 0) {
          const paths = files.map((f) => `${folder}/${f.name}`);
          await supabase.storage.from("images").remove(paths);
        }
      }
    } catch (e) {
      console.error("Storage cleanup failed — continuing", e);
    }

    // 2. Auth user → CASCADE on public schema
    const { error: deleteError } = await supabase.auth.admin.deleteUser(userId);

    if (deleteError) {
      console.error("auth.admin.deleteUser:", deleteError);
      return new Response(
        JSON.stringify({ success: false, error: "delete_failed" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(
      JSON.stringify({ success: false, error: message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
