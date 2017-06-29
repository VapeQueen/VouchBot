local adapter = {}

local mix = {
	[":)"] = "☺️",
}

adapter.swap = function(emoji)
	return mix[emoji] or emoji
end

return adapter