import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const authHeader =
      req.headers.get("Authorization") ??
      req.headers.get("authorization") ??
      "";
    const callerId = getUserIdFromJWT(authHeader);

    if (!callerId) {
      return new Response(
        JSON.stringify({ success: false, error: "unauthorized" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const body = await req.json().catch(() => ({}));
    const targetUserId: string = body.user_id ?? callerId;
    const limit: number = Math.min(body.limit ?? 20, 50);
    const cursor: string | null = body.cursor ?? null;

    let query = supabase
      .from("follows")
      .select(
        `
        follower_id, created_at,
        profiles!follower_id (id, username, avatar_id, rank_tier, is_verified, net_worth, currency)
      `
      )
      .eq("following_id", targetUserId)
      .order("created_at", { ascending: false })
      .limit(limit + 1);

    if (cursor) {
      query = query.lt("created_at", cursor);
    }

    const { data: rows, error: queryError } = await query;

    if (queryError) {
      return new Response(
        JSON.stringify({ success: false, error: queryError.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const all = rows ?? [];
    const hasMore = all.length > limit;
    const page = all.slice(0, limit);

    const users = page.map((r: any) => ({
      ...(r.profiles ?? {}),
      followed_at: r.created_at,
    }));

    const last = page[page.length - 1];
    const nextCursor = hasMore && last ? last.created_at : null;

    return new Response(
      JSON.stringify({
        success: true,
        users,
        next_cursor: nextCursor,
        has_more: hasMore,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
