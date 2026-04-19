// supabase/functions/get-feed/index.ts
//
// Feed modes via `filter`:
//   recents    — all published posts, newest first (cursor = created_at ISO)
//   hots       — active boosts first (newest created_at), then others by likes+comments+votes then created_at;
//              max 100 posts (cursor = next offset string). Active boost = is_boosted and (no expiry or expiry > now).
//   followings — posts from profiles the user follows, newest first (cursor = created_at ISO)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type FeedFilter = "recents" | "hots" | "followings";

function getUserIdFromJWT(authHeader: string): string | null {
  try {
    const token = authHeader.replace("Bearer ", "");
    const parts = token.split(".");
    if (parts.length !== 3) return null;
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(base64.length + (4 - base64.length % 4) % 4, "=");
    const payload = JSON.parse(atob(padded));
    return payload.sub ?? null;
  } catch {
    return null;
  }
}

const POST_SELECT = `
  id, content, image_url, post_type, poll_options,
  is_boosted, boost_expires_at, likes_count, comments_count,
  created_at, author_id,
  profiles!author_id (username, avatar_id, rank_tier, is_verified, net_worth, currency)
`;

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const authHeader = req.headers.get("Authorization") ?? req.headers.get("authorization") ?? "";
    const userId = getUserIdFromJWT(authHeader);

    if (!userId) {
      return new Response(JSON.stringify({ success: false, error: "unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json().catch(() => ({}));
    const limit = Math.min(Number(body.limit) || 20, 50);
    const rawFilter = (body.filter as string | undefined)?.toLowerCase() ?? "recents";
    const filter: FeedFilter =
      rawFilter === "hots" || rawFilter === "followings" ? (rawFilter as FeedFilter) : "recents";
    const cursor: string | null = body.cursor ?? null;

    const now = new Date();
    const nowIso = now.toISOString();

    const { data: likedData } = await supabase
      .from("post_likes")
      .select("post_id")
      .eq("user_id", userId);

    const likedPostIds = new Set<string>((likedData ?? []).map((l: { post_id: string }) => l.post_id));

    const decorate = (rows: any[] | null, slot: string) =>
      (rows ?? []).map((p: any) => ({
        ...p,
        feed_slot: slot,
        is_liked: likedPostIds.has(p.id),
      }));

    if (filter === "recents") {
      let q = supabase
        .from("posts")
        .select(POST_SELECT)
        .eq("status", "published")
        .order("created_at", { ascending: false })
        .limit(limit);

      if (cursor) {
        q = q.lt("created_at", cursor);
      }

      const { data: rows, error } = await q;
      if (error) throw error;

      const posts = decorate(rows, "recents");
      const last = posts[posts.length - 1];
      const nextCursor = last?.created_at ?? null;
      const hasMore = posts.length === limit;

      return new Response(
        JSON.stringify({
          success: true,
          posts,
          next_cursor: hasMore ? nextCursor : null,
          has_more: hasMore,
          filter,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (filter === "followings") {
      const { data: followRows, error: fErr } = await supabase
        .from("follows")
        .select("following_id")
        .eq("follower_id", userId);

      if (fErr) throw fErr;

      const followingIds = [...new Set((followRows ?? []).map((r: { following_id: string }) => r.following_id))];

      if (followingIds.length === 0) {
        return new Response(
          JSON.stringify({
            success: true,
            posts: [],
            next_cursor: null,
            has_more: false,
            filter,
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      let q = supabase
        .from("posts")
        .select(POST_SELECT)
        .eq("status", "published")
        .in("author_id", followingIds)
        .order("created_at", { ascending: false })
        .limit(limit);

      if (cursor) {
        q = q.lt("created_at", cursor);
      }

      const { data: rows, error } = await q;
      if (error) throw error;

      const posts = decorate(rows, "followings");
      const last = posts[posts.length - 1];
      const nextCursor = last?.created_at ?? null;
      const hasMore = posts.length === limit;

      return new Response(
        JSON.stringify({
          success: true,
          posts,
          next_cursor: hasMore ? nextCursor : null,
          has_more: hasMore,
          filter,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // hots
    const offset = Math.max(0, Math.min(parseInt(cursor ?? "0", 10) || 0, 99));
    const { data: idRows, error: idErr } = await supabase.rpc("get_hot_feed_post_ids", {
      p_now: nowIso,
      p_offset: offset,
      p_limit: limit,
    });

    if (idErr) throw idErr;

    const ids = (idRows ?? []).map((r: { post_id: string }) => r.post_id).filter(Boolean);

    if (ids.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          posts: [],
          next_cursor: null,
          has_more: false,
          filter,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: rawPosts, error: pErr } = await supabase
      .from("posts")
      .select(POST_SELECT)
      .in("id", ids);

    if (pErr) throw pErr;

    const byId = new Map((rawPosts ?? []).map((p: any) => [p.id, p]));
    const ordered = ids.map((id) => byId.get(id)).filter(Boolean);
    const posts = decorate(ordered, "hots");

    const nextOffset = offset + posts.length;
    const hasMore = nextOffset < 100 && posts.length === limit;

    return new Response(
      JSON.stringify({
        success: true,
        posts,
        next_cursor: hasMore ? String(nextOffset) : null,
        has_more: hasMore,
        filter,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ success: false, error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
