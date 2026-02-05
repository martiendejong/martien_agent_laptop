#!/usr/bin/env python3
"""
Convert markdown blog posts to HTML with proper formatting
"""

import re
import os

# Post metadata
posts = [
    {"num": "01", "title": "You're Not Crazy, The System Is", "file": "01-youre-not-crazy"},
    {"num": "02", "title": "The Narcissism You Can't See (Because You're In It)", "file": "02-narcissism-you-cant-see"},
    {"num": "03", "title": "How Social Media Gave Us All Narcissistic Personality Disorder", "file": "03-social-media-npd-factory"},
    {"num": "04", "title": "The Eight Feedback Loops Destroying Society", "file": "04-eight-feedback-loops"},
    {"num": "05", "title": "Why Fact-Checking Failed (And What That Tells Us)", "file": "05-why-fact-checking-failed"},
    {"num": "06", "title": "The Three-Layer Solution (Or: How To Fight Fire With Fire)", "file": "06-three-layer-solution"},
    {"num": "07", "title": "The Algorithm War: Building Tech That Heals Instead of Harms", "file": "07-algorithm-war"},
    {"num": "08", "title": "The Regulatory Blitz: How To Make Big Tech Bend", "file": "08-regulatory-blitz"},
    {"num": "09", "title": "The Narrative Offensive: Making Bridge-Building Cool", "file": "09-narrative-offensive"},
    {"num": "10", "title": "The App That Deprograms You (In Real-Time)", "file": "10-depolarization-toolkit"},
    {"num": "11", "title": "The Implementation Blueprint: How We Coordinate", "file": "11-implementation-blueprint"},
    {"num": "12", "title": "The Two Futures: Choose Wisely", "file": "12-two-futures"},
]

def md_to_html(md_text):
    """Convert markdown to HTML"""
    html = md_text

    # Headers
    html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
    html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)

    # Bold and italic
    html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
    html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)

    # Code blocks
    html = re.sub(r'```([^`]+)```', r'<pre><code>\1</code></pre>', html, flags=re.DOTALL)
    html = re.sub(r'`([^`]+)`', r'<code>\1</code>', html)

    # Blockquotes
    html = re.sub(r'^> (.+)$', r'<blockquote>\1</blockquote>', html, flags=re.MULTILINE)

    # Links
    html = re.sub(r'\[([^\]]+)\]\(([^\)]+)\)', r'<a href="\2">\1</a>', html)

    # Paragraphs (lines separated by blank lines)
    paragraphs = html.split('\n\n')
    for i, para in enumerate(paragraphs):
        if not para.strip():
            continue
        # Don't wrap headers, lists, or already-wrapped HTML
        if not re.match(r'<[^>]+>', para) and not re.match(r'^[\-\*\d]', para.strip()):
            paragraphs[i] = f'<p>{para}</p>'

    html = '\n\n'.join(paragraphs)

    # Horizontal rules
    html = re.sub(r'^---+$', '<hr>', html, flags=re.MULTILINE)

    return html

def create_html_page(post_num, title, content):
    """Create full HTML page"""
    template = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - The Narcissism Pandemic Series</title>
    <link rel="stylesheet" href="style.css">
    <meta name="description" content="Part {post_num} of The Narcissism Pandemic series - understanding and solving the polarization crisis.">
</head>
<body>
    <header>
        <p class="series-info">Part {post_num} of 12: The Narcissism Pandemic Series</p>
    </header>

    <article>
        {content}
    </article>

    <nav class="series-nav">
        <a href="index.html">← Series Home</a>
        {"<a href='" + posts[int(post_num)-2]["file"] + ".html'>← Previous Post</a>" if int(post_num) > 1 else ""}
        {"<a href='" + posts[int(post_num)]["file"] + ".html'>Next Post →</a>" if int(post_num) < 12 else ""}
    </nav>

    <footer>
        <p><em>This is Part {post_num} of a 12-part series examining the polarization crisis and how to solve it.</em></p>
        <p>Based on analysis from 1,000 experts across political psychology, media theory, technology ethics, sociology, game theory, neuroscience, and more.</p>
    </footer>
</body>
</html>'''
    return template

# Process each post
for post in posts:
    md_path = f"../blog-posts/markdown/{post['file']}.md"
    html_path = f"../blog-posts/html/{post['file']}.html"

    print(f"Converting {post['file']}...")

    try:
        with open(md_path, 'r', encoding='utf-8') as f:
            md_content = f.read()

        # Remove the first line (title - already in header)
        md_content = '\n'.join(md_content.split('\n')[1:])

        # Convert to HTML
        html_content = md_to_html(md_content)

        # Create full page
        full_html = create_html_page(post['num'], post['title'], html_content)

        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(full_html)

        print(f"  OK Created {post['file']}.html")
    except Exception as e:
        print(f"  ERROR Error: {e}")

# Create index page
index_html = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Narcissism Pandemic - Complete Series</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>The Narcissism Pandemic</h1>
        <p class="series-info">A 12-Part Series on Solving the Polarization Crisis</p>
    </header>

    <article>
        <h2>About This Series</h2>
        <p>We're not just polarized. We're in a collective narcissism pandemic, amplified by algorithms, reinforced by eight feedback loops, and destroying society from within.</p>
        <p>This series diagnoses the disease and prescribes the cure. Based on insights from 1,000 experts across 11 disciplines.</p>

        <h2>The Complete Series</h2>
        <ol style="line-height: 2;">
'''

for post in posts:
    index_html += f'            <li><a href="{post["file"]}.html"><strong>Part {post["num"]}:</strong> {post["title"]}</a></li>\n'

index_html += '''        </ol>

        <div class="cta-section">
            <h2>Ready to Start?</h2>
            <p>Begin with Part 1 and work your way through. Each post builds on the previous. By the end, you'll understand the problem and the solution.</p>
            <a href="01-youre-not-crazy.html" class="button">Start Reading →</a>
        </div>
    </article>

    <footer>
        <p><em>The Narcissism Pandemic series by [Author]</em></p>
        <p>Want updates? <a href="#">Subscribe to the newsletter</a></p>
    </footer>
</body>
</html>'''

with open('../blog-posts/html/index.html', 'w', encoding='utf-8') as f:
    f.write(index_html)

print("\nOK All HTML files created successfully!")
print(f"OK Created index.html")
print(f"\nTotal: {len(posts)} posts + index page")
