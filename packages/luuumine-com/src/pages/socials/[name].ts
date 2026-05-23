import type { APIRoute } from "astro";
import { socials } from "@/data/socials";

export function getStaticPaths() {
  return socials
    .filter((s) => s.hasLink)
    .map((s) => ({
      params: { name: s.path },
    }));
}

export const GET: APIRoute = ({ params, redirect }) => {
  const social = socials.find((s) => s.path === params.name);

  if (!social) {
    // never runs as Astro catches the path before
    return new Response(null, { status: 404 });
  }

  return redirect(social.url, 307);
};
