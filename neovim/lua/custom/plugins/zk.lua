-- Notebook lives at ~/repos/notes. Layout: PARA dirs for lifecycle,
-- zettel/ for atomic notes. Groups and templates in notes/.zk/config.toml.
local notebook = vim.fn.expand '~/repos/notes'

local function new_in(dir, opts)
  return function()
    require('zk.commands').get('ZkNew')(vim.tbl_extend('force', { dir = notebook .. '/' .. dir }, opts or {}))
  end
end

local function prompt_new(dir, prompt)
  return function()
    vim.ui.input({ prompt = prompt }, function(title)
      if title and title ~= '' then
        require('zk.commands').get('ZkNew') { dir = notebook .. '/' .. dir, title = title }
      end
    end)
  end
end

return {
  'zk-org/zk-nvim',
  name = 'zk',
  opts = {
    picker = 'snacks_picker',
    lsp = {
      config = {
        cmd = { 'zk', 'lsp' },
        filetypes = { 'markdown' },
      },
      auto_attach = { enabled = true },
    },
  },
  keys = {
    -- Create
    { '<leader>nn', prompt_new('zettel', 'Zettel title: '), desc = 'New zettel' },
    { '<leader>nj', new_in('journal', { noInput = true }), desc = 'New journal entry' },
    { '<leader>np', prompt_new('projects', 'Project title: '), desc = 'New project' },
    { '<leader>na', prompt_new('areas', 'Area title: '), desc = 'New area' },
    { '<leader>nr', prompt_new('resources', 'Resource title: '), desc = 'New resource' },
    { '<leader>nm', prompt_new('moc', 'Map title: '), desc = 'New map of content' },
    { '<leader>nN', ':ZkNewFromTitleSelection<cr>', mode = 'v', desc = 'New zettel from selection' },

    -- Browse
    { '<leader>no', '<cmd>ZkNotes<cr>', desc = 'Open notes' },
    { '<leader>nt', '<cmd>ZkTags<cr>', desc = 'Browse tags' },
    { '<leader>nf', ':ZkMatch<cr>', mode = 'v', desc = 'Search for selection' },

    -- Graph
    { '<leader>ni', '<cmd>ZkInsertLink<cr>', desc = 'Insert link' },
    { '<leader>nb', '<cmd>ZkBacklinks<cr>', desc = 'Backlinks' },
    { '<leader>nl', '<cmd>ZkLinks<cr>', desc = 'Links' },
    { '<leader>nR', function() require('zk.commands').get 'ZkNotes' { hrefs = { vim.fn.expand '%:p' }, related = true } end, desc = 'Related notes' },
    { '<leader>nO', function() require('zk.commands').get 'ZkNotes' { orphan = true, exclude = { 'journal' } } end, desc = 'Orphan notes' },
  },
}
