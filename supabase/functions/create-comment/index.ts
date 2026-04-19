// supabase/functions/create-comment/index.ts
// Création d'un commentaire : coûte 100 crédits.
// Les triggers DB gèrent automatiquement : +2 XP auteur, comments_count, notification.

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

    const authHeader = req.headers.get("Authorization")!;
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", "")
    );
    if (authError || !user) {
      return new Response(JSON.stringify({ success: false, error: "unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { post_id, content, parent_comment_id } = await req.json();
    const COST = 100;

    if (!content || content.trim().length === 0) {
      return new Response(
        JSON.stringify({ success: false, error: "content_required" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Vérifie que le post existe et est publié
    const { data: post } = await supabase
      .from("posts")
      .select("id")
      .eq("id", post_id)
      .eq("status", "published")
      .single();

    if (!post) {
      return new Response(
        JSON.stringify({ success: false, error: "post_not_found" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Vérifie le solde
    const { data: profile } = await supabase
      .from("profiles")
      .select("credits")
      .eq("id", user.id)
      .single();

    if (!profile || profile.credits < COST) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "insufficient_credits",
          required: COST,
          current: profile?.credits ?? 0,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Débite
    await supabase
      .from("profiles")
      .update({ credits: profile.credits - COST })
      .eq("id", user.id);

    // 4. Resolve parent_comment_id to root (two-level hierarchy only)
    let resolvedParentId: string | null = null;
    if (parent_comment_id) {
      const { data: targetComment } = await supabase
        .from("comments")
        .select("id, parent_comment_id")
        .eq("id", parent_comment_id)
        .single();
      if (targetComment) {
        resolvedParentId = targetComment.parent_comment_id ?? targetComment.id;
      }
    }

    // 5. Crée le commentaire (les triggers T10/T11/T12 s'exécutent automatiquement)
    const { data: comment, error: commentError } = await supabase
      .from("comments")
      .insert({
        post_id,
        author_id: user.id,
        content: content.trim(),
        parent_comment_id: resolvedParentId,
      })
      .select("id")
      .single();

    if (commentError) throw commentError;

    // 6. Ledger
    await supabase.from("credit_transactions").insert({
      user_id: user.id,
      amount: -COST,
      reason: "comment_creation",
      ref_id: comment.id,
    });

    const { data: updated } = await supabase
      .from("profiles")
      .select("credits")
      .eq("id", user.id)
      .single();

    return new Response(
      JSON.stringify({ success: true, comment_id: comment.id, cost: COST, balance: updated?.credits }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
