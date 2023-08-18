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
		use({
			"lewis6991/impatient.nvim",
			config = [[require("impatient")]],
		})

		use({ "wbthomason/packer.nvim", opt = true })

		-- showing keybindings
		use({
			"folke/which-key.nvim",
			config = function()
				vim.o.timeout = true
				vim.o.timeoutlen = 500
				require("which-key").setup()
			end,
		})

		use({
			"nvim-tree/nvim-tree.lua",
			config = [[require('config.nvim-tree')]],
		})

		-- file explorer
		use({
			"nvim-tree/nvim-web-devicons",
			config = [[require("config.web-devicons")]],
		})

		-- auto-completion engine
		use({ "onsails/lspkind-nvim", event = "VimEnter" })
		use({
			"hrsh7th/nvim-cmp",
			after = "lspkind-nvim",
			config = [[require("config.nvim-cmp")]],
			event = "VimEnter",
		})

		-- nvim-cmp completion sources
		use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
		use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })

		-- Snippet engine and snippet template
		use({ "SirVer/ultisnips", event = "InsertEnter" })
		use({ "honza/vim-snippets", after = "ultisnips" })
		use({
			"quangnguyen30192/cmp-nvim-ultisnips",
			after = { "nvim-cmp", "ultisnips" },
		})
		use("L3MON4D3/LuaSnip") -- Snippets plugin

		-- Language server protocol support.
		use({ "ms-jpq/coq_nvim", run = "python3 -m coq deps" })
		use({ "ms-jpq/coq.artifacts" })
		use({ "ms-jpq/coq.thirdparty" })
		use({
			"neovim/nvim-lspconfig",
			after = { "cmp-nvim-lsp" },
			config = [[require("config.lsp")]],
		})

		-- Tree-sitter is a parser generator tool and an incremental
		-- parsing library. It can build a concrete syntax tree for
		-- a source file and efficiently update the syntax tree as
		-- the source file is edited.
		use({
			"nvim-treesitter/nvim-treesitter",
			after = "nvim-lspconfig",
			run = ":TSUpdate",
			config = [[require('config.treesitter')]],
		})

		-- Python indent (follows the PEP8 style)
		use({ "Vimjas/vim-python-pep8-indent", ft = { "python" } })

		-- Python-related text object
		use({ "jeetsukumaran/vim-pythonsense", ft = { "python" } })

		-- A Vim text editor plugin to swap delimited items.
		use({ "machakann/vim-swap", event = "VimEnter" })

		-- Super fast buffer jump
		use({
			"phaazon/hop.nvim",
			event = "VimEnter",
			branch = "v2",
			config = function()
				require("hop").setup()
			end,
		})

		-- Show match number and index for searching
		use({
			"kevinhwang91/nvim-hlslens",
			branch = "main",
			keys = { { "n", "*" }, { "n", "#" }, { "n", "n" }, { "n", "N" } },
			config = [[require("config.hlslens")]],
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

		-- Dependencies for telescope.
		use({ "sharkdp/fd" })
		use({
			"nvim-telescope/telescope.nvim",
			requires = { { "nvim-lua/plenary.nvim" } },
			config = [[require("config.telescope")]],
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
		use({ "sainnhe/everforest" })
		use({ "EdenEast/nightfox.nvim", opt = true })
		use({ "rebelot/kanagawa.nvim", opt = true })
		use({ "catppuccin/nvim", as = "catppuccin", opt = true })
		use({ "rose-pine/neovim", as = "rose-pine", opt = true })
		use({ "olimorris/onedarkpro.nvim", opt = true })
		use({ "tanvirtin/monokai.nvim", opt = true })
		use({ "marko-cerovac/material.nvim", opt = true })

		-- Using Lua to configure the nvim status line.
		use({
			"nvim-lualine/lualine.nvim",
			event = "VimEnter",
			cond = firenvim_not_active,
			config = [[require("config.statusline")]],
			requires = "nvim-tree/nvim-web-devicons",
		})

		-- Make the buffer tabs more beautiful.
		use({
			"akinsho/bufferline.nvim",
			event = "VimEnter",
			cond = firenvim_not_active,
			config = [[require("config.bufferline")]],
			tag = "*",
			requires = "nvim-tree/nvim-web-devicons",
		})

		-- fancy start screen
		use({
			"glepnir/dashboard-nvim",
			event = "VimEnter",
			cond = firenvim_not_active,
			config = [[require("config.dashboard-nvim")]],
		})

		-- Adds indentation guides to all lines (including empty lines).
		use({
			"lukas-reineke/indent-blankline.nvim",
			config = [[require("config.indent-blankline")]],
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

		-- Only install these plugins if ctags are installed on the system
		if utils.executable("ctags") then
			-- show file tags in vim window
			use({ "liuchengxu/vista.vim", cmd = "Vista" })
		end

		-- -- Automatic insertion and deletion of a pair of characters
		use({ "Raimondi/delimitMate", event = "InsertEnter" })

		-- Comment plugin
		use({
			"numToStr/Comment.nvim",
			config = [[require('config.comment')]],
		})

		-- Multiple cursor plugin like Sublime Text?
		use("mg979/vim-visual-multi")

		-- Show undo history visually
		use({ "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } })

		-- Handy unix command inside Vim (Rename, Move etc.)
		use({ "tpope/vim-eunuch", cmd = { "Rename", "Delete" } })

		-- Auto format tools
		use({ "sbdchd/neoformat", cmd = { "Neoformat" } })

		-- Show git change (change, delete, add) signs in vim sign column
		use({
			"lewis6991/gitsigns.nvim",
			config = [[require("config.gitsigns")]],
		})

		-- Vim tabular plugin for manipulate tabular,
		-- required by markdown plugins
		use({ "godlygeek/tabular", cmd = { "Tabularize" } })

		-- Since tmux is only available on Linux and Mac,
		-- we only enable these plugins
		-- for Linux and Mac
		if utils.executable("tmux") then
			use({ "tmux-plugins/vim-tmux", ft = { "tmux" } })
		end

		-- Modern matchit implementation
		use({
			"andymass/vim-matchup",
			setup = function()
				-- may set any options here
				vim.g.matchup_matchparen_offscreen = { method = "popup" }
			end,
		})

		-- The missing auto-completion for cmdline!
		use({
			"gelguy/wilder.nvim",
			opt = true,
			setup = function()
				vim.cmd("packadd wilder.nvim")
			end,
		})

		-- show and trim trailing whitespaces
		use({ "jdhao/whitespace.nvim", event = "VimEnter" })

		use({ "habamax/vim-rst" })

		use({ "stsewd/sphinx.nvim" })

		use({ "neoclide/coc.nvim", branch = "release" })

		use({ "junegunn/fzf" })

		use({
			"j-hui/fidget.nvim",
			after = "nvim-lspconfig",
			tag = "legacy",
			config = [[require("config.fidget-nvim")]],
		})

		-- tmux and nvim copy and from plugin.
		use({
			"aserowy/tmux.nvim",
			config = [[require("tmux").setup()]],
		})

		-- Iron allows you to quickly interact with the repl without having to leave your work bufferline.
		use({ "Vigemus/iron.nvim", config = [[require('config.iron')]] })

		---------------------------------------------------------------------------
		--------------------- Find out what causes the text insert of first line.
		-- Asynchronous command execution
		-- use({ "skywind3000/asyncrun.vim", opt = true, cmd = { "AsyncRun" } })
		-- use({ "cespare/vim-toml", ft = { "toml" }, branch = "main" })

		-- -- Session management plugin
		-- use({ "tpope/vim-obsession", cmd = "Obsession" })

		-- -- Plugin to make vim plugins.
		-- use({
		-- 	"tpope/vim-scriptease",
		-- 	cmd = { "Scriptnames", "Message", "Verbose" },
		-- })

		-- -- Another markdown plugin
		-- use({ "preservim/vim-markdown", ft = { "markdown" } })

		-- -- Faster footnote generation
		-- use({ "vim-pandoc/vim-markdownfootnotes", ft = { "markdown" } })

		--------------------- Above has been confirmed: Not related.

		-- Debugger plugin
		-- if vim.g.is_win or vim.g.is_linux then
		-- 	use({
		-- 		"sakhnik/nvim-gdb",
		-- 		run = { "bash install.sh" },
		-- 		opt = true,
		-- 		setup = [[vim.cmd('packadd nvim-gdb')]],
		-- 	})
		-- end

		-- Additional powerful text object for vim,
		-- this plugin should be studied
		-- carefully to use its full power
		-- use({ "wellle/targets.vim", event = "VimEnter" })

		-- -- Plugin to manipulate character pairs quickly
		-- use({ "machakann/vim-sandwich", event = "VimEnter" })

		-- -- Add indent object for vim (useful for languages like Python)
		-- use({ "michaeljsmith/vim-indent-object", event = "VimEnter" })

		-- use({
		-- 	"folke/zen-mode.nvim",
		-- 	cmd = "ZenMode",
		-- 	config = [[require('config.zen-mode')]],
		-- })

		-- Better git log display
		-- use({
		-- 	"rbong/vim-flog",
		-- 	requires = "tpope/vim-fugitive",
		-- 	cmd = { "Flog" },
		-- })

		-- use({
		-- 	"christoomey/vim-conflicted",
		-- 	requires = "tpope/vim-fugitive",
		-- 	cmd = { "Conflicted" },
		-- })

		-- use({
		-- 	"ruifm/gitlinker.nvim",
		-- 	requires = "nvim-lua/plenary.nvim",
		-- 	event = "User InGitRepo",
		-- 	config = [[require('config.git-linker')]],
		-- })

		-- Distraction-free coding for Neovim >= 0.5.
		-- use({ "rhysd/vim-grammarous", ft = { "markdown" } })

		-- use({ "chrisbra/unicode.vim", event = "VimEnter" })

		-- Better git commit experience
		-- use({
		-- 	"rhysd/committia.vim",
		-- 	opt = true,
		-- 	setup = [[vim.cmd('packadd committia.vim')]],
		-- })

		-- use({
		-- 	"kevinhwang91/nvim-bqf",
		-- 	ft = "qf",
		-- 	config = [[require('config.bqf')]],
		-- })

		-- Repeat vim motions
		-- use({ "tpope/vim-repeat", event = "VimEnter" })

		-- use({ "nvim-zh/better-escape.vim", event = { "InsertEnter" } })

		-- Manage your yank history
		-- use({
		-- 	"gbprod/yanky.nvim",
		-- 	config = [[require('config.yanky')]],
		-- })

		-- better UI for some nvim actions
		-- use({ "stevearc/dressing.nvim" })

		-- Git command inside vim
		-- use({
		-- 	"tpope/vim-fugitive",
		-- 	event = "User InGitRepo",
		-- 	config = [[require('config.fugitive')]],
		-- })

		-- IDE for Lisp
		-- if utils.executable("sbcl") then
		-- 	use("kovisoft/slimv")
		-- 	use({ "vlime/vlime", rtp = "vim/", ft = { "lisp" } })
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

-- Auto format the file after save the file.
api.nvim_create_autocmd({ "BufWritePost" }, {
	group = api.nvim_create_augroup("file_auto_format", { clear = true }),
	callback = function(ctx)
		vim.cmd("Neoformat")
		vim.notify(
			"Auto format done!",
			vim.log.levels.INFO,
			{ title = "Neoformat" }
		)
	end,
})

-- Auto-generate packer_compiled.lua file
api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = "*/nvim/lua/plugins.lua",
	group = api.nvim_create_augroup("packer_auto_compile", { clear = true }),
	callback = function(ctx)
		local cmd = "source " .. ctx.file
		vim.cmd(cmd)
		vim.cmd("PackerCompile")
		vim.notify(
			"PackerCompile done!",
			vim.log.levels.INFO,
			{ title = "Nvim-config" }
		)
	end,
})
