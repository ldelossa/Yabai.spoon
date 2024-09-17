local SpaceMenuBaryIcon = dofile(hs.spoons.resourcePath("spaceMenuBarIcon.lua"))
local SpaceCleaner = dofile(hs.spoons.resourcePath("spaceCleaner.lua"))
local StackIndicator = dofile(hs.spoons.resourcePath("stackIndicator/init.lua"))

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Yabai"
obj.version = "0.1"
obj.author = "Louis DeLosSantos <louis.delos@gmail.com>"
obj.homepage = "https://github.com/ldelossa/YabaiSpoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- fields
obj.logger = hs.logger.new('Yabai', 'debug')
obj.client = dofile(hs.spoons.resourcePath("client.lua"))

obj.spaceMenuBarIcon = nil
obj.spaceCleaner = nil
obj.stackIndicator = nil

obj.registry = {
	onApplicationChanged = {},
	onSpacesChanged = {},
	onWindowsChanged = {},
	onDisplaysChanged = {}
}

local defaultHotKeysMapping = {
	createSpace = { { "alt", "shift" }, "n" },
	selectSpace = { { "alt" }, "w" },
	labelSpace = { { "alt" }, "r" },
	toggleSpaceLayout = { { "alt" }, "o" }
}

local hotKeyHandlers = {
	createSpace = function() obj:createSpace() end,
	selectSpace = function() obj:selectSpace() end,
	labelSpace = function() obj:labelSpace() end,
	toggleSpaceLayout = function() obj:toggleSpaceLayout() end
}

function obj:bindHotkeys(mapping)
	if mapping then
		for k, v in pairs(mapping) do
			defaultHotKeysMapping[k] = v
		end
	end

	for k, v in pairs(defaultHotKeysMapping) do
		hs.hotkey.bind(v[1], v[2], hotKeyHandlers[k])
	end
end

local defaultConfig = {
	showSpaceMenuBarIcon = true,
	cleanEmptySpaces = true,
	showOnScreenStackIndicator = true,
	showStackIndicatorMenuBarIcon = true
}

function obj:configure(configuration)
	-- merge provided configuration keys if present
	if configuration then
		for key, value in pairs(configuration) do
			defaultConfig[key] = value
		end
	end
	print(hs.inspect(configuration))
	print(hs.inspect(defaultConfig))
end

function obj:start()
	if defaultConfig.showSpaceMenuBarIcon then
		self.spaceMenuBarIcon = SpaceMenuBaryIcon:new()
		self.spaceMenuBarIcon:init(self)
	end

	if defaultConfig.cleanEmptySpaces then
		self.spaceCleaner = SpaceCleaner:new()
		self.spaceCleaner:init(self)
	end

	if defaultConfig.showOnScreenStackIndicator then
		self.stackIndicator = StackIndicator:new()
		self.stackIndicator:init(self,
			defaultConfig.showOnScreenStackIndicator,
			defaultConfig.showStackIndicatorMenuBarIcon)
	end

	-- create our local ports for IPC from yabai
	self.localPortAppsChanged = hs.ipc.localPort("yabaiHammerSpoon:onApplicationsChanged", function()
		self.logger.df("Applications changed")
		self:onApplicationsChanged()
	end)
	self.localPortSpacesChanged = hs.ipc.localPort("yabaiHammerSpoon:onSpacesChanged", function()
		self.logger.df("Spaces changed")
		self:onSpacesChanged()
	end)
	self.localPortWindowsChanged = hs.ipc.localPort("yabaiHammerSpoon:onWindowsChanged", function()
		self.logger.df("Windows changed")
		self:onWindowsChanged()
	end)
	self.localPortDisplaysChanged = hs.ipc.localPort("yabaiHammerSpoon:onDisplaysChanged", function()
		self.logger.df("Displays changed")
		self:onDisplaysChanged()
	end)
end

function obj:stop()
end

function obj:onApplicationsChanged(event)
	for _, cb in ipairs(self.registry.onApplicationChanged) do
		cb(event)
	end
end

function obj:onSpacesChanged(event)
	for _, cb in ipairs(self.registry.onSpacesChanged) do
		cb(event)
	end
end

function obj:onWindowsChanged(event)
	for _, cb in ipairs(self.registry.onWindowsChanged) do
		cb(event)
	end
end

function obj:onDisplaysChanged(event)
	for _, cb in ipairs(self.registry.onDisplaysChanged) do
		cb(event)
	end
end

function obj:registerOnApplicationsChangedCB(func)
	table.insert(self.registry.onApplicationChanged, func)
end

function obj:registerOnSpacesChangedCB(func)
	table.insert(self.registry.onSpacesChanged, func)
end

function obj:registerOnWindowsChangedCB(func)
	table.insert(self.registry.onWindowsChanged, func)
end

function obj:registerOnDisplaysChangedCB(func)
	table.insert(self.registry.onDisplaysChanged, func)
end

-- Creates a chooser which invokes `cb` on a choice.
-- @param cb function: The callback to invoke on a choice which takes the
-- following arguments:
-- 										{choice}
--
-- The `choice` argument to the callback will have a .space member containing
-- the selected Yabai space.
--
-- If `choice` is nil, the user canceled the operation or no spaces exist.
function obj:spaceChooser(cb)
	local spaces = self.client:getSpaces()
	if not spaces then
		self.logger.ef("Failed to retrieve spaces")
		return
	end

	if #spaces == 0 then
		self.logger.df("No spaces found")
		return
	end

	local choices = {}
	for _, space in ipairs(spaces) do
		local text = space.index
		if space.label ~= "" then
			text = space.label
		end

		table.insert(choices, {
			text = text,
			subText = "",
			uuid = space.id,
			space = space
		})
	end

	local chooser = hs.chooser.new(function(choice)
		cb(choice)
	end)

	local rows = #choices
	if rows > 10 then
		rows = 10
	end

	chooser:rows(rows)
	chooser:choices(choices)
	chooser:show()
end

function obj:simpleTextPrompt(summary, details)
	local button, input = hs.dialog.textPrompt(summary, details, "", "OK", "Cancel")
	if (button == "Cancel") then
		return nil
	end
	return input
end

-- Promp the user with a TextPrompt for a label, create a new space, label it
-- and focus it.
function obj:createSpace()
	self.logger.d("Creating a new space")

	local label = self:simpleTextPrompt("Create a new space",
		"Provide a label for the space.\nAn empty label will use the next available desktop number.")

	if not label then return end

	self.client:createSpace(label, true)
	self.logger.df("Created new space with label: %s", label)
end

-- Prompt the user with a chooser to select a space to focus.
function obj:selectSpace()
	self.logger.d("Selecting a space")

	self:spaceChooser(function(choice)
		if not choice then
			self.logger.df("User canceled space selection")
			return
		end

		self.client:focusSpace(choice.space)
		self.logger.df("Focused space with label: %s", choice.text)
	end)
end

-- Prompt the user with a TextPrompt for a label, label the focused space.
-- Provide an empty labe to remove an existing one.
function obj:labelSpace()
	self.logger.d("Labeling a space")

	local button, label = hs.dialog.textPrompt("Label space",
		"Provide a label for this workspace.\nAn empty label will remove an existing label.",
		"", "OK", "Cancel")

	if (button == "Cancel") then
		return
	end

	local focusedSpace = self.client:getSpaces(true)
	if not focusedSpace then
		obj.logger.ef("Failed to retrieve focused space")
		return
	end

	self.client:labelSpace(focusedSpace, label)

	-- trigger space change event, Yabai does not trigger this on label change
	self:onSpacesChanged()

	self.logger.df("Labeled space with label: %s", label)
end

function obj:toggleSpaceLayout()
	self.logger.d("Toggling space layout")

	local focusedSpace = self.client:getSpaces(true)

	if focusedSpace['type'] == 'stack' then
		self.client:setSpaceLayout(focusedSpace, 'bsp')
	end

	if focusedSpace['type'] == 'bsp' then
		self.client:setSpaceLayout(focusedSpace, 'float')
	end

	if focusedSpace['type'] == 'float' then
		self.client:setSpaceLayout(focusedSpace, 'stack')
	end

	-- trigger events to update our components
	self:onSpacesChanged()
end

return obj
