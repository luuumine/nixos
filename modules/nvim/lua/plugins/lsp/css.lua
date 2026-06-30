if vim.fn.executable("vscode-css-language-server") == 1 then
	vim.lsp.enable("cssls")
end
