local Constants = require(script.Parent.Constants)
local Settings = Constants.Settings

local DEFAULT_SETTINGS = {
  -- Controls whether the prefab has its position adjusted so it rests on top of
  -- the same surface as the placeholder.
  --
  -- This fixes an issue where the prefab will be floating in the air. The
  -- PrimaryPart is always below the prefab so there's no clipping while
  -- building, and the placeholder is always above ground so it can be easily
  -- viewed.
  --
  -- This setting adjusts the prefab's position that it rests on the same
  -- surface as the placeholder, instead of floating in the air.
	[Settings.MOVE_PREFAB_TO_PLACEHOLDER_SURFACE] = true,

	-- Turns the PrimaryParts of every prefab invisible when cloning it in.
	--
	-- This allows you to be aware of where you're positioner is while working,
	-- while not having to worry about changing its visibility when it's cloned in.
	[Settings.MAKE_PRIMARY_PART_INVISIBLE] = true,

	-- This tag is used to associate the prefab with placeholders in the workspace.
	[Settings.PREFAB_TAG_PATTERN] = "^prefab",

	-- This is the name given to ObjectValues created by the plugin.
  [Settings.PREFAB_VISIBILITY_OBJECT_VALUE_NAME] = "ArePrefabsShown",

  -- Forces CanCollide to be false for both the PrimaryPart of the prefab and the
  -- placeholder itself (when showing the prefab).
  [Settings.PREVENT_COLLISIONS] = true
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
