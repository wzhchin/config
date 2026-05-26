vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml" },
})

vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
	root_markers = { "tsconfig.json", "package.json" },
})

vim.lsp.config("pyright", {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py" },
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
			},
		},
	},
})

vim.lsp.enable({ "rust_analyzer", "ts_ls", "pyright" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufmap = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
		end

		bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
		bufmap("n", "gr", vim.lsp.buf.references, "Go to references")
		bufmap("n", "K", vim.lsp.buf.hover, "Hover")
		bufmap("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
		bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})
