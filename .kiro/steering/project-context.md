---
inclusion: always
---

# Runefall - Project Context

## Game Concept
Runefall is a puzzle game inspired by Dr. Mario where a shaman calms angry rising elements using magical runes.

## Core Mechanics
- **Shaman**: Player character who drops runes
- **Runes**: Falling pairs of colored squares (4 types: Fire, Water, Earth, Air)
- **Elements**: Rising angry circles that need to be calmed (4 types matching runes)
- **Win Condition**: Match 4 of the same type (rune + element) to make them disappear

## Technical Stack
- **Engine**: Godot 4.3
- **Language**: GDScript
- **Platform**: Windows (development), targeting Steam release
- **Repository**: https://github.com/hmisee/runefall

## Current State
- Basic grid system (8x16)
- Falling rune pairs with rotation
- Match-4 detection (horizontal and vertical)
- Simple colored shapes (squares for runes, circles for elements)
- Replicate MCP integration for future AI-generated sprites

## Development Priorities
1. Core gameplay mechanics
2. Visual polish (will use AI-generated sprites later)
3. Score system and progression
4. Game over detection
5. Sound and particle effects

## Code Style
- Keep code minimal and focused
- Use Godot best practices
- Comment complex game logic
- Maintain clean separation between game objects
