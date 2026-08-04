vim.api.nvim_create_user_command("Layout", function()
	-- reset to 1 window
	vim.cmd("only")

	-- 3 vert windows
	vim.cmd("vsplit")
	vim.cmd("vsplit")

	-- resize
	vim.cmd("1wincmd w")
	vim.cmd("vertical resize 100")

	vim.cmd("wincmd l")
	vim.cmd("vertical resize 100")

	-- terminal
	vim.cmd("wincmd l")
	vim.cmd("terminal")

	-- back to main window
	vim.cmd("1wincmd w")
end, {})
