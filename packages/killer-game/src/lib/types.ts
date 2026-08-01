export type GameState = "PREPARING" | "RUNNING" | "ENDED";

export interface Player {
  id: number;
  uuid: string;
  playerName: string;
  missionText: string;
  totalKills: number;
  isAlive: number;
  gender: number;
}

export interface MissionData {
  id: number;
  hunter: string;
  target: string;
  missionText: string;
}

export interface KillLogData {
  id: number;
  timestamp: string;
  killerName: string;
  victimName: string;
}

export interface LeaderboardEntry {
  id: number;
  uuid: string;
  playerName: string;
  totalKills: number;
  isAlive: number;
}
