// supabase/functions/purchase-avatar/index.ts
// Покупка аватара за кредиты.
// Проверяет баланс, списывает атомарно, добавляет в инвентарь.

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

    const { avatar_id } = await req.json();

    // 1. Получаем данные аватара
    const { data: avatar, error: avatarError } = await supabase
      .from("avatar_catalog")
      .select("price_credits, is_free")
      .eq("id", avatar_id)
      .single();

    if (avatarError || !avatar) {
      return new Response(
        JSON.stringify({ success: false, error: "avatar_not_found" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Уже куплен?
    const { data: existing } = await supabase
      .from("user_avatars")
      .select("avatar_id")
      .eq("user_id", user.id)
      .eq("avatar_id", avatar_id)
      .single();

    if (existing) {
      return new Response(
        JSON.stringify({ success: false, error: "already_owned" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Бесплатный — просто добавляем
    if (avatar.is_free) {
      await supabase.from("user_avatars").insert({ user_id: user.id, avatar_id });
      return new Response(
        JSON.stringify({ success: true, cost: 0 }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. Платный — проверяем баланс
    const { data: profile } = await supabase
      .from("profiles")
      .select("credits")
      .eq("id", user.id)
      .single();

    if (!profile || profile.credits < avatar.price_credits) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "insufficient_credits",
          required: avatar.price_credits,
          current: profile?.credits ?? 0,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 5. Списываем + добавляем в инвентарь + ledger
    await supabase
      .from("profiles")
      .update({ credits: profile.credits - avatar.price_credits })
      .eq("id", user.id);

    await supabase.from("user_avatars").insert({ user_id: user.id, avatar_id });

    await supabase.from("credit_transactions").insert({
      user_id: user.id,
      amount: -avatar.price_credits,
      reason: "avatar_purchase",
    });

    const { data: updated } = await supabase
      .from("profiles")
      .select("credits")
      .eq("id", user.id)
      .single();

    return new Response(
      JSON.stringify({ success: true, cost: avatar.price_credits, balance: updated?.credits }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});