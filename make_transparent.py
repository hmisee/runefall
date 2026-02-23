#!/usr/bin/env python3
"""
Make sprite backgrounds transparent by detecting and removing background color.
Usage: python make_transparent.py input.png output.png [mode]
Modes: auto (default), white, black, corner
"""

import sys
from PIL import Image

def get_background_color(img, mode="auto"):
    """Detect the background color from the image."""
    pixels = img.load()
    width, height = img.size
    
    if mode == "white":
        return (255, 255, 255)
    elif mode == "black":
        return (0, 0, 0)
    elif mode == "corner":
        # Sample corners to find most common color
        corners = [
            pixels[0, 0],
            pixels[width-1, 0],
            pixels[0, height-1],
            pixels[width-1, height-1]
        ]
        # Return most common corner color
        return max(set(corners), key=corners.count)[:3]
    else:  # auto
        # Sample edges to find background
        edge_colors = []
        # Top and bottom edges
        for x in range(0, width, 10):
            edge_colors.append(pixels[x, 0][:3])
            edge_colors.append(pixels[x, height-1][:3])
        # Left and right edges
        for y in range(0, height, 10):
            edge_colors.append(pixels[0, y][:3])
            edge_colors.append(pixels[width-1, y][:3])
        
        # Find most common edge color
        return max(set(edge_colors), key=edge_colors.count)

def make_transparent(input_path, output_path, mode="auto", tolerance=30):
    """Remove background color and make it transparent."""
    
    print(f"📂 Opening: {input_path}")
    img = Image.open(input_path)
    img = img.convert("RGBA")
    
    pixels = img.load()
    width, height = img.size
    
    # Detect background color
    bg_color = get_background_color(img, mode)
    print(f"🎨 Background color detected: RGB{bg_color}")
    
    transparent_count = 0
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # Check if pixel is close to background color
            if (abs(r - bg_color[0]) <= tolerance and 
                abs(g - bg_color[1]) <= tolerance and 
                abs(b - bg_color[2]) <= tolerance):
                pixels[x, y] = (r, g, b, 0)
                transparent_count += 1
    
    img.save(output_path, "PNG")
    print(f"✅ Saved: {output_path}")
    print(f"🔍 Made {transparent_count:,} pixels transparent ({transparent_count/(width*height)*100:.1f}%)")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python make_transparent.py input.png output.png [mode]")
        print("\nModes:")
        print("  auto   - Auto-detect background from edges (default)")
        print("  white  - Remove white background")
        print("  black  - Remove black background")
        print("  corner - Use corner pixels to detect background")
        print("\nExample:")
        print("  python make_transparent.py sprite.png sprite_transparent.png auto")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    mode = sys.argv[3] if len(sys.argv) > 3 else "auto"
    
    make_transparent(input_path, output_path, mode)
