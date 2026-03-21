from PIL import Image, ImageDraw, ImageFont
import math
import random

# Create a high-res canvas
width, height = 1200, 1600
img = Image.new('RGB', (width, height), (5, 8, 20))
draw = ImageDraw.Draw(img)

# Try to load a modern font, fallback to default
try:
    title_font = ImageFont.truetype('segoeui.ttf', 48)
    subtitle_font = ImageFont.truetype('segoeui.ttf', 20)
    header_font = ImageFont.truetype('seguisb.ttf', 28)
    text_font = ImageFont.truetype('segoeui.ttf', 18)
    small_font = ImageFont.truetype('segoeui.ttf', 14)
except:
    title_font = ImageFont.load_default()
    subtitle_font = ImageFont.load_default()
    header_font = ImageFont.load_default()
    text_font = ImageFont.load_default()
    small_font = ImageFont.load_default()

# Color palette - cyber blue/purple/orange
cyan = (0, 200, 255)
purple = (180, 100, 255)
orange = (255, 150, 50)
pink = (255, 100, 180)
blue = (50, 150, 255)
green = (100, 255, 150)
red = (255, 80, 80)

def draw_glow_circle(x, y, r, color, intensity=3):
    """Draw a glowing circle"""
    for i in range(intensity, 0, -1):
        alpha = int(255 * (i / intensity) * 0.3)
        glow_color = tuple([int(c * 0.7) for c in color])
        draw.ellipse([x-r-i*3, y-r-i*3, x+r+i*3, y+r+i*3],
                     outline=glow_color, width=2)
    draw.ellipse([x-r, y-r, x+r, y+r], outline=color, width=3)

def draw_box(x, y, w, h, color, title, items):
    """Draw a stylized box with title and items"""
    # Outer glow
    draw.rectangle([x-2, y-2, x+w+2, y+h+2], outline=color, width=1)
    # Main box
    draw.rectangle([x, y, x+w, y+h], outline=color, width=2)
    # Title bar
    draw.rectangle([x, y, x+w, y+35], fill=tuple([int(c*0.2) for c in color]))
    draw.text((x+10, y+8), title, fill=color, font=header_font)
    # Items
    for i, item in enumerate(items):
        draw.text((x+15, y+45+i*25), f'• {item}', fill=(200, 220, 255), font=text_font)

def draw_arrow(x1, y1, x2, y2, color):
    """Draw an arrow"""
    draw.line([x1, y1, x2, y2], fill=color, width=3)
    # Arrowhead
    angle = math.atan2(y2-y1, x2-x1)
    arrow_len = 15
    angle1 = angle + math.pi * 0.8
    angle2 = angle - math.pi * 0.8
    draw.line([x2, y2, x2 + arrow_len*math.cos(angle1), y2 + arrow_len*math.sin(angle1)], fill=color, width=3)
    draw.line([x2, y2, x2 + arrow_len*math.cos(angle2), y2 + arrow_len*math.sin(angle2)], fill=color, width=3)

# Background stars
random.seed(42)
for _ in range(200):
    x, y = random.randint(0, width), random.randint(0, height)
    size = random.randint(1, 3)
    brightness = random.randint(100, 255)
    draw.ellipse([x, y, x+size, y+size], fill=(brightness, brightness, 255))

# TITLE
draw.text((width//2-200, 30), 'JENGO AI', fill=cyan, font=title_font)
draw.text((width//2-280, 85), 'Self-Evolving Autonomous Intelligence', fill=purple, font=subtitle_font)

# CORE - SCP 3 RINGS (center)
center_x, center_y = width//2, 280
ring_colors = [red, orange, green]
ring_labels = ['RING 1: RESOURCE', 'RING 2: CONFIDENCE', 'RING 3: EMERGENCE']
for i, (color, label) in enumerate(zip(ring_colors, ring_labels)):
    r = 80 - i*20
    draw_glow_circle(center_x, center_y, r, color, intensity=4)
    if i == 0:
        # Inner core label
        draw.text((center_x-30, center_y-10), 'SCP', fill=cyan, font=header_font)
        draw.text((center_x-35, center_y+10), 'CORE', fill=cyan, font=text_font)

# Ring labels
draw.text((center_x-180, center_y-120), 'R1: Resource', fill=red, font=small_font)
draw.text((center_x-180, center_y-100), 'Anti-Loop', fill=(255, 180, 180), font=small_font)
draw.text((center_x+80, center_y-120), 'R2: Confidence', fill=orange, font=small_font)
draw.text((center_x+80, center_y-100), 'Anti-Hallucination', fill=(255, 200, 150), font=small_font)
draw.text((center_x-50, center_y+120), 'R3: Emergence', fill=green, font=small_font)

# GDIO LAYERS (left side)
gdio_x, gdio_y = 80, 450
draw_box(gdio_x, gdio_y, 280, 180, blue, 'GDIO LAYERS',
         ['L1: Frozen Values', 'L2: Trainable Keys', 'L3: Expandable MLP', 'Orthogonal Isolation'])
draw_arrow(gdio_x+280, gdio_y+90, center_x-90, center_y+50, blue)

# KAIZEN ENGINE (right side)
kaizen_x, kaizen_y = width-360, 450
draw_box(kaizen_x, kaizen_y, 280, 180, purple, 'KAIZEN ENGINE',
         ['Signal Classification', 'Pattern Detection', '3+ Instance Rule', 'Safety Gates'])
draw_arrow(kaizen_x, kaizen_y+90, center_x+90, center_y+50, purple)

# EXPERT MASTERMIND (top left)
expert_x, expert_y = 60, 160
draw_box(expert_x, expert_y, 260, 110, pink, 'EXPERT ANALYSIS',
         ['9 Legendary Minds', '100 Domain Experts', '50 Universes'])
draw_arrow(expert_x+130, expert_y+110, center_x-50, center_y-80, pink)

# ATHENA'S TEMPLES (top right)
temple_x, temple_y = width-320, 160
draw_box(temple_x, temple_y, 260, 110, orange, "ATHENA'S TEMPLES",
         ['Prevented Disasters', 'Pattern Evolution', 'Unasked Questions'])
draw_arrow(temple_x+130, temple_y+110, center_x+50, center_y-80, orange)

# OUROBOROS LOOP (bottom center - the snake eating its tail)
ouroboros_y = 680
draw.text((width//2-150, ouroboros_y), 'OUROBOROS LOOP', fill=cyan, font=header_font)
draw.text((width//2-180, ouroboros_y+30), 'Self-Perpetuating Evolution', fill=(150, 200, 255), font=text_font)

# Draw circular ouroboros
oro_center_x, oro_center_y = width//2, ouroboros_y+100
oro_radius = 100
for angle in range(0, 360, 5):
    rad1 = math.radians(angle)
    rad2 = math.radians(angle + 5)
    x1 = oro_center_x + oro_radius * math.cos(rad1)
    y1 = oro_center_y + oro_radius * math.sin(rad1)
    x2 = oro_center_x + oro_radius * math.cos(rad2)
    y2 = oro_center_y + oro_radius * math.sin(rad2)
    # Color gradient
    color_val = int(128 + 127 * math.sin(math.radians(angle * 2)))
    draw.line([x1, y1, x2, y2], fill=(color_val, 200, 255), width=4)

# Ouroboros components
oro_items = ['Kaizen', 'Autoresearch', 'Expert Analysis', 'Retrospective']
for i, item in enumerate(oro_items):
    angle = i * 90
    rad = math.radians(angle)
    x = oro_center_x + (oro_radius + 30) * math.cos(rad)
    y = oro_center_y + (oro_radius + 30) * math.sin(rad)
    draw.text((x-30, y-10), item, fill=(200, 220, 255), font=small_font)

# IMPLEMENTATION LAYER (bottom)
impl_y = 900
draw.text((width//2-180, impl_y), 'IMPLEMENTATION LAYER', fill=cyan, font=header_font)

# Three implementation boxes
impl_boxes = [
    ('WORKFLOW', ['ClickUp Engine', 'Refinement', 'Task Execution']),
    ('CODE', ['Worktree Mgmt', 'Git Automation', 'PR Creation']),
    ('DEPLOY', ['IIS Pipeline', 'Health Checks', 'Verification'])
]
box_width = 260
spacing = (width - 3*box_width) // 4
for i, (title, items) in enumerate(impl_boxes):
    x = spacing + i * (box_width + spacing)
    draw_box(x, impl_y+40, box_width, 130, green, title, items)

# OUTPUT (bottom)
output_y = 1120
draw.text((width//2-140, output_y), 'VALIDATED OUTPUT', fill=cyan, font=header_font)

# Output flow
output_items = ['Code + PRs', 'Documentation', 'Learning', 'Evolution']
item_width = 200
total_width = len(output_items) * item_width
start_x = (width - total_width) // 2
for i, item in enumerate(output_items):
    x = start_x + i * item_width
    y = output_y + 50
    draw.rectangle([x, y, x+180, y+60], outline=cyan, width=2)
    draw.text((x+30, y+25), item, fill=(200, 255, 255), font=text_font)

# INPUT (very top)
input_y = 1280
draw.text((width//2-120, input_y), 'INPUT STREAMS', fill=purple, font=header_font)
input_items = ['User Request', 'Memory', 'Context', 'Patterns']
start_x = (width - len(input_items) * 200) // 2
for i, item in enumerate(input_items):
    x = start_x + i * 200
    draw.ellipse([x, input_y+30, x+150, input_y+80], outline=purple, width=2)
    draw.text((x+30, y+50), item, fill=(220, 180, 255), font=text_font)

# Central flow arrows
draw_arrow(width//2, output_y+110, width//2, input_y+30, (100, 150, 255))

# Signature
draw.text((width//2-200, height-40), '343,890x Better Than Components Alone',
          fill=(120, 160, 255), font=small_font)
draw.text((width//2-180, height-20), 'The Snake Eating Its Tail → Infinite Improvement',
          fill=(150, 150, 150), font=small_font)

# Save
output_path = 'C:/scripts/agentidentity/jengo-architecture-visualization.png'
img.save(output_path)
print(f'Saved to: {output_path}')
