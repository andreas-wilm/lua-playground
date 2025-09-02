function love.mousepressed(x, y, button, istouch)
	print("x", x, "y", y)
end

function love.update() end

function love.load()
	tilemap = {
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
		{ 1, 2, 3, 4, 5, 5, 4, 3, 2, 1 },
		{ 1, 2, 2, 2, 2, 2, 2, 2, 2, 1 },
		{ 1, 1, 1, 1, 0, 1, 1, 1, 1, 1 },
	}
	colors = {
		--Fill it with tables filled with RGB numbers
		{ 1, 1, 1 },
		{ 1, 0, 0 },
		{ 1, 0, 1 },
		{ 0, 0, 1 },
		{ 0, 1, 1 },
	}
end

function love.draw()
	print("FIXME continue at images")
	for i, row in ipairs(tilemap) do
		for j, tile in ipairs(row) do
			if tile ~= 0 then
				--Set the color. .setColor() also accepts a table with 3 numbers.
				--We pass the table with as position the value of tile.
				--So if tile equals 3 then we pass colors[3] which is {1, 0, 1}
				love.graphics.setColor(colors[tile])
				--Draw the tile
				love.graphics.rectangle("fill", j * 25, i * 25, 25, 25)
			end --Draw the tile
		end
	end
end
