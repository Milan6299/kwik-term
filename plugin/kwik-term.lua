if vim.g.loaded_kwik_term then
	return
end
vim.g.loaded_kwik_term = true

local kwik = require("kwik-term")

vim.api.nvim_create_user_command("KwikTermFloat", function()
	kwik.toggle({ float = true })
end, { desc = "Toggle floating terminal" })

vim.api.nvim_create_user_command("KwikTermSplit", function()
	kwik.toggle({ float = false })
end, { desc = "Toggle bottom split terminal" })

vim.api.nvim_create_user_command("KwikTermSend", function(opts)
	kwik.send(opts.args, { float = true })
end, { nargs = "+", desc = "Send command to kwik-term" })
