local M = {}

local uv = vim.uv or vim.loop

function M.setup(opts)
	opts = opts or {}

	local enabled = true
	local threshold = opts.threshold or 10
	local interval_ms = opts.interval_ms or 2000
	local cooldown_ms = opts.cooldown_ms or 4000
	local message = opts.message or "Use a better motion."
	local keys = opts.keys or { "h", "j", "k", "l", "+", "-" }
	local state = {}

	local function now_ms()
		return math.floor(uv.hrtime() / 1000000)
	end

	for _, key in ipairs(keys) do
		state[key] = { count = 0, last = 0, warned_at = 0 }

		vim.keymap.set("n", key, function()
			if not enabled then
				return key
			end

			local entry = state[key]
			local now = now_ms()

			if now - entry.last <= interval_ms then
				entry.count = entry.count + 1
			else
				entry.count = 1
			end

			entry.last = now

			if entry.count >= threshold and now - entry.warned_at >= cooldown_ms then
				entry.warned_at = now
				vim.schedule(function()
					vim.notify(message, vim.log.levels.WARN, { title = "Discipline" })
				end)
			end

			return key
		end, { expr = true, silent = true, desc = "Motion discipline: " .. key })
	end

	vim.api.nvim_create_user_command("DisciplineToggle", function()
		enabled = not enabled
		vim.notify("Discipline " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
	end, { desc = "Toggle motion discipline warnings" })
end

return M
