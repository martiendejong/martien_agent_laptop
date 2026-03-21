"""Final login test for Brand2Boost"""
from playwright.sync_api import sync_playwright
import time
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    context = browser.new_context(viewport={"width": 1280, "height": 720})
    page = context.new_page()

    api_calls = []
    def on_response(response):
        url = response.url
        if any(x in url.lower() for x in ["auth", "login", "language", "featureflag"]):
            try:
                body = response.text()
            except:
                body = ""
            api_calls.append({"url": url, "status": response.status, "body": body[:300]})
    page.on("response", on_response)

    console_errors = []
    page.on("console", lambda msg: console_errors.append(f"[{msg.type}] {msg.text}") if msg.type == "error" else None)

    print("1. Navigate...")
    page.goto("https://app.brand2boost.com", timeout=60000)
    time.sleep(5)
    page.screenshot(path="C:\\scripts\\tools\\final_step1.png")
    print(f"   URL: {page.url}")

    # Find and click Sign In
    print("2. Click Sign In...")
    # Try multiple approaches
    clicked = False
    for sel in ['text=Sign In', 'button:has-text("Sign In")', 'a:has-text("Sign In")', '[href*="login"]', '[href*="signin"]']:
        try:
            el = page.locator(sel).first
            if el.is_visible(timeout=3000):
                el.click()
                clicked = True
                print(f"   Clicked: {sel}")
                break
        except:
            continue

    if not clicked:
        print("   Could not find Sign In button, trying direct navigation to /login")
        page.goto("https://app.brand2boost.com/login", timeout=30000)

    time.sleep(5)
    page.screenshot(path="C:\\scripts\\tools\\final_step2.png")
    print(f"   URL: {page.url}")

    # List all inputs to find the form
    inputs = page.locator('input').all()
    print(f"   Total inputs on page: {len(inputs)}")
    for i, inp in enumerate(inputs):
        try:
            visible = inp.is_visible()
            attrs = f"type={inp.get_attribute('type')}, placeholder={inp.get_attribute('placeholder')}, name={inp.get_attribute('name')}"
            print(f"   Input {i} (visible={visible}): {attrs}")
        except:
            pass

    # Fill the form
    print("3. Fill credentials...")
    filled_email = False
    for sel in ['input[placeholder*="email" i]', 'input[placeholder*="Email"]', 'input[type="email"]', 'input[type="text"]:visible']:
        try:
            el = page.locator(sel).first
            if el.is_visible(timeout=3000):
                el.fill("info@prospergenics.com")
                filled_email = True
                print(f"   Email filled via: {sel}")
                break
        except:
            continue

    if not filled_email:
        print("   WARNING: Could not fill email!")

    filled_pwd = False
    for sel in ['input[type="password"]', 'input[placeholder*="password" i]']:
        try:
            el = page.locator(sel).first
            if el.is_visible(timeout=3000):
                el.fill("SpaceElevator1tam!")
                filled_pwd = True
                print(f"   Password filled via: {sel}")
                break
        except:
            continue

    if not filled_pwd:
        print("   WARNING: Could not fill password!")

    time.sleep(1)
    page.screenshot(path="C:\\scripts\\tools\\final_step3.png")

    if filled_email and filled_pwd:
        # Clear tracking
        api_calls.clear()
        console_errors.clear()

        print("4. Submit login...")
        for sel in ['button[type="submit"]', 'button:has-text("Sign In")', 'button:has-text("Login")']:
            try:
                el = page.locator(sel).first
                if el.is_visible(timeout=3000):
                    el.click()
                    print(f"   Clicked: {sel}")
                    break
            except:
                continue

        print("   Waiting 20 seconds for response...")
        time.sleep(20)

        page.screenshot(path="C:\\scripts\\tools\\final_step4.png")
        print(f"\n   URL: {page.url}")

        print("\n   API CALLS:")
        for c in api_calls:
            print(f"     {c['status']} {c['url']}")
            if c['body']:
                try:
                    print(f"       {c['body'][:200]}")
                except:
                    pass

        print(f"\n   CONSOLE ERRORS ({len(console_errors)}):")
        for e in console_errors[:5]:
            try:
                print(f"     {e[:200]}")
            except:
                pass

    print(f"\nFinal URL: {page.url}")
    context.close()
    browser.close()
    print("Done.")
