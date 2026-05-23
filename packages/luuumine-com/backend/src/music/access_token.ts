const CLIENT_ID = process.env.SPOTIFY_CLIENT_ID;
const CLIENT_SECRET = process.env.SPOTIFY_CLIENT_SECRET;
const REFRESH_TOKEN = process.env.SPOTIFY_REFRESH_TOKEN;

const TOKEN_TTL = 60_000 * 30;

let cachedToken = null;
let tokenExpirationEpoch = 0;

const authHeader =
  "Basic " + Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString("base64");

export async function getAccessToken() {
  if (cachedToken && Date.now() < tokenExpirationEpoch) {
    return cachedToken;
  }

  if (!CLIENT_ID || !CLIENT_SECRET || !REFRESH_TOKEN) {
    throw new Error("Cannot fetch access token: Missing spotify credentials.");
  }

  try {
    const response = await fetch("https://accounts.spotify.com/api/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        Authorization: authHeader,
      },
      body: new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: REFRESH_TOKEN,
      }),
    });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `Spotify API responded with status ${response.status}: ${errorText}`,
      );
    }

    const data = await response.json();

    cachedToken = data.access_token;
    tokenExpirationEpoch = Date.now() + TOKEN_TTL;

    return cachedToken;
  } catch (error) {
    console.error("Error fetching Spotify access token:", error);
    throw error;
  }
}
