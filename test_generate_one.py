#!/usr/bin/env python3
"""
Test script to generate ONE sprite and download it
Run: python test_generate_one.py
"""

import replicate
import os
import requests

def download_image(url, filepath):
    """Download image from URL to filepath"""
    print(f"📥 Downloading from: {url}")
    response = requests.get(url)
    response.raise_for_status()
    with open(filepath, 'wb') as f:
        f.write(response.content)
    print(f"✅ Downloaded: {filepath}")

def test_generation():
    """Generate one test sprite"""
    print("🎨 Testing sprite generation...")
    print("=" * 50)
    
    # Check for API token
    if not os.environ.get("REPLICATE_API_TOKEN"):
        print("❌ Error: REPLICATE_API_TOKEN environment variable not set")
        print("\nTo set it:")
        print("  Windows PowerShell: $env:REPLICATE_API_TOKEN='your_token_here'")
        print("  Windows CMD: set REPLICATE_API_TOKEN=your_token_here")
        print("\nGet your token from: https://replicate.com/account/api-tokens")
        return
    
    try:
        print("\n🔄 Generating fire rune sprite...")
        
        # Run the model
        output = replicate.run(
            "retro-diffusion/rd-fast:067f6cd8a3c5582b4317d462176b75d9cdfae8ae548033220bddd0c19c4a1357",
            input={
                "prompt": "Fire rune square icon, glowing red and orange flames, pixel art, game asset, simple background",
                "width": 64,
                "height": 64,
                "style": "game_asset",
                "remove_bg": True,
                "num_images": 1
            }
        )
        
        print(f"📦 Output received: {output}")
        
        # Download the generated image
        if output and len(output) > 0:
            image_url = output[0]
            filepath = "test_fire_rune.png"
            download_image(image_url, filepath)
            print("\n" + "=" * 50)
            print("✅ SUCCESS! Test sprite generated and downloaded!")
            print(f"📁 Check the file: {filepath}")
        else:
            print("❌ No output received from the model")
            
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nTroubleshooting:")
        print("1. Make sure your REPLICATE_API_TOKEN is set correctly")
        print("2. Check you have payment method set up at replicate.com")
        print("3. Verify you have credits/balance available")

if __name__ == "__main__":
    test_generation()
