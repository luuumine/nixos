export interface Translations {
  homeTitle: string;
  homeDesc: string;
  welcome: string;
  deadTitle: string;
  victoryTitle: string;
  victoryDesc: string;
  gameOverTitle: string;
  gameOverDesc: string;
  youWon: string;
  waitingForGame: string;
  currentScore: string;
  targetIs: string;
  btnAccomplished: string;
  confirmQuestion: string;
  btnYes: string;
  btnNo: string;
  finalScore: (score: number) => string;
  killPrefix: (gender: number | null) => string;
}

const en: Translations = {
  homeTitle: "Private game in progress.",
  homeDesc: "Scan your personal QR code to access your mission.",
  welcome: "Welcome",
  deadTitle: "You are dead! The game is over for you.",
  victoryTitle: "Victory!",
  victoryDesc: "You are the last survivor!",
  gameOverTitle: "Game Ended",
  gameOverDesc: "The game has been concluded by the admin.",
  youWon: "You won the game!",
  waitingForGame: "The game hasn't started yet. Get ready!",
  currentScore: "Your current score is",
  targetIs: "Your target is",
  btnAccomplished: "mission accomplished",
  confirmQuestion: "Did your target complete their dare?",
  btnYes: "Yes",
  btnNo: "No",
  finalScore: (score: number) =>
    `Your final score is ${score} elimination${score > 1 ? "s" : ""}.`,
  killPrefix: (gender: number | null) =>
    gender === 1 ? "To kill her:" : "To kill him:",
};

const fr: Translations = {
  homeTitle: "Partie privée en cours.",
  homeDesc: "Scanne ton QR code personnel pour accéder à ta mission.",
  welcome: "Bienvenue",
  deadTitle: "Tu es mort ! La partie est terminée pour toi.",
  victoryTitle: "Victoire !",
  victoryDesc: "Tu es le dernier survivant !",
  gameOverTitle: "Partie Terminée",
  gameOverDesc: "La partie a été terminée par l'administrateur.",
  youWon: "Tu as gagné la partie !",
  waitingForGame: "La partie n'a pas encore commencé. Prépare-toi !",
  currentScore: "Ton score actuel est de",
  targetIs: "Ta cible est",
  btnAccomplished: "mission accomplie",
  confirmQuestion: "Ta cible a-t-elle bien fait son gage ?",
  btnYes: "Oui",
  btnNo: "Non",
  finalScore: (score: number) =>
    `Ton score final est de ${score} élimination${score > 1 ? "s" : ""}.`,
  killPrefix: (gender: number | null) =>
    gender === 1 ? "Pour la tuer :" : "Pour le tuer :",
};

export function getTranslations(): Translations {
  return process.env.LANG === "fr" ? fr : en;
}
