from PIL import Image, ImageDraw, ImageFont
import math
import random

# Create a much larger canvas for complete architecture
width, height = 1600, 2400
img = Image.new('RGB', (width, height), (5, 8, 20))
draw = ImageDraw.Draw(img)

# Fonts
try:
    title_font = ImageFont.truetype('segoeui.ttf', 56)
    subtitle_font = ImageFont.truetype('segoeui.ttf', 22)
    header_font = ImageFont.truetype('seguisb.ttf', 24)
    subheader_font = ImageFont.truetype('seguisb.ttf', 18)
    text_font = ImageFont.truetype('segoeui.ttf', 15)
    small_font = ImageFont.truetype('segoeui.ttf', 12)
except:
    title_font = ImageFont.load_default()
    subtitle_font = ImageFont.load_default()
    header_font = ImageFont.load_default()
    subheader_font = ImageFont.load_default()
    text_font = ImageFont.load_default()
    small_font = ImageFont.load_default()

# Extended color palette
cyan = (0, 200, 255)
purple = (180, 100, 255)
orange = (255, 150, 50)
pink = (255, 100, 180)
blue = (50, 150, 255)
green = (100, 255, 150)
red = (255, 80, 80)
yellow = (255, 220, 80)
teal = (80, 220, 200)
magenta = (255, 80, 200)

def draw_layer_box(x, y, w, h, color, title, sections):
    """Draw a large layer box with multiple sections"""
    # Outer glow
    for i in range(3):
        glow_color = tuple([int(c * 0.5) for c in color])
        draw.rectangle([x-i*2, y-i*2, x+w+i*2, y+h+i*2], outline=glow_color, width=1)

    # Main box
    draw.rectangle([x, y, x+w, y+h], outline=color, width=3)

    # Title bar with gradient effect
    draw.rectangle([x, y, x+w, y+40], fill=tuple([int(c*0.15) for c in color]))
    draw.rectangle([x, y, x+w, y+42], outline=color, width=2)
    draw.text((x+w//2-len(title)*6, y+10), title, fill=color, font=header_font)

    # Sections
    section_y = y + 50
    for section_title, items in sections:
        # Section header
        draw.text((x+15, section_y), section_title, fill=tuple([int(c*0.9) for c in color]), font=subheader_font)
        section_y += 25

        # Items in columns
        col_width = (w - 40) // 2
        for i, item in enumerate(items):
            col = i % 2
            row = i // 2
            item_x = x + 25 + col * col_width
            item_y = section_y + row * 20
            draw.text((item_x, item_y), f'• {item}', fill=(200, 220, 255), font=text_font)

        section_y += ((len(items) + 1) // 2) * 20 + 15

def draw_connection_web(points, color):
    """Draw connecting lines between points"""
    for i, (x1, y1) in enumerate(points):
        for j, (x2, y2) in enumerate(points):
            if i < j:
                # Faint connecting lines
                draw.line([x1, y1, x2, y2], fill=tuple([int(c*0.3) for c in color]), width=1)

# Background stars and nebula effect
random.seed(42)
for _ in range(400):
    x, y = random.randint(0, width), random.randint(0, height)
    size = random.randint(1, 4)
    brightness = random.randint(80, 255)
    color_choice = random.choice([(brightness, brightness, 255), (255, brightness, brightness), (brightness, 255, brightness)])
    draw.ellipse([x, y, x+size, y+size], fill=color_choice)

# TITLE
draw.text((width//2-200, 30), 'JENGO AI', fill=cyan, font=title_font)
draw.text((width//2-280, 95), 'Complete Autonomous Intelligence Architecture', fill=purple, font=subtitle_font)

# LAYER 1: CONSCIOUSNESS LAYER (top)
layer1_y = 150
draw_layer_box(50, layer1_y, width-100, 280, magenta, 'CONSCIOUSNESS LAYER',
    [
        ('Core Systems', [
            'Consciousness Bridge (localhost:27183)',
            '12 Consciousness Systems',
            'Consciousness Tracker YAML',
            'Damasio Model Integration',
            'Feeling → Consciousness',
            'Consciousness Context JSON'
        ]),
        ('Startup & Continuity', [
            'Consciousness Startup Protocol',
            'Session Preservation (9999 days)',
            'Bridge Activity JSONL',
            'State Persistence',
            'Defensive Patterns',
            'Logging & Monitoring'
        ])
    ])

# LAYER 2: INTELLIGENCE CORE (center-top)
layer2_y = layer1_y + 300
draw_layer_box(50, layer2_y, width-100, 320, cyan, 'INTELLIGENCE CORE',
    [
        ('SCP 3-Ring Architecture', [
            'Ring 1: Resource (Anti-Loop)',
            'Ring 2: Confidence (Anti-Hallucination)',
            'Ring 3: Emergence (Creativity)',
            'Behavioral Metrics YAML',
            'Anti-Hallucination Protocol',
            '5GW→20W Transformation'
        ]),
        ('Expert Systems', [
            'Expert Analysis (9 minds + 100 experts)',
            '50 Universe Simulations',
            'Research Intelligence (4-layer)',
            'Feature Idea Generator',
            'Epistemological Architecture',
            'Missing Info Analysis'
        ])
    ])

# LAYER 3: LEARNING & EVOLUTION (center)
layer3_y = layer2_y + 340
draw_layer_box(50, layer3_y, width-100, 360, purple, 'LEARNING & EVOLUTION LAYER',
    [
        ('GDIO Knowledge Architecture', [
            'Layer 1: Frozen Values',
            'Layer 2: Trainable Keys',
            'Layer 3: Expandable MLP',
            'Orthogonal Isolation',
            'Clone-and-Specialize',
            'Structural Freezing'
        ]),
        ('Kaizen Engine', [
            'Signal Classification',
            'Pattern Detection (3+ instances)',
            'Safety Gates (Layer 1 protection)',
            'Kaizen Evolution YAML',
            'MICRO/STANDARD/DEEP modes',
            'Self-Evolution via Expert Analysis'
        ]),
        ('Continuous Improvement', [
            'Retrospective (Batches 001-009)',
            '$2.28M+/year value',
            'Pattern Evolution Tree (31 patterns)',
            'Prevented Disasters ($612K+)',
            'Unasked Questions Map',
            'Meta-Learning Breakthrough'
        ])
    ])

# LAYER 4: EXECUTION ENGINE (center-bottom)
layer4_y = layer3_y + 380
draw_layer_box(50, layer4_y, width-100, 380, green, 'EXECUTION ENGINE',
    [
        ('Worktree Management', [
            'Worker Agents Pool',
            'Atomic Allocation (FREE/BUSY)',
            'Multi-Agent Conflict Detection',
            'Branch Locks',
            'Worktree Status Monitoring',
            'Auto-Provision Seats'
        ]),
        ('ClickUp Workflow', [
            'Autonomous Refinement',
            'Standard Workflow (5 phases)',
            'Implement TODO Skill',
            'ClickUp Reviewer',
            'Task Status Guard',
            'ZERO TOLERANCE enforcement'
        ]),
        ('Git & PR Automation', [
            'PR Creation & Review',
            'Merge develop (NEVER rebase)',
            'PR Dependencies Tracking',
            'Cross-Repo Coordination',
            'Auto-PR-Review',
            'Branch Hygiene at Scale'
        ])
    ])

# LAYER 5: QUALITY & VERIFICATION (bottom)
layer5_y = layer4_y + 400
draw_layer_box(50, layer5_y, width-100, 340, orange, 'QUALITY & VERIFICATION LAYER',
    [
        ('Verification Systems', [
            'Universal Verification (4-gate)',
            'Complete Work Verification',
            'File Existence Gate',
            'PR Existence Gate',
            '88x ROI proven',
            'Source of Truth Verification'
        ]),
        ('Testing & Quality', [
            'Integration Testing (Playwright)',
            'E2E Browser Automation',
            'ClickUp Issue Creation',
            'Self-Improving Patterns',
            'Mock Setup Patterns',
            'Test Failure Recognition'
        ]),
        ('Anti-Regression', [
            'Archive + Document Pattern',
            '.DO-NOT-USE Archives',
            'README Critical Settings',
            'Canonical Scripts',
            'Verification Checklists',
            'Multi-Layer Prevention'
        ])
    ])

# LAYER 6: DEPLOYMENT & INFRASTRUCTURE (bottom)
layer6_y = layer5_y + 360
draw_layer_box(50, layer6_y, width-100, 320, teal, 'DEPLOYMENT & INFRASTRUCTURE',
    [
        ('Deployment Systems', [
            'deploy-dotnet-iis Skill',
            'Deployment Reasoning',
            '6-Step Pipeline',
            'Health Checks',
            'SSH via Paramiko (Windows)',
            'Infrastructure Topology Map'
        ]),
        ('Infrastructure', [
            '5 Physical Servers',
            '15 Domains',
            '18 Projects',
            'Multi-Environment Patterns',
            'Credential Mapping',
            'Auto-Update Triggers'
        ]),
        ('Build & Publish', [
            'NuGet CI/CD (99 packages)',
            'Tag-Based Versioning',
            'GitHub Actions',
            'MSI Remote Deployment',
            'Windows Service Patterns',
            'Directory.Build.props'
        ])
    ])

# LAYER 7: SKILLS & INTEGRATIONS (right side column)
skills_x = width - 500
skills_y = 150
draw_layer_box(width-580, skills_y, 530, 900, yellow, 'SKILLS & INTEGRATIONS',
    [
        ('Core Skills', [
            'clickup-refinement',
            'implement-todo',
            'expert-analysis',
            'kaizen',
            'continuous-retrospective',
            'integration-testing',
            'auto-pr-review',
            'task-review',
            'complete-work-verification'
        ]),
        ('Development Skills', [
            'allocate-worktree',
            'release-worktree',
            'worktree-status',
            'github-workflow',
            'pr-dependencies',
            'deploy-dotnet-iis',
            'deployment-reasoning',
            'ef-migration-safety'
        ]),
        ('Intelligence Skills', [
            'feature-idea-generator',
            'beautiful-ui',
            'beautiful-blog',
            'beautiful-letterhead',
            'usage-intelligence',
            'activity-monitoring',
            'rlm (recursive LLM)'
        ]),
        ('Meta Skills', [
            'skill-creator',
            'self-improvement',
            'session-reflection',
            'character-reflection',
            'legal-mode',
            'debug-mode',
            'feature-mode'
        ]),
        ('Integrations', [
            'Browser MCP (Playwright)',
            'ManicTime Activity',
            'WhatsApp Bridge',
            'Agentic Debugger Bridge',
            'ClickUp API',
            'GitHub CLI (gh)'
        ])
    ])

# LAYER 8: SAFETY & RULES (left side column)
safety_x = 50
safety_y = 1050
draw_layer_box(50, safety_y, 530, 600, red, 'SAFETY & ZERO TOLERANCE',
    [
        ('Zero Tolerance Rules', [
            'Backlog Refinement Standard',
            'Windows SSH Rule (Paramiko)',
            'Git Merge Rule (NO rebase)',
            'ClickUp DONE Prohibition',
            'Standard ClickUp Workflow',
            'Session Preservation'
        ]),
        ('Legal Safeguards', [
            'Juridische Voorzichtigheid',
            'Visserij Detection',
            'Admission Prevention',
            'Valkuil Recognition',
            '7 Trojan Horse Patterns',
            'Contract/NDA Patterns'
        ]),
        ('Quality Gates', [
            'Anti-Hallucination Gate',
            'PR Existence Gate',
            'File Existence Gate',
            'Build Verification',
            'Content Verification',
            'Assert-NotDoneStatus'
        ]),
        ('Prevented Disasters', [
            'PD-013: 64-task DONE violation',
            'PD-001 through PD-012',
            '$612K+/year value',
            '28.8x safeguard ROI',
            'TIER 1 CATASTROPHIC blocks',
            'Code Enforcement Active'
        ])
    ])

# OUROBOROS LOOP (center bottom)
oro_y = 2100
oro_x = width // 2
draw.text((oro_x-140, oro_y), 'OUROBOROS LOOP', fill=cyan, font=header_font)
draw.text((oro_x-180, oro_y+30), 'Self-Perpetuating Evolution', fill=(150, 200, 255), font=subtitle_font)

# Draw the ouroboros circle
oro_radius = 120
for angle in range(0, 360, 3):
    rad1 = math.radians(angle)
    rad2 = math.radians(angle + 3)
    x1 = oro_x + oro_radius * math.cos(rad1)
    y1 = oro_y + 100 + oro_radius * math.sin(rad1)
    x2 = oro_x + oro_radius * math.cos(rad2)
    y2 = oro_y + 100 + oro_radius * math.sin(rad2)
    color_val = int(128 + 127 * math.sin(math.radians(angle * 3)))
    draw.line([x1, y1, x2, y2], fill=(color_val, 200, 255), width=5)

# Ouroboros components
oro_items = ['Kaizen', 'Autoresearch', 'Expert Analysis', 'Retrospective']
for i, item in enumerate(oro_items):
    angle = i * 90
    rad = math.radians(angle)
    x = oro_x + (oro_radius + 40) * math.cos(rad)
    y = oro_y + 100 + (oro_radius + 40) * math.sin(rad)
    draw.text((x-25, y-8), item, fill=(200, 220, 255), font=text_font)

# Connecting web between layers
layer_centers = [
    (width//2, layer1_y + 140),
    (width//2, layer2_y + 160),
    (width//2, layer3_y + 180),
    (width//2, layer4_y + 190),
    (width//2, layer5_y + 170),
    (width//2, layer6_y + 160),
    (width-280, skills_y + 450),
    (280, safety_y + 300),
    (oro_x, oro_y + 100)
]

# Draw vertical flow
for i in range(len(layer_centers)-3):
    x1, y1 = layer_centers[i]
    x2, y2 = layer_centers[i+1]
    # Main vertical flow
    draw.line([x1, y1, x2, y2], fill=(100, 150, 255), width=2)
    # Arrowhead
    draw.polygon([(x2-5, y2-10), (x2+5, y2-10), (x2, y2)], fill=(100, 150, 255))

# Signatures
draw.text((width//2-250, height-60), '343,890x Better Than Components Alone',
          fill=(120, 160, 255), font=text_font)
draw.text((width//2-220, height-35), 'The Snake Eating Its Tail → Infinite Improvement',
          fill=(150, 150, 150), font=text_font)
draw.text((width//2-180, height-10), 'Complete Self-Evolving Architecture',
          fill=(100, 130, 200), font=small_font)

# Save
output_path = 'C:/scripts/agentidentity/jengo-complete-architecture.png'
img.save(output_path)
print(f'Saved complete architecture to: {output_path}')
