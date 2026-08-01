export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";

const ADMIN_UUID = process.env.ADMIN_UUID;

function shuffle<T>(array: T[]): T[] {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

export const POST: APIRoute = async ({ request }) => {
  try {
    const { adminUuid } = await request.json();
    if (adminUuid !== ADMIN_UUID)
      return new Response("Unauthorized", { status: 401 });

    const startGame = db.transaction(() => {
      const players = db
        .prepare(`SELECT id, missionText FROM players WHERE isAlive = 1`)
        .all() as any[];
      if (players.length < 2)
        throw new Error("Need at least 2 players to start.");

      // wipe old logs
      db.prepare(`DELETE FROM kills`).run();
      db.prepare(`DELETE FROM missions`).run();
      db.prepare(`UPDATE players SET totalKills = 0, isAlive = 1`).run();

      const shuffled = shuffle(players);
      const insertMission = db.prepare(`
        INSERT INTO missions (missionText, targetPlayerId, assignedPlayerId, isActive) VALUES (?, ?, ?, 1)
      `);

      for (let i = 0; i < shuffled.length; i++) {
        const hunter = shuffled[i];
        const target = shuffled[(i + 1) % shuffled.length];
        insertMission.run(target.missionText, target.id, hunter.id);
      }
    });

    startGame();
    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
