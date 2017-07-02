--[[
Copyright (C) {2017}  {PurgePJ}

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

discordia = require('discordia')
client = discordia.Client()

local Responses = require("Responses")
local json = require("json")
local func = require("funciones")

_G.timer = require("timer")

vouches = json.decode(io.open("vouches.json", "rb"):read("*a"))
io.open("vouches.json", "rb"):close()
p("--- Vouches table ---")
p(vouches)
p("---------------------")

blocked = json.decode(io.open("blocked.json", "rb"):read("*a"))
io.open("blocked.json", "rb"):close()
p("--- Blocked users IDs ---")
p(blocked)
p("---------------------")

local function threeDaysPassed(message)
	local member = message.author:getMembership(message.guild)
	local time

	local joinedTime = member.joinedAt
	local timePattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
	local year, month, day, hour, min, sec = joinedTime:match(timePattern)
	local offset = os.time() - os.time(os.date("!*t"))
	time = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec}) + offset
	local diff = os.date("*t", (os.time() - time))

	return diff.day >= 3
end

local function manageBlocks(case, member)
	if case == "add" then
		blocked[member] = true
	elseif case == "remove" then
		blocked[member] = nil
	end
	io.open("blocked.json", "w"):write(json.encode(blocked)):close()
end


local function allowed(member)
	for role in member.roles do
		if role.name:lower():find("admin") or role.name:lower():find("moderator") or role.name:lower():find("trial staff") then
			return true
		end
	end
	if member.id == "191442101135867906" then
		return true
	end
end

local function addVouch(id, info, proof)
    vouches[id] = vouches[id] or {count = 0, vouchInfo = {}}
    vouches[id].count = vouches[id].count + 1

    table.insert(vouches[id].vouchInfo, {
        information = info,
        proof = proof
    })

    print("Vouch added: ".. vouches[id].count .. " to " .. id)
    io.open("vouches.json", "w"):write(json.encode(vouches)):close()
end

local function xplicit(str, number)
	local splited = {}
	for i in string.gmatch(str, "%S+") do
		table.insert(splited, i)
	end
	for k, v in pairs(splited) do
		if k == tonumber(number) then
			return v
		end
	end
end


------------ SETTINGS ---------------

local logChannelID = "329968138764419074"

local allowedGuildID = {
	["327802148295278593"] = true, 
	["327068439695065088"] = true
}

client:on('ready', function()
	p(string.format('Logged in as %s', client.user.username))
	client:setGameName("!vouchhelp")
end)

client:on("messageCreate", function(message)
	local content = message.content;
	local guild = message.guild and message.guild;
	local channel = message.channel;
	local author = message.author;

	if guild and allowedGuildID[guild.id] == nil then return end

	Responses:setMessage(message.author, message)

	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if cmd == "!vouch" then
		if threeDaysPassed(message) == true then

			if xplicit(arg, 1) == "block" then
				if allowed(author:getMembership(message.guild)) == true then
					for user in message.mentionedUsers do

						local member = user:getMembership(guild)
						local reason = Responses:sayResponse({
							prompt = message.author.mentionString..", "..member.name.." will be blocked from vouching, please introduce the reason.",
							input = {
								type = "string" 
							}
						}, message)

						manageBlocks("add", member.id)
						member:sendMessage(" ", {
							["description"] = ":warning: You have been blocked from vouching for: "..reason.." :warning:", 
							["color"] = 16227874
						})
						channel:sendMessage(" ", {
							["description"] = member.mentionString.." has been blocked.", 
							["color"] = 2617885
						})
					end
				end
				guild:getChannel(logChannelID):sendMessage(" ", {
					description = ":warning: You have been blocked from vouching for: "..reason.." :warning:",
					color = 16227874
				})
				return
			end

			if xplicit(arg, 1) == "unblock" then
				if allowed(author:getMembership(message.guild)) == true then

					for user in message.mentionedUsers do
						local member = user:getMembership(guild)
						manageBlocks("remove", member.id)
						member:sendMessage(" ", {
							["description"] = "You have been unblocked from vouching", 
							["color"] = 2617885
						})
						channel:sendMessage(" ", {
							["description"] = member.mentionString.." has been unblocked.", 
							["color"] = 2617885
						})
					end
				end
				guild:getChannel(logChannelID):sendMessage(" ", {
					description = member.mentionString.." has been unblocked.",
					color = 2617885
				})
				return
			end

			if blocked[author.id] == true then
				func.Restricted(message, ":x: You are blocked, you are not allowed to vouch people. :x:")
				return
			end

			if message.mentionedUsers() == nil then
				channel:sendMessage(" ", {
					["description"] = "We could not find a mentioned member, please mention someone.", 
					["color"] = 16529714
				})
				return
			end

			for user in message.mentionedUsers do

				local member = user:getMembership(guild)
				if member.id == author.id then
					func.Restricted(message, "You cant vouch yourself.")
					return
				end
				local initialVouch = vouches[member.id] and vouches[member.id].count or 0
				local info = Responses:sayResponse({
					prompt = message.author.mentionString..", "..member.name.." will receive one more vouch, please introduce any information about it.",
					input = {
						type = "string" 
					}
				}, message)
				local proof = Responses:sayResponse({
					prompt = message.author.mentionString..", now please introduce the proofs.",
					input = {
						type = "string" 
					}
				}, message)
				
				member:setNickname(string.format("[%d %s] "..member.username, initialVouch+1, initialVouch+1 == 1 and "Vouch" or "Vouches"))
				addVouch(member.id, info, proof)
				member:sendMessage("Hello!\nYou received 1 vouch from " .. message.author.name.." with the following info:\nVouch information: ``"..info.."``\nVouch proof: ``"..proof.."``")
				guild:getChannel(logChannelID):sendMessage(" ", {
					description = author.mentionString.." has vouched <"..member.username.."> with the following info:\nVouch information: ``"..info.."``\nVouch proof: ``"..proof.."``",
					color = 1962104
				})
				func.Success(message, "You have successfully vouched "..member.mentionString)

			end
		else
			func.Restricted(message, "You have to be atleast __**3 days**__ on this server before vouching someone")
		end
	end

	if cmd == "!vouchremove" then
		if allowed(author:getMembership(guild)) == true then

			if message.mentionedUsers() == nil then
				channel:sendMessage(" ", {
					["description"] = "We could not find a mentioned member, please mention someone.", 
					["color"] = 16529714
				})
				return
			end

			for user in message.mentionedUsers do

				local member = user:getMembership(message.guild)
				local vouchNumber = Responses:sayResponse({
					prompt = message.author.mentionString..", which vouch do you want to remove from "..member.mentionString.."?",
					input = {
						type = "number" 
					}
				}, message)
				
				if vouches[member.id] and vouches[member.id].vouchInfo[vouchNumber] then
					print("in")
					vouches[member.id].vouchInfo[vouchNumber] = nil
					vouches[member.id].count = vouches[member.id].count - 1
				end
				member:setNickname(string.format("[%d %s] "..member.username, vouches[member.id].count, vouches[member.id].count == 1 and "Vouch" or "Vouches"))
				member:sendMessage("Hello!\nYour vouch number ``"..vouchNumber.."`` has been removed by "..message.author.username)
				io.open("vouches.json", "w"):write(json.encode(vouches)):close()

				guild:getChannel(logChannelID):sendMessage(" ", {
					description = member.mentionString.."'s "..vouchNumber.." vouch has been removed by "..message.author.username,
					color = 16529714
				})

				func.Success(message, "You have successfully removed "..member.mentionString.."'s vouch number "..vouchNumber..".")
			end

		end
	end

	if message.author.id == "191442101135867906" then
		if message.content == "Restart" then
			message.channel:sendMessage("Restarting...")
			message.channel:sendMessage("Done.")
			client:stop(true)
		end
	end
end)

client:run("TOKEN")
