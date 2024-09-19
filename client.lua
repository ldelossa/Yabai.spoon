local YabaiClient = {}
YabaiClient.index = YabaiClient

local log = hs.logger.new('YabaiClient', 'debug')

function YabaiClient:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

-- Executes a yabai command
-- @param domain string: The domain to execute the command in
-- @param args string: The arguments to pass to the command
local execYabai = function(domain, args)
	local cmd = "yabai -m " .. domain .. " " .. args
	local data, _, _, code = hs.execute(cmd, true)
	return data, code
end

-- Help function which returns the focused item in the given json list
-- @param json table: The json list to search
-- @return table: The focused item or nil
local _returnIfFocused = function(json)
	for i, obj in ipairs(json) do
		if obj['has-focus'] then return obj end
	end
	return nil
end

-- Returns a liste of spaces
-- @param focused boolean: Return only the focused space
-- @return table: A list of spaces
function YabaiClient:getSpaces(focused)
	local json, code = execYabai("query", "--spaces")
	if code ~= 0 then
		log.ef("getSpaces failed. code: %d", code)
		return nil
	end
	json = hs.json.decode(json)

	if focused then
		return _returnIfFocused(json)
	end

	return json
end

-- Returns a list of displays
-- @param focused boolean: Return only the focused display
-- @return table: A list of displays
function YabaiClient:getDisplays(focused)
	local json, code = execYabai("query", "--displays")
	if code ~= 0 then
		log.ef("getDisplays failed. code: %d", code)
		return nil
	end
	json = hs.json.decode(json)

	if focused then
		return _returnIfFocused(json)
	end

	return json
end

-- Returns a list of windows
-- @param focused boolean: Return only the focused window
-- @return table: A list of windows
function YabaiClient:getWindows(focused)
	local json, code = execYabai("query", "--windows")
	if code ~= 0 then
		log.ef("getWindows failed. code: %d", code)
		return nil
	end
	json = hs.json.decode(json)

	if focused then
		return _returnIfFocused(json)
	end

	return json
end

function YabaiClient:focusWindow(window)
	if not window.id then
		log.ef("Window does not have an id")
		return
	end

	local _, code = execYabai("window", "--focus " .. window.id)
	if code ~= 0 then
		log.ef("Failed to focus window %d. code: %d", window.id, code)
	end
end

-- Focuses a space
-- @param space table: The space to focus
function YabaiClient:focusSpace(space)
	log.df("Focusing space %d", space.index)

	if not space.index then
		log.ef("Space does not have an index")
		return
	end

	local _, code = execYabai("space", "--focus " .. space.index)
	if code ~= 0 then
		log.ef("Failed to focus space %d. code: %d", space.index, code)
	end
end

-- Labels a space
-- @param space table: The space to label
-- @param label string: The label to apply
function YabaiClient:labelSpace(space, label)
	if not space.index then
		log.ef("Space does not have an index")
		return
	end
	if not label then
		log.ef("Label is required")
		return
	end

	execYabai("space", space.index .. " --label ")
	execYabai("space", space.index .. " --label " .. label)
end

-- Creates a new space
-- @param label string: The label of the space
-- @param focus boolean: Whether to focus the space after creation
function YabaiClient:createSpace(label, focus)
	execYabai("space", "--create")

	local spaces = self:getSpaces()
	if not spaces then
		log.ef("Failed to retrieve spaces while creating space")
		return
	end

	if #spaces == 0 then
		log.ef("No spaces found after creating space")
		return
	end

	local space = spaces[#spaces]
	if not space then
		log.ef("Failed to retrieve space after creating space")
		return
	end

	if label then
		self:labelSpace(space, label)
	end

	if focus then
		self:focusSpace(space)
	end
end

-- Destroys a space
-- @param space table: The space to destroy
function YabaiClient:destroySpace(space)
	if not space.index then
		log.ef("Space does not have an index")
		return
	end

	execYabai("space", "--destroy " .. space.index)
end

function YabaiClient:setSpaceLayout(space, layout)
	if (layout ~= "bsp" and layout ~= "float" and layout ~= "stack") then
		log.ef("Invalid layout: %s", layout)
		return
	end

	execYabai("space", space.index .. " --layout " .. layout)
end

function YabaiClient:nextInStack()
	execYabai("window", "--focus stack.next")
end

function YabaiClient:previousInStack()
	execYabai("window", "--focus stack.prev")
end

return YabaiClient
