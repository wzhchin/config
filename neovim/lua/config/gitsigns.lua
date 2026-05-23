vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { link = "Comment", italic = true })

require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text_pos = "right_align",
		delay = 250,
	},
	current_line_blame_formatter = "<author> • <author_time:%Y-%m-%d> • <summary>",
})
