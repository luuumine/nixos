if vim.fn.executable("qmlls") == 1 then
	vim.lsp.config("qmlls", {
		cmd = { "qmlls", "-E" },
		filetypes = { "qml", "qmljs" },
		single_file_support = true,
	})
	vim.lsp.enable("qmlls")
end
