#!/usr/bin/env python3
"""
Generate 12 professional editorial-style featured images for "The Narcissism Pandemic" blog series.
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
OUTPUT_DIR = Path(r"C:\scripts\_projects\polarization-analysis\blog-posts\images")

# Image specifications
IMAGE_SIZE = "1792x1024"  # Landscape format for WordPress featured images
IMAGE_QUALITY = "hd"
IMAGE_STYLE = "natural"  # Professional editorial style

# Image prompts for each blog post
IMAGES = [
    {
        "filename": "01-youre-not-crazy-the-system-is.png",
        "prompt": "Professional editorial image showing societal chaos and confusion, distorted reality with fractured mirrors and warped perspectives, people looking disoriented in a surreal urban environment, dramatic lighting with dark blues and deep oranges, photorealistic style, serious journalistic tone, symbolizing questioning reality and systemic dysfunction"
    },
    {
        "filename": "02-the-narcissism-you-cant-see.png",
        "prompt": "Professional editorial image of a person looking at their reflection in a mirror, surrounded by fragmented mirror pieces showing different versions of themselves, themes of self-absorption and blind spots, narcissistic self-focus, dark atmospheric lighting with blue and orange tones, photorealistic style, psychological depth, editorial photography quality"
    },
    {
        "filename": "03-how-social-media-gave-us-npd.png",
        "prompt": "Professional editorial image showing people zombified by their phones, glowing screens illuminating faces in darkness, algorithm manipulation visualized as puppet strings or digital tendrils controlling users, social media addiction concept, dystopian atmosphere with dramatic blue and orange lighting, photorealistic style, serious journalistic tone about technology addiction"
    },
    {
        "filename": "04-the-eight-feedback-loops.png",
        "prompt": "Professional editorial illustration showing eight interconnected circular feedback loops spiraling downward, destroying society, abstract representation of cascading system failures, dark blues and fiery oranges, dramatic lighting suggesting entropy and collapse, sophisticated graphic design style, editorial quality, symbolizing destructive cycles and reinforcing patterns"
    },
    {
        "filename": "05-why-fact-checking-failed.png",
        "prompt": "Professional editorial image of broken fact-checking systems, crumbling truth meters and shattered verification badges, misinformation spreading like wildfire through digital networks, newspapers and screens showing conflicting information, dark atmosphere with dramatic lighting in blues and oranges, photorealistic style, editorial photography depicting the failure of truth verification systems"
    },
    {
        "filename": "06-the-three-layer-solution.png",
        "prompt": "Professional editorial illustration showing three distinct architectural layers stacked vertically, representing a three-tiered solution framework, clean sophisticated design with connecting elements between layers, themes of healing and systematic reconstruction, dark blue and orange color palette, modern infographic style with editorial quality, symbolizing structured approach to solving complex problems"
    },
    {
        "filename": "07-the-algorithm-war.png",
        "prompt": "Professional editorial image depicting digital warfare and algorithm battles, technological conflict visualization with data streams clashing, neural networks in combat, cyberpunk aesthetic with dramatic blue and orange lighting, photorealistic style mixed with digital effects, serious editorial tone about the fight for control of information systems and AI"
    },
    {
        "filename": "08-the-regulatory-blitz.png",
        "prompt": "Professional editorial image showing government regulation coming down on Big Tech, massive policy hammer or gavel striking digital platforms, corporate tech buildings under regulatory scrutiny, law books and legal documents surrounding technology symbols, authoritative atmosphere with dark blues and oranges, photorealistic editorial style depicting governmental power and regulatory action"
    },
    {
        "filename": "09-the-narrative-offensive.png",
        "prompt": "Professional editorial image of communication revolution and storytelling power, megaphones and voices breaking through noise, narrative waves spreading across society, powerful messaging symbols, books and words transforming reality, dramatic lighting with blues and oranges, photorealistic editorial style showing the force of counter-narratives and strategic communication"
    },
    {
        "filename": "10-the-app-that-deprograms-you.png",
        "prompt": "Professional editorial image of a healing technology app interface, smartphone displaying deprogramming software, mental clarity visualization, chains breaking from minds, users emerging from manipulation fog, hopeful yet serious tone, blue and orange atmospheric lighting, photorealistic editorial style showing redemptive technology and psychological liberation"
    },
    {
        "filename": "11-the-implementation-blueprint.png",
        "prompt": "Professional editorial illustration of strategic planning and coordination blueprint, architectural plans and flowcharts, interconnected systems working together, command center visualization, organized complexity, professional business aesthetic with dark blue and orange tones, sophisticated infographic style, editorial quality depicting systematic implementation and project management"
    },
    {
        "filename": "12-the-two-futures.png",
        "prompt": "Professional editorial image showing a dramatic fork in the road leading to two divergent futures in 2030, one path leading to dystopian darkness and chaos, the other to hopeful restoration and healing, split-screen contrast visualization, people at the crossroads making choice, powerful symbolic imagery with blue and orange lighting, photorealistic editorial style depicting critical decision point and diverging timelines"
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
    """Generate all 12 blog images."""
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Generating 12 editorial images for 'The Narcissism Pandemic' blog series")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"Image size: {IMAGE_SIZE} (landscape, HD quality)")
    print(f"Style: Professional editorial, photorealistic")

    success_count = 0
    failed = []

    for i, img_spec in enumerate(IMAGES, 1):
        output_path = OUTPUT_DIR / img_spec["filename"]

        if output_path.exists():
            print(f"\n[{i}/12] Skipping (already exists): {img_spec['filename']}")
            success_count += 1
            continue

        print(f"\n[{i}/12] Generating image...")

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
        print("\n[SUCCESS] All images generated successfully!")
        print(f"\nImages saved to: {OUTPUT_DIR}")
        sys.exit(0)


if __name__ == "__main__":
    main()
