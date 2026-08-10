export const prerender = false;
import type { APIRoute } from "astro";
import db from "@/lib/db";
import crypto from "crypto";

const ADMIN_UUID = process.env.ADMIN_UUID;

// Helper for start-game
function shuffle<T>(array: T[]): T[] {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

export const POST: APIRoute = async ({ request, params }) => {
  try {
    const payload = await request.json();

    if (payload.adminUuid !== ADMIN_UUID) {
      return new Response("Unauthorized", { status: 401 });
    }

    switch (params.action) {
      case "end-game": {
        db.prepare(`UPDATE missions SET isActive = 0`).run();
        break;
      }

      case "prepare-game": {
        db.transaction(() => {
          db.prepare(`DELETE FROM kills`).run();
          db.prepare(`DELETE FROM missions`).run();
          db.prepare(`UPDATE players SET totalKills = 0, isAlive = 1`).run();
        })();
        break;
      }

      case "add-player": {
        const uuid = crypto.randomUUID();
        const pGender = payload.gender === 1 ? 1 : 0;
        db.prepare(
          `INSERT INTO players (uuid, playerName, missionText, gender) VALUES (?, ?, ?, ?)`,
        ).run(uuid, payload.playerName, payload.missionText, pGender);

        return new Response(JSON.stringify({ success: true, uuid }), {
          status: 200,
        });
      }

      case "remove-player": {
        db.prepare(`DELETE FROM players WHERE uuid = ?`).run(
          payload.playerUuid,
        );
        break;
      }

      case "set-players": {
        db.transaction(() => {
          db.prepare(`DELETE FROM kills`).run();
          db.prepare(`DELETE FROM missions`).run();
          db.prepare(`DELETE FROM players`).run();

          const insert = db.prepare(
            `INSERT INTO players (uuid, playerName, missionText, gender) VALUES (?, ?, ?, ?)`,
          );

          for (const p of payload.playersData) {
            const uuid = p.uuid || crypto.randomUUID();
            const gender = p.gender === 1 ? 1 : 0;
            insert.run(uuid, p.playerName, p.missionText, gender);
          }
        })();
        break;
      }

      case "start-game": {
        db.transaction(() => {
          const players = db
            .prepare(
              `SELECT id, missionText FROM players WHERE isAlive = 1 ORDER BY id ASC`,
            )
            .all() as any[];

          if (players.length < 2)
            throw new Error("Need at least 2 players to start.");

          db.prepare(`DELETE FROM kills`).run();
          db.prepare(`DELETE FROM missions`).run();
          db.prepare(`UPDATE players SET totalKills = 0, isAlive = 1`).run();

          const orderedPlayers = payload.shouldShuffle
            ? shuffle(players)
            : players;

          const insertMission = db.prepare(`
            INSERT INTO missions (missionText, targetPlayerId, assignedPlayerId, isActive) VALUES (?, ?, ?, 1)
          `);

          for (let i = 0; i < orderedPlayers.length; i++) {
            const hunter = orderedPlayers[i];
            const target = orderedPlayers[(i + 1) % orderedPlayers.length];
            insertMission.run(target.missionText, target.id, hunter.id);
          }
        })();
        break;
      }

      case "force-kill": {
        db.transaction((targetVictimId: number) => {
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
            .prepare(
              `SELECT COUNT(*) as aliveCount FROM players WHERE isAlive = 1`,
            )
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
        })(payload.victimPlayerId);
        break;
      }

      case "cancel-kill": {
        db.transaction((targetKillId: number) => {
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
          db.prepare(`UPDATE players SET isAlive = 1 WHERE id = ?`).run(
            victimId,
          );
          db.prepare(
            `UPDATE players SET totalKills = MAX(0, totalKills - 1) WHERE id = ?`,
          ).run(killerId);
        })(payload.killId);
        break;
      }

      default:
        return new Response(
          JSON.stringify({ success: false, error: "Unknown action" }),
          { status: 400 },
        );
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500 },
    );
  }
};
