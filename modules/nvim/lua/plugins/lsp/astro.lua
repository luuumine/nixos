if vim.fn.executable("astro-ls") == 1 then
	local project_ts_path = vim.fn.getcwd() .. "/node_modules/typescript/lib"
	vim.lsp.config("astro", {
		init_options = {
			typescript = { tsdk = project_ts_path },
		},
	})
	vim.lsp.enable("astro")
end
