if vim.fn.executable("vscode-html-language-server") == 1 then
	vim.lsp.config("html", {
		filetypes = { "html", "htmldjango" },
	})
	vim.lsp.enable("html")
end
