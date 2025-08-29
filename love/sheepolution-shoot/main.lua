function love.load()
	Object = require("lib/classic")
	require("lib/enemy")
	require("lib/player")
	require("lib/bullet")

	player = Player()
	enemy = Enemy()
	listOfBullets = {}
end

function love.update(dt)
	player:update(dt)
	enemy:update(dt)

	for i, v in ipairs(listOfBullets) do
		v:update(dt)
	end
end

function love.draw()
	player:draw()
	enemy:draw()

	for i, v in ipairs(listOfBullets) do
		v:draw()
	end
end

function love.keypressed(key)
	player:keyPressed(key)
end
