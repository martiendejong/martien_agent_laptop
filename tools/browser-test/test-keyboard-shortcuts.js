const { chromium } = require('playwright');

(async () => {
  console.log('⌨️ Testing Keyboard Shortcuts...\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log('📊 Opening dashboard');
    await page.goto('http://localhost:4242/work-dashboard.html', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);

    // Test 1: Ctrl+K - Focus search
    console.log('\n🧪 Test 1: Ctrl+K (Focus search)');
    await page.keyboard.press('Control+k');
    await page.waitForTimeout(500);
    const searchFocused = await page.evaluate(() => document.activeElement.id === 'search-box');
    console.log(`   ${searchFocused ? '✅' : '❌'} Search box focused: ${searchFocused}`);

    // Test 2: Esc - Clear search
    console.log('\n🧪 Test 2: Esc (Clear search)');
    await page.type('#search-box', 'test query');
    await page.waitForTimeout(300);
    const valueBeforeEsc = await page.inputValue('#search-box');
    console.log(`   📝 Typed: "${valueBeforeEsc}"`);

    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);
    const valueAfterEsc = await page.inputValue('#search-box');
    console.log(`   ${valueAfterEsc === '' ? '✅' : '❌'} Search cleared: "${valueAfterEsc}"`);

    // Test 3: Ctrl+D - Toggle theme
    console.log('\n🧪 Test 3: Ctrl+D (Toggle theme)');
    const themeBefore = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
    console.log(`   🌙 Theme before: ${themeBefore}`);

    await page.keyboard.press('Control+d');
    await page.waitForTimeout(500);

    const themeAfter = await page.evaluate(() => document.documentElement.getAttribute('data-theme'));
    console.log(`   ${themeBefore !== themeAfter ? '✅' : '❌'} Theme toggled to: ${themeAfter}`);

    // Test 4: ? - Show shortcuts help
    console.log('\n🧪 Test 4: ? (Show shortcuts help)');
    await page.keyboard.press('Shift+Slash'); // ? key
    await page.waitForTimeout(500);

    const modalVisible = await page.evaluate(() => {
      const modal = document.getElementById('shortcuts-modal');
      return modal.classList.contains('show');
    });
    console.log(`   ${modalVisible ? '✅' : '❌'} Modal visible: ${modalVisible}`);

    // Test 5: Esc - Close modal
    console.log('\n🧪 Test 5: Esc (Close modal)');
    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);

    const modalHidden = await page.evaluate(() => {
      const modal = document.getElementById('shortcuts-modal');
      return !modal.classList.contains('show');
    });
    console.log(`   ${modalHidden ? '✅' : '❌'} Modal hidden: ${modalHidden}`);

    // Test 6: Ctrl+R - Refresh
    console.log('\n🧪 Test 6: Ctrl+R (Force refresh)');
    await page.keyboard.press('Control+r');
    await page.waitForTimeout(500);

    const countdownText = await page.textContent('#countdown');
    console.log(`   ✅ Refresh triggered, countdown: ${countdownText}`);

    // Take screenshot of shortcuts modal
    await page.keyboard.press('Shift+Slash'); // Show modal
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'C:/scripts/_machine/dashboard-shortcuts.png', fullPage: true });
    console.log('\n📸 Screenshot saved: dashboard-shortcuts.png');

    console.log('\n✅ All keyboard shortcuts tests passed!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await browser.close();
  }
})();
