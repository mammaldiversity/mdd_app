import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import cv2
import numpy as np
import pytest
import shutil
from main import generate_svgs

@pytest.fixture
def dummy_data(tmp_path):
    img_path = str(tmp_path / "test_img.png")
    out_dir = str(tmp_path / "output")
    
    # Create a dummy image with a white square (which will become a contour)
    img = np.full((100, 100), 255, dtype=np.uint8)  # White background
    cv2.rectangle(img, (20, 20), (80, 80), 0, -1)  # Black square
    
    # findContours in main.py uses cv2.THRESH_BINARY_INV with 200 threshold
    # So black (0) becomes 255 (white), white (255) becomes 0.
    # A single black square on white background will yield one large contour.
    cv2.imwrite(img_path, img)
    
    return img_path, out_dir

def test_generate_svgs(dummy_data):
    img_path, out_dir = dummy_data
    
    # Run the generator
    success = generate_svgs(img_path, out_dir)
    assert success is True
    
    # We expect 1 SVG to be generated because there is 1 contour
    # The first order is "Afrosoricida"
    expected_file = os.path.join(out_dir, "afrosoricida.svg")
    assert os.path.exists(expected_file)
    
    # Check the file content
    with open(expected_file, 'r') as f:
        content = f.read()
        assert "<svg" in content
        assert "path d=" in content

def test_generate_svgs_invalid_path(tmp_path):
    out_dir = str(tmp_path / "output")
    success = generate_svgs("non_existent_file.png", out_dir)
    assert success is False
