_G.lf = _G.lf or {}

function _G.lf.setup()
	vim.opt.swapfile = false
	vim.opt.backup = false
	vim.opt.writebackup = false
	vim.opt.termguicolors = true

	vim.pack.add({
		{
			src = "https://github.com/nvim-treesitter/nvim-treesitter.git",
			name = "nvim-treesitter",
		},
		{
			src = "https://github.com/barrettruth/midnight.nvim.git",
			name = "midnight.nvim",
		},
	})

	vim.cmd('silent TSInstall all')

	vim.api.nvim_create_autocmd("OptionSet", {
		pattern = "background",
		callback = function()
			vim.cmd.colorscheme(vim.o.background == "dark" and "midnight" or "daylight")
		end,
		group = vim.api.nvim_create_augroup("Midnight", { clear = true }),
	})
end

local hl_cache = {}
local reset = "\27[0m"

---@param name string
---@return string
local function get_fg_ansi(name)
	if hl_cache[name] then
		return hl_cache[name]
	end

	local hl = vim.api.nvim_get_hl(0, { name = name, link = false })

	if not hl.fg then
		hl_cache[name] = ""
		return ""
	end

	local r = bit.rshift(bit.band(hl.fg, 0xff0000), 16)
	local g = bit.rshift(bit.band(hl.fg, 0x00ff00), 8)
	local b = bit.band(hl.fg, 0x0000ff)

	local ansi = string.format("\27[38;2;%d;%d;%dm", r, g, b)
	hl_cache[name] = ansi
	return ansi
end

---@param lines string[]
---@return boolean
local function render_with_vim_syntax(lines)
	local ok = pcall(vim.cmd.syntax, "enable")
	if not ok then
		return false
	end

	for lnum, text in ipairs(lines) do
		if #text == 0 then
			io.write("\n")
		else
			local rendered = {}
			local current_group = nil
			local chunk_start = 1

			for col = 1, #text do
				local syn_id = vim.fn.synID(lnum, col, 1)
				local group = vim.fn.synIDattr(syn_id, "name")

				if group ~= current_group then
					if current_group then
						local chunk = text:sub(chunk_start, col - 1)
						local ansi = get_fg_ansi(current_group)
						if ansi ~= "" then
							table.insert(rendered, ansi)
							table.insert(rendered, chunk)
							table.insert(rendered, reset)
						else
							table.insert(rendered, chunk)
						end
					end
					current_group = group
					chunk_start = col
				end
			end

			if current_group then
				local chunk = text:sub(chunk_start)
				local ansi = get_fg_ansi(current_group)
				if ansi ~= "" then
					table.insert(rendered, ansi)
					table.insert(rendered, chunk)
					table.insert(rendered, reset)
				else
					table.insert(rendered, chunk)
				end
			end

			local line = table.concat(rendered)
			io.write(line .. "\n")
		end
	end

	io.flush()
	return true
end

---@param lines string[]
local function render_plain(lines)
	for _, line in ipairs(lines) do
		io.write(line .. "\n")
	end
	io.flush()
end

---@param buf number
---@param lines string[]
---@param filetype string
---@param preview_line_count number
---@return table<number, table<number, {[1]: number, [2]: number, [3]: string}>>
local function collect_treesitter_highlights(buf, lines, filetype, preview_line_count)
	local parser = vim.treesitter.get_parser(buf)
	local trees = parser:parse()
	if not trees or #trees == 0 then
		return {}
	end

	local root = trees[1]:root()
	local query = vim.treesitter.query.get(filetype, "highlights")
	if not query then
		return {}
	end

	---@type table<number, table<number, {[1]: number, [2]: number, [3]: string}>>
	local line_highlights = {}

	for id, node in query:iter_captures(root, buf, 0, preview_line_count) do
		local name = query.captures[id]
		local start_row, start_col, end_row, end_col = node:range()

		for row = start_row, end_row do
			line_highlights[row] = line_highlights[row] or {}
			local s_col = row == start_row and start_col or 0
			local e_col = row == end_row and end_col or #lines[row + 1]
			table.insert(line_highlights[row], { s_col, e_col, name })
		end
	end

	for _, highlights in pairs(line_highlights) do
		table.sort(highlights, function(a, b)
			if a[1] == b[1] then
				return a[2] > b[2]
			end
			return a[1] < b[1]
		end)
	end

	return line_highlights
end

---@param lines string[]
---@param line_highlights table<number, table<number, {[1]: number, [2]: number, [3]: string}>>
---@param filetype string
local function render_with_treesitter(lines, line_highlights, filetype)
	for i, text in ipairs(lines) do
		local row = i - 1
		local highlights = line_highlights[row] or {}

		if #highlights == 0 then
			io.write(text .. "\n")
		else
			local rendered = {}
			local pos = 0
			---@type {[1]: number, [2]: number}[]
			local used_ranges = {}

			for _, hl in ipairs(highlights) do
				local s_col, e_col, name = hl[1], hl[2], hl[3]

				local skip = false
				for _, used in ipairs(used_ranges) do
					if s_col >= used[1] and s_col < used[2] then
						skip = true
						break
					end
				end

				if not skip then
					if pos < s_col then
						table.insert(rendered, text:sub(pos + 1, s_col))
					end

					local chunk = text:sub(s_col + 1, e_col)
					local ansi = get_fg_ansi("@" .. name .. "." .. filetype)
					if ansi == "" then
						ansi = get_fg_ansi("@" .. name)
					end

					if ansi ~= "" then
						table.insert(rendered, ansi)
						table.insert(rendered, chunk)
						table.insert(rendered, reset)
					else
						table.insert(rendered, chunk)
					end

					table.insert(used_ranges, { s_col, e_col })
					pos = e_col
				end
			end

			if pos < #text then
				table.insert(rendered, text:sub(pos + 1))
			end

			io.write(table.concat(rendered) .. "\n")
		end
	end

	io.flush()
end

---@param filepath string
---@param preview_line_count number
function _G.lf.preview(filepath, preview_line_count)
	vim.cmd.edit(filepath)
	vim.cmd.colorscheme(vim.env.THEME)

	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, preview_line_count, false)

	local ft = vim.filetype.match({ buf = buf, filename = filepath })

	local tsok, result = pcall(collect_treesitter_highlights, buf, lines, ft, preview_line_count)

	if tsok and next(result) ~= nil then
		render_with_treesitter(lines, result, ft)
	elseif render_with_vim_syntax(lines) then
		return
	else
		render_plain(lines)
	end
end
