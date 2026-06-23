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
      { capacity: 250, type: "NVMe", label: "windows" },
    ],
    displays: [
      { size: 27, resolution: 1440, hz: 240, panel: "OLED" },
      { size: 24, resolution: 1080, hz: 180, panel: "IPS" },
    ],
    note: "my daily driver. for basically everything.",
  },
  {
    hostname: "luminadel",
    os: "NixOS",
    cpu: "Intel Core Ultra 5 245K",
    memory: { capacity: 32, hz: 5600, ddr: 5 },
    storage: [
      { capacity: 2000, type: "NVMe", label: "main" },
      { capacity: 8000, type: "HDD", label: "media" },
    ],
    displays: [],
    note: "main server. hosts this website and every other service",
  },
  {
    hostname: "luminode",
    os: "NixOS",
    cpu: "AMD Athlon PRO 200GE",
    memory: { capacity: 16, hz: 2666, ddr: 4 },
    storage: [{ capacity: 500, type: "NVMe", label: "main" }],
    displays: [],
    note: "remote server. for backups only",
  },
  {
    hostname: "luminout",
    os: "NixOS",
    cpu: "AMD Ryzen 9 5900HX",
    gpu: "AMD Radeon RX 6700M",
    memory: { capacity: 16, hz: 3200, ddr: 4 },
    storage: [{ capacity: 1000, type: "NVMe", label: "main" }],
    displays: [{ size: 15.6, resolution: 1080, hz: 240, panel: "IPS" }],
    note: "mostly used when traveling.",
  },
];
