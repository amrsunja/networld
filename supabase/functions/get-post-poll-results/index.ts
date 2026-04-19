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
    const padded = base64.padEnd(base64.length + (4 - base64.length % 4) % 4, "=");
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
    const supabase = createClient(
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

    const body = await req.json().catch(() => ({}));
    const postId = body.post_id as string | undefined;
    if (!postId) {
      return new Response(
        JSON.stringify({ success: false, error: "post_id_required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: votes, error: votesError } = await supabase
      .from("votes")
      .select("option_id, user_id")
      .eq("post_id", postId);

    if (votesError) throw votesError;

    const rows = votes ?? [];
    const countsByOptionId: Record<string, number> = {};
    const userIdsByOptionId: Record<string, string[]> = {};
    const allUserIds = new Set<string>();

    for (const row of rows) {
      const optionId = Number(row.option_id);
      const uid = String(row.user_id ?? "");
      if (!Number.isFinite(optionId) || !uid) continue;

      const key = String(optionId);
      countsByOptionId[key] = (countsByOptionId[key] ?? 0) + 1;
      userIdsByOptionId[key] = [...(userIdsByOptionId[key] ?? []), uid];
      allUserIds.add(uid);
    }

    const avgNetWorthByOptionId: Record<string, number | null> = {};

    if (allUserIds.size > 0) {
      const { data: profiles, error: profilesError } = await supabase
        .from("profiles")
        .select("id, net_worth")
        .in("id", Array.from(allUserIds));

      if (profilesError) throw profilesError;

      const netWorthByUserId = new Map<string, number>();
      for (const p of profiles ?? []) {
        const id = String(p.id ?? "");
        const nw = Number(p.net_worth ?? 0);
        if (!id || !Number.isFinite(nw)) continue;
        netWorthByUserId.set(id, nw);
      }

      for (const [optionId, ids] of Object.entries(userIdsByOptionId)) {
        let sum = 0;
        let cnt = 0;
        for (const id of ids) {
          const nw = netWorthByUserId.get(id);
          if (nw === undefined) continue;
          sum += nw;
          cnt += 1;
        }
        avgNetWorthByOptionId[optionId] = cnt > 0 ? sum / cnt : null;
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        counts_by_option_id: countsByOptionId,
        avg_net_worth_by_option_id: avgNetWorthByOptionId,
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

