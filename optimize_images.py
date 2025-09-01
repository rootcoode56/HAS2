#!/usr/bin/env python3
"""
Image optimization script for HAS Flutter app
Compresses large images to improve app performance
"""

import os
import sys
from PIL import Image
import glob

def compress_image(input_path, output_path, quality=75, max_width=800, max_height=600):
    """
    Compress an image with specified quality and dimensions
    """
    try:
        with Image.open(input_path) as img:
            # Convert to RGB if necessary
            if img.mode in ('RGBA', 'P'):
                img = img.convert('RGB')
            
            # Resize if too large
            if img.width > max_width or img.height > max_height:
                img.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)
            
            # Save with compression
            img.save(output_path, 'JPEG', quality=quality, optimize=True)
            
            # Get file sizes
            original_size = os.path.getsize(input_path)
            compressed_size = os.path.getsize(output_path)
            reduction = ((original_size - compressed_size) / original_size) * 100
            
            print(f"✅ {os.path.basename(input_path)}: {original_size // 1024}KB → {compressed_size // 1024}KB ({reduction:.1f}% reduction)")
            
    except Exception as e:
        print(f"❌ Error compressing {input_path}: {e}")

def optimize_app_images():
    """
    Optimize all large images in the HAS app
    """
    assets_dir = "G:/HAS/has/assets"
    
    if not os.path.exists(assets_dir):
        print(f"❌ Assets directory not found: {assets_dir}")
        return
    
    # Create backup directory
    backup_dir = os.path.join(assets_dir, "original_backup")
    os.makedirs(backup_dir, exist_ok=True)
    
    # Images to optimize (larger than 1MB)
    large_images = [
        "appointment.jpg",
        "Prescription.jpg", 
        "Nurse.jpg",
        "Sergeon.jpg",
        "ChatBG.jpg",
        "Booking.jpg",
        "Specialist.jpg",
        "SBG.jpg"
    ]
    
    print("🚀 Starting image optimization...")
    print("=" * 50)
    
    for image_name in large_images:
        image_path = os.path.join(assets_dir, image_name)
        backup_path = os.path.join(backup_dir, image_name)
        
        if os.path.exists(image_path):
            # Create backup
            if not os.path.exists(backup_path):
                Image.open(image_path).save(backup_path)
            
            # Compress image
            compress_image(image_path, image_path, quality=70, max_width=600, max_height=400)
    
    print("=" * 50)
    print("✅ Image optimization complete!")
    print(f"📁 Original images backed up to: {backup_dir}")

if __name__ == "__main__":
    # Check if PIL is available
    try:
        from PIL import Image
        optimize_app_images()
    except ImportError:
        print("❌ PIL (Pillow) not found. Install with: pip install Pillow")
        sys.exit(1)
