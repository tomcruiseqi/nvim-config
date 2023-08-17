local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local utils = require("utils")

local custom_attach = function(client, bufnr)
	-- Use LspAttach autocommand to only map the following keys
	-- after the language server attaches to the current buffer
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			-- Enable completion triggered by <c-x><c-o>
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

			-- self-setup keybindings using which-key.
			local wk = require("which-key")
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
					r = {
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
				},
			}, {
				prefix = "<Space>",
				buffer = ev.buf,
			})
		end,
	})

	-- Mappings.
	local map = function(mode, l, r, opts)
		opts = opts or {}
		opts.silent = true
		opts.buffer = bufnr
		keymap.set(mode, l, r, opts)
	end

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
				(
					cursor_pos[1] ~= vim.b.diagnostics_pos[1]
					or cursor_pos[2] ~= vim.b.diagnostics_pos[2]
				) and #diagnostic.get() > 0
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

		local gid =
			api.nvim_create_augroup("lsp_document_highlight", { clear = true })
		api.nvim_create_autocmd("CursorHold", {
			group = gid,
			buffer = bufnr,
			callback = function()
				lsp.buf.document_highlight()
			end,
		})

		api.nvim_create_autocmd("CursorMoved", {
			group = gid,
			buffer = bufnr,
			callback = function()
				lsp.buf.clear_references()
			end,
		})
	end

	if vim.g.logging_level == "debug" then
		local msg = string.format("Language server %s started!", client.name)
		vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
	end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig")

if utils.executable("pylsp") then
	lspconfig.pylsp.setup({
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
		flags = {
			debounce_text_changes = 200,
		},
		capabilities = capabilities,
	})
else
	vim.notify(
		"pylsp not found!",
		vim.log.levels.WARN,
		{ title = "Nvim-config" }
	)
end

-- if utils.executable('pyright') then
--   lspconfig.pyright.setup{
--     on_attach = custom_attach,
--     capabilities = capabilities
--   }
-- else
--   vim.notify("pyright not found!", vim.log.levels.WARN, {title = 'Nvim-config'})
-- end

if utils.executable("ltex-ls") then
	lspconfig.ltex.setup({
		on_attach = custom_attach,
		cmd = { "ltex-ls" },
		filetypes = { "text", "plaintex", "tex", "markdown" },
		settings = {
			ltex = {
				language = "en",
			},
		},
		flags = { debounce_text_changes = 300 },
	})
end

if utils.executable("clangd") then
	lspconfig.clangd.setup({
		on_attach = custom_attach,
		capabilities = capabilities,
		filetypes = { "c", "cpp", "cc" },
		flags = {
			debounce_text_changes = 500,
		},
	})
end

-- set up vim-language-server
if utils.executable("vim-language-server") then
	lspconfig.vimls.setup({
		on_attach = custom_attach,
		flags = {
			debounce_text_changes = 500,
		},
		capabilities = capabilities,
	})
else
	vim.notify(
		"vim-language-server not found!",
		vim.log.levels.WARN,
		{ title = "Nvim-config" }
	)
end

-- set up bash-language-server
if utils.executable("bash-language-server") then
	lspconfig.bashls.setup({
		on_attach = custom_attach,
		capabilities = capabilities,
	})
end

if utils.executable("lua-language-server") then
	-- settings for lua-language-server can be found on https://github.com/LuaLS/lua-language-server/wiki/Settings .
	lspconfig.lua_ls.setup({
		on_attach = custom_attach,
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files,
					-- see also https://github.com/LuaLS/lua-language-server/wiki/Libraries#link-to-workspace .
					-- Lua-dev.nvim also has similar settings for lua ls, https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
					library = {
						fn.stdpath("data")
							.. "/site/pack/packer/opt/emmylua-nvim",
						fn.stdpath("config"),
					},
					maxPreload = 2000,
					preloadFileSize = 50000,
				},
			},
		},
		capabilities = capabilities,
	})
end

lspconfig.tsserver.setup({})
-- for rust.
lspconfig.rust_analyzer.setup({
	-- Server-specific settings. See `:help lspconfig-setup`
	settings = {
		["rust-analyzer"] = {},
	},
})
-- for html
--Enable (broadcasting) snippet capability for completion
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.html.setup({ capabilities = capabilities })
lspconfig.jsonls.setup({ capabilities = capabilities })
lspconfig.cssls.setup({ capabilities = capabilities })
lspconfig.eslint.setup({
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})

-- for java.
lspconfig.java_language_server.setup({
	cmd = {
		"/home/qizengtian/Documents/02-source/40-java-language-server/dist/lang_server_linux.sh",
	},
})

-- for ruby.
lspconfig.ruby_ls.setup({})

-- for sql.
lspconfig.sqlls.setup({})

-- Change diagnostic signs.
fn.sign_define(
	"DiagnosticSignError",
	{ text = "✗", texthl = "DiagnosticSignError" }
)
fn.sign_define(
	"DiagnosticSignWarn",
	{ text = "!", texthl = "DiagnosticSignWarn" }
)
fn.sign_define(
	"DiagnosticSignInformation",
	{ text = "", texthl = "DiagnosticSignInfo" }
)
fn.sign_define(
	"DiagnosticSignHint",
	{ text = "", texthl = "DiagnosticSignHint" }
)

-- global config for diagnostic
diagnostic.config({
	underline = false,
	virtual_text = false,
	signs = true,
	severity_sort = true,
})

-- lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
--   underline = false,
--   virtual_text = false,
--   signs = true,
--   update_in_insert = false,
-- })

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
