local adapter = {}

local mix = {
	[":heart_eyes:"] = "😍",
}

adapter.swap = function(emoji)
	print(mix[emoji])
	return mix[emoji] or emoji
end

return adapter