# Chrome Debugging in WSL with nvim DAP

## Problem

WSL2 networking isolation prevents nvim DAP from launching Chrome directly. Chrome runs in Windows while nvim runs in WSL.

## Solution

Manually launch Chrome from Windows with debugging enabled, then attach nvim DAP to it.

## Quick Start

### 1. Start Chrome with Debugging (Windows)

**Option A: From Windows PowerShell**

```powershell
# Navigate to configs
cd \\wsl$\Ubuntu\home\simon\repos\configs\wsl-scripts

# Run the script
.\Start-ChromeDebug.ps1

# Or with custom URL
.\Start-ChromeDebug.ps1 "http://localhost:3000"
```

**Option B: Manual Command**

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="C:\temp\chrome-debug" `
  http://localhost:5173
```

### 2. Attach nvim DAP (WSL)

1. Open your project in neovim
2. Set a breakpoint: `<leader>db`
3. Start debugging: `<leader>dc`
4. Select: **"Attach to Chrome (WSL)"**

## How It Works

1. Chrome runs in Windows listening on `localhost:9222`
2. WSL can connect to Windows `localhost` automatically (WSL2 feature)
3. nvim DAP connects to Chrome's debug protocol
4. Breakpoints and debugging work normally

## Troubleshooting

### Chrome won't start with debugging

- **Kill existing Chrome**: Close all Chrome windows first
- **Check port**: Make sure nothing else is using port 9222
  ```powershell
  Get-NetTCPConnection -LocalPort 9222
  ```

### DAP won't connect

- **Verify Chrome is listening**: From Windows PowerShell:

  ```powershell
  Invoke-WebRequest http://localhost:9222/json/version
  ```

  Should return JSON with Chrome version

- **Check from WSL**:
  ```bash
  curl http://localhost:9222/json/version
  ```
  Should return the same JSON

### Breakpoints not working

- **Clear user data**: Delete `C:\temp\chrome-debug` and restart Chrome
- **Check sourcemaps**: Ensure your dev server generates sourcemaps
- **Verify webRoot**: Make sure it matches your project directory

## Files

- **`~/repos/configs/wsl-scripts/Start-ChromeDebug.ps1`** - PowerShell script to launch Chrome
- **`~/repos/configs/neovim/lua/custom/plugins/dap.lua`** - DAP configuration with WSL instructions

## Alternative: Use Chrome DevTools

If DAP continues to have issues, you can use Chrome's built-in DevTools which work perfectly in this setup:

1. Launch Chrome with the debug script above
2. Press F12 in Chrome
3. Use Chrome DevTools for debugging

The advantage of nvim DAP is you can set breakpoints in your editor without switching windows.
