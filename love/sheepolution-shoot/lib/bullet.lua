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
end

function Bullet:draw()
	love.graphics.draw(self.image, self.x, self.y)
end
