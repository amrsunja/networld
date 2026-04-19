// supabase/functions/get-comments/index.ts
//
// Returns comments for a post with two-level hierarchy:
//   - Parent comments (parent_comment_id IS NULL) with cursor-based pagination
//   - All children nested inside each parent (parent_comment_id = parent.id)
//
// Input: { post_id, limit (default 20), cursor (created_at of last parent) }

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

const COMMENT_SELECT = `
  id, post_id, author_id, parent_comment_id, content, likes_count, created_at,
  profiles!author_id (id, username, avatar_id, rank_tier, is_verified, net_worth, currency)
`;

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
    const postId: string = body.post_id;
    const limit: number = Math.min(body.limit ?? 20, 50);
    const cursor: string | null = body.cursor ?? null;

    if (!postId) {
      return new Response(
        JSON.stringify({ success: false, error: "post_id_required" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 1. Fetch parent comments (paginated)
    let parentQuery = supabase
      .from("comments")
      .select(COMMENT_SELECT)
      .eq("post_id", postId)
      .is("parent_comment_id", null)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (cursor) {
      parentQuery = parentQuery.lt("created_at", cursor);
    }

    const { data: parents, error: parentErr } = await parentQuery;
    if (parentErr) throw parentErr;

    const parentList: any[] = parents ?? [];

    if (parentList.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          comments: [],
          next_cursor: null,
          has_more: false,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const parentIds = parentList.map((p: any) => p.id);

    // 2. Fetch all children for these parents in one query
    const { data: children, error: childErr } = await supabase
      .from("comments")
      .select(COMMENT_SELECT)
      .in("parent_comment_id", parentIds)
      .order("created_at", { ascending: true });

    if (childErr) throw childErr;

    const childList: any[] = children ?? [];

    // 3. Collect all comment IDs to check likes
    const allCommentIds = [
      ...parentIds,
      ...childList.map((c: any) => c.id),
    ];

    const { data: likedRows } = await supabase
      .from("comment_likes")
      .select("comment_id")
      .eq("user_id", userId)
      .in("comment_id", allCommentIds);

    const likedSet = new Set(
      (likedRows ?? []).map((r: any) => r.comment_id)
    );

    // 4. Group children by parent_comment_id
    const childrenByParent: Record<string, any[]> = {};
    for (const child of childList) {
      const pid = child.parent_comment_id;
      if (!childrenByParent[pid]) childrenByParent[pid] = [];
      childrenByParent[pid].push({
        ...child,
        is_liked: likedSet.has(child.id),
      });
    }

    // 5. Assemble response
    const comments = parentList.map((p: any) => ({
      ...p,
      is_liked: likedSet.has(p.id),
      children: childrenByParent[p.id] ?? [],
    }));

    const lastParent = parentList[parentList.length - 1];
    const hasMore = parentList.length === limit;
    const nextCursor = hasMore ? lastParent.created_at : null;

    return new Response(
      JSON.stringify({
        success: true,
        comments,
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
