local OnScreenIndicator = {}
OnScreenIndicator.__index = OnScreenIndicator

local log = hs.logger.new("Indicator", 'debug')

local rectangle = {
	x = 0,
	y = 0,
	w = 40,
	h = 5
}

function OnScreenIndicator:new()
	local obj = {}
	setmetatable(obj, self)
	return obj
end

function OnScreenIndicator:init(client)
	self.client = client
	self.canvas = hs.canvas.new({})
	self.canvas:mouseCallback(function(_, _, id, x, y)
		OnScreenIndicator.OnElementClick(self, id, x, y)
	end)
end

local function rectangleElement(winID, xOffset)
	return {
		type = "rectangle",
		-- light grey fill color with some transparency
		fillColor = { red = 1.0, green = 1.0, blue = 1.0, alpha = 0.5 },
		frame = {
			x = xOffset,
			y = 0,
			w = rectangle.w,
			h = rectangle.h,
		},
		trackMouseDown = true,
		id = winID
	}
end

function OnScreenIndicator:SetIndicator(win, winsInStack)
	-- if there is only a single window in the stack
	-- we don't display ourselves
	if #winsInStack == 1 then
		self:Hide()
		return
	end

	-- set our canvas to the width of the window
	-- 8 and 6 are just padding values that look good.
	self.canvas:frame({
		x = win.frame.x - (rectangle.w - 8),
		y = win.frame.y - 6,
		h = 10,
		w = win.frame.w
	})

	while self.canvas:elementCount() > 0 do
		self.canvas:removeElement(1)
	end

	for i, stackWin in ipairs(winsInStack) do
		local xOffset = i * rectangle.w
		local element = rectangleElement(stackWin.id, xOffset)
		self.canvas:insertElement(element)
	end

	-- set element at window's stack-index fillColor
	self.canvas[win['stack-index']].fillColor = { red = 1.0, green = 1.0, blue = 1.0, alpha = 0.9 }

	self.canvas:show()
end

function OnScreenIndicator:Hide()
	self.canvas:hide()
end

function OnScreenIndicator:OnElementClick(id, x, y)
	log.d("OnElementClick", id, x, y)
	self.client:focusWindow({ id = id })
end

return OnScreenIndicator
