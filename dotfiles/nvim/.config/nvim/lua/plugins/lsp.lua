return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local function enable(server, cfg)
					vim.lsp.config(server, cfg or {})
					vim.lsp.enable(server)
			end

			-- Python
			enable("pyright")

			-- Rust
			enable("rust_analyzer")

			-- Nix
			enable("nixd")

			-- C/C++
			enable("clangd")

			-- Lua
			enable("lua_ls", {
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
			enable("ts_ls", {
				on_attach = function(client)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- Astro
			-- Use the local project typescript library
			local project_ts_path = vim.fn.getcwd() .. "/node_modules/typescript/lib"
			enable("astro", {
				init_options = {
					typescript = { tsdk = project_ts_path },
				},
			})

			-- CSS
			enable("cssls")

			-- JSON
			enable("jsonls")

			-- QML
			enable("qmlls", {
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
