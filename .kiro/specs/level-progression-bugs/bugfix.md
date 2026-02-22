# Bugfix Requirements Document

## Introduction

This document addresses three critical bugs affecting level progression and user experience in Runefall:

1. **Drop Speed Bug**: Rune pairs fall too fast on level 3, making the game unplayable
2. **Notification Overflow Bug**: Level clear notification text is cut off and unreadable
3. **Game Over Routing Bug**: Players are not returned to the main menu after game over

These bugs impact core gameplay flow and prevent players from properly experiencing level progression.

## Bug Analysis

### Current Behavior (Defect)

#### Bug 1: Drop Speed Increases on Level 3

1.1 WHEN the player completes level 2 and starts level 3 THEN the rune pair drop speed becomes excessively fast (fall_speed remains at 0.05 from previous fast-drop input)

1.2 WHEN the player holds down the down arrow key and then releases it before locking a pair THEN the fall_speed is set to 0.05 but may not reset to 0.5 if the pair locks while the key is held

#### Bug 2: Level Clear Notification Text Overflow

1.3 WHEN a level is completed THEN the notification message "The shaman successfully calmed down all the elements" overflows the MessageLabel bounds (600px width, 48px font size)

1.4 WHEN the final level is completed THEN the notification message "Congratulations! You have mastered all elements!" overflows the MessageLabel bounds

#### Bug 3: Missing Game Over Routing

1.5 WHEN the game enters the LOSS state (game over) THEN the player remains on the game screen with no way to return to the main menu

1.6 WHEN the loss_condition_met signal is emitted THEN no automatic routing or user prompt to return to main menu is triggered

### Expected Behavior (Correct)

#### Bug 1: Drop Speed Should Remain Constant

2.1 WHEN the player starts any level (1, 2, or 3) THEN the rune pair drop speed SHALL be initialized to 0.5 seconds

2.2 WHEN the player releases the down arrow key THEN the fall_speed SHALL be reset to 0.5 seconds

2.3 WHEN a new level starts THEN the fall_speed SHALL be explicitly reset to 0.5 seconds regardless of previous input state

#### Bug 2: Notification Text Should Be Readable

2.4 WHEN a level is completed THEN the notification message SHALL be fully visible and readable within the MessageLabel bounds

2.5 WHEN the final level is completed THEN the congratulations message SHALL be fully visible and readable within the MessageLabel bounds

2.6 WHEN any message is displayed THEN the text SHALL automatically wrap or the font size SHALL be reduced to fit the available space

#### Bug 3: Game Over Should Route to Main Menu

2.7 WHEN the game enters the LOSS state THEN the system SHALL automatically return the player to the main menu after displaying the game over message for 3 seconds

2.8 WHEN the loss_condition_met signal is emitted THEN the game SHALL transition to LOSS state, display a message, wait 3 seconds, and then call return_to_menu()

### Unchanged Behavior (Regression Prevention)

#### Level Progression

3.1 WHEN the player completes a level (not game over) THEN the system SHALL CONTINUE TO unlock the next level and save progress

3.2 WHEN the player wins the final level THEN the system SHALL CONTINUE TO display the congratulations message without auto-progressing

#### Drop Speed Controls

3.3 WHEN the player presses the down arrow key during gameplay THEN the system SHALL CONTINUE TO increase drop speed to 0.05 seconds for fast dropping

3.4 WHEN the player uses left/right/rotate controls THEN the system SHALL CONTINUE TO function normally regardless of drop speed

#### Win Condition Auto-Progress

3.5 WHEN the player completes a non-final level THEN the system SHALL CONTINUE TO automatically progress to the next level after 3 seconds

3.6 WHEN the game is in TRANSITION state THEN the system SHALL CONTINUE TO pause the game board

#### UI Display

3.7 WHEN the game is in PLAYING state THEN the GameUI SHALL CONTINUE TO be visible with level info, elements count, and preview

3.8 WHEN the game is in MENU state THEN the GameUI SHALL CONTINUE TO be hidden and the main menu SHALL be shown

#### Pause Functionality

3.9 WHEN the player pauses the game THEN the system SHALL CONTINUE TO pause the game board and show the pause menu

3.10 WHEN the player resumes from pause THEN the system SHALL CONTINUE TO unpause the game board and hide the pause menu
