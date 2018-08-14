local constants = require(script.Parent.constants)
local settings = constants.settings

local DEFAULT_SETTINGS = {
	-- Turns the PrimaryParts of every prefab invisible when cloning it in.
	--
	-- This allows you to be aware of where you're positioner is while working,
	-- while not having to worry about changing its visibility when it's cloned in.
	[settings.MAKE_PRIMARY_PART_INVISIBLE] = true,

  -- This gets prepended to every prefab tag so there's no chance of naming collisions.
  [settings.TAG_PREFIX] = "prefab",

  -- Forces CanCollide to be false for both the PrimaryPart of the prefab and the
  -- placeholder itself (when showing the prefab).
  [settings.PREVENT_COLLISIONS] = true
}

return function(plugin)
	local PluginSettings = {}
	PluginSettings.__index = PluginSettings

	function PluginSettings.new(profile)
		local self = {
			profile = profile,
		}
		setmetatable(self, PluginSettings)

		return self
	end

	function PluginSettings:_formatKey(key)
		return string.format("%s:%s", self.profile, key)
	end

	function PluginSettings:Get(key)
		return plugin:getSetting(self:_formatKey(key)) or DEFAULT_SETTINGS[key]
	end

	function PluginSettings:Set(key, value)
		plugin:setSetting(self:_formatKey(key), value)
	end

	return PluginSettings
end
