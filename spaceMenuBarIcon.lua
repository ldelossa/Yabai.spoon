local SpaceMenuBarIcon = {}
SpaceMenuBarIcon.__index = SpaceMenuBarIcon

local log = hs.logger.new("SpaceMenuBarIcon", 'debug')

function SpaceMenuBarIcon:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

function SpaceMenuBarIcon:init(spoon)
	-- keep a reference to spoon's API and Yabai client
	self.spoon = spoon
	self.client = spoon.client
	-- create a menubar icon which will display the current space
	self.menu = hs.menubar.new(true, "yabaiSpoon-space-menubar")

	-- register our event handler
	spoon:registerOnSpacesChangedCB(function() self:onEvent() end)
	spoon:registerOnApplicationsChangedCB(function() self:onEvent() end)

	-- fire initial event to click things off
	self:onEvent()
end

function SpaceMenuBarIcon:onEvent()
	log.df("SpaceMenuBarIcon:onEvent")

	local focusedSpace = self.client:getSpaces(true)
	if not focusedSpace then
		log.ef("Failed to retrieve focused space")
		return
	end

	local title = focusedSpace.index
	if focusedSpace.label ~= "" then
		title = focusedSpace.label
	end

	print(title)
	self.menu:setTitle(title)
end

return SpaceMenuBarIcon
