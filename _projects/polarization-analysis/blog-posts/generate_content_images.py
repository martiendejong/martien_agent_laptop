#!/usr/bin/env python3
"""
Generate 8 concept images for inline use in "The Narcissism Pandemic" blog series.
These are smaller, editorial infographic-style images for floating in content.
"""

import os
import sys
import requests
import time
from pathlib import Path

# OpenAI API configuration
OPENAI_API_KEY = "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"
API_ENDPOINT = "https://api.openai.com/v1/images/generations"

# Output directory
OUTPUT_DIR = Path(r"C:\scripts\_projects\polarization-analysis\blog-posts\images\content")

# Image specifications (800x600 equivalent = 1024x1024 for DALL-E 3)
IMAGE_SIZE = "1024x1024"  # Will be suitable for 800x600 display
IMAGE_QUALITY = "standard"  # Standard quality for content images
IMAGE_STYLE = "natural"

# Image prompts for inline concept images
IMAGES = [
    {
        "filename": "social-media-feedback-loop.png",
        "prompt": "Clean editorial infographic showing social media feedback loop addiction cycle. Circular diagram with smartphone at center, arrows showing: notification -> dopamine hit -> scroll -> like -> validation -> craving -> notification. Simple icons, dark navy blue and orange accent colors, white background, minimal style, clear labels, professional infographic design"
    },
    {
        "filename": "tribal-brain.png",
        "prompt": "Editorial infographic showing human cognitive bias. Brain diagram split vertically down the middle with abstract division line. Left hemisphere in warm orange gradient, right hemisphere in cool blue gradient. Simple geometric shapes representing ingroup vs outgroup thinking patterns. Clean minimalist medical illustration style, white background, professional psychology textbook aesthetic, no text labels needed"
    },
    {
        "filename": "algorithm-manipulation.png",
        "prompt": "Editorial illustration showing algorithm manipulation. Person sitting with smartphone, puppet strings from above controlling their scrolling hand. Strings lead to shadowy algorithm represented by abstract code/circuits above. Dark navy blue background, orange accent on phone screen, clean minimalist style, editorial infographic design"
    },
    {
        "filename": "bridging-conversation.png",
        "prompt": "Clean editorial illustration of bridging conversation. Two people sitting across from each other at table, one with blue political symbol, one with orange political symbol. Speech bubbles overlap in middle showing connection. Calm, respectful body language. Soft lighting, hope-filled atmosphere, minimal style, simple warm background, professional editorial illustration"
    },
    {
        "filename": "wellbeing-vs-engagement.png",
        "prompt": "Split screen comparison infographic. LEFT: 'Healthy Social Feed' showing diverse content, nature photos, learning, human connections, calm colors. RIGHT: 'Toxic Social Feed' showing rage bait, clickbait headlines, conflict, harsh red/orange warning colors. Clear vertical divide, editorial infographic style, clean layout, professional design"
    },
    {
        "filename": "depolarization-progress.png",
        "prompt": "Editorial infographic showing depolarization progress graph. Line chart with downward trend from left to right. Y-axis labeled 'Polarization Level', X-axis showing timeline. Starting high in orange/red zone, declining into green 'healthy discourse' zone. Clean data visualization style, white background, hopeful colors, professional business chart aesthetic"
    },
    {
        "filename": "collective-narcissism.png",
        "prompt": "Editorial illustration of collective narcissism. Group of 6-7 people standing in circle, each holding up mirror and looking at their own reflection instead of each other. Disconnected despite proximity. Dark navy blue background, orange-tinted mirrors, minimalist style showing isolation within groups, clean editorial illustration"
    },
    {
        "filename": "platform-accountability.png",
        "prompt": "Editorial infographic of platform accountability. Classic scales of justice in center. LEFT side: Big Tech logos and money symbols weighing down. RIGHT side: user wellbeing symbols (mental health icons, real connections, truth) rising up but lighter. Need for rebalancing clear. Clean, professional style, dark blue and orange colors, white background, editorial infographic design"
    }
]


def generate_image(prompt, output_path):
    """Generate a single image using OpenAI DALL-E API."""
    print(f"\nGenerating: {output_path.name}")
    print(f"Prompt: {prompt[:80]}...")

    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": IMAGE_SIZE,
        "quality": IMAGE_QUALITY,
        "style": IMAGE_STYLE
    }

    try:
        response = requests.post(API_ENDPOINT, json=payload, headers=headers)
        response.raise_for_status()

        result = response.json()
        image_url = result["data"][0]["url"]

        # Download the image
        image_response = requests.get(image_url)
        image_response.raise_for_status()

        # Save to file
        with open(output_path, "wb") as f:
            f.write(image_response.content)

        print(f"[OK] Saved: {output_path}")
        return True

    except requests.exceptions.RequestException as e:
        print(f"[ERROR] {e}")
        if hasattr(e.response, 'text'):
            print(f"Response: {e.response.text}")
        return False


def main():
    """Generate all 8 concept images."""
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Generating 8 concept images for inline use in 'The Narcissism Pandemic' blog series")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"Image size: {IMAGE_SIZE} (suitable for 800x600 display)")
    print(f"Style: Editorial infographics, clean and minimal")

    success_count = 0
    failed = []

    for i, img_spec in enumerate(IMAGES, 1):
        output_path = OUTPUT_DIR / img_spec["filename"]

        if output_path.exists():
            print(f"\n[{i}/8] Skipping (already exists): {img_spec['filename']}")
            success_count += 1
            continue

        print(f"\n[{i}/8] Generating image...")

        if generate_image(img_spec["prompt"], output_path):
            success_count += 1
        else:
            failed.append(img_spec["filename"])

        # Rate limiting: Wait between requests
        if i < len(IMAGES):
            time.sleep(2)

    # Summary
    print("\n" + "="*70)
    print(f"Generation complete: {success_count}/{len(IMAGES)} successful")

    if failed:
        print(f"\nFailed images:")
        for filename in failed:
            print(f"  - {filename}")
        sys.exit(1)
    else:
        print("\n[SUCCESS] All concept images generated successfully!")
        print(f"\nImages saved to: {OUTPUT_DIR}")
        sys.exit(0)


if __name__ == "__main__":
    main()
