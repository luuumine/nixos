#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Player {
    Red,
    Blue,
    Green,
    Yellow,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnitType {
    Infantry,
    Tank,
    Fighter,
    Destroyer,
    Regiment,
    HeavyTank,
    Bomber,
    Cruiser,
    Nuke,
    Flag,
    Power,
}

impl UnitType {
    /// Represents the base cost to build, and base combat strength for normal units
    pub fn value(self) -> u32 {
        match self {
            Self::Flag => 0,
            Self::Power => 1,
            Self::Infantry => 2,
            Self::Tank => 3,
            Self::Fighter => 5,
            Self::Destroyer => 10,
            Self::Regiment => 20,
            Self::Bomber => 25,
            Self::HeavyTank => 30,
            Self::Cruiser => 50,
            Self::Nuke => 100,
        }
    }

    /// Represents the range a piece can move in a single turn
    pub fn range(self) -> u8 {
        match self {
            Self::Flag | Self::Power => 0,
            Self::Infantry | Self::Regiment => 2,
            Self::Tank | Self::HeavyTank => 3,
            Self::Fighter | Self::Bomber => 5,
            Self::Destroyer | Self::Cruiser => 1,
            Self::Nuke => u8::MAX,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Unit {
    pub owner: Player,
    pub unit_type: UnitType,
}
