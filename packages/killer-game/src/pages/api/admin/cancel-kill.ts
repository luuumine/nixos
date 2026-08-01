export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";

const ADMIN_UUID = process.env.ADMIN_UUID;

export const POST: APIRoute = async ({ request }) => {
  try {
    const { adminUuid, killId } = await request.json();

    if (adminUuid !== ADMIN_UUID) {
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401 },
      );
    }

    const processCancelKill = db.transaction((targetKillId: number) => {
      const killRecord = db
        .prepare(
          `
        SELECT killerId, victimId, missionId, deactivatedMissionId, newMissionId 
        FROM kills WHERE id = ?
      `,
        )
        .get(targetKillId) as any;

      if (!killRecord) throw new Error("Kill record not found.");

      const {
        killerId,
        victimId,
        missionId,
        deactivatedMissionId,
        newMissionId,
      } = killRecord;

      db.prepare(`DELETE FROM kills WHERE id = ?`).run(targetKillId);
      if (newMissionId)
        db.prepare(`DELETE FROM missions WHERE id = ?`).run(newMissionId);
      db.prepare(`UPDATE missions SET isActive = 1 WHERE id IN (?, ?)`).run(
        missionId,
        deactivatedMissionId,
      );
      db.prepare(`UPDATE players SET isAlive = 1 WHERE id = ?`).run(victimId);
      db.prepare(
        `UPDATE players SET totalKills = MAX(0, totalKills - 1) WHERE id = ?`,
      ).run(killerId);
    });

    processCancelKill(killId);
    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
