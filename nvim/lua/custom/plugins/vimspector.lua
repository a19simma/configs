return {
    "puremourning/vimspector",
    ft = { "cs" },
    config = function()
        function map(mode, lhs, rhs, opts)
            local options = { noremap = true }
            if opts then
                options = vim.tbl_extend("force", options, opts)
            end
            vim.api.nvim_set_keymap(mode, lhs, rhs, options)
        end

        local cmd = vim.api.nvim_command
        vim.cmd([[
            nmap <F9> <cmd>call vimspector#Launch()<cr>
            nmap <F5> <cmd>call vimspector#StepOver()<cr>
            nmap <F8> <cmd>call vimspector#Reset()<cr>
            nmap <F11> <cmd>call vimspector#StepOver()<cr>")
            nmap <F12> <cmd>call vimspector#StepOut()<cr>")
            nmap <F10> <cmd>call vimspector#StepInto()<cr>")
            nmap <F6> <cmd>call vimspector#Continue()<cr>")
        ]])
        map('n', "Db", ":call vimspector#ToggleBreakpoint()<cr>")
        map('n', "Dw", ":call vimspector#AddWatch()<cr>")
        map('n', "De", ":call vimspector#Evaluate()<cr>")
        vim.g.vimspector_enable_mappings = 'HUMAN'
    end
}
