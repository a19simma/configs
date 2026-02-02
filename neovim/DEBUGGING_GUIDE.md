# Testing nvim-dap Setup for Svelte Projects

This guide will help you test your new debugging setup in Neovim.

## Initial Setup

1. **Restart Neovim** to load the new plugin configuration:
   ```bash
   nvim
   ```

2. **Install the plugins**:
   - Lazy.nvim will automatically detect the new plugin
   - Wait for the plugins to install (this may take a minute as vscode-js-debug builds)
   - You should see the build process for vscode-js-debug running

3. **Verify installation**:
   - Open Neovim
   - Run `:Lazy` to check that all DAP plugins are installed
   - Look for: `nvim-dap`, `nvim-dap-ui`, `nvim-dap-vscode-js`, `vscode-js-debug`

## Testing Server-Side Debugging (SvelteKit API Routes)

### Step 1: Create a Test SvelteKit Project

```bash
# Create a new SvelteKit project
npm create svelte@latest test-svelte-debug
cd test-svelte-debug

# Choose these options:
# - SvelteKit demo app (or skeleton)
# - TypeScript: Yes
# - ESLint, Prettier: Optional

# Install dependencies
npm install
```

### Step 2: Create a Server Route to Debug

Create `src/routes/api/test/+server.ts`:

```typescript
export async function GET({ url }) {
    const name = url.searchParams.get('name') ?? 'World';
    
    // Set a breakpoint on the next line in Neovim
    const message = `Hello, ${name}!`;
    
    const data = {
        message,
        timestamp: new Date().toISOString(),
        calculation: 42 * 2,
    };
    
    // Set another breakpoint here
    return new Response(JSON.stringify(data), {
        headers: { 'Content-Type': 'application/json' }
    });
}
```

### Step 3: Debug the Server Route

1. **Start the dev server with debugging enabled**:
   ```bash
   NODE_OPTIONS="--inspect" npm run dev
   ```
   
   You should see output like:
   ```
   Debugger listening on ws://127.0.0.1:9229/...
   ```

2. **Open the file in Neovim**:
   ```bash
   nvim src/routes/api/test/+server.ts
   ```

3. **Set breakpoints**:
   - Navigate to line with `const message = ...`
   - Press `<leader>db` (Space + d + b) to set a breakpoint
   - You should see a red dot (●) in the sign column

4. **Start debugging**:
   - Press `<leader>dc` (Space + d + c) to continue/start debugging
   - Select "Attach to Node --inspect process"
   - Select your `vite dev` process from the list

5. **Trigger the breakpoint**:
   - Open your browser and visit: `http://localhost:5173/api/test?name=Simon`
   - Neovim should stop at your breakpoint!

6. **Debug navigation**:
   - `<leader>dc` - Continue to next breakpoint
   - `<leader>di` - Step into functions
   - `<leader>do` - Step over lines
   - `<leader>dO` - Step out of functions
   - `<leader>dh` - Hover over variables to see values
   - `<leader>du` - Toggle debug UI (shows variables, call stack, etc.)

## Testing Client-Side Debugging (Svelte Components)

### Step 1: Create a Component to Debug

Create or modify `src/routes/+page.svelte`:

```svelte
<script lang="ts">
    let count = 0;
    
    function increment() {
        // Set a breakpoint here
        count += 1;
        
        // Set another breakpoint here
        console.log('Count is now:', count);
    }
    
    async function fetchData() {
        // Set a breakpoint here
        const response = await fetch('/api/test?name=Client');
        const data = await response.json();
        
        // Set a breakpoint here
        console.log('Received:', data);
        alert(data.message);
    }
</script>

<h1>Debug Test Page</h1>

<button on:click={increment}>
    Count: {count}
</button>

<button on:click={fetchData}>
    Fetch Data
</button>
```

### Step 2: Debug the Client Code

1. **Make sure dev server is running**:
   ```bash
   npm run dev
   ```

2. **Open the component in Neovim**:
   ```bash
   nvim src/routes/+page.svelte
   ```

3. **Set breakpoints** in the `<script>` section:
   - Navigate to `count += 1;`
   - Press `<leader>db` to set breakpoint

4. **Start Chrome debugging**:
   - Press `<leader>dc`
   - Select "Launch Chrome to debug client"
   - Chrome will open with your app

5. **Trigger the breakpoint**:
   - Click the "Count" button in the browser
   - Neovim should stop at your breakpoint!
   - Use the same debug navigation keys

## Debugging Both Client and Server Together

1. **Start server debugging first**:
   ```bash
   NODE_OPTIONS="--inspect" npm run dev
   ```

2. **In Neovim, attach to the server**:
   - Open `src/routes/api/test/+server.ts`
   - Set breakpoints
   - Press `<leader>dc` → "Attach to Node --inspect process"

3. **In a separate Neovim instance (or tab), debug the client**:
   - Open `src/routes/+page.svelte`
   - Set breakpoints
   - Press `<leader>dc` → "Launch Chrome to debug client"

4. **Click "Fetch Data"** in the browser:
   - First hits the client-side breakpoint in `fetchData()`
   - Then hits the server-side breakpoint in the API route!

## Troubleshooting

### Breakpoints not hitting?

1. **Check source maps**:
   - Ensure your dev server is running
   - Vite enables source maps by default

2. **Verify debugger is attached**:
   - Run `:DapContinue` to see if debugger connects
   - Check the REPL output (`:lua require('dap').repl.open()`)

3. **Check the log**:
   ```vim
   :lua require('dap').set_log_level('TRACE')
   :edit ~/.local/state/nvim/dap.log
   ```

### vscode-js-debug build failed?

1. **Manually rebuild**:
   ```bash
   cd ~/.local/share/nvim/lazy/vscode-js-debug
   npm install
   npm run compile vsDebugServerBundle
   mv dist out
   ```

### Process picker shows no processes?

- Make sure you started the dev server with `NODE_OPTIONS="--inspect"`
- The debugger port should be visible in the terminal output

## Useful Commands

- `:DapContinue` - Start/continue debugging
- `:DapToggleBreakpoint` - Toggle breakpoint at current line
- `:DapTerminate` - Stop debugging session
- `:DapStepOver` - Step over current line
- `:DapStepInto` - Step into function
- `:DapStepOut` - Step out of function
- `:lua require('dapui').toggle()` - Toggle debug UI

## Quick Reference: Keymaps

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue/Start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>du` | Toggle UI |
| `<leader>dt` | Terminate session |
| `<leader>dh` | Hover variables |

## Next Steps

Once you've verified everything works:

1. **Add to your package.json**:
   ```json
   {
     "scripts": {
       "dev:debug": "NODE_OPTIONS='--inspect' vite dev"
     }
   }
   ```

2. **Create a `.vscode/launch.json`** (optional, for reference):
   - nvim-dap doesn't use this, but it's good documentation

3. **Learn more**:
   - `:help dap.txt`
   - `:help dap-configuration`
   - Visit: https://github.com/mfussenegger/nvim-dap

Happy debugging! 🐛
