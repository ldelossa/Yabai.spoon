local OnScreenIndicator = dofile(hs.spoons.resourcePath("onScreenIndicator.lua"))
local MenuBarIndicator = dofile(hs.spoons.resourcePath("menuBarIndicator.lua"))

local StackIndicator = {}
StackIndicator.__index = StackIndicator

local log = hs.logger.new("StackIndicator", 'debug')

function StackIndicator:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

function StackIndicator:init(spoon, showOnScreenStackIndicator, showMenuBarStackIndicator)
	log.df("StackIndicator:init")
	self.spoon = spoon
	self.client = spoon.client

	if not showOnScreenStackIndicator and not showMenuBarStackIndicator then
		log.df("No indicators to show, abort initialization")
		return
	end

	if showOnScreenStackIndicator then
		self.osd = OnScreenIndicator:new()
		self.osd:init(self.client)
	end

	if showMenuBarStackIndicator then
		self.menuIndicator = MenuBarIndicator:new()
		self.menuIndicator:init(self.client)
	end

	spoon:registerOnWindowsChangedCB(function() self:onEvent() end)
	self:onEvent()
end

local function _makeFrameKey(window)
	return string.format("%d,%d,%d,%d,%d",
		window.frame.x, window.frame.y, window.frame.w, window.frame.h, window.space)
end

-- inventory each window and what stack it belongs to.
-- windows belong to the same stack when they occupy the same exact frame
-- dimensions from the WM, since the Yabai API does not provide a better way
-- to determine this via its API.
function StackIndicator:onEvent()
	log.df("StackIndicator:onEvent")

	local focusedWindow = nil
	local focusedWindowFrameKey = nil
	local frames = {}
	local windows = self.client:getWindows(false)

	for _, window in ipairs(windows) do
		local frameKey = _makeFrameKey(window)
		if not frames[frameKey] then
			frames[frameKey] = {}
		end

		table.insert(frames[frameKey], window)
		if window['has-focus'] then
			focusedWindow = window
			focusedWindowFrameKey = frameKey
		end
	end

	if not focusedWindow then
		self.osd:Hide()
		return
	end

	-- sort by stack index
	table.sort(frames[focusedWindowFrameKey], function(a, b) return a['stack-index'] < b['stack-index'] end)

	-- compute total windows in stack, and current windows stack position.
	self.osd:SetIndicator(focusedWindow, frames[focusedWindowFrameKey])
	self.menuIndicator:SetIndicator(focusedWindow, frames[focusedWindowFrameKey])
end

return StackIndicator
