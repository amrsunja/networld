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

    const body = await req.json().catch(() => ({}));
    const limit: number = Math.min(body.limit ?? 20, 50);
    const cursor: string | null = body.cursor ?? null;

    // Unread count (always returned so the client can show badge)
    const { count: unreadCount } = await supabase
      .from("notifications")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("is_read", false);

    // Paginated notifications
    let query = supabase
      .from("notifications")
      .select("id, user_id, type, ref_id, is_read, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(limit + 1);

    if (cursor) {
      query = query.lt("created_at", cursor);
    }

    const { data, error } = await query;

    if (error) {
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const rows = data ?? [];
    const hasMore = rows.length > limit;
    const pageRows = hasMore ? rows.slice(0, limit) : rows;

    const followerIds = [
      ...new Set(
        pageRows
          .filter((n: { type?: string; ref_id?: string | null }) =>
            n.type === "new_follower" && n.ref_id
          )
          .map((n: { ref_id: string }) => n.ref_id)
      ),
    ];

    const usernameById = new Map<string, string>();
    if (followerIds.length > 0) {
      const { data: profiles } = await supabase
        .from("profiles")
        .select("id, username")
        .in("id", followerIds);
      for (const p of profiles ?? []) {
        usernameById.set((p as { id: string }).id, (p as { username: string }).username);
      }
    }

    const notifications = pageRows.map((n: Record<string, unknown>) => {
      if (n.type === "new_follower" && typeof n.ref_id === "string") {
        const un = usernameById.get(n.ref_id);
        return { ...n, ref_username: un ?? null };
      }
      return n;
    });

    const lastItem = notifications[notifications.length - 1];
    const nextCursor = hasMore && lastItem ? lastItem.created_at : null;

    return new Response(
      JSON.stringify({
        success: true,
        notifications,
        next_cursor: nextCursor,
        has_more: hasMore,
        unread_count: unreadCount ?? 0,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
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
