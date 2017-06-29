local response = {messages={}}
response.__index = response
DEFAULT_BOT_RESPONSE = ""

function response.new()
  return setmetatable({},response)
end

function response:setMessage(author,message)
  response.messages[author.id] = message
end

function response:clean(typeOf,message,dialog,server)
  local contentLower = message.content:lower()
  if typeOf == "mention" then
    --
  elseif typeOf == "string" then
    return message.content
  elseif typeOf == "user" then
    local user = _G.class.Users:find(message,server)
    if not user then return {false,_G.DEFAULT_BOT_RESPONSE.."could not find the user!"} end
    return user
  elseif typeOf == "number" then
    local num = tonumber(message.content)
    if not num then return {false,_G.DEFAULT_BOT_RESPONSE.."you didn't give me a number!"} end
    return num
  elseif typeOf == "choices" then
    for i,v in pairs(dialog.input.choices) do
      if contentLower == v then
        return v
      end
    end
    return {false,_G.DEFAULT_BOT_RESPONSE.."\nInvalid type. Choices = "..table.concat(dialog.input.choices,", ").."."} 
  end
end
function response:sayResponse(dialog,message,ignore_prompt)
    local channel = message.channel
    local author = message.author
    if not ignore_prompt then message.channel:sendMessage(_G.DEFAULT_BOT_RESPONSE..dialog.prompt) end
    response.messages[message.author.id] = nil
    while not response.messages[message.author.id] do
      timer.sleep(500)
    end    
    local content = response:clean(dialog.input.type,response.messages[message.author.id],dialog,message.server)
    if type(content) == "table" then
      if content[1] == false then
        message.channel:sendMessage(content[2])
       return response:sayResponse(dialog,message,true)
      end
    end
    return content
end

function response:setDialogs(dialogs,message)
  local args = {}
  for i,v in pairs(dialogs) do
    if v.input.name then
     args[v.input.name] = response:sayResponse(v,message)
    end
  end
  return args 
end


return response