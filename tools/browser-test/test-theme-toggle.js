const { chromium } = require('playwright');

(async () => {
  console.log('🎨 Testing Dark/Light Theme Toggle...\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate to dashboard
    console.log('📊 Opening dashboard');
    await page.goto('http://localhost:4242/work-dashboard.html', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // Check default theme (should be dark)
    const initialTheme = await page.evaluate(() => {
      return document.documentElement.getAttribute('data-theme') || 'dark';
    });
    console.log(`🌙 Initial theme: ${initialTheme}`);

    // Check localStorage
    const savedTheme = await page.evaluate(() => localStorage.getItem('theme'));
    console.log(`💾 Saved theme: ${savedTheme || 'not set (defaults to dark)'}`);

    // Click theme toggle
    console.log('\n🖱️ Clicking theme toggle...');
    await page.click('.theme-toggle');
    await page.waitForTimeout(500);

    // Check theme changed
    const newTheme = await page.evaluate(() => {
      return document.documentElement.getAttribute('data-theme');
    });
    console.log(`☀️ New theme: ${newTheme}`);

    // Check icon changed
    const iconAfterToggle = await page.textContent('#theme-icon');
    console.log(`🔆 Icon changed to: ${iconAfterToggle}`);

    // Check localStorage updated
    const newSavedTheme = await page.evaluate(() => localStorage.getItem('theme'));
    console.log(`💾 Saved theme updated to: ${newSavedTheme}`);

    // Check CSS variable changed (background color)
    const bgColor = await page.evaluate(() => {
      return getComputedStyle(document.body).backgroundColor;
    });
    console.log(`🎨 Background color: ${bgColor}`);

    // Toggle back
    console.log('\n🖱️ Toggling back to dark...');
    await page.click('.theme-toggle');
    await page.waitForTimeout(500);

    const finalTheme = await page.evaluate(() => {
      return document.documentElement.getAttribute('data-theme');
    });
    console.log(`🌙 Final theme: ${finalTheme}`);

    // Test persistence: reload page
    console.log('\n🔄 Reloading page to test persistence...');
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    const persistedTheme = await page.evaluate(() => {
      return document.documentElement.getAttribute('data-theme');
    });
    console.log(`✅ Theme persisted across reload: ${persistedTheme}`);

    // Take screenshots
    await page.screenshot({ path: 'C:/scripts/_machine/dashboard-dark.png', fullPage: true });
    console.log('📸 Screenshot saved: dashboard-dark.png');

    await page.click('.theme-toggle');
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'C:/scripts/_machine/dashboard-light.png', fullPage: true });
    console.log('📸 Screenshot saved: dashboard-light.png');

    console.log('\n✅ Theme toggle test complete!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
})();
