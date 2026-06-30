if vim.fn.executable("typescript-language-server") == 1 then
	vim.lsp.config("ts_ls", {
		on_attach = function(client)
			client.server_capabilities.documentFormattingProvider = false
		end,
	})
	vim.lsp.enable("ts_ls")
end
