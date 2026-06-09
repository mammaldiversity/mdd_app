import os
import argparse
import cv2
import numpy as np
import svgwrite
from dotenv import load_dotenv

def generate_svgs(image_path, output_dir):
    if not os.path.exists(image_path):
        print(f"Error: Image file not found at {image_path}")
        return False

    print(f"Loading image from {image_path}...")
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print(f"Error: Failed to read image at {image_path}. Check if it is a valid image file.")
        return False

    _, thresh = cv2.threshold(img, 200, 255, cv2.THRESH_BINARY_INV)

    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    large_contours = [c for c in contours if cv2.contourArea(c) > 600]

    animals = []
    for c in large_contours:
        x, y, w, h = cv2.boundingRect(c)
        animals.append({'contour': c, 'box': (x, y, w, h)})

    # Sort by row (y grouped by 80), then by x
    animals.sort(key=lambda a: (a['box'][1] // 80, a['box'][0]))

    orders = [
        "Afrosoricida", "Artiodactyla", "Carnivora", "Cetacea", "Chiroptera", "Cingulata", "Dasyuromorphia",
        "Dermoptera", "Didelphimorphia", "Diprotodontia", "Eulipotyphla", "Hyracoidea", "Lagomorpha", "Macroscelidea",
        "Microbiotheria", "Monotremata", "Notoryctemorphia", "Paucituberculata", "Peramelemorphia", "Pholidota", "Pilosa",
        "Primates", "Proboscidea", "Rodentia", "Scandentia", "Sirenia", "Tubulidentata", "Perissodactyla"
    ]

    os.makedirs(output_dir, exist_ok=True)

    if len(animals) != len(orders):
        print(f"Warning: Found {len(animals)} silhouettes but expected {len(orders)}.")

    for i, animal in enumerate(animals):
        if i >= len(orders):
            break
        order = orders[i]
        c = animal['contour']
        x, y, w, h = animal['box']
        
        output_file = os.path.join(output_dir, f"{order.lower()}.svg")
        dwg = svgwrite.Drawing(output_file, size=('100', '100'))
        
        epsilon = 0.002 * cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, epsilon, True)
        
        scale = 80.0 / max(w, h)
        
        path_data = ""
        for pt in approx:
            px, py = pt[0]
            nx = (px - x) * scale + (100 - w * scale) / 2
            ny = (py - y) * scale + (100 - h * scale) / 2
            
            if path_data == "":
                path_data += f"M {nx:.1f},{ny:.1f} "
            else:
                path_data += f"L {nx:.1f},{ny:.1f} "
        path_data += "Z"
        
        dwg.add(dwg.path(d=path_data, fill='#333333'))
        dwg.save()

    print(f"Successfully generated {min(len(animals), len(orders))} SVGs in {output_dir}")
    return True

def main():
    # Load environment variables from .env file
    load_dotenv()
    
    parser = argparse.ArgumentParser(description="Generate SVG order icons from a composite silhouette image.")
    parser.add_argument(
        '--image', 
        type=str, 
        default=os.environ.get('SOURCE_IMAGE_PATH'),
        help='Path to the input image (can also be set via SOURCE_IMAGE_PATH in .env)'
    )
    parser.add_argument(
        '--output', 
        type=str, 
        default=os.environ.get('OUTPUT_DIR', '../../assets/order-icons'),
        help='Directory to output the SVGs (can also be set via OUTPUT_DIR in .env)'
    )

    args = parser.parse_args()

    if not args.image:
        print("Error: Input image path must be provided either via --image or SOURCE_IMAGE_PATH in .env")
        parser.print_help()
        exit(1)

    # Ensure output dir is relative to where script is run, or absolute
    # If it's relative, it's relative to the current working directory.
    generate_svgs(args.image, args.output)

if __name__ == '__main__':
    main()
