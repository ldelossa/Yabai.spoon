local SpaceCleaner = {}
SpaceCleaner.__index = SpaceCleaner

local log = hs.logger.new("SpaceCleaner", 'debug')

function SpaceCleaner:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

function SpaceCleaner:init(spoon)
	log.df("SpaceCleaner:init")
	-- keep a reference to spoon's API and Yabai client
	self.spoon = spoon
	self.client = spoon.client
	-- register our event handler
	spoon:registerOnSpacesChangedCB(function() self:onEvent() end)
	-- fire initial event to click things off
	self:onEvent()
end

-- Find any spaces with zero windows and destroy them, unless the space is
-- is currently focused.
function SpaceCleaner:onEvent()
	log.df("SpaceCleaner:onEvent")

	local spaces = self.client:getSpaces(false)
	local windows = self.client:getWindows()

	local seen_spaces = {}

	for _, win in ipairs(windows) do
		seen_spaces[win.space] = true
	end

	for _, space in ipairs(spaces) do
		if not seen_spaces[space.index] and not space['has-focus'] then
			log.df("SpaceCleaner: space %d is empty", space.index)
			self.client:destroySpace(space)
		end
	end
end

return SpaceCleaner
