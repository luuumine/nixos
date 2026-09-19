use crate::power::{
    board::Region,
    engine::PiecesLocation,
    pieces::{Player, Unit, UnitType},
};

pub fn merge(
    pieces: &mut PiecesLocation,
    player: Player,
    from: Region,
    source_type: UnitType,
    count: u32,
    final_type: UnitType,
) -> Result<(), &'static str> {
    if [UnitType::Flag, UnitType::Power, UnitType::Nuke].contains(&final_type) {
        return Err("Cannot create this piece");
    }

    let cell_units = pieces.get_mut(&from).ok_or("Region not found")?;

    let available_count = cell_units
        .iter()
        .filter(|u| u.owner == player && u.unit_type == source_type)
        .count() as u32;

    if available_count < count {
        return Err("Not enough units of the source type in this region");
    }

    if source_type == UnitType::Power {
        let total_power_value = count * UnitType::Power.value();
        if total_power_value != final_type.value() {
            return Err("Power token count does not match target unit value");
        }
    } else {
        if count != 3 {
            return Err("Standard unit merges require exactly 3 pieces");
        }
        if source_type == UnitType::Flag {
            return Err("Cannot merge flags");
        }
    }

    let mut removed = 0;
    cell_units.retain(|u| {
        if removed < count && u.owner == player && u.unit_type == source_type {
            removed += 1;
            false
        } else {
            true
        }
    });

    cell_units.push(Unit {
        owner: player,
        unit_type: final_type,
    });

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::power::board::Region;
    use crate::power::pieces::{Player, Unit, UnitType};
    use std::collections::HashMap;

    fn setup_mock_cell(units: Vec<Unit>) -> PiecesLocation {
        let mut pieces = HashMap::new();
        pieces.insert(Region::Hq(Player::Red), units);
        pieces
    }

    #[test]
    fn test_merge_success_powers() {
        // 3 Powers = 1 Tank
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Power,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Power,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Power,
            },
        ]);

        let result = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Power,
            3,
            UnitType::Tank,
        );

        assert!(result.is_ok());
        let cell = pieces.get(&Region::Hq(Player::Red)).unwrap();
        assert_eq!(cell.len(), 1);
        assert_eq!(cell[0].unit_type, UnitType::Tank);
    }

    #[test]
    fn test_merge_success_standard_units() {
        // 3 Infantry -> 1 Regiment
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
        ]);

        let result = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Infantry,
            3,
            UnitType::Regiment,
        );

        assert!(result.is_ok());
        let cell = pieces.get(&Region::Hq(Player::Red)).unwrap();
        assert_eq!(cell.len(), 1);
        assert_eq!(cell[0].unit_type, UnitType::Regiment);
    }

    #[test]
    fn test_merge_retains_excess_and_enemy_units() {
        // Red has 4 Infantry, Blue has 2 Infantry on the same cell
        // Red merges 3 Infantry into a Regiment
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            }, // Extra Red
            Unit {
                owner: Player::Blue,
                unit_type: UnitType::Infantry,
            }, // Blue
            Unit {
                owner: Player::Blue,
                unit_type: UnitType::Infantry,
            }, // Blue
        ]);

        let result = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Infantry,
            3,
            UnitType::Regiment,
        );

        assert!(result.is_ok());
        let cell = pieces.get(&Region::Hq(Player::Red)).unwrap();

        // Should have 1 Red Infantry, 1 Red Regiment, and 2 Blue Infantry = 4 units left
        assert_eq!(cell.len(), 4);

        let red_infantry_count = cell
            .iter()
            .filter(|u| u.owner == Player::Red && u.unit_type == UnitType::Infantry)
            .count();
        let red_regiment_count = cell
            .iter()
            .filter(|u| u.owner == Player::Red && u.unit_type == UnitType::Regiment)
            .count();
        let blue_infantry_count = cell
            .iter()
            .filter(|u| u.owner == Player::Blue && u.unit_type == UnitType::Infantry)
            .count();

        assert_eq!(red_infantry_count, 1);
        assert_eq!(red_regiment_count, 1);
        assert_eq!(blue_infantry_count, 2);
    }

    #[test]
    fn test_fail_invalid_target_types() {
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry
            };
            3
        ]);

        // Attempt to merge into Flag
        let res_flag = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Infantry,
            3,
            UnitType::Flag,
        );
        assert_eq!(res_flag, Err("Cannot create this piece"));

        // Attempt to merge into Nuke
        let res_nuke = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Infantry,
            3,
            UnitType::Nuke,
        );
        assert_eq!(res_nuke, Err("Cannot create this piece"));
    }

    #[test]
    fn test_fail_not_enough_units() {
        // Only 2 Infantry available
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry,
            },
        ]);

        let result = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Infantry,
            3,
            UnitType::Regiment,
        );
        assert_eq!(
            result,
            Err("Not enough units of the source type in this region")
        );
    }

    #[test]
    fn test_fail_bad_power_math() {
        // 2 Powers (value 2) trying to make a Tank (value 3)
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Power
            };
            2
        ]);

        let result = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Power,
            2,
            UnitType::Tank,
        );
        assert_eq!(
            result,
            Err("Power token count does not match target unit value")
        );
    }

    #[test]
    fn test_fail_standard_merge_wrong_count() {
        // 4 Infantry trying to merge at once (standard merges require exactly 3)
        let mut pieces = setup_mock_cell(vec![
            Unit {
                owner: Player::Red,
                unit_type: UnitType::Infantry
            };
            4
        ]);

        let result = merge(
            &mut pieces,
            Player::Red,
            Region::Hq(Player::Red),
            UnitType::Infantry,
            4,
            UnitType::Regiment,
        );
        assert_eq!(result, Err("Standard unit merges require exactly 3 pieces"));
    }
}
