# Requirements Document

## Introduction

This feature implements proper 4-way rotation for rune pairs in Runefall, allowing players to cycle through all four possible orientations. Currently, the game only toggles between horizontal and vertical orientations (2 states), which prevents players from flipping which rune is in which position. This is essential for gameplay strategy when runes have different colors, as players need to position each specific rune exactly where needed.

## Glossary

- **Rune_Pair**: A falling pair of two colored runes controlled by the player
- **Rune1**: The first rune in a Rune_Pair (currently positioned left or top)
- **Rune2**: The second rune in a Rune_Pair (currently positioned right or bottom)
- **Rotation_State**: An integer value (0-3) representing one of four possible orientations
- **Orientation**: The spatial arrangement of Rune1 and Rune2 in a Rune_Pair
- **Wall_Kick**: Automatic horizontal adjustment when rotation would collide with walls or pieces
- **Game_Board**: The grid system that manages piece placement and collision detection

## Requirements

### Requirement 1: Four Rotation States

**User Story:** As a player, I want to rotate my rune pair through four distinct orientations, so that I can position each rune exactly where I need it.

#### Acceptance Criteria

1. THE Rune_Pair SHALL support four distinct Rotation_State values: 0, 1, 2, and 3
2. WHEN Rotation_State is 0, THE Rune_Pair SHALL position Rune1 left and Rune2 right (horizontal)
3. WHEN Rotation_State is 1, THE Rune_Pair SHALL position Rune1 top and Rune2 bottom (vertical)
4. WHEN Rotation_State is 2, THE Rune_Pair SHALL position Rune2 left and Rune1 right (horizontal)
5. WHEN Rotation_State is 3, THE Rune_Pair SHALL position Rune2 top and Rune1 bottom (vertical)

### Requirement 2: Rotation Cycling

**User Story:** As a player, I want rotation to cycle through all four orientations in order, so that I can reach any desired arrangement.

#### Acceptance Criteria

1. WHEN the player presses the rotate input, THE Rune_Pair SHALL increment Rotation_State by 1
2. WHEN Rotation_State is 3 and the player presses rotate, THE Rune_Pair SHALL set Rotation_State to 0
3. FOR ALL rotation operations, THE Rune_Pair SHALL update visual positions to match the new Rotation_State

### Requirement 3: Collision Detection for All Orientations

**User Story:** As a player, I want rotation to respect game boundaries and existing pieces, so that the game remains fair and predictable.

#### Acceptance Criteria

1. WHEN rotation is requested, THE Game_Board SHALL calculate collision for the target Rotation_State
2. IF the target Rotation_State would cause collision, THEN THE Game_Board SHALL attempt Wall_Kick adjustments
3. IF no valid position exists after Wall_Kick attempts, THEN THE Game_Board SHALL prevent rotation and maintain current Rotation_State
4. FOR ALL Rotation_State values, THE Game_Board SHALL correctly identify both rune positions for collision checking

### Requirement 4: Wall Kick Behavior Preservation

**User Story:** As a player, I want wall kicks to work with four-way rotation, so that I can rotate near walls without frustration.

#### Acceptance Criteria

1. WHEN rotation would collide at current position, THE Game_Board SHALL attempt rotation at grid_x minus 1
2. IF grid_x minus 1 is valid, THEN THE Game_Board SHALL apply rotation and move Rune_Pair to grid_x minus 1
3. IF grid_x minus 1 is invalid, THEN THE Game_Board SHALL attempt rotation at grid_x plus 1
4. IF grid_x plus 1 is valid, THEN THE Game_Board SHALL apply rotation and move Rune_Pair to grid_x plus 1

### Requirement 5: Piece Locking Correctness

**User Story:** As a player, I want runes to lock in their correct positions regardless of rotation state, so that the game behaves consistently.

#### Acceptance Criteria

1. WHEN a Rune_Pair locks, THE Game_Board SHALL place Rune1 at its visual position based on current Rotation_State
2. WHEN a Rune_Pair locks, THE Game_Board SHALL place Rune2 at its visual position based on current Rotation_State
3. FOR ALL Rotation_State values, THE Game_Board SHALL correctly map visual positions to grid coordinates
4. WHEN Rotation_State is 0 or 2, THE Game_Board SHALL place both runes in the same row
5. WHEN Rotation_State is 1 or 3, THE Game_Board SHALL place both runes in the same column

### Requirement 6: Backward Compatibility

**User Story:** As a developer, I want the rotation system to integrate cleanly with existing code, so that other game systems continue to work.

#### Acceptance Criteria

1. THE Rune_Pair SHALL maintain grid_x and grid_y properties for position tracking
2. THE Game_Board SHALL continue to use existing collision detection functions
3. THE Game_Board SHALL continue to use existing gravity and match detection systems
4. FOR ALL rotation operations, THE Rune_Pair SHALL update positions using the existing update_positions pattern
