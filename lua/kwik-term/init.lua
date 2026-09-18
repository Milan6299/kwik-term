local M = {}

M.config = {
	height = 7, -- Split window height
	width = 0.9, -- Float width (0.1 to 1.0)
	height_ratio = 0.9, -- Float height (0.1 to 1.0)
	border = "single", -- "single", "rounded", "double", "solid"
	start_in_insert = true, -- Start typing immediately when opened
}

local terminal_buf = nil
local job_id = nil

local function notify(msg, level)
	vim.notify(msg or "", level or vim.log.levels.INFO, { title = "kwik-term" })
end

local function set_window_options(win)
	vim.api.nvim_set_option_value("number", false, { win = win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = win })
	vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
end

local function open_floating_win(buf)
	local width = math.floor(vim.o.columns * M.config.width)
	local height = math.floor(vim.o.lines * M.config.height_ratio)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = M.config.border,
	})
	set_window_options(win)
	return win
end

local function open_split_win(buf, height)
	vim.cmd("botright " .. (height or M.config.height) .. "split")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	set_window_options(win)
	return win
end

local function setup_terminal_buffer(buf)
	-- Reset state if shell process terminates or buffer is deleted
	vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout" }, {
		buffer = buf,
		once = true,
		callback = function()
			terminal_buf = nil
			job_id = nil
		end,
	})

	-- 'q' in normal mode hides the window
	vim.keymap.set("n", "q", function()
		M.hide()
	end, { buffer = buf, silent = true, desc = "Hide kwik-term" })
end

---Open terminal (or focus if already open)
function M.open(opts)
	opts = opts or {}

	if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
		local win = vim.fn.bufwinid(terminal_buf)
		if win ~= -1 then
			vim.api.nvim_set_current_win(win)
		else
			if opts.float then
				open_floating_win(terminal_buf)
			else
				open_split_win(terminal_buf, opts.height)
			end
		end
	else
		terminal_buf = vim.api.nvim_create_buf(false, true)

		if opts.float then
			open_floating_win(terminal_buf)
		else
			open_split_win(terminal_buf, opts.height)
		end

		vim.cmd.term()
		terminal_buf = vim.api.nvim_get_current_buf()
		job_id = vim.b[terminal_buf].terminal_job_id or vim.bo[terminal_buf].channel

		setup_terminal_buffer(terminal_buf)
	end

	if M.config.start_in_insert then
		vim.cmd("startinsert")
	end
end

---Hide terminal window
function M.hide()
	if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
		local win = vim.fn.bufwinid(terminal_buf)
		if win ~= -1 then
			vim.api.nvim_win_hide(win)
		end
	end
end

---Toggle terminal (close if visible, open if hidden)
function M.toggle(opts)
	opts = opts or {}
	if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
		local win = vim.fn.bufwinid(terminal_buf)
		if win ~= -1 then
			vim.api.nvim_win_hide(win)
			return
		end
	end
	M.open(opts)
end

---Send command text into the terminal
function M.send(cmd, opts)
	opts = opts or {}
	M.open(opts)

	if not job_id then
		notify("No active terminal job found!", vim.log.levels.WARN)
		return
	end

	vim.fn.chansend(job_id, cmd .. "\n")
end

---Run current file with an executable (e.g. 'python', 'uv run')
function M.run_current_file(runner, opts)
	-- Expand filename BEFORE switching focus to terminal window
	local file = vim.fn.expand("%:p")
	if file == "" then
		notify("No file found in current buffer!", vim.log.levels.WARN)
		return
	end
	local cmd = runner .. " " .. vim.fn.shellescape(file)
	M.send(cmd, opts)
end

---User setup function
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
