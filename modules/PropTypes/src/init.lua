local BUILTIN_TYPE_NAMES = {
	"string", "number", "table", "boolean",
	-- typeof(coroutine) == thread
	"thread",
	"Axes", "BrickColor", "CFrame", "Color3",
	"ColorSequence", "ColorSequenceKeypoint",
	"Faces", "Instance", "NumberRange",
	"NumberSequence", "NumberSequenceKeypoint",
	"PhysicalProperties", "Ray", "Rect",
	"Region3", "Region3int16", "TweenInfo",
	"UDim", "UDim2", "Vector2", "Vector3",
	"Vector3int16", "Enum", "EnumItem"
}

local DEFAULT_REASON = "<validation failed: no reason given>"

local function makePrimitiveValidator(typeName)
	return function(value)
		local valueType = typeof(value)

		return valueType == typeName, ("expected type %q, got type %q"):format(typeName, valueType)
	end
end

local PropTypes = {}

for _, typeName in ipairs(BUILTIN_TYPE_NAMES) do
	PropTypes[typeName] = makePrimitiveValidator(typeName)
end

PropTypes.coroutine = makePrimitiveValidator("thread")

function PropTypes.userdata(value)
	return type(value) == "userdata", ("expected type \"userdata\", got type %q"):format(typeof(value))
end

function PropTypes.func(value)
	return type(value) == "function", ("expected type \"function\", got type %q"):format(typeof(value))
end

function PropTypes.some(value)
	return value ~= nil, "expected a value, got nil"
end

--[[
	Creates a validator that checks if all its supplied validator functions
	succeeded.
]]
function PropTypes.all(...)
	local validators = { ... }

	return function(value)
		for _, validator in ipairs(validators) do
			local success, failureReason = validator(value)

			if not success then
				return false, failureReason or DEFAULT_REASON
			end
		end

		return true
	end
end

--[[
	Creates a validator that checks if any of its supplied validator functions
	succeeded.
]]
function PropTypes.any(...)
	local validators = { ... }

	return function(value)
		for _, validator in ipairs(validators) do
			local success, _ = validator(value)

			if success then
				return true
			end
		end

		return false, ("No validators affirmed the value %q"):format(tostring(value))
	end
end

--[[
	Returns a new validator function that behaves identically to the original,
	but allows `nil` to be passed through.
]]
function PropTypes.optional(inner)
	return function(value)
		-- Specifically check for nil to avoid cases where "false" is not allowed
		if value == nil then
			return true
		else
			return inner(value)
		end
	end
end

--[[
	A validator function that checks if you can index into the value.
	Does not check if you can *successfully* index into the value with a
	specific key, but does make sure that you're not going to try to index into
	a number or string!
]]
local indexable = PropTypes.any(
	PropTypes.table,
	PropTypes.userdata
)

--[[
	Creates a validator function that checks if a value matches a given shape.
]]
function PropTypes.object(shape)
	return PropTypes.all(
		-- If we definitely can't index into the value, it can't have a shape!
		indexable,
		function(value)
			local failures = {}

			for key, keyValidator in pairs(shape) do
				local subValue = value[key]
				local success, failureReason = keyValidator(subValue)

				failureReason = failureReason or DEFAULT_REASON

				if not success then
					-- Increase the indentation of all indented lines in the
					-- failure reason by one. This makes indents nest nicely
					-- when you have multiple nested `object` validators.
					failureReason = failureReason:gsub("\n\t*", function(tabSequence)
						return tabSequence .. "\t"
					end)

					table.insert(failures, ("key %q: %s"):format(key, failureReason))
				end
			end

			if #failures > 0 then
				return false, ("%d key%s incorrect:\n%s"):format(
					#failures,
					#failures == 1 and " is" or "s are",
					table.concat(failures, "\n")
				)
			else
				return true
			end
		end
	)
end

--[[
	Creates a validator function that checks if a value matches a given shape exactly, failing if the value contains
	a key not specified in the shape.
]]
function PropTypes.strictObject(shape)
	return PropTypes.all(
		PropTypes.object(shape),
		-- object will handle any keys that are supposed to be there; this only needs to check for the presence of
		-- unspecified keys.
		function(value)
			local failures = {}

			for key, _ in pairs(value) do
				if shape[key] == nil then
					table.insert(failures, ("%q"):format(tostring(key)))
				end
			end

			if #failures > 0 then
				return false, ("%d illegal key%s present: { %s }"):format(
					#failures,
					#failures == 1 and " is" or "s are",
					table.concat(failures, ", ")
				)
			else
				return true
			end
		end
	)
end

--[[
	Creates a validator that checks if a value is an EnumItem of a particular
	Enum.
]]
function PropTypes.enumOf(enum, allowCasting)
	local enumItem = PropTypes.all(
		PropTypes.EnumItem,
		function(value)
			return value.EnumType == enum, ("the EnumItem %q belongs to the %q Enum, not the %q Enum"):format(
				tostring(value),
				tostring(value.EnumType),
				tostring(enum)
			)
		end
	)

	if allowCasting then
		return PropTypes.any(
			enumItem,
			PropTypes.all(
				PropTypes.any(PropTypes.string, PropTypes.number),
				function(value)
					for _, item in ipairs(enum:GetEnumItems()) do
						if item.Name == value or item.Value == value then
							return true
						end
					end

					return false, ("the %s %q cannot be coerced to an EnumItem in the %q Enum"):format(
						typeof(value),
						tostring(value),
						tostring(enum)
					)
				end
			)
		)
	else
		return enumItem
	end
end

function PropTypes.ofClass(className)
	return PropTypes.all(
		PropTypes.Instance,
		function(value)
			return value:IsA(className), ("the Instance %s is not descended from the class %q (is a %q)"):format(
				value:GetFullName(),
				className,
				value.ClassName
			)
		end
	)
end

function PropTypes.tableOf(itemValidator)
	return PropTypes.all(
		PropTypes.table,
		function(value)
			local failures = {}

			for key, subValue in pairs(value) do
				local success, failureReason = itemValidator(subValue)

				if not success then
					table.insert(failures, ("\tkey %q (%q of type %q):\n\t\t%s"):format(
						tostring(key),
						tostring(subValue),
						typeof(subValue),
						failureReason or DEFAULT_REASON
					))
				end
			end

			if #failures > 0 then
				return false, ("%d key%s incorrect:\n%s"):format(
					#failures,
					#failures == 1 and " is" or "s are",
					table.concat(failures, "\n")
				)
			else
				return true
			end
		end
	)
end

function PropTypes.oneOf(possibilities)
	-- Generate a list of all the tostring-ed possiblities.
	-- This allows the use of table.concat.
	local stringPossibilities = {}

	for _, possibility in ipairs(possibilities) do
		table.insert(stringPossibilities, tostring(possibility))
	end

	return function(value)
		for _, possibility in ipairs(possibilities) do
			if possibility == value then
				return true
			end
		end

		return false, ("%q is not in the list of possibilities: { %s }"):format(
			tostring(value),
			table.concat(stringPossibilities, ", ")
		)
	end
end

function PropTypes.tuple(...)
	local validators = { ... }

	return function(...)
		local failures = {}

		for i = 1, select("#", ...) do
			local value = select(i, ...)
			local validator = validators[i]

			local success, message = validator(value)
			if not success then
				table.insert(failures, ("\targument #%d: %s"):format(
					i,
					message or DEFAULT_REASON
				))

			end
		end

		if #failures > 0 then
			return false, ("%d argument%s incorrect:\n%s"):format(
				#failures,
				#failures == 1 and " is" or "s are",
				table.concat(failures, "\n")
			)
		else
			return true
		end
	end
end

return PropTypes
