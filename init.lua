-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "catppuccin/nvim",
  
  -- git
  "tpope/vim-fugitive",
  
  -- Powerline alternative
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },
  
  -- LSP
  "neovim/nvim-lspconfig",
  
  -- Autocomplete
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
  },
  
  -- Debugging
  "mfussenegger/nvim-dap",
  "mfussenegger/nvim-dap-python",
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" }
  },
  "theHamsta/nvim-dap-virtual-text",
  
  -- LaTeX
  "lervag/vimtex",
  
  -- Telescope for fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
  -- AnsiEsc
  {
    'powerman/vim-plugin-AnsiEsc',
    cmd = 'AnsiEsc'
  }, 
  -- Claude Code
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
    -- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
    -- spec defers loading until a <leader>a* mapping is pressed and the commands
    -- would not exist yet.
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeStatus",
      "ClaudeCodeStart",
      "ClaudeCodeStop",
      "ClaudeCodeOpen",
      "ClaudeCodeClose",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeCloseAllDiffs",
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  }
})

-- cross platform --
local is_mac = vim.fn.has('macunix') == 1

if is_mac then
  vim.g.vimtex_view_method = 'skim'
  vim.g.vimtex_view_skim_sync = 1
  vim.g.vimtex_view_skim_activate = 1
else
  vim.g.vimtex_view_method = 'zathura'
end

vim.env.GIT_EDITOR = 'nvim'
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("vertical,algorithm:histogram,indent-heuristic")

vim.keymap.set('n', ']q', ':cnext<CR>', { desc = "Next quickfix item" })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = "Previous quickfix item" })
vim.keymap.set('n', '<leader>q', ':copen<CR>', { desc = "Open quickfix" })

-- Color scheme
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

-- 
-- 1. LaTeX configuration
--
-- vim.g.vimtex_view_method = 'general'
-- vim.g.vimtex_view_general_viewer = 'open'
-- vim.g.vimtex_view_general_options = '-a "PDF Expert" --args'

vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1

-- Configure vimtex to use make
vim.g.vimtex_compiler_method = 'generic'
vim.g.vimtex_compiler_generic = {
  command = 'make',
  build_dir = '',
  callback = 1,
  continuous = 0,
  executable = 'make',
  options = {
    '-f', 'Makefile',
  },
}

-- Hack to compile single file LaTeX sources
vim.keymap.set('n', '<leader>lx', function()
  vim.cmd('!latexmk -pdf -synctex=1 ' .. vim.fn.shellescape(vim.fn.expand('%')))
end, { desc = 'Compile current LaTeX file with latexmk' })

-- Only show errors and critical warnings
vim.g.vimtex_quickfix_mode = 1
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_quickfix_ignore_filters = {
  'Underfull \\hbox',
  'Overfull \\hbox',
  'Package hyperref Warning',
  'LaTeX Font Warning',
}

-- Autocompletion 

vim.g.vimtex_complete_enabled = 0

-- LaTeX-specific setup: use only LSP (texlab)


-- Make sure omnifunc is not set to vimtex in LaTeX files
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"tex", "latex"},
  callback = function()
    vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc" 
  end
})

-- Set up lualine (Powerline alternative)
require('lualine').setup {
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {
      -- Python virtual environment component
      {
        function()
          if vim.bo.filetype == "python" then
            local venv = vim.env.VIRTUAL_ENV
            if venv then
              local venv_name = vim.fn.fnamemodify(venv, ':t')
              return '  ' .. venv_name
            end
          end
          return ''
        end,
        color = { fg = '#98be65' },
      },
      'encoding', 
      'fileformat', 
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}

-- 
-- 2. LSP Configuration
-- 

-- Apply cmp capabilities to every server
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Python
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

-- JavaScript/TypeScript/React
vim.lsp.config('ts_ls', {
  filetypes = { "javascript", "javascriptreact", "javascript.jsx",
                "typescript", "typescriptreact", "typescript.tsx" },
})

-- LaTeX
vim.lsp.config('texlab', {
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = false,
      },
      chktex = {
        onOpenAndSave = false,
        onEdit = false,
      },
      bibtex = {
        formatting = { lineLength = 120 },
      },
      completion = {
        bibtex = { enabled = true },
      },
    },
  },
})

-- bashls and sqlls need no overrides
vim.lsp.enable({ 'pyright', 'bashls', 'ts_ls', 'sqlls', 'texlab' })


-- Add keybindings for LSP functionality
local opts = { noremap=true, silent=true }
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)

-- Add keybindings for project navigation
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {})

-- Set the working directory to the project root
-- vim.cmd[[
--   augroup latex_workdir
--     autocmd!
--     autocmd FileType tex lcd %:p:h
--   augroup END
-- ]]


--
-- 3. Nvimtree
-- 
require('nvim-tree').setup()


-- Markers that indicate a project root
local project_files = {
  'Makefile', 'makefile', 'main.tex',
  'requirements.txt', 'pyproject.toml', 'setup.py',
  'package.json', 'Cargo.toml', 'CMakeLists.txt',
  'build.gradle', 'pom.xml', 'Gemfile', 'composer.json',
  'go.mod', '.projectile',
}

-- Cache: dir -> bool, so we don't walk the filesystem on every buffer switch
local project_cache = {}

local function is_project_file()
  local dir = vim.fn.expand('%:p:h')
  if dir == '' then return false end
  if project_cache[dir] ~= nil then return project_cache[dir] end

  local found = false
  for _, name in ipairs(project_files) do
    if vim.fn.findfile(name, dir .. ';') ~= '' then
      found = true
      break
    end
  end
  -- .git is usually a directory, but a *file* in submodules and worktrees
  if not found then
    if vim.fn.finddir('.git', dir .. ';') ~= ''
       or vim.fn.findfile('.git', dir .. ';') ~= '' then
      found = true
    end
  end

  project_cache[dir] = found
  return found
end

-- Filetypes that should never trigger the sidebar
local ignored_filetypes = {
  help = true, qf = true, netrw = true, NvimTree = true,
  startify = true, dashboard = true, packer = true,
  neogitstatus = true, fugitive = true,
  TelescopePrompt = true, TelescopeResults = true, mail = true,
}

local function tree_is_visible()
  local ok, view = pcall(require, 'nvim-tree.view')
  return ok and view.is_visible()
end

vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function(args)
    -- real file buffers only: skip terminals, quickfix, nvim-tree itself, etc.
    if vim.bo[args.buf].buftype ~= '' then return end
    if vim.api.nvim_buf_get_name(args.buf) == '' then return end
    if ignored_filetypes[vim.bo[args.buf].filetype] then return end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end

      local want_open = is_project_file()
      local is_open = tree_is_visible()

      -- Only act when the state actually needs to change
      if want_open and not is_open then
        local cur = vim.api.nvim_get_current_win()
        require('nvim-tree.api').tree.open()
        if vim.api.nvim_win_is_valid(cur) then
          vim.api.nvim_set_current_win(cur)
        end
      elseif not want_open and is_open then
        require('nvim-tree.api').tree.close()
      end
    end)
  end,
})

-- Clear the project-root cache (e.g. after adding a Makefile mid-session)
vim.api.nvim_create_user_command('ProjectCacheClear', function()
  project_cache = {}
end, {})

-- Still keep the manual toggle available
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })


-- Fix disappearing cursor in iTerm2 on Mac
vim.opt.guicursor = ""  -- Disable Neovim's cursor shape control

-- 
-- 4. Global line number settings
-- 
--
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = false  -- Turn off relative line numbers (optional)

-- Create an autocommand to disable line numbers for specific file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"text", "tex", "latex", "markdown", "plaintex"},
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})

-- Create an autocommand to ensure line numbers are on for programming languages
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp", "python", "javascript", "typescript", "java", "rust", "go", "bash", "sh", "zsh", "lua"},
  callback = function()
    vim.opt_local.number = true
    -- If you want relative numbers for programming languages, uncomment below:
    -- vim.opt_local.relativenumber = true
  end
})

-- Toggle regular line numbers
vim.keymap.set('n', '<leader>n', function()
  vim.opt.number = not vim.opt.number:get()
end, { noremap = true, silent = true, desc = "Toggle line numbers" })

-- Toggle relative line numbers
vim.keymap.set('n', '<leader>rn', function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { noremap = true, silent = true, desc = "Toggle relative line numbers" })

-- Toggle both line number types (completely on/off)
vim.keymap.set('n', '<leader>tn', function()
  if vim.opt.number:get() and vim.opt.relativenumber:get() then
    -- If both are on, turn both off
    vim.opt.number = false
    vim.opt.relativenumber = false
  elseif vim.opt.number:get() then
    -- If only number is on, turn on relative number too
    vim.opt.relativenumber = true
  else
    -- If both are off, turn on number
    vim.opt.number = true
  end
end, { noremap = true, silent = true, desc = "Cycle through line number modes" })

-- 
-- 5.Import key mappings from .exrc
-- Originally by Garrett Hillebrand, adapted by Nicolas Christin, 2002
-- 
--

-- Key mappings (using the = prefix)
vim.keymap.set('n', '=dd', ':!rm %<CR>:n<CR>', { noremap = true, silent = false })

-- Formatting options
vim.keymap.set('n', '=j', '!}par 72<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '=J', '!}par 60j<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '=S', ':r ~/.signature.long<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '=w', ':w<CR>:n<CR>', { noremap = true, silent = false })

-- === Sentence-per-line formatter with paragraph reflow ===
-- Put this in your init.lua

local function process_paragraph_text(s)
  -- Split into sentences: after ., ?, or ! followed by whitespace
  -- (Lua patterns: escape special chars with %)
  s = s:gsub("([%.%!%?])%s+", "%1\n")
  -- Trim trailing spaces per line
  s = s:gsub("[ \t]+\n", "\n")
  return s
end

local function format_range(first, last)
  local bufnr = 0
  -- Get lines (Lua uses 0-based indexing; nvim_buf_get_lines end is exclusive)
  local lines = vim.api.nvim_buf_get_lines(bufnr, first - 1, last, false)

  local out = {}
  local para = nil

  local function flush_para()
    if para ~= nil then
      -- Sentence split within this paragraph
      local processed = process_paragraph_text(para)
      -- Explode on \n into out[]
      for line in processed:gmatch("([^\n]*)\n?") do
        if line ~= "" then
          table.insert(out, line)
        end
      end
      para = nil
    end
  end

  for _, l in ipairs(lines) do
    if l:match("^%s*$") then
      -- Blank line: end of paragraph
      flush_para()
      table.insert(out, "") -- preserve blank line
    else
      -- Trim trailing spaces
      local trimmed = l:gsub("%s+$", "")
      if para == nil then
        -- Start new paragraph with leading spaces trimmed
        para = trimmed:gsub("^%s+", "")
      else
        -- If previous line ended with hyphen, drop it and add one space
        if para:sub(-1) == "-" then
          para = para:sub(1, -2) .. " " .. trimmed:gsub("^%s+", "")
        else
          para = para .. " " .. trimmed:gsub("^%s+", "")
        end
      end
    end
  end
  -- Last paragraph (if file doesn't end with blank line)
  flush_para()

  -- Replace the original range with the formatted output
  vim.api.nvim_buf_set_lines(bufnr, first - 1, last, false, out)
end

local function find_current_paragraph_bounds()
  local cur = vim.api.nvim_win_get_cursor(0)
  local row = cur[1] -- 1-based
  local last_line = vim.api.nvim_buf_line_count(0)

  -- Find previous blank line (or BOF)
  local start_line = row
  while start_line > 1 do
    local prev = vim.api.nvim_buf_get_lines(0, start_line - 2, start_line - 1, false)[1]
    if prev:match("^%s*$") then break end
    start_line = start_line - 1
  end

  -- Find next blank line (or EOF)
  local end_line = row
  while end_line < last_line do
    local nextl = vim.api.nvim_buf_get_lines(0, end_line, end_line + 1, false)[1]
    if nextl:match("^%s*$") then break end
    end_line = end_line + 1
  end

  return start_line, end_line
end

-- Keymaps

-- Current paragraph
vim.keymap.set('n', '=f', function()
  local s, e = find_current_paragraph_bounds()
  format_range(s, e)
end, { noremap = true, silent = true })

-- Whole buffer
vim.keymap.set('n', '=F', function()
  format_range(1, vim.api.nvim_buf_line_count(0))
end, { noremap = true, silent = true })

-- Visual selection (linewise)
vim.keymap.set('v', '=f', function()
  local s = vim.fn.line("'<")
  local e = vim.fn.line("'>")
  format_range(s, e)
end, { noremap = true, silent = true })



-- Center line
vim.keymap.set('n', '=c', '072i <CR>$70hd0:s/  / /g<CR>', { noremap = true, silent = false })

-- Replace time-stamp (for web pages)
vim.keymap.set('n', '=T', ':d<CR>:-1<CR>:r !date<CR>', { noremap = true, silent = false })

-- Spell checking
vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.keymap.set('n', '=s', ':set spell!<CR>', { noremap = true })

vim.keymap.set('n', '=V', function()
  vim.cmd('w')  -- Save first
  local file = vim.fn.expand('%')
  vim.cmd('terminal aspell -d american -c ' .. file)
  -- Set up autocmd to reload file when terminal closes
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = 0,
    once = true,
    callback = function()
      vim.cmd('bdelete!')  -- Close terminal buffer
      vim.cmd('e!')        -- Reload the file
    end
  })
end, { noremap = true, silent = false })

-- Spell checking with French dictionary
vim.keymap.set('n', '=vf', function()
  vim.cmd('w')  -- Save first
  local file = vim.fn.expand('%')
  vim.cmd('terminal aspell -d francais -c ' .. file)
  -- Set up autocmd to reload file when terminal closes
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = 0,
    once = true,
    callback = function()
      vim.cmd('bdelete!')  -- Close terminal buffer
      vim.cmd('e!')        -- Reload the file
    end
  })
end, { noremap = true, silent = false })


--
-- 6. DAP (Debugger) configuration
--
-- Python debugging setup
local dap = require('dap')
local dap_python = require('dap-python')

-- Use the current virtual environment's python
dap_python.setup('python')  -- This will use 'python' from your PATH, which should be your venv python

-- Key mappings for debugging
vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<leader>dB', function() 
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) 
end, { desc = "Set conditional breakpoint" })
vim.keymap.set('n', '<leader>dc', function() dap.continue() end, { desc = "Continue/Start debugging" })
vim.keymap.set('n', '<leader>dn', function() dap.step_over() end, { desc = "Step over" })
vim.keymap.set('n', '<leader>di', function() dap.step_into() end, { desc = "Step into" })
vim.keymap.set('n', '<leader>do', function() dap.step_out() end, { desc = "Step out" })
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = "Open debug REPL" })
vim.keymap.set('n', '<leader>dl', function() dap.run_last() end, { desc = "Run last" })
vim.keymap.set('n', '<leader>dt', function() dap.terminate() end, { desc = "Terminate debugging" })

-- Visual indicator for breakpoints
vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='🔸', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapLogPoint', {text='📝', texthl='', linehl='', numhl=''})

-- Optional: Configure dap-ui for better debugging experience
require("dapui").setup()
local dapui = require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Python debugging configurations
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      -- Return the path to the python executable in your virtual environment
      if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
      else
        return '/usr/bin/python3'
      end
    end,
  },
  {
    type = 'python',
    request = 'launch',
    name = "Launch Django server",
    program = vim.fn.getcwd() .. '/manage.py',
    args = {'runserver', '--noreload'},
    pythonPath = function()
      if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
      else
        return '/usr/bin/python3'
      end
    end,
    django = true,
  },
  {
    type = 'python',
    request = 'launch',
    name = "Launch module",
    module = function()
      return vim.fn.input('Module name: ')
    end,
    pythonPath = function()
      if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
      else
        return '/usr/bin/python3'
      end
    end,
  },
}

-- Enable virtual text for debugging
require("nvim-dap-virtual-text").setup()


-- Auto-detect Python virtual environment
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = "*.py",
  callback = function()
    -- Check for various virtual environment patterns
    local venv_path = vim.fn.getcwd() .. '/venv'
    local env_path = vim.fn.getcwd() .. '/.venv'
    local conda_env = vim.fn.getcwd() .. '/conda-env'

    -- pick the first venv that exists
    local venv = nil
    if vim.fn.isdirectory(venv_path) == 1 then
      venv = venv_path
    elseif vim.fn.isdirectory(env_path) == 1 then
      venv = env_path
    elseif vim.fn.isdirectory(conda_env) == 1 then
      venv = conda_env
    end

    -- only touch PATH if we're actually switching to a different venv
    if venv and vim.env.VIRTUAL_ENV ~= venv then
      vim.env.VIRTUAL_ENV = venv
      vim.env.PATH = venv .. '/bin:' .. vim.env.PATH
    end    
  end
})

-- 
-- 7. Fugitive/git
--

vim.g.fugitive_async = 1

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "tex",
--   callback = function()
--     if vim.fn.expand('%') ~= '' and not vim.fn.expand('%'):match('^fugitive:') then
--       vim.cmd('lcd %:p:h')
--     end
--   end,
--   group = vim.api.nvim_create_augroup("latex_workdir", { clear = true })
-- })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  group = vim.api.nvim_create_augroup("latex_workdir", { clear = true }),
  callback = function()
    local name = vim.fn.expand('%')
    if name == '' or name:match('^fugitive:') then return end
    local mk = vim.fn.findfile('Makefile', vim.fn.expand('%:p:h') .. ';')
    if mk ~= '' then
      vim.cmd('lcd ' .. vim.fn.fnameescape(vim.fn.fnamemodify(mk, ':p:h')))
    else
      vim.cmd('lcd %:p:h')  -- fall back to old behavior for standalone files
    end
  end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "*",
--   callback = function()
--     if vim.bo.filetype == "gitcommit" then
--       vim.cmd("startinsert")
--     end
--   end
-- })
--
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    -- Simple delay to ensure window is properly set up
    vim.defer_fn(function()
      vim.cmd("startinsert")
    end, 50)
  end
})

-- Ensure proper focus when entering commit buffer
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "COMMIT_EDITMSG",
  callback = function()
    vim.defer_fn(function()
      vim.cmd("startinsert")
    end, 50)
  end
})


vim.api.nvim_create_autocmd("User", {
  pattern = "FugitiveCommit",
  callback = function()
    vim.cmd("bdelete")
    -- Force focus back to main editing area (not NvimTree)
    vim.cmd("wincmd l")  -- Move to right window (main editor)
  end
})

-- Git shortcuts
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = "Git push" })
vim.keymap.set('n', '<leader>gl', ':Git pull<CR>', { desc = "Git pull" })
vim.keymap.set('n', '<leader>gs', ':Git status<CR>', { desc = "Git status" })
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { desc = "Diff buffer against index" })
vim.keymap.set('n', '<leader>gD', ':Gvdiffsplit HEAD<CR>', { desc = "Diff buffer against HEAD" })
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = "Git commit" })

vim.keymap.set('n', '<leader>gt', function()
  local tag = vim.fn.input('Tag name: ')
  local message = vim.fn.input('Tag message: ')
  if tag ~= '' then
    vim.cmd('Git tag -a ' .. tag .. ' -m "' .. message .. '"')
    local push = vim.fn.input('Push tag? (y/n): ')
    if push:lower() == 'y' then
      vim.cmd('Git push origin ' .. tag)
    end
  end
end, { desc = 'Create and optionally push Git tag' })

--
-- 8. Indents
-- 
local indent_settings = {
  lua = 2,
  javascript = 2,
  typescript = 2,
  html = 2,
  css = 2,
  json = 2,
  yaml = 2,
  tex = 2,
  latex = 2,
  python = 4,  -- PEP 8 standard
  go = 4,      -- Go convention (though Go uses tabs by default)
  rust = 4,    -- Rust official standard
}

for filetype, spaces in pairs(indent_settings) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    callback = function()
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = spaces
      vim.opt_local.tabstop = spaces
      vim.opt_local.softtabstop = spaces
    end,
  })
end

--
-- 9. Autocompletion setup
--
local cmp = require('cmp')

cmp.setup({
  completion = {
--    autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
    autocomplete = false, 
    completeopt = 'menu,menuone,noselect',
  },

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },    -- LSP completions
    { name = 'buffer' },      -- Buffer completions
    { name = 'path' },        -- Path completions
  }),
  
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-n>'] = cmp.mapping.complete(),      
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  
  -- Optional: customize appearance
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        buffer = "[Buffer]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end
  },
})

-- LaTeX-specific completion configuration for better citation support
cmp.setup.filetype('tex', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },  -- Prioritize LSP (texlab) for LaTeX
    { name = 'buffer', priority = 800 },     -- Buffer scanning for existing citations
    { name = 'path', priority = 300 },       -- Path completions
  })
})


vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    require("nvim-tree").setup({
      update_focused_file = {
        enable = true,
        update_root = false,
      },
    })
  end,
})
