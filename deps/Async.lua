_G.discordia = require('discordia')
_G.timer = require("timer")
local Responses = require("Responses")
_G.func = require("funciones")
local fs = require("fs")
require("table2")
require("lib/utf8")
require("lib/utf8data")

local json = require("json")
local http1 = require("coro-http")
_G.client = discordia.Client()
_G.DiscordiaVersion = "1.0"


local function Post(url, rest)
	url = url or "http://paste.ee/api"
	local er, body = http1.request("POST", url.."?"..rest)
	p(er.code)
	return body
end

_G.read_file = function(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*a"
	file:close()
	return content
end

function bigMessage( Ttable, message, header, symb )
  symb = symb or ""
  header = header and header.."\n" or "\n"
  local msg = ""
  for _, messageString in pairs(Ttable) do
    if string.utf8len(header..symb..msg.."\n"..messageString..symb) > 2000 then
      if msg ~= "" then
        send(message.channel, "```lua\n"..symb..msg..symb.."\n```")
        header = ""
      end
      msg = messageString
      while string.utf8len(header..symb..msg..symb) > 2000 do
        send(message.channel, "```lua\n"..symb..string.utf8sub(msg, 1, 2000-string.utf8len(header)-(string.utf8len(symb)*2))..symb.."\n```")
        msg = string.utf8sub(msg, 2001-string.utf8len(header)-(string.utf8len(symb)*2), -1)
      end
    else
      msg = (msg == "" and messageString) or msg.."\n"..messageString
    end
  end
  send(message.channel, "```lua\n"..symb..msg..symb.."\n```")
end

_G.sendAndDelete = function( channel, message, Ttimer )
	  Ttimer = Ttimer or 3000
	  local Tmessage = channel:sendMessage(message)
	  if Tmessage then
	    timer.setTimeout(Ttimer, coroutine.wrap(function()
	      	Tmessage:delete()
	   	end))
	end
end

_G.sendAndEdit = function( channel, message)
      local Tmessage = channel:sendMessage(message)
      if Tmessage then
          for k = 1, 10 do
            timer.sleep(1000)
            Tmessage:setContent("`>=>`")
            timer.sleep(1000)
            Tmessage:setContent("`^=^`")
            timer.sleep(1000)
            Tmessage:setContent("`v=v`")
            timer.sleep(1000)
            Tmessage:setContent("`<=<`")
            timer.sleep(1000)
            Tmessage:setContent("`°º¤ø,¸¸,ø¤º°'°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°'°º¤ø,¸`")
        end
    end
end

_G.send = function( channel, message)
	channel:sendMessage(message)
end

function GetMessages(message, choose)
	local output = ""

	if choose then

		local file = io.open("tag/"..choose..".txt", "rb")
		if not file then return nil end
		local content = file:read "*a"
		file:close()
		output = content

	    message.channel:sendMessage(output)
	end
end

function SaveMessage(message, tag, content)
	if message.author.id == "296622738054053888" then return end
	if not fs.existsSync("tag") then
		fs.mkdirSync("tag")
	end
	print(tag)
	local file = io.open("tag/"..tag..".txt", "w")
	file:write(content)
	file:close()
end

client:on('ready', function()
	p(string.format('Logged in as %s', client.user.username))
	client:setUsername("AsyncTest")
end)

client:on("messageCreate", function(message)
	Responses:setMessage(message.author, message)
	
	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if cmd == ".add" then
		for rolee in message.member.roles do
			local role = rolee.name
				local tag = Responses:sayResponse({
					prompt = ", choose a name for the tag.",
					input = {
						type = "string" 
					}
				}, message)

				local content = Responses:sayResponse({
					prompt = ", what do you want to add to that tag?",
					input = {
						type = "string" 
					}
				}, message)

				SaveMessage(message, tag, content)
				message.channel:sendMessage("Added.")
				return
		end
	end

	if cmd == ".tag" then
		if not arg then func.error(message, "Please insert a tag.") return end
		GetMessages(message, arg)
	end


	function shallowcopy(orig)
	  local orig_type = type(orig)
	  local copy
	  if orig_type == 'table' then
	    copy = {}
	    for orig_key, orig_value in pairs(orig) do
	      copy[orig_key] = orig_value
	    end
	  else -- number, string, boolean, etc
	    copy = orig
	  end
	  return copy
	end

	function LoadFunc3( message, arg )
    	local success, err = pcall(function(message)
    		local sandbox = shallowcopy(_G)
    		sandbox.os = {clock = os.clock, time = os.time, date = os.date, difftime = os.difftime}
    		local toReturn = {}
    		sandbox.toReturn = toReturn
			sandbox.io = io
    		sandbox.message = message
    		sandbox.channel, sandbox.guild = message.channel, message.guild
    		sandbox.client = client 
    		sandbox.error, sandbox.success = func.error, func.Success

      		sandbox.p = function( ... )
        		local answer = {}
        		for _, value in pairs({ ... }) do
          			if type(value) == "table" then
            			table.insert(answer, table.tostring(value))
          			else
            			table.insert(answer, tostring(value))
          			end
        		end
        		table.insert(toReturn, table.concat(answer, "\n"))
      		end
      		sandbox.print = sandbox.p
      		load(arg, "", "t", sandbox)()
      		if toReturn[1] == ("" or nil) then
      			--
			else
				if not toReturn[1] == nil then
					message.channel:sendMessage(" ", {
						title = "Success",
						description = toReturn[1],
					})
				end
			end
    	end, message)
    	if not success then
     		message.channel:sendMessage(" ", {
     			title = "Error",
				description = err,
			})
    	end
  	end

	if message.author.id == "191442101135867906" then
		if cmd == "eval" then
			if not arg then return end
			if arg then
				LoadFunc3(message, arg)
			end
		end
		if message.content == "Restart" then
			msg = message.channel:sendMessage("Restarting...\n██░░░░░░")
			timer.sleep(math.random(100, 500))
			msg:setContent("Restarting...\n████░░░")
			timer.sleep(math.random(100, 500))
			msg:setContent("Restarting...\n██████░░")
			timer.sleep(math.random(100, 500))
			msg:setContent("Restarted.")
			client:stop(true)
		end
	end
end)

client:run("MTYwNDA4MzkwNDY2NTM1NDI0.C8f0gw.gmDbork03oZIVZlIvc1TqLZMZZk")