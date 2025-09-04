function love.mousepressed(x, y, button, istouch)
	print("x", x, "y", y)
end

function love.update() end

function love.load()
	image = love.graphics.newImage("img/tileset.png")
	local image_width = image:getWidth()
	local image_height = image:getHeight()

	--The width and height of each tile is 32, 32
	--So we could do:
	-- width = 32
	-- height = 32
	--But let's say we don't know the width and height of a tile
	--We can also use the number of rows and columns in the tileset
	--Our tileset has 2 rows and 3 columns
	--But we need to subtract 2 to make up for the empty pixels we included to prevent bleeding
	width = (image_width / 3) - 2
	height = (image_height / 2) - 2

	--Create the quads
	quads = {}

	for i = 0, 1 do
		for j = 0, 2 do
			table.insert(
				quads,
				love.graphics.newQuad(
					1 + j * (width + 2),
					1 + i * (height + 2),
					width,
					height,
					image_width,
					image_height
				)
			)
		end
	end

	tilemap = {
		{ 1, 6, 6, 2, 1, 6, 6, 2 },
		{ 3, 0, 0, 4, 5, 0, 0, 3 },
		{ 3, 0, 0, 0, 0, 0, 0, 3 },
		{ 4, 2, 0, 0, 0, 0, 1, 5 },
		{ 1, 5, 0, 0, 0, 0, 4, 2 },
		{ 3, 0, 0, 0, 0, 0, 0, 3 },
		{ 3, 0, 0, 1, 2, 0, 0, 3 },
		{ 4, 6, 6, 5, 4, 6, 6, 5 },
	}
	player = {
		image = love.graphics.newImage("img/player.png"),
		tile_x = 2, -- position
		tile_y = 2,
	}

	local masterVolume = 0.9
	local sfxVolume = 1
	local musicVolume = 0.1

	song = love.audio.newSource("audio/song.ogg", "stream")
	song:setVolume(masterVolume * musicVolume)
	song:setLooping(true)
	song:play()

	sfx = love.audio.newSource("audio/sfx.ogg", "static")
	sfx:setVolume(masterVolume * sfxVolume)
end

function print_tilemap()
	for i, row in ipairs(tilemap) do
		row_str = ""
		for j, tile in ipairs(row) do
			row_str = row_str .. tilemap[i][j]
		end
		print(row_str)
	end
end

function love.keypressed(key)
	local x = player.tile_x
	local y = player.tile_y

	if key == "space" then
		-- create holes in sorrounding tiles
		print("tilemap before mod")
		sfx:play()
		print_tilemap()
		for x_offset = -1, 1 do
			for y_offset = -1, 1 do
				if x_offset ~= 0 or y_offset ~= 0 then
					-- print("x", x, "x_offset", x_offset)
					-- print("y", y, "y_offset", y_offset)
					tilemap[y + y_offset][x + x_offset] = 0
				end
			end
		end
		print("tilemap after mod")
		print_tilemap()
		print()
	end

	if key == "left" then
		x = x - 1
	elseif key == "right" then
		x = x + 1
	elseif key == "up" then
		y = y - 1
	elseif key == "down" then
		y = y + 1
	end

	if isEmpty(x, y) then
		player.tile_x = x
		player.tile_y = y
	end
end

function isEmpty(x, y)
	return tilemap[y][x] == 0
end

function love.draw()
	for i, row in ipairs(tilemap) do
		for j, tile in ipairs(row) do
			if tile ~= 0 then
				--Draw the image with the correct quad
				love.graphics.draw(image, quads[tile], j * width, i * height)
			end
		end
	end
	love.graphics.draw(player.image, player.tile_x * width, player.tile_y * height)
end
