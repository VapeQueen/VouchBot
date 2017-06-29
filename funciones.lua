local func = {}

func.ts = function(...) return tostring(...) end -- tostring
func.l = function(...) return string.lower(...) end -- lower
func.u = function(...) return string.upper(...) end -- upper
func.r = function(index, times)                     -- repeat
    local k = "" 
    for i = 1, tonumber(times) do 
        k = k.." "..index 
    end
    return k
end

func.Restricted = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Restricted Command**\n"..str or "", 
        ["color"] = 16520231,
    })
end

func.error = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Error**\n"..str, 
        ["color"] = 16520231,
    })
end

func.Requesting = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Requesting...**\n"..str, 
        ["color"] = 15917850,
    })
end

func.Success = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Success**\n"..str, 
        ["color"] = 1765979,
    })
end

func.Info = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Info**\n"..str, 
        ["color"] = 4359924,
    })
end

return func
