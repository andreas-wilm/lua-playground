function love.load()
	--Create an object called circle
	circle = {}

	--Give it the properties x, y, radius and speed
	circle.x = 100
	circle.y = 100
	circle.radius = 25
	circle.speed = 100

	arrow = {}
	arrow.x = 200
	arrow.y = 200
	arrow.speed = 300
	arrow.angle = 0
	arrow.image = love.graphics.newImage("img/arrow_right.png")
end

function getDistance(x1, y1, x2, y2)
	-- pythagoras
	local horizontal_distance = x1 - x2
	local vertical_distance = y1 - y2
	--Both of these work
	local a = horizontal_distance * horizontal_distance
	local b = vertical_distance ^ 2

	local c = a + b
	local distance = math.sqrt(c)
	return distance
end

function love.draw()
	--Draw the circle
	love.graphics.circle("line", circle.x, circle.y, circle.radius)
	love.graphics.print("angle: " .. angle, 10, 10)

	love.graphics.line(circle.x, circle.y, mouse_x, mouse_y)
	love.graphics.line(circle.x, circle.y, mouse_x, circle.y)
	love.graphics.line(mouse_x, mouse_y, mouse_x, circle.y)

	local distance = getDistance(circle.x, circle.y, mouse_x, mouse_y)
	love.graphics.circle("line", circle.x, circle.y, distance)
end

function love.update(dt)
	--love.mouse.getPosition returns the x and y position of the cursor.
	mouse_x, mouse_y = love.mouse.getPosition()
	-- To move the circle towards the cursor, we need to know the angle. We can get the angle with the function math.atan2. The first argument is the y-position you want to go to, minus your object's y-position. The second argument is the same but for the x-position. This is one of the rare occasions where y comes before x.
	-- Basically what atan2 does is that it takes a vertical and horizontal vector (distance + direction), and with that information it returns an angle.
	-- angles in love.love2d are always measured in radians.
	angle = math.atan2(mouse_y - circle.y, mouse_x - circle.x)
	cos = math.cos(angle)
	sin = math.sin(angle)

	local distance = getDistance(circle.x, circle.y, mouse_x, mouse_y)

	if distance < 400 then
		circle.x = circle.x + circle.speed * cos * (distance / 100) * dt
		circle.y = circle.y + circle.speed * sin * (distance / 100) * dt
	end
end
