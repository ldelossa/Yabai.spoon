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
obj.registry = {
	onApplicationChanged = {},
	onSpacesChanged = {},
	onWindowsChanged = {},
	onDisplaysChanged = {}
}

local defaultHotKeysMapping = {
	createSpace = { { "alt", "shift" }, "n" },
	selectSpace = { { "alt" }, "w" },
	labelSpace = { { "alt" }, "r" }
}

local hotKeyHandlers = {
	createSpace = function() obj:createSpace() end,
	selectSpace = function() obj:selectSpace() end,
	labelSpace = function() obj:labelSpace() end
}

function obj:bindHotkeys(mapping)
	if mapping then
		-- merge into defaultHotKeysMapping, preferring the items in mapping
		for k, _ in pairs(defaultHotKeysMapping) do
			if mapping[k] then
				defaultHotKeysMapping[k] = mapping[k]
			end
		end
	end

	for k, v in pairs(defaultHotKeysMapping) do
		hs.hotkey.bind(v[1], v[2], hotKeyHandlers[k])
	end
end

local defaultConfig = {
	spaceMenuBarIcon = true
}

function obj:configure(configuration)
end

function obj:start()
	if defaultConfig.spaceMenuBarIcon then
		self.spaceMenuBarIcon = dofile(hs.spoons.resourcePath("spaceMenuBarIcon.lua"))
		self.spaceMenuBarIcon:init(self)
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

-- Prompt the user for a label via a TextPrompt and create a new workspace
-- labels it, and then focuses it.
function obj:createSpace()
	self.logger.d("Creating a new space")

	local button, label = hs.dialog.textPrompt("Create a new space",
		"Provide a label for the space",
		"", "OK", "Cancel")

	if (button == "Cancel") then
		return
	end

	self.client:createSpace(label, true)
	self.logger.df("Created new space with label: %s", label)
end

function obj:selectSpace()
	self.logger.d("Selecting a space")

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
			-- not part of chooser api, but you gotta love duck typing right.
			space = space
		})
	end

	local chooser = hs.chooser.new(function(choice)
		if not choice then return end
		self.client:focusSpace(choice.space)
	end)

	local rows = #choices
	if rows > 10 then
		rows = 10
	end

	chooser:rows(rows)
	chooser:choices(choices)
	chooser:show()
end

function obj:labelSpace()
	self.logger.d("Labeling a space")

	local button, label = hs.dialog.textPrompt("Label workspace",
		"Provide a label for this workspace",
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
	self.logger.df("Labeled space with label: %s", label)
end

return obj
