-- Add copy keybinding to all Telescope pickers
return {
  'nvim-telescope/telescope.nvim',
  opts = function(_, opts)
    local action_state = require 'telescope.actions.state'

    -- Ensure defaults and mappings exist
    opts.defaults = opts.defaults or {}
    opts.defaults.mappings = opts.defaults.mappings or {}
    opts.defaults.mappings.i = opts.defaults.mappings.i or {}
    opts.defaults.mappings.n = opts.defaults.mappings.n or {}

    -- Add copy keybinding to insert and normal mode
    local copy_function = function(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if selection then
        local text = selection.value or selection.display or selection.ordinal or ''
        vim.fn.setreg('+', text)
        vim.notify('Copied: ' .. text:sub(1, 50), vim.log.levels.INFO)
      end
    end

    opts.defaults.mappings.i['<C-y>'] = copy_function
    opts.defaults.mappings.n['<C-y>'] = copy_function

    return opts
  end,
}
