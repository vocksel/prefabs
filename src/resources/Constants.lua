return {
	Names = {
		TOOLBAR = "prefab",
		TOGGLE_BUTTON_TITLE = "Toggle",
		TOGGLE_BUTTON_TOOLTIP = "Toggles all of the prefabs between parts and real models",
    MODEL_CONTAINER = "Prefabs"
	},

	Images = {
		TOOGLE_BUTTON_ICON = "rbxassetid://413367266",
	},

	Settings = {
    MAKE_PRIMARY_PART_INVISIBLE = "MAKE_PRIMARY_PART_INVISIBLE",
		PREFAB_TAG_PATTERN = "PREFAB_TAG_PATTERN",
    PREVENT_COLLISIONS = "PREVENT_COLLISIONS",
    TAG_PREFIX = "TAG_PREFIX"
  },

  Errors = {
    NO_PREFABS_YET = "No prefabs exist currently, register a prefab first and try again.",
    MUST_BE_MODEL = "For %s to be a prefab it must be a Model instance",
    MUST_HAVE_PRIMARY_PART = "%s needs a PrimaryPart to be a prefab",
    NO_PREFAB_TAG = "%s is missing a prefab tag",
    PREFAB_NOT_FOUND = "No prefab named %s found"
  },

  Waypoints = {
    REGISTERED = "Registered prefab",
    INSERTED = "Inserted prefab",
    UPDATED = "Updated prefab",
    REFRESHED = "Refreshed prefabs"
  }
}
