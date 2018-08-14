--[[
	Provides functions for manipulating immutable data structures.
]]

local immutable = {}

--[[
	Merges dictionary-like tables together.
]]
function immutable.joinDictionaries(...)
	local result = {}

	for i = 1, select("#", ...) do
		local dictionary = select(i, ...)
		for key, value in pairs(dictionary) do
			result[key] = value
		end
	end

	return result
end

--[[
	Joins any number of lists together into a new list
]]
function immutable.joinLists(...)
	local new = {}

	for listKey = 1, select("#", ...) do
		local list = select(listKey, ...)
		local len = #new

		for itemKey = 1, #list do
			new[len + itemKey] = list[itemKey]
		end
	end

	return new
end

--[[
	Creates a new copy of the dictionary and sets a value inside it.
]]
function immutable.set(dictionary, key, value)
	local new = {}

	for key, value in pairs(dictionary) do
		new[key] = value
	end

	new[key] = value

	return new
end

--[[
	Creates a new copy of the list with the given elements appended to it.
]]
function immutable.append(list, ...)
	local new = {}
	local len = #list

	for key = 1, len do
		new[key] = list[key]
	end

	for i = 1, select("#", ...) do
		new[len + i] = select(i, ...)
	end

	return new
end

--[[
	Remove elements from a dictionary
]]
function immutable.removeFromDictionary(dictionary, ...)
	local result = {}

	for key, value in pairs(dictionary) do
		local found = false
		for listKey = 1, select("#", ...) do
			if key == select(listKey, ...) then
				found = true
				break
			end
		end
		if not found then
			result[key] = value
		end
	end

	return result
end

--[[
	Remove the given key from the list.
]]
function immutable.removeFromList(list, removeIndex)
	local new = {}

	for i = 1, #list do
		if i ~= removeIndex then
			table.insert(new, list[i])
		end
	end

	return new
end

--[[
	Remove the range from the list starting from the index.
]]
function immutable.removeRangeFromList(list, index, count)
	local new = {}

	for i = 1, #list do
		if i < index or i >= index + count then
			table.insert(new, list[i])
		end
	end

	return new
end

--[[
	Creates a new list that has no occurrences of the given value.
]]
function immutable.removeValueFromList(list, removeValue)
	local new = {}

	for i = 1, #list do
		if list[i] ~= removeValue then
			table.insert(new, list[i])
		end
	end

	return new
end

return immutable
