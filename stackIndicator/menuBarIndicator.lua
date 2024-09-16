local MenuBarIndicator = {}
MenuBarIndicator.__index = MenuBarIndicator

local log = hs.logger.new("Indicator", 'debug')

function MenuBarIndicator:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

function MenuBarIndicator:init(client)
	self.client = client

	self.menu = hs.menubar.new(true, "yabaiHS:stackIndicatorMenuBarIcon")
	self.menu:setMenu(function() return self:onMenuPopup() end)
end

function MenuBarIndicator:SetIndicator(win, winsInStack)
	if #winsInStack == 1 then
		self:Hide()
		return
	end

	self.menu:returnToMenuBar()

	local text = string.format("stack: %d/%d", win['stack-index'], #winsInStack)
	self.menu:setTitle(text)

	local menuItems = {}
	for _, window in ipairs(winsInStack) do
		local title = string.format("%d: %s", window['stack-index'], window.app)

		local item = {
			title = title,
			fn = function() self.client:focusWindow(window) end,
		}
		table.insert(menuItems, item)
	end

	self.menu:setMenu(menuItems)
end

function MenuBarIndicator:Hide()
	self.menu:removeFromMenuBar()
end

return MenuBarIndicator