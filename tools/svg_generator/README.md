# SVG Generator

A Python-based command-line tool designed to extract individual animal silhouettes from a single composite image grid and convert them into scalable SVG icons.

## Prerequisites

- [Python 3.12+](https://www.python.org/)
- [uv](https://github.com/astral-sh/uv) (Extremely fast Python package installer and resolver)

## Installation

This tool uses `uv` to manage its dependencies (`opencv-python`, `numpy`, `svgwrite`, `python-dotenv`, `pytest`) cleanly.

1. Navigate to the `svg_generator` directory:
   ```bash
   cd tools/svg_generator
   ```

2. (Optional but recommended) Sync the environment to ensure all packages are installed:
   ```bash
   uv sync
   ```

## Configuration

Before running the tool, you should configure your environment variables. 

Copy the example environment file:
```bash
cp .env.example .env
```

Open `.env` and set the path to your source image:
```env
SOURCE_IMAGE_PATH=/absolute/path/to/your/composite_silhouettes.png
OUTPUT_DIR=../../assets/order-icons
```
*Note: Do not commit the `.env` file to version control, as it may contain paths specific to your local machine.*

## Usage

You can run the script entirely through `uv` without needing to manually activate virtual environments:

### Using the `.env` file
```bash
uv run main.py
```
*This will automatically pull the `SOURCE_IMAGE_PATH` and `OUTPUT_DIR` from your `.env`.*

### Overriding paths via CLI flags
You can dynamically override the configuration using command-line arguments:
```bash
uv run main.py --image /path/to/another_image.png --output ./test_output
```

## Testing

The tool includes an automated test suite utilizing `pytest`. 
To run the tests:
```bash
uv run pytest
```
*The test suite automatically generates a dummy silhouette using OpenCV to verify the core conversion logic and SVG exporting process, ensuring it runs reliably on CI/CD pipelines.*
