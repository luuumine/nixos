export type RAM = {
  capacity: number; // GB
  hz: number;
  ddr: 4 | 5;
};

export type Storage = {
  capacity: number; // in GB
  type: "HDD" | "NVMe";
  label: string;
};

export type Display = {
  size: number; // inches
  resolution: number; // vertical pixels
  hz: number;
  panel: "OLED" | "IPS";
};

export type Machine = {
  hostname: string;
  os: string;
  cpu: string;
  gpu?: string;
  memory: RAM;
  storage: Storage[];
  displays: Display[];
  note?: string;
};

export const machines: Machine[] = [
  {
    hostname: "luminix",
    os: "NixOS",
    cpu: "AMD Ryzen 7 9800X3D",
    gpu: "AMD Radeon RX 9070XT",
    memory: { capacity: 32, hz: 6000, ddr: 5 },
    storage: [
      { capacity: 2000, type: "NVMe", label: "main" },
      { capacity: 2000, type: "NVMe", label: "data" },
      { capacity: 250, type: "NVMe", label: "windows" },
    ],
    displays: [
      { size: 27, resolution: 1440, hz: 240, panel: "OLED" },
      { size: 24, resolution: 1080, hz: 180, panel: "IPS" },
    ],
    note: "my daily driver. for basically everything.",
  },
  {
    hostname: "luminode",
    os: "Arch Linux",
    cpu: "AMD Athlon PRO 200GE",
    gpu: "Radeon Vega 3 (Integrated)",
    memory: { capacity: 16, hz: 2666, ddr: 4 },
    storage: [{ capacity: 500, type: "NVMe", label: "main" }],
    displays: [],
    note: "home server. it runs 24/7 with services like pihole, jellyfin, and this website.",
  },
  {
    hostname: "luminarch",
    os: "Arch Linux",
    cpu: "AMD Ryzen 9 5900HX",
    gpu: "AMD Radeon RX 6700M",
    memory: { capacity: 16, hz: 3200, ddr: 4 },
    storage: [{ capacity: 1000, type: "NVMe", label: "main" }],
    displays: [{ size: 15.6, resolution: 1080, hz: 240, panel: "IPS" }],
    note: "mostly used when traveling.",
  },
];
