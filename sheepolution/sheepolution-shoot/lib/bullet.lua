Bullet = Object:extend()

--We pass the x and y of the player.
function Bullet:new(x, y)
	self.image = love.graphics.newImage("img/bullet.png")
	self.x = x
	self.y = y
	self.speed = 700
	--We'll need these for collision checking
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
end

function Bullet:update(dt)
	self.y = self.y + self.speed * dt

	if self.y > love.graphics.getHeight() then
		--Restart the game if we didn't hit
		print("You lost")
		love.load()
	end
end

function Bullet:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

function Bullet:checkCollision(obj)
	local self_left = self.x
	local self_right = self.x + self.width
	local self_top = self.y
	local self_bottom = self.y + self.height

	local obj_left = obj.x
	local obj_right = obj.x + obj.width
	local obj_top = obj.y
	local obj_bottom = obj.y + obj.height

	if self_right > obj_left and self_left < obj_right and self_bottom > obj_top and self_top < obj_bottom then
		self.dead = true
		--Increase enemy speed
		incr = 50
		if obj.speed < 0 then
			obj.speed = obj.speed - incr
		else
			obj.speed = obj.speed + incr
		end
		print("obj speed now", obj.speed)
	end
end
