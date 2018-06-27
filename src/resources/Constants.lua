return {
	Names = {
		TOOLBAR = "prefab",
		TOGGLE_BUTTON_TITLE = "Toggle",
		TOGGLE_BUTTON_TOOLTIP = "Toggles all of the prefabs between parts and real models",
	},

	Images = {
		TOOGLE_BUTTON_ICON = "rbxassetid://413367266",
	},

	Settings = {
		-- Controls how far down (in studs) the prefab will be moved when cloning it in.
		--
		-- This is so the PrimaryPart can be below the prefab, while having the
		-- placeholder in the workspace be above ground, so that it can be viewed.
		--
		-- This makes it easier to work with the prefab, as the PrimaryPart doesn't
		-- have to be lodged into the model in any way.
		SHIFT_DOWN_FROM_PLACEHOLDER = 1,

		-- Turns the PrimaryParts of every prefab invisible when cloning it in.
		--
		-- This allows you to be aware of where you're positioner is while working,
		-- while not having to worry about changing its visibility when it's cloned in.
		MAKE_PRIMARY_PART_INVISIBLE = true,

		-- This tag is used to associate the prefab with placeholders in the workspace.
		PREFAB_TAG_PATTERN = "^prefab",

		-- This is the name given to ObjectValues created by the plugin.
		PREFAB_VISIBILITY_OBJECT_VALUE = "ArePrefabsShown",
	},
}