import Database from "better-sqlite3";
import path from "path";

const dbPath = process.env.DB_PATH || path.resolve(process.cwd(), "game.db");
const db = new Database(dbPath);
db.pragma("journal_mode = WAL");

db.exec(`
  CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT UNIQUE NOT NULL,
    playerName TEXT NOT NULL,
    missionText TEXT NOT NULL,
    totalKills INTEGER DEFAULT 0,
    isAlive INTEGER DEFAULT 1,
    gender INTEGER DEFAULT 0
  );

  CREATE TABLE IF NOT EXISTS missions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    missionText TEXT NOT NULL,
    targetPlayerId INTEGER NOT NULL,
    assignedPlayerId INTEGER NOT NULL,
    isActive INTEGER DEFAULT 1,
    FOREIGN KEY(targetPlayerId) REFERENCES players(id),
    FOREIGN KEY(assignedPlayerId) REFERENCES players(id)
  );

  CREATE TABLE IF NOT EXISTS kills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    killerId INTEGER NOT NULL,
    victimId INTEGER NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    missionId INTEGER,
    deactivatedMissionId INTEGER,
    newMissionId INTEGER,
    FOREIGN KEY(killerId) REFERENCES players(id),
    FOREIGN KEY(victimId) REFERENCES players(id),
    FOREIGN KEY(missionId) REFERENCES missions(id),
    FOREIGN KEY(deactivatedMissionId) REFERENCES missions(id),
    FOREIGN KEY(newMissionId) REFERENCES missions(id)
  );
`);

export default db;
