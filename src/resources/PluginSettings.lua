local Constants = require(script.Parent.Constants)
local Settings = Constants.Settings

local DEFAULT_SETTINGS = {
	-- Controls how far down (in studs) the prefab will be moved when cloning it in.
	--
	-- This is so the PrimaryPart can be below the prefab, while having the
	-- placeholder in the workspace be above ground, so that it can be viewed.
	--
	-- This makes it easier to work with the prefab, as the PrimaryPart doesn't
	-- have to be lodged into the model in any way.
	[Settings.SHIFT_DOWN_FROM_PLACEHOLDER] = 1,

	-- Turns the PrimaryParts of every prefab invisible when cloning it in.
	--
	-- This allows you to be aware of where you're positioner is while working,
	-- while not having to worry about changing its visibility when it's cloned in.
	[Settings.MAKE_PRIMARY_PART_INVISIBLE] = true,

	-- This tag is used to associate the prefab with placeholders in the workspace.
	[Settings.PREFAB_TAG_PATTERN] = "^prefab",

	-- This is the name given to ObjectValues created by the plugin.
	[Settings.PREFAB_VISIBILITY_OBJECT_VALUE_NAME] = "ArePrefabsShown",
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
		return plugin:GetSetting(self:_formatKey(key)) or DEFAULT_SETTINGS[key]
	end

	function PluginSettings:Set(key, value)
		plugin:SetSetting(self:_formatKey(key), value)
	end

	return PluginSettings
end