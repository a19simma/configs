# Quick Reference: Chrome Debugging in WSL

## Option 1: Automatic Launch with Custom Command (Easiest!)

In nvim (WSL):

1. Set breakpoint: `<leader>db`
2. Run command: `:DapLaunchChrome`
3. Chrome will launch automatically and DAP will attach!

## Option 2: Use DAP UI

In nvim (WSL):

1. `<leader>db` - Set breakpoint
2. `<leader>dc` - Start debugging
3. Select: **"Attach to Chrome (WSL)"** (Chrome must already be running)

## Option 3: Manual Launch then Attach

**Start Chrome from Windows PowerShell:**

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\temp\chrome-debug" http://localhost:5173
```

**Or use the helper script:**

```powershell
# From Windows PowerShell, navigate to:
cd \\wsl$\Ubuntu\home\simon\repos\configs\wsl-scripts

# Run:
.\Start-ChromeDebug.ps1
```

**Then in nvim (WSL):**

1. `<leader>db` - Set breakpoint
2. `<leader>dc` - Start debugging
3. Select: **"Attach to Chrome (WSL)"**

## Available Commands & Profiles

### Commands

- **`:DapLaunchChrome`** - ⭐ Automatically launch Chrome and attach (WSL-compatible)

### DAP Profiles

- **"Attach to Chrome (WSL)"** - Attach to manually-launched Chrome
- **"Launch Chrome"** - Original profile (may not work in WSL)

## Test Connection

From WSL, verify Chrome debug port is accessible:

```bash
curl http://localhost:9222/json/version
```

Should return JSON with Chrome version info.

## Troubleshooting

- **"Debug adapter disconnected"**: Use `:DapLaunchChrome` command instead of the launch profile
- **Close all Chrome windows first** before debugging
- **Check port**: `powershell.exe -Command "Get-NetTCPConnection -LocalPort 9222"`
- **Clear cache**: Delete `C:\temp\chrome-debug` folder
