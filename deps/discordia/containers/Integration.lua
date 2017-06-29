local Snowflake = require('./Snowflake')

local format = string.format

local Integration, property, method = class('Integration', Snowflake)
Integration.__description = "Represents a Discord Integration."

function Integration:__init(data, parent)
	Snowflake.__init(self, data, parent)
	--[[
	self._id = data.id
	self._name = data.name
	self._type = data.type
	self._enabled = data.enabled
	self._syncing = data.syncing
	self._expire_behavior = data.expire_behavior
	self._expire_grace_period = data.expire_grace_period
	self._user = data.user
	self._account = self.account
	self._synced_at = data.synced_at
	]]
end

function Integration:__tostring()
	return format('%s: %s', self.__name, self._type)
end

function Integration:__eq(other)
	return self.__name == other.__name and self._type == other._type
end

local function get(self, guild_id)
	return self._parent._api:getGuildIntegrations(guild_id)
end

local function create(self, guild_id)
	return self._parent._api:createGuildIntegration(guild_id, {
		type = self._type, 
		id = self._id
	})
end

local function modify(self, guild_id, enable_emoticons)
	local success, data = self._parent._api:modifyGuildIntegration(guild_id, self._id, {
		expire_behavior = self._expire_behavior,
		expire_grace_period = self._expire_grace_period,
		enable_emoticons = enable_emoticons
	})
	return success
end

local function delete(self, guild_id)
	local success, data = self._parent._api:deleteGuildIntegration(guild_id, self._id)
	return success
end

local function syncGuild(self, guild_id)
	local success, data = self._parent._api:syncGuildIntegration(guild_id, self._id)
	return success
end

property('id', '_id', nil, 'snowflake', "Integration identifying id.")
property('name', '_name', nil, 'string', "Integration identifying name.")
property('type', '_type', nil, 'string', "Integration identifying type.")
property('enabled', 'enabled', nil, 'boolean', "Property identifying if the Integration is enabled.")
property('syncing', '_syncing', nil, 'boolean', "Property identifying if the Integration is syncing.")
property('expire_behavior', '_expire_behavior', nil, 'integer', "Integration's behavior of expiring subscribers.")
property('expire_grace_period', '_expire_grace_period', nil, 'integer', "Integration's grace period before expiring subscribers.")
property('user', '_user', nil, 'User', "Integration identifying User Object.")
property('account', '_account', nil, 'Account', "Integration identifying Account Object.")
property('synced_at', '_synced_at', nil, 'timestamp', "Integration identifying token.")

method('get', get, "guild_id", "Returns an Integration.")
method('create', create, "guild_id", "Creates an Integration.")
method('modify', modify, "guild_id, enable_emoticons", "Modifies the Integration.")
method('delete', delete, nil, "Deletes the Integration.")
method('syncGuild', syncGuild, "guild_id", "Syncs the Integration.")

return Integration