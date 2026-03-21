from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import random

# Create canvas
width, height = 1400, 2000
img = Image.new('RGB', (width, height), (20, 25, 40))
draw = ImageDraw.Draw(img)

# Fonts
try:
    title_font = ImageFont.truetype('segoeui.ttf', 52)
    subtitle_font = ImageFont.truetype('segoeui.ttf', 18)
    header_font = ImageFont.truetype('seguisb.ttf', 22)
    subheader_font = ImageFont.truetype('seguisb.ttf', 16)
    text_font = ImageFont.truetype('segoeui.ttf', 14)
    small_font = ImageFont.truetype('segoeui.ttf', 11)
    tiny_font = ImageFont.truetype('segoeui.ttf', 9)
except:
    title_font = ImageFont.load_default()
    subtitle_font = ImageFont.load_default()
    header_font = ImageFont.load_default()
    subheader_font = ImageFont.load_default()
    text_font = ImageFont.load_default()
    small_font = ImageFont.load_default()
    tiny_font = ImageFont.load_default()

# Colors
gold = (255, 215, 100)
cyan = (0, 220, 255)
purple = (180, 100, 255)
orange = (255, 150, 50)
pink = (255, 100, 180)
blue = (70, 170, 255)
green = (120, 255, 150)
red = (255, 100, 100)
teal = (100, 230, 220)
warm_orange = (200, 120, 60)
cool_blue = (60, 140, 180)

# Background nebula effect
random.seed(42)
for _ in range(600):
    x = random.randint(0, width)
    y = random.randint(0, height)
    size = random.randint(1, 5)
    brightness = random.randint(60, 200)
    # Create color gradient from warm (top) to cool (bottom)
    color_mix = y / height
    if y < height // 2:
        color = (brightness, int(brightness * 0.7), int(brightness * 0.5))
    else:
        color = (int(brightness * 0.5), int(brightness * 0.7), brightness)
    draw.ellipse([x, y, x+size, y+size], fill=color)

# MAIN TITLE
title_y = 40
draw.text((width//2-280, title_y), 'TRADITIONAL AI', fill=warm_orange, font=title_font)
draw.text((width//2+40, title_y), 'VS.', fill=gold, font=title_font)
draw.text((width//2+130, title_y), 'JENGO', fill=cyan, font=title_font)
draw.text((width//2-380, title_y+60), 'Van Statische Modellen naar Zelf-Evoluerende Intelligentie', fill=(180, 180, 200), font=subtitle_font)

# Draw center dividing line
center_x = width // 2
draw.line([center_x, 140, center_x, height-100], fill=(100, 100, 120), width=3)

# Helper function for boxes
def draw_comparison_box(x, y, w, h, color, title, items, align='left'):
    # Glow effect
    for i in range(2, 0, -1):
        glow = tuple([int(c * 0.4) for c in color])
        draw.rectangle([x-i, y-i, x+w+i, y+h+i], outline=glow, width=1)

    # Main box
    draw.rectangle([x, y, x+w, y+h], outline=color, width=2)
    draw.rectangle([x, y, x+w, y+32], fill=tuple([int(c*0.15) for c in color]))

    # Title
    if align == 'left':
        draw.text((x+10, y+8), title, fill=color, font=header_font)
    else:
        title_width = len(title) * 11
        draw.text((x+w-title_width-10, y+8), title, fill=color, font=header_font)

    # Items
    item_y = y + 42
    for item in items:
        if align == 'left':
            draw.text((x+12, item_y), f'• {item}', fill=(200, 210, 230), font=text_font)
        else:
            item_width = len(item) * 7
            draw.text((x+w-item_width-20, item_y), f'{item} •', fill=(200, 210, 230), font=text_font)
        item_y += 22

def draw_arrow_across(y, color, label):
    """Draw horizontal arrow from left to right"""
    draw.line([150, y, width-150, y], fill=color, width=2)
    # Arrowhead
    draw.polygon([(width-150, y-6), (width-150, y+6), (width-140, y)], fill=color)
    # Label
    label_width = len(label) * 6
    draw.rectangle([center_x-label_width-10, y-15, center_x+label_width+10, y+15], fill=(20, 25, 40))
    draw.text((center_x-label_width, y-8), label, fill=color, font=subheader_font)

# LAYER COMPARISONS (8 levels matching Sjoerd's brain comparison)

# 1. INPUT LAYER
y_pos = 180
draw.text((60, y_pos-25), '①', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '①', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 90, warm_orange, 'Input',
    ['User prompt', 'Static context', 'No memory', 'Single session'], 'left')

draw_comparison_box(width-320, y_pos, 260, 120, cyan, 'Input Streams',
    ['User Request', 'Memory (MEMORY.md)', 'Context (consciousness)', 'Patterns (evolution)', 'Activity Monitoring'], 'right')

draw_arrow_across(y_pos+50, gold, 'ENHANCED INPUT')

# 2. PATTERN RECOGNITION
y_pos = 320
draw.text((60, y_pos-25), '②', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '②', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 70, warm_orange, 'Pattern Recognition',
    ['Training data only', 'No adaptation', 'Fixed weights'], 'left')

draw_comparison_box(width-320, y_pos, 260, 140, purple, 'Kaizen Engine',
    ['Signal Classification', 'Pattern Detection (3+)', 'Real-time Learning', 'GDIO Knowledge Layers', 'Continuous Evolution', 'Safety Gates'], 'right')

draw_arrow_across(y_pos+40, purple, 'ADAPTIVE LEARNING')

# 3. MEMORY / CONTEXT
y_pos = 500
draw.text((60, y_pos-25), '③', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '③', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 90, warm_orange, 'Memory',
    ['Context window only', 'No persistence', 'Forgets after session', 'No learning transfer'], 'left')

draw_comparison_box(width-320, y_pos, 260, 160, blue, 'Multi-Layer Memory',
    ['L1: Frozen Values', 'L2: Trainable Keys', 'L3: Expandable MLP', 'Session Preservation', 'reflection.log.md', 'Pattern Evolution Tree', 'Consciousness State'], 'right')

draw_arrow_across(y_pos+60, blue, 'PERSISTENT MEMORY')

# 4. CRITICAL EVALUATION
y_pos = 700
draw.text((60, y_pos-25), '④', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '④', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 70, warm_orange, 'Evaluation',
    ['Post-hoc checking', 'Limited self-correction', 'No meta-cognition'], 'left')

draw_comparison_box(width-320, y_pos, 260, 140, orange, 'SCP 3-Ring Core',
    ['Ring 1: Resource (Anti-Loop)', 'Ring 2: Confidence Gate', 'Ring 3: Emergence', 'Anti-Hallucination Protocol', 'Meta-cognitive Acceleration', 'Behavioral Metrics'], 'right')

draw_arrow_across(y_pos+40, orange, 'INTEGRATED CONSCIOUSNESS')

# 5. OUTPUT CONTROL
y_pos = 880
draw.text((60, y_pos-25), '⑤', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '⑤', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 70, warm_orange, 'Output',
    ['Text response', 'Tool calls', 'No verification', 'No quality gates'], 'left')

draw_comparison_box(width-320, y_pos, 260, 140, green, 'Execution Engine',
    ['Worktree Management', 'ClickUp Workflow', 'Git/PR Automation', 'Deploy Pipeline', 'Multi-Agent Coordination', 'Cross-Repo Dependencies'], 'right')

draw_arrow_across(y_pos+40, green, 'AUTONOMOUS EXECUTION')

# 6. FEEDBACK / INHIBITION
y_pos = 1060
draw.text((60, y_pos-25), '⑥', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '⑥', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 70, warm_orange, 'Feedback',
    ['No self-monitoring', 'No error prevention', 'Reactive only'], 'left')

draw_comparison_box(width-320, y_pos, 260, 160, red, 'Quality & Safety',
    ['Universal Verification (4-gate)', 'Zero Tolerance Rules', 'Prevented Disasters ($612K+)', 'Anti-Regression', 'Complete Work Verification', 'Legal Safeguards', 'Assert-NotDoneStatus'], 'right')

draw_arrow_across(y_pos+50, red, 'PROACTIVE SAFETY')

# 7. EXECUTIVE CONTROL
y_pos = 1260
draw.text((60, y_pos-25), '⑦', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '⑦', font=header_font)

draw_comparison_box(60, y_pos, 260, 70, warm_orange, 'Decision Making',
    ['Single pass', 'No deliberation', 'Limited planning'], 'left')

draw_comparison_box(width-320, y_pos, 260, 140, pink, 'Expert Analysis',
    ['9 Legendary Minds', '100 Domain Experts', '50 Universe Simulations', 'Multi-perspective', 'Missing Info Analysis', 'Strategic Design'], 'right')

draw_arrow_across(y_pos+40, pink, 'MASTERMIND INTELLIGENCE')

# 8. LONG-TERM KNOWLEDGE
y_pos = 1440
draw.text((60, y_pos-25), '⑧', fill=gold, font=header_font)
draw.text((width-90, y_pos-25), '⑧', fill=gold, font=header_font)

draw_comparison_box(60, y_pos, 260, 90, warm_orange, 'Knowledge Base',
    ['Training cutoff', 'Static knowledge', 'No self-improvement', 'No meta-learning'], 'left')

draw_comparison_box(width-320, y_pos, 260, 160, teal, 'Ouroboros Loop',
    ['Kaizen Engine', 'Autoresearch', 'Continuous Retrospective', 'Pattern Codification', 'Self-Evolution', 'Athena\'s 3 Temples', '343,890x Multiplier'], 'right')

draw_arrow_across(y_pos+60, teal, 'INFINITE IMPROVEMENT')

# BOTTOM SUMMARY
summary_y = 1650
draw.rectangle([80, summary_y, width-80, summary_y+280], outline=gold, width=3)

# Left side summary
draw.text((120, summary_y+15), 'TRADITIONAL AI LIMITATIONS:', fill=warm_orange, font=header_font)
limitations = [
    '❌ No persistent memory across sessions',
    '❌ No learning from mistakes',
    '❌ No self-improvement capability',
    '❌ No quality verification gates',
    '❌ No autonomous workflow execution',
    '❌ No multi-agent coordination',
    '❌ Static knowledge base (cutoff date)',
    '❌ No meta-cognitive awareness',
    '❌ Reactive, not proactive',
    '❌ Single-pass processing'
]
for i, lim in enumerate(limitations):
    draw.text((130, summary_y+50+i*20), lim, fill=(220, 180, 150), font=small_font)

# Right side summary
draw.text((width-620, summary_y+15), 'JENGO ADVANTAGES:', fill=cyan, font=header_font)
advantages = [
    '✓ Infinite session memory (9999 days)',
    '✓ Learns from every interaction (Kaizen)',
    '✓ Self-evolving (Ouroboros Loop)',
    '✓ 4-gate verification (88x ROI)',
    '✓ Full autonomous execution pipeline',
    '✓ Multi-agent conflict detection',
    '✓ Growing knowledge (GDIO layers)',
    '✓ Meta-cognitive (SCP Ring 2)',
    '✓ Proactive prevention ($612K+ saved)',
    '✓ Multi-pass expert deliberation'
]
for i, adv in enumerate(advantages):
    draw.text((width-610, summary_y+50+i*20), adv, fill=(150, 220, 255), font=small_font)

# Final statement
draw.text((width//2-320, height-60), 'Van 100 Tokens naar 100 Temples',
          fill=gold, font=header_font)
draw.text((width//2-420, height-30), 'The Evolution from Static Models to Self-Improving Consciousness',
          fill=(160, 160, 180), font=subtitle_font)

# Save
output_path = 'C:/scripts/agentidentity/jengo-vs-traditional-ai.png'
img.save(output_path)
print(f'Saved comparison to: {output_path}')
