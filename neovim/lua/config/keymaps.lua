local map = vim.keymap.set

map("n", "<leader>cf", function()
	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		vim.notify("No file name", vim.log.levels.WARN)
		return
	end

	local ft = vim.bo.filetype
	local ext = ft
	if ext == "" then
		ext = vim.fn.expand("%:e")
	end
	if ext == "" then
		vim.notify("Cannot detect file type", vim.log.levels.WARN)
		return
	end

	local tmp = vim.fn.tempname() .. "." .. ext
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	vim.fn.writefile(lines, tmp)

	local cmd = string.format("kfmt -w -t %s %s", vim.fn.shellescape(ext), vim.fn.shellescape(tmp))
	local result = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		vim.fn.delete(tmp)
		vim.notify("kfmt failed: " .. result, vim.log.levels.ERROR)
		return
	end

	local formatted = vim.fn.readfile(tmp)
	vim.fn.delete(tmp)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
	vim.notify("Formatted with kfmt (" .. ext .. ")", vim.log.levels.INFO)
end, { desc = "Format current file with kfmt" })

map("v", "<leader>cf", function()
	local ft = vim.bo.filetype
	local ext = ft
	if ext == "" then
		ext = vim.fn.expand("%:e")
	end
	if ext == "" then
		vim.notify("Cannot detect file type", vim.log.levels.WARN)
		return
	end

	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	local tmp = vim.fn.tempname() .. "." .. ext
	vim.fn.writefile(lines, tmp)

	local cmd = string.format("kfmt -t %s %s", vim.fn.shellescape(ext), vim.fn.shellescape(tmp))
	local result = vim.fn.systemlist(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		vim.fn.delete(tmp)
		vim.notify("kfmt failed", vim.log.levels.ERROR)
		return
	end

	vim.fn.delete(tmp)
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, result)
	vim.notify("Formatted selection with kfmt (" .. ext .. ")", vim.log.levels.INFO)
end, { desc = "Format selection with kfmt" })

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<ESC>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
