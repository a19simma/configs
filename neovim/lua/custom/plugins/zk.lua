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
    { '<leader>zn', function()
        vim.ui.input({ prompt = 'Note title: ' }, function(title)
          if title and title ~= '' then
            require('zk.commands').get('ZkNew')({ dir = vim.fn.expand('~/repos/knowledge/notes'), title = title })
          end
        end)
      end, desc = 'New note' },
    { '<leader>zj', function() require('zk.commands').get('ZkNew')({ dir = vim.fn.expand('~/repos/knowledge/journal'), noInput = true }) end, desc = 'New journal entry' },
    { '<leader>zo', '<cmd>ZkNotes<cr>', desc = 'Open notes' },
    { '<leader>zt', '<cmd>ZkTags<cr>', desc = 'Browse tags' },
    { '<leader>zi', '<cmd>ZkInsertLink<cr>', desc = 'Insert link' },
    { '<leader>zb', '<cmd>ZkBacklinks<cr>', desc = 'Backlinks' },
    { '<leader>zl', '<cmd>ZkLinks<cr>', desc = 'Links' },
  },
}
