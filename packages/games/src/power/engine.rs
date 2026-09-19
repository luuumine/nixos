use std::collections::HashMap;

use crate::power::{
    board::{
        Map,
        Region::{self, Hq},
    },
    pieces::{Player, Unit, UnitType},
};

pub type PiecesLocation = HashMap<Region, Vec<Unit>>;

pub struct GameState {
    pub map: Map,
    pub pieces: PiecesLocation,
    pub active_players: Vec<Player>,
}

pub enum Move {
    /// Moves a unit from one region to another
    Move {
        from: Region,
        unit_type: UnitType,
        to: Region,
    },
    /// Merges multiples units of specific types into a new unit on a specific region
    Merge {
        from: Region,
        source_type: UnitType,
        count: u8,
        final_type: UnitType,
    },
    /// Creates a a nuke using specified pieces on a region
    MakeNuke {
        from: Region,
        units: Vec<UnitType>,
        final_type: UnitType,
    },
    DoNothing,
}

impl GameState {
    pub fn new() -> Self {
        GameState {
            map: Map::new(),
            pieces: Self::starting_pieces(),
            active_players: vec![Player::Red, Player::Blue, Player::Green, Player::Yellow],
        }
    }

    fn starting_pieces() -> PiecesLocation {
        let mut locations: PiecesLocation = HashMap::new();

        for player in [Player::Red, Player::Blue, Player::Green, Player::Yellow] {
            let initial_army = vec![
                Unit {
                    owner: player,
                    unit_type: UnitType::Flag,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Infantry,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Infantry,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Tank,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Tank,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Fighter,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Fighter,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Destroyer,
                },
                Unit {
                    owner: player,
                    unit_type: UnitType::Destroyer,
                },
            ];

            locations.insert(Hq(player), initial_army);
        }

        locations
    }
}
