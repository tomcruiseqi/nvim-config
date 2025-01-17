local fn = vim.fn
local api = vim.api
local diagnostic = vim.diagnostic
local utils = require("utils")
local wk = require("which-key")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp = require("lspconfig")
local coq = require("coq")

local custom_attach = function(client, bufnr)
  -- self-setup keybindings using which-key.
  wk.register({
    w = {
      name = "lspkeymap",
      D = {
        vim.lsp.buf.declaration,
        "Go to declaratin",
      },
      d = {
        vim.lsp.buf.definition,
        "Go to definition",
      },
      h = {
        vim.lsp.buf.document_highlight,
        "Highlight on selection.",
      },
      s = {
        vim.lsp.buf.document_symbol,
        "List all symbols.",
      },
      F = {
        vim.lsp.buf.format,
        "Format.",
      },
      b = {
        vim.lsp.buf.hover,
        "Brief of selection.",
      },
      i = {
        vim.lsp.buf.implementation,
        "Get all implementations.",
      },
      c = {
        vim.lsp.buf.incoming_calls,
        "Find all symbol usages.",
      },
      C = {
        vim.lsp.buf.outgoing_calls,
        "Get all callees.",
      },
      R = {
        vim.lsp.buf.references,
        "Get all references.",
      },
      S = {
        vim.lsp.buf.server_ready,
        "Check server status.",
      },
      a = {
        vim.lsp.buf.add_workspace_folder,
        "Add lsp workspace.",
      },
      r = {
        vim.lsp.buf.rename,
        "Rename the variable.",
      },
    },
  }, {
    prefix = "<Space>",
    buffer = bufnr,
  })

  api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local float_opts = {
        focusable = false,
        close_events = {
          "BufLeave",
          "CursorMoved",
          "InsertEnter",
          "FocusLost",
        },
        border = "rounded",
        source = "always", -- show source in diagnostic popup window
        prefix = " ",
      }

      if not vim.b.diagnostics_pos then
        vim.b.diagnostics_pos = { nil, nil }
      end

      local cursor_pos = api.nvim_win_get_cursor(0)
      if
        (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
        and #diagnostic.get() > 0
      then
        diagnostic.open_float(nil, float_opts)
      end

      vim.b.diagnostics_pos = cursor_pos
    end,
  })

  -- The blow command will highlight the current variable and its usages in the buffer.
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd([[
      hi! link LspReferenceRead Visual
      hi! link LspReferenceText Visual
      hi! link LspReferenceWrite Visual
    ]])
  end
end

if utils.executable("pylsp") then
  lsp.pylsp.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    settings = {
      pylsp = {
        plugins = {
          pylint = { enabled = true, executable = "pylint" },
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          jedi_completion = { fuzzy = true },
          pyls_isort = { enabled = true },
          pylsp_mypy = { enabled = true },
        },
      },
    },
    capabilities = capabilities,
  })
else
  vim.notify("pylsp not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

if utils.executable("clangd") then
  lsp.clangd.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    capabilities = capabilities,
  })
end

-- set up vim-language-server
if utils.executable("vim-language-server") then
  lsp.vimls.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    capabilities = capabilities,
  })
end

-- set up bash-language-server
if utils.executable("bash-language-server") then
  lsp.bashls.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    capabilities = capabilities,
  })
end

-- Set up lua-language-server.
if utils.executable("lua-language-server") then
  lsp.lua_ls.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of
          -- Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files,
          -- see also https://github.com/LuaLS/lua-language-server/wiki
          -- /Libraries#link-to-workspace .
          -- Lua-dev.nvim also has similar settings for lua ls,
          -- https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
          library = {
            fn.stdpath("data") .. "/site/pack/packer/opt/emmylua-nvim",
            fn.stdpath("config"),
          },
          maxPreload = 2000,
          preloadFileSize = 50000,
        },
      },
    },
  })
end

-- Set up golang-language-server.
if utils.executable("gopls") then
  lsp.gopls.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    capabilities = capabilities,
  })
end

-- Set up ruby language server.
if utils.executable("ruby-lsp") then
  lsp.gopls.setup(coq.lsp_ensure_capabilities {
    on_attach = custom_attach,
    capabilities = capabilities,
  })
end
