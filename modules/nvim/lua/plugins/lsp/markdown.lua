if vim.fn.executable("marksman") == 1 then
	vim.lsp.config("marksman", {
		cmd = { "marksman", "server" },
		filetypes = { "markdown" },
		single_file_support = true,
	})
	vim.lsp.enable("marksman")
end
