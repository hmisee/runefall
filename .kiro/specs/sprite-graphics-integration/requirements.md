# Requirements Document

## Introduction

This feature replaces the current simple colored shapes (ColorRect nodes) with sprite graphics for runes and elements in the Runefall puzzle game. The visual upgrade will enhance player experience while maintaining the core gameplay mechanics and visual clarity needed for match-4 puzzle gameplay.

## Glossary

- **Rune**: A falling square-shaped game piece controlled by the player, representing one of four elemental types
- **Element**: A rising circular angry face that needs to be calmed by matching with runes
- **Element_Type**: One of four categories: Fire, Water, Earth, or Air
- **Grid_Cell**: A single position in the 8x16 game grid
- **Sprite**: A 2D image asset used to visually represent game objects
- **Match_Group**: A collection of 4 or more connected runes and elements of the same type
- **Game_Grid**: The 8-column by 16-row playing field where runes and elements exist

## Requirements

### Requirement 1: Sprite Asset Management

**User Story:** As a developer, I want to organize sprite assets by element type, so that the game can load and reference them efficiently.

#### Acceptance Criteria

1. THE Game SHALL store sprite assets in a dedicated sprites directory organized by element type
2. FOR EACH Element_Type, THE Game SHALL provide exactly two sprite variants: one rune sprite and one element sprite
3. THE Game SHALL support PNG format sprite files with transparency
4. WHEN the game initializes, THE Game SHALL load all sprite assets into memory
5. IF a required sprite asset is missing, THEN THE Game SHALL log an error message and fall back to colored shapes

### Requirement 2: Rune Visual Representation

**User Story:** As a player, I want runes to display as geometric sprites with elemental symbols, so that I can easily identify their type.

#### Acceptance Criteria

1. WHEN a Rune is created, THE Rune SHALL display its corresponding sprite based on its Element_Type
2. THE Rune SHALL use a Sprite2D node instead of a ColorRect node for rendering
3. THE Rune SHALL scale its sprite to fit within a Grid_Cell while maintaining aspect ratio
4. FOR Fire runes, THE Rune SHALL display a red or orange colored sprite
5. FOR Water runes, THE Rune SHALL display a blue or cyan colored sprite
6. FOR Earth runes, THE Rune SHALL display a brown or green colored sprite
7. FOR Air runes, THE Rune SHALL display a white or light gray colored sprite

### Requirement 3: Element Visual Representation

**User Story:** As a player, I want elements to display as circular angry faces with elemental themes, so that I can distinguish them from runes and identify their type.

#### Acceptance Criteria

1. WHEN an Element is created, THE Element SHALL display its corresponding sprite based on its Element_Type
2. THE Element SHALL use a Sprite2D node instead of a ColorRect node for rendering
3. THE Element SHALL scale its sprite to fit within a Grid_Cell while maintaining aspect ratio
4. FOR Fire elements, THE Element SHALL display a red or orange colored sprite with an angry expression
5. FOR Water elements, THE Element SHALL display a blue or cyan colored sprite with an angry expression
6. FOR Earth elements, THE Element SHALL display a brown or green colored sprite with an angry expression
7. FOR Air elements, THE Element SHALL display a white or light gray colored sprite with an angry expression

### Requirement 4: Color Consistency Between Matching Types

**User Story:** As a player, I want matching runes and elements to share the same color scheme, so that I can quickly identify which pieces will match.

#### Acceptance Criteria

1. FOR Fire type, THE Game SHALL use red or orange colors for both rune and element sprites
2. FOR Water type, THE Game SHALL use blue or cyan colors for both rune and element sprites
3. FOR Earth type, THE Game SHALL use brown or green colors for both rune and element sprites
4. FOR Air type, THE Game SHALL use white or light gray colors for both rune and element sprites
5. WHEN a Match_Group forms, THE Game SHALL visually confirm that all pieces share the same color scheme

### Requirement 5: Sprite Integration with Existing Game Logic

**User Story:** As a developer, I want sprites to integrate seamlessly with existing game mechanics, so that no gameplay functionality is broken.

#### Acceptance Criteria

1. WHEN a Rune rotates, THE Rune SHALL maintain its sprite orientation
2. WHEN a Rune or Element falls, THE Sprite SHALL move smoothly with the game object
3. WHEN a Match_Group is detected, THE Game SHALL remove sprites along with their game objects
4. THE Game SHALL maintain the same collision detection behavior regardless of sprite or ColorRect rendering
5. THE Game SHALL maintain the same grid positioning logic regardless of sprite or ColorRect rendering

### Requirement 6: Sprite Scaling and Grid Compatibility

**User Story:** As a player, I want sprites to fit properly within the game grid, so that the visual presentation is clean and readable.

#### Acceptance Criteria

1. THE Game SHALL calculate sprite scale based on Grid_Cell dimensions
2. WHEN a sprite is larger than a Grid_Cell, THE Game SHALL scale it down to fit
3. WHEN a sprite is smaller than a Grid_Cell, THE Game SHALL scale it up to fill the space efficiently
4. THE Game SHALL maintain sprite aspect ratio during scaling operations
5. THE Game SHALL center sprites within their Grid_Cell positions

### Requirement 7: Asset Attribution and Licensing

**User Story:** As a developer, I want to properly attribute sprite sources, so that the game complies with licensing requirements.

#### Acceptance Criteria

1. THE Game SHALL include a credits file documenting all sprite sources and licenses
2. WHERE sprites require attribution, THE Game SHALL display attribution in the game credits screen
3. THE Game SHALL only use sprites that permit commercial use
4. THE Game SHALL document the source URL for each sprite pack used

### Requirement 8: Fallback Rendering Mode

**User Story:** As a developer, I want the game to gracefully handle missing sprites, so that development and testing can continue even with incomplete assets.

#### Acceptance Criteria

1. IF a sprite file cannot be loaded, THEN THE Game SHALL render the object using a ColorRect node with the appropriate color
2. WHEN operating in fallback mode, THE Game SHALL log which sprites are missing
3. THE Game SHALL maintain all gameplay functionality when using fallback rendering
4. THE Game SHALL use the same color scheme in fallback mode as specified for sprite colors
