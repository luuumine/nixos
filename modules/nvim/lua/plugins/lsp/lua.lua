if vim.fn.executable("lua-language-server") == 1 then
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
					ignoreDir = {
						".direnv",
						"node_modules",
						"target",
						"result",
					},
				},
				telemetry = { enable = false },
			},
		},
	})
	vim.lsp.enable("lua_ls")
end
