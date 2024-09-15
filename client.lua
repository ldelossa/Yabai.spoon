local YabaiClient = {}
YabaiClient.index = YabaiClient

local log = hs.logger.new('YabaiClient', 'debug')

function YabaiClient:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

local execYabai = function(domain, args)
	local cmd = "yabai -m " .. domain .. " " .. args
	local data, _, _, code = hs.execute(cmd, true)
	return data, code
end

local _returnIfFocused = function(json)
	for i, obj in ipairs(json) do
		if obj['has-focus'] then return obj end
	end
	return nil
end

-- Returns a liste of spaces
-- @param focused boolean: Return only the focused space
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

return YabaiClient
