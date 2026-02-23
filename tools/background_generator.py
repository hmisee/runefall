#!/usr/bin/env python3
"""
Background Generator Tool for Runefall
Generates game backgrounds using Replicate AI models

Usage:
    python tools/background_generator.py --config backgrounds_config.json
    python tools/background_generator.py --prompt "volcanic landscape" --output assets/backgrounds/level_1_bg.png
"""

import replicate
import os
import sys
import json
import argparse
import requests
from pathlib import Path
from typing import Dict, List, Optional

class BackgroundGenerator:
    """Background generator using Replicate API"""
    
    # Default models for background generation
    MODELS = {
        "pixel_art": "retro-diffusion/rd-fast:067f6cd8a3c5582b4317d462176b75d9cdfae8ae548033220bddd0c19c4a1357",
        "pixel_art_hq": "retro-diffusion/rd-plus:60eb48db78cbd38cc6473d309a311db08244ed021567a9234970af971bab0d87",
        "animated": "retro-diffusion/rd-animation:a9f33da7d9a985064dbc2d99621b87da5b8a22ed4d412c3a1c34ab4b807a6d8f"
    }
    
    def __init__(self, api_token: Optional[str] = None):
        """Initialize the background generator"""
        self.api_token = api_token or os.environ.get("REPLICATE_API_TOKEN")
        if not self.api_token:
            raise ValueError("REPLICATE_API_TOKEN not set. Set it as environment variable or pass to constructor.")
    
    def generate_background(
        self,
        prompt: str,
        output_path: str,
        width: int = 600,
        height: int = 900,
        model_type: str = "pixel_art_hq",
        style: str = "game_background",
        remove_bg: bool = False,
        **kwargs
    ) -> str:
        """
        Generate a single background
        
        Args:
            prompt: Text description of the background
            output_path: Where to save the generated background
            width: Background width in pixels (default: 600)
            height: Background height in pixels (default: 900)
            model_type: Type of model to use (pixel_art, pixel_art_hq, animated)
            style: Style preset (game_background, detailed, retro, etc.)
            remove_bg: Remove background for transparency (default: False for backgrounds)
            **kwargs: Additional model-specific parameters
            
        Returns:
            Path to the generated background file
        """
        print(f"🎨 Generating background: {prompt}")
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
            print(f"❌ Error generating background: {e}\n")
            raise
    
    def generate_batch(self, backgrounds: List[Dict]) -> List[str]:
        """
        Generate multiple backgrounds from a list of configurations
        
        Args:
            backgrounds: List of background configurations, each with:
                - prompt: Text description
                - output: Output file path
                - width, height, model_type, style, etc. (optional)
                
        Returns:
            List of generated file paths
        """
        print(f"🎨 Batch generating {len(backgrounds)} backgrounds...")
        print("=" * 60)
        
        results = []
        for i, bg_config in enumerate(backgrounds, 1):
            print(f"\n[{i}/{len(backgrounds)}]")
            try:
                output_path = self.generate_background(**bg_config)
                results.append(output_path)
            except Exception as e:
                print(f"⚠️  Skipping background {i} due to error: {e}")
                results.append(None)
        
        print("\n" + "=" * 60)
        successful = sum(1 for r in results if r is not None)
        print(f"✅ Batch complete: {successful}/{len(backgrounds)} backgrounds generated")
        return results
    
    def generate_from_config(self, config_path: str, backgrounds_to_generate: Optional[List[str]] = None) -> List[str]:
        """
        Generate backgrounds from a JSON configuration file
        
        Args:
            config_path: Path to backgrounds_config.json
            backgrounds_to_generate: Optional list of background IDs to generate (e.g., ["level_1", "menu"])
                                    If None, generates all backgrounds with prompts
        
        Config format:
        {
            "generation_prompts": {
                "level_1": "Mystical background with warm fire...",
                "level_2": "Serene background with cool water...",
                ...
            },
            "backgrounds": {
                "level_1": {
                    "path": "res://assets/backgrounds/level_1_bg.png",
                    "type": "static"
                },
                ...
            }
        }
        """
        print(f"📄 Loading config: {config_path}")
        
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        generation_prompts = config.get("generation_prompts", {})
        backgrounds_config = config.get("backgrounds", {})
        
        if not generation_prompts:
            raise ValueError("No generation_prompts found in config file")
        
        # Build list of backgrounds to generate
        backgrounds_list = []
        for bg_id, prompt in generation_prompts.items():
            # Skip if specific backgrounds requested and this isn't one of them
            if backgrounds_to_generate and bg_id not in backgrounds_to_generate:
                continue
            
            # Get the output path from backgrounds config
            bg_config = backgrounds_config.get(bg_id, {})
            bg_path = bg_config.get("path", "")
            
            # Convert Godot resource path to filesystem path
            if bg_path.startswith("res://"):
                bg_path = bg_path.replace("res://", "")
            
            # For animated backgrounds, generate frames
            if bg_config.get("type") == "animated":
                frame_count = bg_config.get("frame_count", 8)
                print(f"\n🎬 Animated background '{bg_id}' will generate {frame_count} frames")
                
                # Generate each frame
                for frame_num in range(frame_count):
                    frame_prompt = f"{prompt}, frame {frame_num + 1} of {frame_count}"
                    frame_path = f"{bg_path}/frame_{frame_num}.png"
                    
                    backgrounds_list.append({
                        "prompt": frame_prompt,
                        "output": frame_path,
                        "width": 600,
                        "height": 900,
                        "model_type": "animated",
                        "style": "game_background"
                    })
            else:
                # Static background
                backgrounds_list.append({
                    "prompt": prompt,
                    "output": bg_path,
                    "width": 600,
                    "height": 900,
                    "model_type": "pixel_art_hq",
                    "style": "game_background"
                })
        
        if not backgrounds_list:
            print("⚠️  No backgrounds to generate")
            return []
        
        return self.generate_batch(backgrounds_list)
    
    def _download_image(self, url: str, filepath: str):
        """Download image from URL to filepath"""
        response = requests.get(url)
        response.raise_for_status()
        with open(filepath, 'wb') as f:
            f.write(response.content)


def main():
    """Command-line interface"""
    parser = argparse.ArgumentParser(
        description="Generate game backgrounds using AI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate all backgrounds from config
  python tools/background_generator.py --config backgrounds_config.json
  
  # Generate specific backgrounds only
  python tools/background_generator.py --config backgrounds_config.json --backgrounds level_1 level_2
  
  # Generate single background
  python tools/background_generator.py --prompt "volcanic landscape" --output assets/backgrounds/level_1_bg.png
  
  # Generate with custom settings
  python tools/background_generator.py --prompt "water scene" --output water_bg.png --width 600 --height 900 --model pixel_art_hq
        """
    )
    
    # Single background mode
    parser.add_argument("--prompt", help="Background description")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--width", type=int, default=600, help="Background width (default: 600)")
    parser.add_argument("--height", type=int, default=900, help="Background height (default: 900)")
    parser.add_argument("--model", default="pixel_art_hq", help="Model type (default: pixel_art_hq)")
    parser.add_argument("--style", default="game_background", help="Style preset (default: game_background)")
    parser.add_argument("--remove-bg", action="store_true", help="Remove background (not typical for backgrounds)")
    
    # Config file mode
    parser.add_argument("--config", help="JSON config file for batch generation")
    parser.add_argument("--backgrounds", nargs="+", help="Specific background IDs to generate (e.g., level_1 menu)")
    
    args = parser.parse_args()
    
    try:
        generator = BackgroundGenerator()
        
        # Config file mode
        if args.config:
            generator.generate_from_config(args.config, args.backgrounds)
        
        # Single background mode
        elif args.prompt and args.output:
            generator.generate_background(
                prompt=args.prompt,
                output_path=args.output,
                width=args.width,
                height=args.height,
                model_type=args.model,
                style=args.style,
                remove_bg=args.remove_bg
            )
        
        else:
            parser.print_help()
            sys.exit(1)
            
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
