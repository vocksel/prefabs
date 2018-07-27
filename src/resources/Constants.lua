return {
	Names = {
		TOOLBAR = "Prefabs",
    MODEL_CONTAINER = "Prefabs"
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
    PREFAB_NOT_FOUND = "No prefab named %s found",
    NAME_ALREADY_EXISTS = "A prefab named %q already exists. Please rename and try again",
    COULD_NOT_FIND_PREFAB_FROM_SELECTION = "%s is not a prefab, and a " ..
      "prefab could not be found as an ancestor. Please change your "..
      "selection and try again",
    NOTHING_SELECTED = "Failed to perform action, nothing selected"
  },

  Waypoints = {
    REGISTERED = "Registered prefab",
    INSERTED = "Inserted prefab",
    UPDATED = "Updated prefab",
    REFRESHED = "Refreshed prefabs"
  }
}
