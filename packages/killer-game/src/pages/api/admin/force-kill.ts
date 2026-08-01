export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";

const ADMIN_UUID = process.env.ADMIN_UUID;

export const POST: APIRoute = async ({ request }) => {
  try {
    const { adminUuid, victimPlayerId } = await request.json();

    if (adminUuid !== ADMIN_UUID) {
      return new Response(
        JSON.stringify({ success: false, error: "Unauthorized" }),
        { status: 401 },
      );
    }

    const processForceKill = db.transaction((targetVictimId: number) => {
      const victim = db
        .prepare(`SELECT id, isAlive FROM players WHERE id = ?`)
        .get(targetVictimId) as any;
      if (!victim || victim.isAlive === 0)
        throw new Error("Player is already dead or does not exist.");

      const hunterMission = db
        .prepare(
          `
        SELECT id as missionId, assignedPlayerId as hunterId 
        FROM missions WHERE targetPlayerId = ? AND isActive = 1
      `,
        )
        .get(targetVictimId) as any;

      const victimMission = db
        .prepare(
          `
        SELECT id as victimMissionId, targetPlayerId as nextTargetId, missionText as nextGage 
        FROM missions WHERE assignedPlayerId = ? AND isActive = 1
      `,
        )
        .get(targetVictimId) as any;

      if (!hunterMission || !victimMission)
        throw new Error("Could not resolve mission chain.");

      db.prepare(`UPDATE players SET isAlive = 0 WHERE id = ?`).run(
        targetVictimId,
      );
      db.prepare(`UPDATE missions SET isActive = 0 WHERE id IN (?, ?)`).run(
        hunterMission.missionId,
        victimMission.victimMissionId,
      );

      const { aliveCount } = db
        .prepare(`SELECT COUNT(*) as aliveCount FROM players WHERE isAlive = 1`)
        .get() as { aliveCount: number };

      let newMissionId = null;
      if (aliveCount > 1) {
        const insertMission = db
          .prepare(
            `
          INSERT INTO missions (missionText, targetPlayerId, assignedPlayerId, isActive)
          VALUES (?, ?, ?, 1)
        `,
          )
          .run(
            victimMission.nextGage,
            victimMission.nextTargetId,
            hunterMission.hunterId,
          );
        newMissionId = insertMission.lastInsertRowid;
      }

      db.prepare(
        `
        INSERT INTO kills (killerId, victimId, missionId, deactivatedMissionId, newMissionId)
        VALUES (?, ?, ?, ?, ?)
      `,
      ).run(
        hunterMission.hunterId,
        targetVictimId,
        hunterMission.missionId,
        victimMission.victimMissionId,
        newMissionId,
      );

      db.prepare(
        `UPDATE players SET totalKills = totalKills + 1 WHERE id = ?`,
      ).run(hunterMission.hunterId);
    });

    processForceKill(victimPlayerId);
    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
