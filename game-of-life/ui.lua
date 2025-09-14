-- ui.lua
local UI = {}
UI.__index = UI

function UI:new(x, y, width, height)
	local instance = setmetatable({}, UI)
	instance.x = x
	instance.y = y
	instance.width = width
	instance.height = height
	instance.buttons = {}
	return instance
end

function UI:addButton(text, x, y, width, height)
	local button = {
		text = text,
		x = x,
		y = y,
		width = width,
		height = height,
		state = "normal",
	}
	table.insert(self.buttons, button)
end

function UI:update(dt)
	for _, button in ipairs(self.buttons) do
	end
end

function UI:draw()
	-- love.graphics.setColor(0.9, 0.9, 0.9)
	-- love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)

	-- Draw buttons
	for _, button in ipairs(self.buttons) do
		if button.state == "pressed" then
			love.graphics.setColor(0.8, 0.8, 0.8)
		else
			love.graphics.setColor(1, 1, 1)
		end
		love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 5, 5)
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf(button.text, button.x, button.y + button.height / 3, button.width, "center")
		-- love.graphics.print(button.text, button.x, button.y + button.height / 3)
	end
end

return UI
