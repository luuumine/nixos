export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";
import crypto from "crypto";

const ADMIN_UUID = process.env.ADMIN_UUID;

export const POST: APIRoute = async ({ request }) => {
  try {
    const { adminUuid, playerName, missionText, gender } = await request.json();
    if (adminUuid !== ADMIN_UUID)
      return new Response("Unauthorized", { status: 401 });

    const uuid = crypto.randomUUID();
    const pGender = gender === 1 ? 1 : 0;

    db.prepare(
      `INSERT INTO players (uuid, playerName, missionText, gender) VALUES (?, ?, ?, ?)`,
    ).run(uuid, playerName, missionText, pGender);

    return new Response(JSON.stringify({ success: true, uuid }), {
      status: 200,
    });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
