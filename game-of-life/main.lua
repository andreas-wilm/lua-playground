love = require("love") -- shut up LSP

function love.load()
	DELAY = 0
	EVOLVE_EVERY = 0.05 -- in secs
	CELL_SIZE = 10
	DEBUG = false

	print("FIXME color consensus")
	print("FIXME fix wrong cell selection after zoom")
	print("FIXME implement movement in canvas")
	print("FIXME implement mouse dragging of canvas")
	print("FIXME implement change of time")
	print("FIXME implement display of generations, time and number of cells")

	WIN_WIDTH = love.graphics.getWidth()
	WIN_HEIGHT = love.graphics.getHeight()
	print("WIN_WIDTH", WIN_WIDTH)
	print("WIN_HEIGHT", WIN_HEIGHT)

	CANVAS_WIDTH = WIN_WIDTH * 2
	CANVAS_HEIGHT = WIN_HEIGHT
	print("CANVAS_WIDTH", CANVAS_WIDTH)
	print("CANVAS_HEIGHT", CANVAS_HEIGHT)

	-- color-bind palette from IBM design
	COLORS = {
		{ 1.00, 0.69, 0.00 },
		{ 1.00, 0.38, 0.00 },
		{ 0.86, 0.15, 0.50 },
		{ 0.47, 0.37, 0.94 },
		{ 0.39, 0.56, 1.00 },
	}

	NROWS, row_padding = math.modf(CANVAS_HEIGHT / CELL_SIZE)
	NCOLS, col_padding = math.modf(CANVAS_WIDTH / CELL_SIZE)
	print("NROWS", NROWS)
	print("NCOLS", NCOLS)
	-- FIXME pad rows and cols and make padding local

	local pop_rate = 0.25
	CELLS = {}
	for i = 1, NROWS do
		CELLS[i] = {}
		for j = 1, NCOLS do
			local state = 0
			if math.random() < pop_rate then
				state = math.random(#COLORS)
			end
			CELLS[i][j] = state
		end
	end
	print_cells()
	CELLS_ORIG = copy(CELLS)

	CAMERA = { -- FIXME
		x = math.floor(WIN_WIDTH / 2), -- FIXME unused
		y = math.floor(WIN_HEIGHT / 2), -- FIXME unused
		zoom = 1,
	}
end

function love.update(dt)
	DELAY = DELAY + dt -- dt is in seconds
	if DELAY > EVOLVE_EVERY then
		print("Evolving...")
		evolve()
		DELAY = 0
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(WIN_WIDTH / 2, WIN_HEIGHT / 2)
	love.graphics.scale(CAMERA.zoom, CAMERA.zoom)
	love.graphics.translate(-WIN_WIDTH / 2, -WIN_HEIGHT / 2)

	-- love.graphics.translate(-player.x + 400, -player.y + 300)
	for r, row in ipairs(CELLS) do
		for c, _col in ipairs(row) do
			local y = r * CELL_SIZE
			local x = c * CELL_SIZE
			local color = { 0, 0, 0 }
			if CELLS[r][c] ~= 0 then
				color = COLORS[CELLS[r][c]]
			end
			love.graphics.setColor(color)
			love.graphics.rectangle("fill", x, y, CELL_SIZE, CELL_SIZE)
			if DEBUG then
				love.graphics.setColor({ 1, 1, 1 })
				love.graphics.rectangle("line", x, y, CELL_SIZE, CELL_SIZE)
				love.graphics.print(r .. ":" .. c, x, y)
			end
		end
	end
	-- FIXME score, generations, time etc.
	love.graphics.pop()
	-- love.graphics.print(generations, 10, 10)
end

function love.keypressed(key)
	-- FIXME arrows move camera
	if key == "q" then
		love.event.quit()
	end
end

function love.wheelmoved(x, y)
	local zoomSpeed = 0.1 -- Adjust this value for faster/slower zooming
	if y > 0 then -- Scrolled up (zoom in)
		CAMERA.zoom = CAMERA.zoom + zoomSpeed
	elseif y < 0 then -- Scrolled down (zoom out)
		CAMERA.zoom = CAMERA.zoom - zoomSpeed
		if CAMERA.zoom < 0.1 then -- Prevent zooming too far out
			CAMERA.zoom = 0.1
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	print("FIXME doesn't account for translation")
	if button == 1 then
		local c = math.floor(x / CELL_SIZE)
		local r = math.floor(y / CELL_SIZE)
		print("pressed on cell", r, c, "which has", #list_neighbours(r, c), "neighbours")
		if CELLS[r][c] == 0 then
			CELLS[r][c] = 3
		else
			CELLS[r][c] = 0
		end
		-- print_cells()
		-- print()
	end
end

function list_neighbours(r, c)
	local neighbours = {}
	for ro = r - 1, r + 1 do
		for co = c + -1, c + 1 do
			if ro ~= r or co ~= c then
				if CELLS[ro] ~= nil then
					local cell = CELLS[ro][co]
					if cell ~= nil and cell ~= 0 then
						-- print("Inserting", ro, co, "as neighbour of", r, c)
						table.insert(neighbours, cell)
					end
				end
			end
		end
	end
	-- print(#neighbours, "neighbours for", r, c)
	return neighbours
end

function evolve()
	--[[ https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
            Any live cell with fewer than two live neighbours dies, as if by underpopulation.
            Any live cell with two or three live neighbours lives on to the next generation.
            Any live cell with more than three live neighbours dies, as if by overpopulation.
            Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction 
        ]]
	NEW_CELLS = copy(CELLS)
	for i, row in ipairs(CELLS) do
		for j, _col in ipairs(row) do
			local neighbours = list_neighbours(i, j)
			-- FIXME get consensus color
			if CELLS[i][j] ~= 0 then -- alive
				if #neighbours < 2 or #neighbours > 3 then
					NEW_CELLS[i][j] = 0
				end
			elseif #neighbours == 3 then
				-- FIXME majority color from neighbours
				local state = math.random(#COLORS)
				NEW_CELLS[i][j] = state
				-- print("now alive", i, j)
			end
		end
	end
	CELLS = copy(NEW_CELLS)
end

function print_cells()
	for i, row in ipairs(CELLS) do
		local row_str = ""
		for j, _col in ipairs(row) do
			row_str = row_str .. CELLS[i][j]
		end
		print(row_str)
	end
end

function copy(obj, seen) -- somewhere from Stackoverflow
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do
		res[copy(k, s)] = copy(v, s)
	end
	return res
end
