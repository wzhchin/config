local wk = require("which-key")

wk.setup({
	delay = 300,
	icons = {
		mappings = false,
	},
})

wk.add({
	{ "<leader>c", group = "code" },
	{ "<leader>cg", group = "git" },
	{
		"<leader>?",
		function()
			require("which-key").show({ global = false })
		end,
		desc = "Buffer local keymaps",
	},
})
