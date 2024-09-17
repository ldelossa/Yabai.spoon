local SpaceMenuBarIcon = {}
SpaceMenuBarIcon.__index = SpaceMenuBarIcon

local log = hs.logger.new("SpaceMenuBarIcon", 'debug')

function SpaceMenuBarIcon:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

function SpaceMenuBarIcon:init(spoon)
	log.df("SpaceMenuBarIcon:init")
	-- keep a reference to spoon's API and Yabai client
	self.spoon = spoon
	self.client = spoon.client
	-- create a menubar icon which will display the current space
	self.menu = hs.menubar.new(true, "yabaiHS:SpaceMenuBarIcon")
	self.menu:setMenu(function() return self:onMenuPopup() end)

	-- register our event handler
	spoon:registerOnSpacesChangedCB(function() self:onEvent() end)
	spoon:registerOnApplicationsChangedCB(function() self:onEvent() end)

	-- fire initial event to click things off
	self:onEvent()
end


function SpaceMenuBarIcon:onMenuPopup()
	local spaces = self.client:getSpaces(false)

	local menuItems = {}
	for _, space in ipairs(spaces) do
		if space['has-focus'] then
			goto continue
		end

		local title = space.index
		if space.label ~= "" then
			title = space.label
		end

		local item = {
			title = title .. " (" .. space['type'] .. ")",
			fn = function() self.client:focusSpace(space) end
		}
		table.insert(menuItems, item)
		::continue::
	end

	table.insert(menuItems, {
		title = "➕",
		fn = function() self.spoon:createSpace() end
	})

	return menuItems
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

	title = title .. " (" .. focusedSpace['type'] .. ")"

	self.menu:setTitle(title)
end

return SpaceMenuBarIcon
