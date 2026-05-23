import type { ImageMetadata } from "astro";

import plasticMemories from "@/assets/likes/plastic_memories.webp";
import quintuplets from "@/assets/likes/quintuplets.webp";
import pancreas from "@/assets/likes/pancreas.webp";
import gu1t4r from "@/assets/likes/gu1t4r.webp";
import taylorSwift from "@/assets/likes/taylor_swift.webp";
import yoshi from "@/assets/likes/yoshi.webp";

export type LikeItem = {
  name: string;
  url: string;
  image: ImageMetadata;
};

export type LikeCategory = {
  title: string;
  items: LikeItem[];
};

export const likesData: LikeCategory[] = [
  {
    title: "anime / manga",
    items: [
      {
        name: "Plastic Memories",
        url: "https://anilist.co/anime/20872/Plastic-Memories/",
        image: plasticMemories,
      },
      {
        name: "The Quintessential Quintuplets",
        url: "https://anilist.co/manga/100230/The-Quintessential-Quintuplets/",
        image: quintuplets,
      },
      {
        name: "I Want to Eat Your Pancreas",
        url: "https://anilist.co/anime/99750/I-Want-to-Eat-Your-Pancreas/",
        image: pancreas,
      },
    ],
  },
  {
    title: "music",
    items: [
      {
        name: "GU1T4R",
        url: "https://open.spotify.com/artist/0Waq0e4oiQxOvsfoAiOIC5",
        image: gu1t4r,
      },
      {
        name: "Taylor Swift",
        url: "https://open.spotify.com/artist/06HL4z0CvFAxyc27GXpf02",
        image: taylorSwift,
      },
      {
        name: "y0shi.mp3",
        url: "https://open.spotify.com/artist/0d8WAAF87lV4Me7E1f2Luj",
        image: yoshi,
      },
    ],
  },
];
