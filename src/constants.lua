return {
	names = {
		TOOLBAR = "Prefabs",
	},

	settings = {
    MAKE_PRIMARY_PART_INVISIBLE = "MAKE_PRIMARY_PART_INVISIBLE",
		PREFAB_TAG_PATTERN = "PREFAB_TAG_PATTERN",
    PREVENT_COLLISIONS = "PREVENT_COLLISIONS",
    TAG_PREFIX = "TAG_PREFIX"
  },

  toasts = {
    TIMEOUT = 4
  },

  sounds = {
    click = "rbxasset://click.ogg",
    notification = "rbxasset://intuition.ogg"
  },

  ui = {
    font = Enum.Font.SourceSans,
    textSize = 18,
    textColor = Color3.fromRGB(255, 255, 255),
    backgroundColor = Color3.fromRGB(20, 20, 20),
    padding = 16
  },

  -- All of this is related to tagging the prefabs and connecting with the Tag
  -- Editor plugin.
  tagging = {
    -- These names are defined from the Tag Editor plugin. They're being set as
    -- constants incase the names change in the future.
    TAG_FOLDER_NAME = "TagList",
    TAG_GROUP_FOLDER_NAME = "TagGroupList",

    TAG_GROUP_NAME = "Prefabs"
  },

  messages = {
    SUCCESSFULLY_ADDED = "Successfully registered %s",
    SUCCESSFULLY_UPDATED = "Successfully updated all copies of %s",
    SUCCESSFULLY_INSERTED = "Successfully inserted %s"
  },

  errors = {
    MUST_BE_MODEL = "For %s to be a prefab it must be a Model instance",
    MUST_HAVE_PRIMARY_PART = "%s needs a PrimaryPart to be a prefab",
    NO_PREFAB_TAG = "%s is missing a prefab tag",
    PREFAB_NOT_FOUND = "No prefab named %s found",
    NAME_ALREADY_EXISTS = "A prefab named %q already exists. Please rename and try again",
    COULD_NOT_FIND_PREFAB_FROM_SELECTION = "%s is not a prefab, and a " ..
      "prefab could not be found as an ancestor. Please change your "..
      "selection and try again",
    NOTHING_SELECTED = "Failed to perform action, nothing selected"
  },

  waypoints = {
    REGISTERED = "Registered prefab",
    INSERTED = "Inserted prefab",
    UPDATED = "Updated prefab",
    REFRESHED = "Refreshed prefabs",
    CLEAN = "Clean prefab tag",
    DANGEROUSLY_DELETED = "Deleted prefab clones"
  }
}
