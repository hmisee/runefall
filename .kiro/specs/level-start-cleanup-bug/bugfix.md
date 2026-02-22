# Bugfix Requirements Document

## Introduction

When starting a level in Runefall, two visual bugs occur that affect the game's presentation and user experience:

1. **Stale Rune Pairs**: Previously displayed rune pairs from the main menu or previous game sessions remain visible on the game board when starting level 1, creating visual clutter and confusion about which pieces are actually in play.

2. **Preview Color Mismatch**: The "Next:" preview display shows rune colors that don't match the actual runes that spawn, breaking the player's ability to plan ahead effectively.

These bugs undermine the game's polish and the preview feature's core purpose of helping players strategize their next move.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a level is started via `initialize_level()` THEN the system does not remove existing RunePair nodes from the scene tree, leaving old rune pairs visible on screen

1.2 WHEN a level is started and the preview UI is updated THEN the system uses stale `next_rune_pair_data` from before the board was reinitialized, causing preview colors to not match the actual next pair

1.3 WHEN `initialize_level()` calls `initialize_grid()` THEN the system only clears the grid array but does not free existing child nodes (RunePair, Rune, Element instances)

### Expected Behavior (Correct)

2.1 WHEN a level is started via `initialize_level()` THEN the system SHALL remove all existing RunePair nodes from the scene tree before spawning new pairs

2.2 WHEN a level is started and the preview UI is updated THEN the system SHALL use the freshly generated `next_rune_pair_data` that corresponds to the actual next pair that will spawn

2.3 WHEN `initialize_level()` calls `initialize_grid()` THEN the system SHALL free all existing child nodes (RunePair, Rune, Element instances) to ensure a clean board state

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a rune pair is locked and a new pair spawns during normal gameplay THEN the system SHALL CONTINUE TO spawn pairs with types matching the preview

3.2 WHEN elements are spawned during level initialization THEN the system SHALL CONTINUE TO place them randomly at the bottom of the board

3.3 WHEN the grid array is initialized THEN the system SHALL CONTINUE TO create an 8x16 grid with all cells set to null

3.4 WHEN `spawn_new_pair()` is called during gameplay THEN the system SHALL CONTINUE TO use preview data and generate new preview data for the next pair

3.5 WHEN the game board is drawn THEN the system SHALL CONTINUE TO display grid boundaries and lines correctly
