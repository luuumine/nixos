if vim.fn.executable("pyright-langserver") == 1 then
	vim.lsp.enable("pyright")
end
