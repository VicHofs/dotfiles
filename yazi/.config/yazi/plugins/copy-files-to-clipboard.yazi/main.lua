--- @since 26.1.22

local function trim(s)
	return (s:gsub("%s+$", ""))
end

local current_targets = ya.sync(function()
	local tab = cx.active
	local paths = {}

	if #tab.selected > 0 then
		for _, url in pairs(tab.selected) do
			local path = url.path
			if path and path.is_absolute then
				paths[#paths + 1] = tostring(path)
			end
		end
	else
		local hovered = tab.current.hovered
		if hovered then
			local path = hovered.url.path
			if path and path.is_absolute then
				paths[1] = tostring(path)
			end
		end
	end

	return paths
end)

return {
	entry = function()
		if ya.target_os() ~= "macos" then
			return ya.notify {
				title = "Clipboard copy unavailable",
				content = "This keybinding only works on macOS.",
				level = "warn",
				timeout = 3,
			}
		end

		local paths = current_targets()
		if #paths == 0 then
			return ya.notify {
				title = "Nothing to copy",
				content = "Select a file or hover one first.",
				level = "warn",
				timeout = 3,
			}
		end

		local args = {
			"-e", "on run argv",
			"-e", "set fileItems to {}",
			"-e", "repeat with p in argv",
			"-e", "set end of fileItems to (POSIX file p)",
			"-e", "end repeat",
			"-e", "set the clipboard to fileItems",
			"-e", "end run",
		}

		for _, path in ipairs(paths) do
			args[#args + 1] = path
		end

		local output, err = Command("osascript"):arg(args):output()
		if not output then
			return ya.notify {
				title = "Clipboard copy failed",
				content = err and tostring(err) or "Unable to start the clipboard helper.",
				level = "error",
				timeout = 5,
			}
		end

		if not output.status.success then
			local message = trim(output.stderr)
			if message == "" then
				message = "The clipboard helper exited with an error."
			end

			return ya.notify {
				title = "Clipboard copy failed",
				content = message,
				level = "error",
				timeout = 5,
			}
		end

		ya.emit("yank", {})
		ya.notify {
			title = "Copied to clipboard",
			content = string.format("%d item%s ready to paste in Finder.", #paths, #paths == 1 and "" or "s"),
			timeout = 2,
		}
	end,
}
