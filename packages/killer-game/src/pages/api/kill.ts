export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";

export const POST: APIRoute = async ({ request }) => {
  try {
    const { uuid } = await request.json();

    const processKill = db.transaction((killerUuid: string) => {
      const killerInfo = db
        .prepare(
          `
        SELECT p.id as killerId, p.totalKills, m.id as missionId, m.targetPlayerId as victimId
        FROM players p
        JOIN missions m ON p.id = m.assignedPlayerId AND m.isActive = 1
        WHERE p.uuid = ?
      `,
        )
        .get(killerUuid) as any;

      if (!killerInfo) throw new Error("Killer or mission not found");
      const { killerId, totalKills, missionId, victimId } = killerInfo;

      const victimInfo = db
        .prepare(
          `
        SELECT id as victimMissionId, targetPlayerId as nextTargetId, missionText as nextGage
        FROM missions
        WHERE assignedPlayerId = ? AND isActive = 1
      `,
        )
        .get(victimId) as any;

      if (!victimInfo) throw new Error("Victim mission not found");
      const { victimMissionId, nextTargetId, nextGage } = victimInfo;

      db.prepare(`UPDATE players SET isAlive = 0 WHERE id = ?`).run(victimId);
      db.prepare(`UPDATE missions SET isActive = 0 WHERE id IN (?, ?)`).run(
        missionId,
        victimMissionId,
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
          .run(nextGage, nextTargetId, killerId);
        newMissionId = insertMission.lastInsertRowid;
      }

      const newScore = totalKills + 1;
      db.prepare(`UPDATE players SET totalKills = ? WHERE id = ?`).run(
        newScore,
        killerId,
      );

      db.prepare(
        `
        INSERT INTO kills (killerId, victimId, missionId, deactivatedMissionId, newMissionId)
        VALUES (?, ?, ?, ?, ?)
      `,
      ).run(killerId, victimId, missionId, victimMissionId, newMissionId);

      return newScore;
    });

    const finalScore = processKill(uuid);
    return new Response(
      JSON.stringify({ success: true, newScore: finalScore }),
      { status: 200 },
    );
  } catch (error: any) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500 },
    );
  }
};
