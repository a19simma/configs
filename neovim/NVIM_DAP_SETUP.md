# nvim-dap Debugging Setup Summary

## Overview

Successfully configured nvim-dap for debugging JavaScript/TypeScript/Svelte applications in Neovim. This setup supports both server-side (Node.js) and client-side (Chrome) debugging.

## What We Installed

### Plugins
- **nvim-dap** - Debug Adapter Protocol client for Neovim
- **nvim-dap-ui** - UI for nvim-dap (shows variables, call stack, watches, etc.)
- **nvim-nio** - Required dependency for nvim-dap-ui
- **mason-tool-installer.nvim** - Automatically installs debug adapters

### Debug Adapter
- **js-debug-adapter** - Installed via Mason, supports Node.js and Chrome debugging

## Configuration Location

`/home/simon/repos/configs/neovim/lua/custom/plugins/dap.lua`

## Key Configuration Decisions

### 1. Chose Simple Mason-based Approach
- ✅ Used `js-debug-adapter` from Mason (simple, maintained)
- ❌ Avoided `nvim-dap-vscode-js` + manual vscode-js-debug build (complex, unmaintained)

### 2. Adapter Setup
```lua
for _, adapter in pairs({ "pwa-node", "pwa-chrome" }) do
  dap.adapters[adapter] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "js-debug-adapter",
      args = { "${port}" },
    },
  }
end
```

### 3. Critical Fix for Monorepos
**Problem:** `${workspaceFolder}` resolves to where Neovim was opened, not the project root.

**Solution:** Use `vim.fn.getcwd()` instead:
```lua
webRoot = function()
  return vim.fn.getcwd()
end,
```

**Best Practice:** Always `cd` into the actual app directory before opening Neovim in monorepos!

## Usage

### Server-Side Debugging (Node.js/SvelteKit API Routes)

**1. Start dev server with debugging:**
```bash
cd /home/simon/repos/legal-chat/master/apps/web
bun run debug  # Uses: cross-env NODE_OPTIONS='--inspect' bun vite dev
```

You should see:
```
Debugger listening on ws://127.0.0.1:9229/...
```

**2. Open file in Neovim:**
```bash
nvim src/routes/api/test/+server.ts
```

**3. Debug workflow:**
- Navigate to line you want to debug
- `<Space>db` - Set breakpoint (red ● appears)
- `<Space>dc` - Start debugging
- Select: **"Attach to Node Process"**
- Pick the `node ... vite dev` process
- Trigger the code (visit API endpoint in browser)
- Neovim stops at breakpoint! 🎉

### Client-Side Debugging (Svelte Components/Frontend)

**1. Ensure dev server is running:**
```bash
bun run dev
```

**2. Open file in Neovim:**
```bash
cd /home/simon/repos/legal-chat/master/apps/web  # IMPORTANT: cd into app directory!
nvim src/routes/+page.svelte
```

**3. Debug workflow:**
- Set breakpoint in `<script>` section
- `<Space>db` - Set breakpoint
- `<Space>dc` - Start debugging
- Select: **"Launch Chrome"**
- Chrome opens automatically
- Trigger the code (click button, etc.)
- Neovim stops at breakpoint! 🎉

## Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>db` | Toggle breakpoint | Set/remove breakpoint at current line |
| `<Space>dB` | Conditional breakpoint | Set breakpoint with condition |
| `<Space>dc` | Continue | Start debugging or continue to next breakpoint |
| `<Space>di` | Step into | Step into function calls |
| `<Space>do` | Step over | Step over current line |
| `<Space>dO` | Step out | Step out of current function |
| `<Space>du` | Toggle UI | Show/hide debug UI (variables, stack, etc.) |
| `<Space>dr` | Toggle REPL | Open debug console |
| `<Space>dt` | Terminate | Stop debugging session |
| `<Space>dh` | Hover | Show variable value under cursor |
| `<Space>dl` | Run last | Re-run last debug configuration |

## Debug UI Elements

When debugging starts, the UI shows:

**Left Panel:**
- **Scopes** - Local variables and their values
- **Breakpoints** - All set breakpoints
- **Stacks** - Call stack
- **Watches** - Custom watch expressions

**Bottom Panel:**
- **REPL** - Debug console (evaluate expressions)
- **Console** - Program output

## Troubleshooting

### Breakpoints Not Hitting

**Server-side:**
1. Check dev server is running with `--inspect`: `lsof -i :9229`
2. Ensure you're attaching to correct process (pick `node ... vite dev`)
3. Verify source maps are enabled in Vite config

**Client-side:**
1. Ensure you `cd` into the app directory before opening Neovim
2. Check Chrome actually opened
3. Verify you're triggering the code that has the breakpoint
4. If still not working, try setting breakpoint in Chrome DevTools first to verify source maps work

### "adapter.port is required" Error

This was caused by:
- Using `nvim-dap-vscode-js` which was unmaintained
- **Fix:** Use simple `js-debug-adapter` from Mason instead

### Chrome Debugging Doesn't Work

**Root cause:** Wrong `webRoot` in monorepo setups

**Solution:**
1. Always `cd` into the actual app directory
2. Use `vim.fn.getcwd()` instead of `${workspaceFolder}`

### Process Picker Shows Nothing

- Ensure dev server started with `NODE_OPTIONS='--inspect'`
- Check for "Debugger listening" message in terminal
- Verify port 9229 is open: `lsof -i :9229`

## Project-Specific Setup

### package.json Scripts

Added cross-env for cross-shell compatibility (works with nushell):

```json
{
  "scripts": {
    "dev": "bun --bun vite dev",
    "debug": "cross-env NODE_OPTIONS='--inspect' bun vite dev"
  },
  "devDependencies": {
    "cross-env": "^10.1.0"
  }
}
```

### vite.config.ts

Explicitly enable source maps for debugging:

```typescript
export default defineConfig({
  plugins: [tailwindcss(), sveltekit(), devtoolsJson()],
  build: {
    sourcemap: true, // Enable source maps
  },
  server: {
    sourcemapIgnoreList: false, // Don't ignore Svelte files
  },
  // ... rest of config
});
```

## Alternative: Hybrid Debugging Approach

Many experienced Neovim users use:
- **Server-side:** nvim-dap (works perfectly)
- **Client-side:** Chrome DevTools (F12) - often more reliable

This is a valid approach if Chrome debugging in Neovim becomes problematic.

## What Worked vs What Didn't

### ✅ What Works Great
- Server-side debugging with `pwa-node` adapter
- Chrome debugging when in correct directory
- Simple Mason-based setup
- Process picker for attaching

### ❌ What Didn't Work
- `nvim-dap-vscode-js` + manual vscode-js-debug build (complex, unmaintained)
- Using `${workspaceFolder}` in monorepo setups
- Complex source map overrides (simpler is better)
- Bun's `--inspect` flag with `--bun` mode (use without `--bun` or use Node)

## Lessons Learned

1. **Simpler is better** - Use Mason's js-debug-adapter instead of manual builds
2. **Monorepos need care** - Always `cd` into app directory
3. **Test incrementally** - Test with simple HTML first, then add complexity
4. **Source maps are critical** - Vite must generate them for debugging to work
5. **Chrome path mapping is tricky** - Using current working directory is most reliable

## Next Steps

- ✅ JavaScript/TypeScript/Svelte debugging working
- 🔜 .NET debugging setup (next session)

## Useful Commands

**Check if debugger is listening:**
```bash
lsof -i :9229
```

**Check inspector URL:**
```bash
curl http://localhost:9229/json
```

**Enable DAP trace logging:**
```vim
:lua require('dap').set_log_level('TRACE')
:edit ~/.local/state/nvim/dap.log
```

**Check current debug session:**
```vim
:lua vim.print(vim.inspect(require('dap').session()))
```

**Check breakpoints:**
```vim
:lua vim.print(vim.inspect(require('dap').breakpoints.get()))
```

## Resources

- [nvim-dap GitHub](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap Wiki](https://github.com/mfussenegger/nvim-dap/wiki)
- [Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/)
- [vscode-js-debug Options](https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md)

---

**Date:** February 1, 2026  
**Status:** ✅ Working for both server-side and client-side debugging  
**Platform:** Arch Linux with Neovim
