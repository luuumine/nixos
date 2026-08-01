export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";

const ADMIN_UUID = process.env.ADMIN_UUID;

export const POST: APIRoute = async ({ request }) => {
  try {
    const { adminUuid } = await request.json();
    if (adminUuid !== ADMIN_UUID)
      return new Response("Unauthorized", { status: 401 });

    // deactivate all missions. scores and kill logs remain intact.
    db.prepare(`UPDATE missions SET isActive = 0`).run();

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
