export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";
import crypto from "crypto";

const ADMIN_UUID = process.env.ADMIN_UUID;

export const POST: APIRoute = async ({ request }) => {
  try {
    const { adminUuid, playersData } = await request.json();
    if (adminUuid !== ADMIN_UUID)
      return new Response("Unauthorized", { status: 401 });

    const setPlayers = db.transaction(() => {
      db.prepare(`DELETE FROM kills`).run();
      db.prepare(`DELETE FROM missions`).run();
      db.prepare(`DELETE FROM players`).run();

      const insert = db.prepare(
        `INSERT INTO players (uuid, playerName, missionText, gender) VALUES (?, ?, ?, ?)`,
      );

      for (const p of playersData) {
        const uuid = p.uuid || crypto.randomUUID();
        const gender = p.gender === 1 ? 1 : 0;
        insert.run(uuid, p.playerName, p.missionText, gender);
      }
    });

    setPlayers();
    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
