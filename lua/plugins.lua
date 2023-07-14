local api = vim.api
local fn = vim.fn

local utils = require("utils")

-- The root dir to install all plugins.
-- Plugins are under opt/ or start/ sub-directory.
vim.g.plugin_home = fn.stdpath("data") .. "/site/pack/packer"

--- Install packer if it has not been installed.
--- Return:
--- true: if this is a fresh install of packer
--- false: if packer has been installed
local function packer_ensure_install()
	-- Where to install packer.nvim -- the package manager (we make it opt)
	local packer_dir = vim.g.plugin_home .. "/opt/packer.nvim"

	if fn.glob(packer_dir) ~= "" then
		return false
	end

	-- Auto-install packer in case it hasn't been installed.
	vim.api.nvim_echo({ { "Installing packer.nvim", "Type" } }, true, {})

	local packer_repo = "https://github.com/wbthomason/packer.nvim"
	local install_cmd =
		string.format("!git clone --depth=1 %s %s", packer_repo, packer_dir)
	vim.cmd(install_cmd)

	return true
end

local fresh_install = packer_ensure_install()

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

local packer = require("packer")
local packer_util = require("packer.util")

-- check if firenvim is active
local firenvim_not_active = function()
	return not vim.g.started_by_firenvim
end

packer.startup({
	function(use)
		-- it is recommended to put impatient.nvim before any other plugins
		use({ "lewis6991/impatient.nvim", config = [[require('impatient')]] })

		use({ "wbthomason/packer.nvim", opt = true })

		use({ "onsails/lspkind-nvim", event = "VimEnter" })
		-- auto-completion engine
		use({
			"hrsh7th/nvim-cmp",
			after = "lspkind-nvim",
			config = [[require('config.nvim-cmp')]],
		})

		-- nvim-cmp completion sources
		use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })
		use({
			"quangnguyen30192/cmp-nvim-ultisnips",
			after = { "nvim-cmp", "ultisnips" },
		})
		if vim.g.is_mac then
			use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
		end

		use({ "neovim/nvim-lspconfig" })

		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
		})

		-- Python indent (follows the PEP8 style)
		use({ "Vimjas/vim-python-pep8-indent", ft = { "python" } })

		-- Python-related text object
		use({ "jeetsukumaran/vim-pythonsense", ft = { "python" } })

		use({ "machakann/vim-swap", event = "VimEnter" })

		-- IDE for Lisp
		if utils.executable("sbcl") then
			-- use 'kovisoft/slimv'
			use({ "vlime/vlime", rtp = "vim/", ft = { "lisp" } })
		end

		-- Super fast buffer jump
		use({
			"phaazon/hop.nvim",
			event = "VimEnter",
			config = function()
				vim.defer_fn(function()
					require("config.nvim_hop")
				end, 2000)
			end,
		})

		-- Show match number and index for searching
		use({
			"kevinhwang91/nvim-hlslens",
			branch = "main",
			keys = { { "n", "*" }, { "n", "#" }, { "n", "n" }, { "n", "N" } },
			config = [[require('config.hlslens')]],
		})

		-- File search, tag search and more
		if vim.g.is_win then
			use({ "Yggdroot/LeaderF", cmd = "Leaderf" })
		else
			use({
				"Yggdroot/LeaderF",
				cmd = "Leaderf",
				run = ":LeaderfInstallCExtension",
			})
		end

		-- dependencies for telescope.
		use({ "sharkdp/fd" })
		-- telescope.
		use({
			"nvim-telescope/telescope.nvim",
			requires = { { "nvim-lua/plenary.nvim" } },
		})
		-- search emoji and other symbols
		use({
			"nvim-telescope/telescope-symbols.nvim",
			after = "telescope.nvim",
		})

		-- A list of colorscheme plugin you may want to try. Find what suits you.
		use({ "navarasu/onedark.nvim", opt = true })
		use({ "sainnhe/edge", opt = true })
		use({ "sainnhe/sonokai", opt = true })
		use({ "sainnhe/gruvbox-material", opt = true })
		use({ "shaunsingh/nord.nvim", opt = true })
		use({ "sainnhe/everforest", opt = true })
		use({ "EdenEast/nightfox.nvim", opt = true })
		use({ "rebelot/kanagawa.nvim", opt = true })
		use({ "catppuccin/nvim", as = "catppuccin", opt = true })
		use({ "rose-pine/neovim", as = "rose-pine", opt = true })
		use({ "olimorris/onedarkpro.nvim", opt = true })
		use({ "tanvirtin/monokai.nvim", opt = true })
		use({ "marko-cerovac/material.nvim", opt = true })

		use({
			"nvim-lualine/lualine.nvim",
			event = "VimEnter",
			cond = firenvim_not_active,
			config = [[require('config.statusline')]],
		})

		use({
			"akinsho/bufferline.nvim",
			event = "VimEnter",
			cond = firenvim_not_active,
			config = [[require('config.bufferline')]],
		})

		-- fancy start screen
		use({
			"glepnir/dashboard-nvim",
			event = "VimEnter",
			cond = firenvim_not_active,
			config = [[require('config.dashboard-nvim')]],
		})

		use({
			"lukas-reineke/indent-blankline.nvim",
			event = "VimEnter",
			config = [[require('config.indent-blankline')]],
		})

		-- Highlight URLs inside vim
		use({ "itchyny/vim-highlighturl", event = "VimEnter" })

		-- notification plugin
		use({
			"rcarriga/nvim-notify",
			event = "BufEnter",
			config = function()
				vim.defer_fn(function()
					require("config.nvim-notify")
				end, 2000)
			end,
		})

		-- For Windows and Mac, we can open an URL in the browser.
		-- For Linux, it may not be possible since we maybe
		-- in a server which disables GUI.
		if vim.g.is_win or vim.g.is_mac then
			-- open URL in browser
			use({ "tyru/open-browser.vim", event = "VimEnter" })
		end

		-- Only install these plugins if ctags are installed on the system
		if utils.executable("ctags") then
			-- show file tags in vim window
			use({ "liuchengxu/vista.vim", cmd = "Vista" })
		end

		-- Snippet engine and snippet template
		use({ "SirVer/ultisnips", event = "InsertEnter" })
		use({ "honza/vim-snippets", after = "ultisnips" })

		-- Automatic insertion and deletion of a pair of characters
		use({ "Raimondi/delimitMate", event = "InsertEnter" })

		-- Comment plugin
		use({ "tpope/vim-commentary", event = "VimEnter" })

		-- Multiple cursor plugin like Sublime Text?
		-- use 'mg979/vim-visual-multi'

		-- Autosave files on certain events
		use({ "907th/vim-auto-save", event = "InsertEnter" })

		-- Show undo history visually
		use({ "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } })

		-- better UI for some nvim actions
		use({ "stevearc/dressing.nvim" })

		-- Manage your yank history
		use({
			"gbprod/yanky.nvim",
			config = [[require('config.yanky')]],
		})

		-- Handy unix command inside Vim (Rename, Move etc.)
		use({ "tpope/vim-eunuch", cmd = { "Rename", "Delete" } })

		-- Repeat vim motions
		use({ "tpope/vim-repeat", event = "VimEnter" })

		use({ "nvim-zh/better-escape.vim", event = { "InsertEnter" } })

		if vim.g.is_mac then
			use({ "lyokha/vim-xkbswitch", event = { "InsertEnter" } })
		elseif vim.g.is_win then
			use({ "Neur1n/neuims", event = { "InsertEnter" } })
		end

		-- Auto format tools
		use({ "sbdchd/neoformat", cmd = { "Neoformat" } })

		-- Git command inside vim
		use({
			"tpope/vim-fugitive",
			event = "User InGitRepo",
			config = [[require('config.fugitive')]],
		})

		-- Better git log display
		use({
			"rbong/vim-flog",
			requires = "tpope/vim-fugitive",
			cmd = { "Flog" },
		})

		use({
			"christoomey/vim-conflicted",
			requires = "tpope/vim-fugitive",
			cmd = { "Conflicted" },
		})

		use({
			"ruifm/gitlinker.nvim",
			requires = "nvim-lua/plenary.nvim",
			event = "User InGitRepo",
			config = [[require('config.git-linker')]],
		})

		-- Show git change (change, delete, add) signs in vim sign column
		use({
			"lewis6991/gitsigns.nvim",
			config = [[require('config.gitsigns')]],
		})

		-- Better git commit experience
		use({
			"rhysd/committia.vim",
			opt = true,
			setup = [[vim.cmd('packadd committia.vim')]],
		})

		use({
			"kevinhwang91/nvim-bqf",
			ft = "qf",
			config = [[require('config.bqf')]],
		})

		-- Another markdown plugin
		use({ "preservim/vim-markdown", ft = { "markdown" } })

		-- Faster footnote generation
		use({ "vim-pandoc/vim-markdownfootnotes", ft = { "markdown" } })

		-- Vim tabular plugin for manipulate tabular,
		-- required by markdown plugins
		use({ "godlygeek/tabular", cmd = { "Tabularize" } })

		-- Markdown previewing (only for Mac and Windows)
		use({
			"iamcco/markdown-preview.nvim",
			run = "cd app && npm install",
			ft = { "markdown" },
		})

		use({
			"folke/zen-mode.nvim",
			cmd = "ZenMode",
			config = [[require('config.zen-mode')]],
		})

		use({ "rhysd/vim-grammarous", ft = { "markdown" } })

		use({ "chrisbra/unicode.vim", event = "VimEnter" })

		-- Additional powerful text object for vim,
		-- this plugin should be studied
		-- carefully to use its full power
		use({ "wellle/targets.vim", event = "VimEnter" })

		-- Plugin to manipulate character pairs quickly
		use({ "machakann/vim-sandwich", event = "VimEnter" })

		-- Add indent object for vim (useful for languages like Python)
		use({ "michaeljsmith/vim-indent-object", event = "VimEnter" })

		-- Only use these plugin on Windows and Mac and when LaTeX is installed
		if utils.executable("latex") then
			use({ "lervag/vimtex", ft = { "tex" } })
		end

		-- Since tmux is only available on Linux and Mac,
		-- we only enable these plugins
		-- for Linux and Mac
		if utils.executable("tmux") then
			use({ "tmux-plugins/vim-tmux", ft = { "tmux" } })
		end

		-- Modern matchit implementation
		use({ "andymass/vim-matchup", event = "VimEnter" })

		use({
			"tpope/vim-scriptease",
			cmd = { "Scriptnames", "Message", "Verbose" },
		})

		-- Asynchronous command execution
		use({ "skywind3000/asyncrun.vim", opt = true, cmd = { "AsyncRun" } })

		use({ "cespare/vim-toml", ft = { "toml" }, branch = "main" })

		-- Edit text area in browser using nvim
		if vim.g.is_win or vim.g.is_mac then
			use({
				"glacambre/firenvim",
				run = function()
					fn["firenvim#install"](0)
				end,
				opt = true,
				setup = [[vim.cmd('packadd firenvim')]],
			})
		end

		-- Debugger plugin
		if vim.g.is_win or vim.g.is_linux then
			use({
				"sakhnik/nvim-gdb",
				run = { "bash install.sh" },
				opt = true,
				setup = [[vim.cmd('packadd nvim-gdb')]],
			})
		end

		-- Session management plugin
		use({ "tpope/vim-obsession", cmd = "Obsession" })

		if vim.g.is_linux then
			use({ "ojroques/vim-oscyank", cmd = { "OSCYank", "OSCYankReg" } })
		end

		-- The missing auto-completion for cmdline!
		use({
			"gelguy/wilder.nvim",
			opt = true,
			setup = [[vim.cmd('packadd wilder.nvim')]],
		})

		-- showing keybindings
		use({
			"folke/which-key.nvim",
			event = "VimEnter",
			config = function()
				vim.defer_fn(function()
					require("config.which-key")
				end, 2000)
			end,
		})

		-- show and trim trailing whitespaces
		use({ "jdhao/whitespace.nvim", event = "VimEnter" })

		-- file explorer
		use({
			"nvim-tree/nvim-web-devicons",
			"nvim-tree/nvim-tree.lua",
		})

		use({ "habamax/vim-rst" })

		use({ "stsewd/sphinx.nvim" })

		use({ "neoclide/coc.nvim", branch = "release" })

		use({ "junegunn/fzf" })

		use({
			"j-hui/fidget.nvim",
			after = "nvim-lspconfig",
			config = [[require('config.fidget-nvim')]],
		})

		-- tmux and nvim copy and from plugin.
		use({
			"aserowy/tmux.nvim",
			config = function()
				return require("tmux").setup()
			end,
		})
	end,
	config = {
		max_jobs = 16,
		compile_path = packer_util.join_paths(
			fn.stdpath("data"),
			"site",
			"lua",
			"packer_compiled.lua"
		),
	},
})

--------------------------- Plugin configuration --------------------------
---------------------------------------------------------------------------

-- For fresh install, we need to install plugins.
-- Otherwise, we just need to require `packer_compiled.lua`.
if fresh_install then
	-- We run packer.sync() here, because only after packer.startup,
	-- can we know which plugins to install.
	-- So plugin installation should be done after the startup process.
	packer.sync()
else
	local status, _ = pcall(require, "packer_compiled")
	if not status then
		local msg = "File packer_compiled.lua not found: run PackerSync to fix!"
		vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
	end
end

-- nvim-web-devicons-setup
require("nvim-web-devicons").setup({
	-- your personnal icons can go here (to override)
	-- you can specify color or cterm_color instead of specifying both of them
	-- DevIcon will be appended to `name`
	override = {
		zsh = {
			icon = "",
			color = "#428850",
			cterm_color = "65",
			name = "Zsh",
		},
	},
	-- globally enable different highlight colors per icon (default to true)
	-- if set to false all icons will have the default icon's color
	color_icons = true,
	-- globally enable default icons (default to false)
	-- will get overriden by `get_icons` option
	default = true,
	-- globally enable "strict" selection of icons - icon will be looked up in
	-- different tables, first by filename, and if not found by extension; this
	-- prevents cases when file doesn't have any extension but still gets some
	-- icon because its name happened to match some extension (default to false)
	strict = true,
	-- same as `override` but specifically for overrides by filename
	-- takes effect when `strict` is true
	override_by_filename = {
		[".gitignore"] = {
			icon = "",
			color = "#f1502f",
			name = "Gitignore",
		},
	},
	-- same as `override` but specifically for overrides by extension
	-- takes effect when `strict` is true
	override_by_extension = {
		["log"] = {
			icon = "",
			color = "#81e043",
			name = "Log",
		},
	},
})

------------------------------------------------------------------------------
-- nvim-tree setup
require("nvim-tree").setup({
	sort_by = "case_sensitive",
	renderer = {
		highlight_opened_files = "all",
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})

------------------------------------------------------------------------------
-- telesceope setup.
require("telescope").setup({})

------------------------------------------------------------------------------
-- nvim-treesitter setup
require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all" alled).
	ensure_installed = {
		"c",
		"go",
		"cpp",
		"python",
		"java",
		"json",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"html",
		"php",
		"markdown_inline",
		"ruby",
		"rust",
		"perl",
		"sql",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have
	-- `tree-sitter` CLI installed locally
	auto_install = true,

	-- List of parsers to ignore installing (for "all")
	ignore_install = { "javascript" },

	-- If you need to change the installation directory
	-- of the parsers (see -> Advanced Setup)
	-- parser_install_dir = "/some/path/to/store/parsers",
	-- Remember to run
	-- vim.opt.runtimepath:append("/some/path/to/store/parsers")!

	highlight = {
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype.
		-- (for example if you want to
		-- disable highlighting for the `tex` filetype, you need to include
		-- `latex` in this list as this is
		-- the name of the parser)
		-- list of language that will be disabled
		disable = {},
		-- Or use a function for more flexibility,
		-- e.g. to disable slow treesitter highlight for large files
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats =
				pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,

		-- Setting this to true will run `:h syntax`
		-- and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax'
		-- being enabled (like for indentation).
		-- Using this option may slow down your editor,
		-- and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = true,
	},
})

------------------------------------------------------------------------------
-- neovim-lspconfig settings.
-- Setup language servers.
local lspconfig = require("lspconfig")
-- for c,cpp,obj-c,proto.
lspconfig.clangd.setup({})
-- for python.
lspconfig.pylsp.setup({})
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
local capabilities = vim.lsp.protocol.make_client_capabilities()
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

-- Global mappings.

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
			c = {
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
					vim.lsp.buf.format({ async = true }),
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

------------------------------------------------------------------------------
-------------------- plugin variable settings --------------------------------
-- vertial line settings.
vim.opt.colorcolumn = "79"
