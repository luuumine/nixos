import { getAccessToken } from "./access_token.ts";

let cachedMusicData: any = null;
let cachedMusicExpirationEpoch = 0;
let CACHE_TTL = 1000 * 5;

export type NowPlayingResponse =
  | { isPlaying: false }
  | {
      isPlaying: true;
      title: string;
      artists: string[];
      album: string;
      albumImageUrl: string;
      songUrl: string;
    };

interface SpotifyData {
  is_playing: boolean;
  item?: {
    name: string;
    artists: { name: string }[];
    album: { name: string; images: { url: string }[] };
    external_urls: { spotify: string };
  };
}

export async function getCurrentlyPlaying(): Promise<NowPlayingResponse> {
  if (cachedMusicData && Date.now() < cachedMusicExpirationEpoch) {
    return cachedMusicData;
  }

  let nextData: NowPlayingResponse = { isPlaying: false };

  try {
    const token = await getAccessToken();

    const response = await fetch(
      "https://api.spotify.com/v1/me/player/currently-playing",
      {
        headers: { Authorization: "Bearer " + token },
      },
    );

    switch (response.status) {
      case 200: {
        nextData = formatMusicData(await response.json());
        break;
      }
      case 204:
        break;
      case 401: {
        console.error("Spotify token expired");
        break;
      }
      case 429: {
        console.warn("Spotify Rate Limit Hit");
        break;
      }
      default: {
        console.warn("Unexpected status code", response.status);
        break;
      }
    }
  } catch (error) {
    console.error("Error fetching currently playing song:", error);
  }

  cachedMusicData = nextData;
  cachedMusicExpirationEpoch = Date.now() + CACHE_TTL;

  return cachedMusicData;
}

function formatMusicData(data: SpotifyData | null): NowPlayingResponse {
  if (!data || !data.item || !data.is_playing) {
    return { isPlaying: false };
  }

  return {
    isPlaying: true,
    title: data.item.name,
    artists: data.item.artists.map((artist) => artist.name),
    album: data.item.album.name,
    albumImageUrl: data.item.album.images[0]?.url,
    songUrl: data.item.external_urls.spotify,
  };
}
