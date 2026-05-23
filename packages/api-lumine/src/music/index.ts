import { getCurrentlyPlaying } from "./currently_playing.ts";

export async function handle(req: Request): Promise<Response> {
  const songData = await getCurrentlyPlaying();

  return Response.json(songData, {
    status: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
    },
  });
}
