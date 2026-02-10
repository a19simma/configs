# Troubleshooting: "Source missing, cannot jump to frame"

This error occurs when DAP can't map source files between Chrome (Windows) and nvim (WSL).

## Quick Fixes

### 1. Ensure Source Maps are Enabled

Check your Vite/Webpack config has source maps enabled:

**vite.config.ts:**

```typescript
export default defineConfig({
  build: {
    sourcemap: true, // Enable source maps
  },
});
```

**Or for dev server (usually enabled by default):**

```typescript
export default defineConfig({
  server: {
    sourcemap: true,
  },
});
```

### 2. Verify webRoot Matches Your Project

The DAP configuration uses `webRoot` to map paths. Make sure you're running nvim from your project root (where package.json is).

```bash
# In your project root
cd ~/repos/doneai-mono.git/lending-term-ui
nvim .
```

### 3. Check Source Map Path Overrides

The configuration includes common patterns:

- `webpack:///./*` → Maps to project root
- `webpack://?:*/*` → Maps to project root
- `webpack:///*` → Direct mapping

If using a different bundler (Vite, Rollup, etc.), you might need custom overrides.

### 4. Inspect DAP Logs

Enable DAP logging to see path resolution:

```vim
:lua require('dap').set_log_level('DEBUG')
" Check logs at:
:lua print(vim.fn.stdpath('cache') .. '/dap.log')
```

Look for:

- `sourceMapPathOverrides` being applied
- Path resolution failures
- `webRoot` value

### 5. Test Source Map Availability

From your browser's DevTools:

1. Open Chrome DevTools (F12)
2. Go to Sources tab
3. Check if your source files appear under `webpack://` or similar
4. If not, source maps aren't being generated

## Common Causes

### Framework-Specific Issues

**Vite:**

- Source maps are enabled by default in dev mode
- Check `vite.config.ts` for custom `build.sourcemap` settings

**Create React App:**

- Set `GENERATE_SOURCEMAP=true` in `.env`

**Next.js:**

```javascript
// next.config.js
module.exports = {
  productionBrowserSourceMaps: true,
};
```

### Anonymous Frames

If you see `<anonymous>` frames:

- These are usually from eval'd code or inline scripts
- Not much you can do - these don't have source maps
- Set breakpoints in named functions/files instead

## Workaround: Use Chrome DevTools

If source mapping continues to fail:

1. Use `:DapLaunchChrome` to start debugging
2. Open Chrome DevTools (F12)
3. Debug in Chrome DevTools instead of nvim
4. Chrome DevTools works perfectly since everything is in Windows

## Advanced: Custom Path Mapping

If you have a complex setup, add custom sourceMapPathOverrides:

```lua
sourceMapPathOverrides = {
  ["your-pattern"] = "${webRoot}/your-path",
  -- Example for monorepo:
  ["webpack:///packages/*"] = "${webRoot}/packages/*",
}
```

Edit `~/repos/configs/neovim/lua/custom/plugins/dap.lua` and add your patterns.

## Still Not Working?

Fall back to manual debugging:

1. Launch Chrome with `:DapLaunchChrome`
2. Use Chrome DevTools for debugging (F12)
3. This bypasses all path mapping issues
