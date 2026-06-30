if vim.fn.executable("vscode-json-language-server") == 1 then
	vim.lsp.enable("jsonls")
end
