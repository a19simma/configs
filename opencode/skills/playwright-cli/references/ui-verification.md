# UI verification

A loop for checking rendered UI: sweep viewports, screenshot, run axe, check keyboard. Pins: `@playwright/test` 1.65.0 and `@axe-core/playwright` 4.14.0. Run it with `npx playwright test`; use `playwright-cli` for interactive checks. Work inside the scratchpad directory the caller names.

```bash
cd <scratchpad>
npm init -y
npm i -D @playwright/test@1.65.0 @axe-core/playwright@4.14.0
npx playwright install chromium
```

## Viewport sweep with axe

Widths 320, 768, 1280 and 1920 cover phone, tablet, laptop and wide desktop.

```ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const baseUrl = 'http://localhost:3000/';
const viewports = [
  { name: 'phone', width: 320, height: 640 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'laptop', width: 1280, height: 800 },
  { name: 'wide', width: 1920, height: 1080 },
];

for (const vp of viewports) {
  test(`ui at ${vp.name}`, async ({ page }) => {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.goto(baseUrl);
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({ path: `out/${vp.name}.png`, fullPage: true, animations: 'disabled' });
    const result = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze();
    console.log(JSON.stringify({
      viewport: vp.name,
      violations: result.violations.map((v) => ({
        id: v.id,
        impact: v.impact,
        targets: v.nodes.map((n) => n.target),
        fix: v.nodes[0]?.failureSummary,
      })),
      review: result.incomplete.map((v) => ({ id: v.id, nodes: v.nodes.length })),
    }, null, 2));
    expect(result.violations).toEqual([]);
  });
}
```

Set `baseUrl` to the running app. Screenshots land in `out/` under the scratchpad. Read each screenshot against `DESIGN.md`. The test passes on axe alone, so the visual comparison is a separate step.

## What axe covers

- The axe-core README states axe finds on average 57% of WCAG issues automatically. A clean run is a floor.
- `incomplete` lists elements axe could not decide, such as contrast over images or gradients. Review each one by hand.
- Axe scans the DOM as it stands. Re-run it after each state change: open menu, modal, error state.

## Keyboard and focus checks

Axe does not drive interaction. Run these with `page.keyboard`:

1. Press `Tab` through the page. Log the focused element's tag, role and accessible name at each stop. The order matches the visual order and no stop traps focus.
2. Confirm every focused element shows a visible focus indicator in the screenshot.
3. Open each dialog. Focus moves inside, `Escape` closes it, and focus returns to the trigger.
4. Activate custom widgets with `Enter` and `Space`.
5. Repeat at 320px width, with `colorScheme: 'dark'` and `forcedColors: 'active'`.

## Baselines

Rendering depends on OS, fonts and headless mode, so a baseline from macOS fails on Linux. Create and compare baselines in one pinned environment. Use `toHaveScreenshot` for regression against an accepted design, with `mask` for volatile regions and `maxDiffPixelRatio` for tolerance. Read screenshots directly when judging a new design.

## Sources

- [Playwright accessibility testing](https://playwright.dev/docs/accessibility-testing)
- [Playwright visual comparisons](https://playwright.dev/docs/test-snapshots)
- [axe-core README](https://github.com/dequelabs/axe-core/blob/develop/README.md)
