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
	return string.format("%d,%d,%d,%d,%d", window['frame']['x'], window['frame']['y'], window['frame']['w'],
		window['frame']['h'], window['space'])
end

function StackIndicator:onEvent()
	log.df("StackIndicator:onEvent")

	local windows = self.client:getWindows(false)
	local frames = {}

	local focusedWindow = nil
	local focusedWindowFrameKey = nil
	for _, window in ipairs(windows) do
		local frame_key = _makeFrameKey(window)
		log.df("Frame key: %s", frame_key)
		if not frames[frame_key] then
			frames[frame_key] = {}
		end

		table.insert(frames[frame_key], window)
		if window['has-focus'] then
			focusedWindow = window
			focusedWindowFrameKey = frame_key
		end
	end

	if focusedWindow then
		log.df("Focused window: %s", hs.inspect(focusedWindow))
	end

	if not focusedWindow then
		self.osd:Hide()
		return
	end

	-- sort by stack index
	table.sort(frames[focusedWindowFrameKey], function(a, b) return a['stack-index'] < b['stack-index'] end)

	-- compute total windows in stack, and current windows stack position.
	log.df("Wins in stack: %d", #frames[focusedWindowFrameKey])
	self.osd:SetIndicator(focusedWindow, frames[focusedWindowFrameKey])
	self.menuIndicator:SetIndicator(focusedWindow, frames[focusedWindowFrameKey])
end

return StackIndicator
