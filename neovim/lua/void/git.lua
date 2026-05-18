-- https://serenevoid.github.io/blog/git-workflow-with-neovim-and-terminal/

local M = {}

function M.blame_line()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local blame_info = vim.fn.systemlist('git blame -L ' .. row .. ',+1 ' .. filename .. ' --porcelain')
  if blame_info[2] ~= nil then
    local hash = string.sub(blame_info[1], 1, 8)
    local author_name = string.sub(blame_info[2], 8)
    local author_date = os.date('%Y %b %d', tonumber(string.sub(blame_info[4], 12)))
    local summary = string.sub(blame_info[10], 9)
    print(hash .. " - " .. author_name .. " - " .. author_date .. " - " ..  summary)
  else
    print(blame_info[1])
  end
end

vim.api.nvim_create_user_command("GitBlame", ":lua require('void.git').blame_line()", {})

return M
