#!/usr/bin/env python3
"""
Generic Sprite Generator Tool for Runefall
Generates game sprites using Replicate AI models

Usage:
    python tools/sprite_generator.py --config sprites_config.json
    python tools/sprite_generator.py --prompt "fire rune icon" --output assets/sprites/fire/rune.png
    python tools/sprite_generator.py --batch sprites_batch.json
"""

import replicate
import os
import sys
import json
import argparse
import requests
from pathlib import Path
from typing import Dict, List, Optional

class SpriteGenerator:
    """Generic sprite generator using Replicate API"""
    
    # Default models for different sprite types
    MODELS = {
        "pixel_art": "retro-diffusion/rd-fast:067f6cd8a3c5582b4317d462176b75d9cdfae8ae548033220bddd0c19c4a1357",
        "pixel_art_hq": "retro-diffusion/rd-plus:60eb48db78cbd38cc6473d309a311db08244ed021567a9234970af971bab0d87",
        "sprite_sheet": "cjwbw/sd_pixelart_spritesheet_generator:03e288270e5b93b235b18169d2678839b66500117e2b46b7f620389e1a96c002",
        "animated": "retro-diffusion/rd-animation:a9f33da7d9a985064dbc2d99621b87da5b8a22ed4d412c3a1c34ab4b807a6d8f"
    }
    
    def __init__(self, api_token: Optional[str] = None):
        """Initialize the sprite generator"""
        self.api_token = api_token or os.environ.get("REPLICATE_API_TOKEN")
        if not self.api_token:
            raise ValueError("REPLICATE_API_TOKEN not set. Set it as environment variable or pass to constructor.")
    
    def generate_sprite(
        self,
        prompt: str,
        output_path: str,
        width: int = 64,
        height: int = 64,
        model_type: str = "pixel_art",
        style: str = "game_asset",
        remove_bg: bool = True,
        **kwargs
    ) -> str:
        """
        Generate a single sprite
        
        Args:
            prompt: Text description of the sprite
            output_path: Where to save the generated sprite
            width: Sprite width in pixels
            height: Sprite height in pixels
            model_type: Type of model to use (pixel_art, pixel_art_hq, sprite_sheet, animated)
            style: Style preset (game_asset, simple, detailed, retro, etc.)
            remove_bg: Remove background for transparency
            **kwargs: Additional model-specific parameters
            
        Returns:
            Path to the generated sprite file
        """
        print(f"🎨 Generating: {prompt}")
        print(f"   Model: {model_type}")
        print(f"   Size: {width}x{height}")
        print(f"   Output: {output_path}")
        
        # Ensure output directory exists
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        # Get model version
        model = self.MODELS.get(model_type)
        if not model:
            raise ValueError(f"Unknown model type: {model_type}. Available: {list(self.MODELS.keys())}")
        
        # Prepare input parameters
        input_params = {
            "prompt": prompt,
            "width": width,
            "height": height,
            "style": style,
            "remove_bg": remove_bg,
            "num_images": 1,
            **kwargs
        }
        
        try:
            # Run the model
            output = replicate.run(model, input=input_params)
            
            # Download the generated image
            if output and len(output) > 0:
                image_url = output[0]
                self._download_image(image_url, output_path)
                print(f"✅ Generated: {output_path}\n")
                return output_path
            else:
                raise Exception("No output received from model")
                
        except Exception as e:
            print(f"❌ Error generating sprite: {e}\n")
            raise
    
    def generate_batch(self, sprites: List[Dict]) -> List[str]:
        """
        Generate multiple sprites from a list of configurations
        
        Args:
            sprites: List of sprite configurations, each with:
                - prompt: Text description
                - output: Output file path
                - width, height, model_type, style, etc. (optional)
                
        Returns:
            List of generated file paths
        """
        print(f"🎨 Batch generating {len(sprites)} sprites...")
        print("=" * 60)
        
        results = []
        for i, sprite_config in enumerate(sprites, 1):
            print(f"\n[{i}/{len(sprites)}]")
            try:
                output_path = self.generate_sprite(**sprite_config)
                results.append(output_path)
            except Exception as e:
                print(f"⚠️  Skipping sprite {i} due to error: {e}")
                results.append(None)
        
        print("\n" + "=" * 60)
        successful = sum(1 for r in results if r is not None)
        print(f"✅ Batch complete: {successful}/{len(sprites)} sprites generated")
        return results
    
    def generate_from_config(self, config_path: str) -> List[str]:
        """
        Generate sprites from a JSON configuration file
        
        Config format:
        {
            "defaults": {
                "width": 64,
                "height": 64,
                "model_type": "pixel_art",
                "style": "game_asset"
            },
            "sprites": [
                {
                    "prompt": "fire rune icon",
                    "output": "assets/sprites/fire/rune.png"
                },
                ...
            ]
        }
        """
        print(f"📄 Loading config: {config_path}")
        
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        defaults = config.get("defaults", {})
        sprites = config.get("sprites", [])
        
        # Apply defaults to each sprite config
        for sprite in sprites:
            for key, value in defaults.items():
                sprite.setdefault(key, value)
        
        return self.generate_batch(sprites)
    
    def _download_image(self, url: str, filepath: str):
        """Download image from URL to filepath"""
        response = requests.get(url)
        response.raise_for_status()
        with open(filepath, 'wb') as f:
            f.write(response.content)


def main():
    """Command-line interface"""
    parser = argparse.ArgumentParser(
        description="Generate game sprites using AI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate single sprite
  python tools/sprite_generator.py --prompt "fire rune icon" --output assets/sprites/fire.png
  
  # Generate from config file
  python tools/sprite_generator.py --config sprites_config.json
  
  # Generate with custom settings
  python tools/sprite_generator.py --prompt "water element" --output water.png --width 128 --height 128 --model pixel_art_hq
        """
    )
    
    # Single sprite mode
    parser.add_argument("--prompt", help="Sprite description")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--width", type=int, default=64, help="Sprite width (default: 64)")
    parser.add_argument("--height", type=int, default=64, help="Sprite height (default: 64)")
    parser.add_argument("--model", default="pixel_art", help="Model type (default: pixel_art)")
    parser.add_argument("--style", default="game_asset", help="Style preset (default: game_asset)")
    parser.add_argument("--no-remove-bg", action="store_true", help="Keep background")
    
    # Batch mode
    parser.add_argument("--config", help="JSON config file for batch generation")
    parser.add_argument("--batch", help="JSON file with sprite list")
    
    args = parser.parse_args()
    
    try:
        generator = SpriteGenerator()
        
        # Config file mode
        if args.config:
            generator.generate_from_config(args.config)
        
        # Batch file mode
        elif args.batch:
            with open(args.batch, 'r') as f:
                sprites = json.load(f)
            generator.generate_batch(sprites)
        
        # Single sprite mode
        elif args.prompt and args.output:
            generator.generate_sprite(
                prompt=args.prompt,
                output_path=args.output,
                width=args.width,
                height=args.height,
                model_type=args.model,
                style=args.style,
                remove_bg=not args.no_remove_bg
            )
        
        else:
            parser.print_help()
            sys.exit(1)
            
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
