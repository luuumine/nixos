use std::collections::HashMap;

use crate::power::{board::Region::*, pieces::Player};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Terrain {
    Land,
    Sea,
    Coast, // both land and sea
    OffBoard,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Region {
    Hq(Player),
    Landmass(Player, u8), // 0-8
    IslandN,
    IslandE,
    IslandS,
    IslandW,
    IslandX,
    Sea(u8),
    Reserve(Player),
}

impl Region {
    pub fn terrain(self) -> Terrain {
        match self {
            Self::Reserve(_) => Terrain::OffBoard,
            Self::Hq(_) => Terrain::Coast,
            Self::Landmass(_, 4) => Terrain::Land,
            Self::Landmass(_, _) => Terrain::Coast,
            Self::Sea(_) => Terrain::Sea,
            Self::IslandN | Self::IslandE | Self::IslandW | Self::IslandS | Self::IslandX => {
                Terrain::Coast
            }
        }
    }
}

pub struct Map {
    pub adjacencies: HashMap<Region, Vec<Region>>,
}

impl Map {
    pub fn new() -> Self {
        let mut map = Self {
            adjacencies: HashMap::new(),
        };

        map.build_graph();
        map
    }

    fn link(&mut self, a: Region, b: Region) {
        self.adjacencies.entry(a).or_default().push(b);
        self.adjacencies.entry(b).or_default().push(a);
    }
    fn link_group(&mut self, region: Region, player: Player, nodes: &[u8]) {
        for &n in nodes {
            self.link(region, Landmass(player, n));
        }
    }

    fn build_3x3_grid(&mut self, player: Player) {
        let l = |n| Landmass(player, n);

        self.link(IslandX, l(0));
        self.link(l(0), l(1));
        self.link(l(0), l(2));
        self.link(l(0), l(4));
        self.link(l(1), l(3));
        self.link(l(1), l(4));
        self.link(l(2), l(4));
        self.link(l(2), l(5));
        self.link(l(3), l(4));
        self.link(l(3), l(6));
        self.link(l(4), l(5));
        self.link(l(4), l(6));
        self.link(l(4), l(7));
        self.link(l(4), l(8));
        self.link(l(5), l(7));
        self.link(l(6), l(7));
        self.link(l(6), l(8));
        self.link(l(7), l(8));
        self.link(l(8), Hq(player));
    }

    fn build_graph(&mut self) {
        for player in [Player::Red, Player::Blue, Player::Green, Player::Yellow] {
            self.build_3x3_grid(player);
        }

        self.link(IslandX, Sea(1));
        self.link(IslandX, Sea(2));
        self.link(IslandX, Sea(3));
        self.link(IslandX, Sea(4));

        self.link(Sea(1), IslandN);
        self.link_group(Sea(1), Player::Green, &[0, 1, 3]);
        self.link_group(Sea(1), Player::Blue, &[0, 2, 5]);

        self.link(Sea(2), IslandE);
        self.link_group(Sea(2), Player::Blue, &[0, 1, 3]);
        self.link_group(Sea(2), Player::Yellow, &[0, 2, 5]);

        self.link(Sea(3), IslandS);
        self.link_group(Sea(3), Player::Yellow, &[0, 1, 3]);
        self.link_group(Sea(3), Player::Red, &[0, 2, 5]);

        self.link(Sea(4), IslandW);
        self.link_group(Sea(4), Player::Red, &[0, 1, 3]);
        self.link_group(Sea(4), Player::Green, &[0, 2, 5]);

        self.link(Sea(5), IslandW);
        self.link(Sea(5), Hq(Player::Green));
        self.link_group(Sea(5), Player::Green, &[5, 7, 8]);

        self.link(Sea(6), Hq(Player::Green));
        self.link(Sea(6), IslandN);
        self.link_group(Sea(6), Player::Green, &[3, 6, 8]);

        self.link(Sea(7), IslandN);
        self.link(Sea(7), Hq(Player::Blue));
        self.link_group(Sea(7), Player::Blue, &[5, 7, 8]);

        self.link(Sea(8), Hq(Player::Blue));
        self.link(Sea(8), IslandE);
        self.link_group(Sea(8), Player::Blue, &[3, 6, 8]);

        self.link(Sea(9), IslandE);
        self.link(Sea(9), Hq(Player::Yellow));
        self.link_group(Sea(9), Player::Yellow, &[5, 7, 8]);

        self.link(Sea(10), Hq(Player::Yellow));
        self.link(Sea(10), IslandS);
        self.link_group(Sea(10), Player::Yellow, &[3, 6, 8]);

        self.link(Sea(11), IslandS);
        self.link(Sea(11), Hq(Player::Red));
        self.link_group(Sea(11), Player::Red, &[5, 7, 8]);

        self.link(Sea(12), Hq(Player::Red));
        self.link(Sea(12), IslandW);
        self.link_group(Sea(12), Player::Red, &[3, 6, 8]);
    }
}
