---
inclusion: fileMatch
fileMatchPattern: "**/*.gd"
---

# Godot Development Guidelines

## GDScript Best Practices
- Use `@export` for inspector-visible variables
- Use `@onready` for node references
- Prefer signals over direct function calls between nodes
- Use `class_name` for reusable scripts

## Node Structure
- Keep scene hierarchy shallow when possible
- Use groups for managing collections of similar nodes
- Prefer composition over inheritance

## Performance
- Use `queue_free()` instead of `free()` for safe deletion
- Cache node references in `_ready()`
- Avoid heavy operations in `_process()` when possible

## Naming Conventions
- snake_case for variables and functions
- PascalCase for class names
- UPPER_CASE for constants and enums
