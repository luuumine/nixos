return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local function enable_if(cmd, server, cfg)
				if vim.fn.executable(cmd) == 1 then
					vim.lsp.config(server, cfg or {})
					vim.lsp.enable(server)
				end
			end

			-- Python
			enable_if("pyright", "pyright")

			-- Rust
			enable_if("rust-analyzer", "rust_analyzer")

			-- Nix
			enable_if("nixd", "nixd")

			-- Lua
			enable_if("lua-language-server", "lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = { vim.env.VIMRUNTIME },
							scanExternalLibraries = false,
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- Typescript
			enable_if("typescript-language-server", "ts_ls", {
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- Astro
			-- Use the local project typescript library
			local project_ts_path = vim.fn.getcwd() .. "/node_modules/typescript/lib"
			enable_if("astro-ls", "astro", {
				init_options = {
					typescript = { tsdk = project_ts_path },
				},
			})

			-- CSS
			enable_if("vscode-css-language-server", "cssls")

			-- JSON
			enable_if("vscode-json-language-server", "jsonls")

			-- QML
			enable_if("qmlls", "qmlls", {
				cmd = { "qmlls", "-E" },
				filetypes = { "qml", "qmljs" },
				single_file_support = true,
			})

			-- Diagnostics UI
			vim.diagnostic.config({
				severity_sort = true,
				update_in_insert = true,
				virtual_text = {
					spacing = 4,
					prefix = "●",
				},
				float = {
					border = "rounded",
					source = "if_many",
				},
			})
		end,
	},
}
