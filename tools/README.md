# Sprite Generator Tool

Generic tool for generating game sprites using Replicate AI models.

## Setup

```bash
pip install replicate requests
export REPLICATE_API_TOKEN="your_token_here"  # or set in environment
```

## Usage

### Generate Single Sprite

```bash
python tools/sprite_generator.py \
  --prompt "fire rune icon" \
  --output assets/sprites/fire/rune.png \
  --width 64 \
  --height 64
```

### Generate from Config File

```bash
python tools/sprite_generator.py --config sprites_config.json
```

### Generate Batch

Create a JSON file with sprite definitions:

```json
[
  {
    "prompt": "fire rune icon",
    "output": "assets/sprites/fire.png",
    "width": 64,
    "height": 64
  },
  {
    "prompt": "water rune icon",
    "output": "assets/sprites/water.png"
  }
]
```

Then run:

```bash
python tools/sprite_generator.py --batch my_sprites.json
```

## Available Models

- `pixel_art` - Fast pixel art generation (default)
- `pixel_art_hq` - Higher quality pixel art
- `sprite_sheet` - Generate sprite sheets
- `animated` - Animated sprites

## Available Styles

- `game_asset` - Clean game assets (default)
- `simple` - Simple shading
- `detailed` - Detailed pixel art
- `retro` - Retro game style
- `low_res` - Low resolution style

## Config File Format

```json
{
  "defaults": {
    "width": 64,
    "height": 64,
    "model_type": "pixel_art",
    "style": "game_asset",
    "remove_bg": true
  },
  "sprites": [
    {
      "prompt": "fire rune icon",
      "output": "assets/sprites/fire.png"
    }
  ]
}
```

## Examples

### Generate Runefall Sprites

```bash
# Generate all Runefall sprites from config
python tools/sprite_generator.py --config sprites_config.json

# Generate single sprite with custom settings
python tools/sprite_generator.py \
  --prompt "magical fire rune symbol" \
  --output assets/sprites/fire/rune.png \
  --width 128 \
  --height 128 \
  --model pixel_art_hq \
  --style detailed
```

### Use as Python Module

```python
from tools.sprite_generator import SpriteGenerator

generator = SpriteGenerator()

# Generate single sprite
generator.generate_sprite(
    prompt="fire rune icon",
    output_path="assets/sprites/fire.png",
    width=64,
    height=64
)

# Generate batch
sprites = [
    {"prompt": "fire rune", "output": "fire.png"},
    {"prompt": "water rune", "output": "water.png"}
]
generator.generate_batch(sprites)

# Generate from config
generator.generate_from_config("sprites_config.json")
```
