if vim.fn.executable("rust-analyzer") == 1 then
	vim.lsp.config("rust_analyzer", {
		on_attach = function(client, bufnr)
			if client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end
		end,
		settings = {
			["rust-analyzer"] = {
				inlayHints = {
					typeHints = { enable = true },
					chainingHints = { enable = true },
					bindingModeHints = { enable = true },
					closureReturnTypeHints = { enable = "always" },
					lifetimeElisionHints = { enable = "always" },
					maxLength = 5,
					enable = true,
				},
				lens = { enable = true },
			},
		},
	})
	vim.lsp.enable("rust_analyzer")
end
