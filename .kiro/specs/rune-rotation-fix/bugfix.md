# Bugfix Requirements Document

## Introduction

The rune rotation feature is currently non-functional, making the game extremely difficult to play. While the `rotate_pair()` function exists and is called when the player presses the rotation key (ui_up), it lacks collision validation. This causes runes to rotate into invalid positions (out of bounds or overlapping existing pieces), breaking the game state. This bugfix will implement proper collision checking and wall-kick behavior to make rotation work correctly.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the player presses the rotation key and the rotated position would place runes out of bounds THEN the system rotates anyway, causing runes to exist outside the valid grid

1.2 WHEN the player presses the rotation key and the rotated position would collide with existing pieces THEN the system rotates anyway, causing runes to overlap with existing grid pieces

1.3 WHEN the player presses the rotation key near the right edge while horizontal THEN the system rotates to vertical without checking if there's space below, potentially placing rune2 out of bounds

1.4 WHEN the player presses the rotation key near the bottom while vertical THEN the system rotates to horizontal without checking if there's space to the right, potentially placing rune2 out of bounds

### Expected Behavior (Correct)

2.1 WHEN the player presses the rotation key and the rotated position would place runes out of bounds THEN the system SHALL attempt to wall-kick (shift the pair left or right) to make the rotation valid

2.2 WHEN the player presses the rotation key and the rotated position would collide with existing pieces THEN the system SHALL attempt to wall-kick (shift the pair left or right) to make the rotation valid

2.3 WHEN the player presses the rotation key and wall-kick cannot resolve the collision or bounds issue THEN the system SHALL block the rotation and keep the current orientation

2.4 WHEN the player presses the rotation key and the rotation is valid without adjustment THEN the system SHALL rotate the pair immediately

2.5 WHEN wall-kick is successful THEN the system SHALL update both the orientation and the grid position of the pair

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the player presses left/right movement keys THEN the system SHALL CONTINUE TO move the pair horizontally with proper collision checking

3.2 WHEN the pair falls automatically or with down key THEN the system SHALL CONTINUE TO move the pair downward with proper collision checking

3.3 WHEN the pair locks into place THEN the system SHALL CONTINUE TO separate the runes and place them in the grid correctly

3.4 WHEN matches are detected after locking THEN the system SHALL CONTINUE TO remove matched pieces and apply gravity

3.5 WHEN the pair is horizontal THEN the system SHALL CONTINUE TO occupy two horizontal grid cells

3.6 WHEN the pair is vertical THEN the system SHALL CONTINUE TO occupy two vertical grid cells
