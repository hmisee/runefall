#!/usr/bin/env python3
"""
Simple script to generate and download sprites using Replicate API.
Usage: python generate_sprite.py "your prompt here" output_filename.png
"""

import os
import sys
import time
import requests
import replicate

def generate_and_download(prompt: str, output_path: str, width: int = 512, height: int = 512):
    """Generate an image using Replicate and download it."""
    
    # Check for API token
    if not os.environ.get("REPLICATE_API_TOKEN"):
        print("❌ Error: REPLICATE_API_TOKEN environment variable not set")
        print("\nTo set it:")
        print("  Windows: set REPLICATE_API_TOKEN=your_token_here")
        print("  Linux/Mac: export REPLICATE_API_TOKEN=your_token_here")
        return False
    
    print(f"🎨 Generating image with prompt: {prompt}")
    print(f"📐 Size: {width}x{height}")
    
    try:
        # Run the model - using Flux Schnell (faster, less NSFW filtering)
        output = replicate.run(
            "black-forest-labs/flux-schnell",
            input={
                "prompt": prompt,
                "width": width,
                "height": height,
                "num_outputs": 1,
                "output_format": "png",
                "output_quality": 100
            }
        )
        
        # Get the image URL
        if isinstance(output, list) and len(output) > 0:
            image_url = output[0]
        else:
            image_url = output
        
        print(f"✅ Image generated: {image_url}")
        
        # Download the image
        print(f"⬇️  Downloading to: {output_path}")
        response = requests.get(image_url, stream=True)
        response.raise_for_status()
        
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        file_size = os.path.getsize(output_path)
        print(f"✅ Downloaded successfully! ({file_size:,} bytes)")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_sprite.py \"prompt\" output_path.png")
        print("\nExample:")
        print('  python generate_sprite.py "fire rune symbol" assets/sprites/fire/fire_rune.png')
        sys.exit(1)
    
    prompt = sys.argv[1]
    output_path = sys.argv[2]
    
    success = generate_and_download(prompt, output_path)
    sys.exit(0 if success else 1)
