local love = require("love") -- shut up LSP
local argparse = require("lib/argparse/argparse")

local CAMERA = {
	x = 0,
	y = 0,
	zoom = 1.0,
}

local PANNING = {
	active = false,
	speed = 0.75,
	last_mouse_x = nil,
	last_mouse_y = nil,
}

-- color-bind palette from IBM design
local COLORS = {
	{ 1.00, 0.69, 0.00 },
	{ 1.00, 0.38, 0.00 },
	{ 0.86, 0.15, 0.50 },
	{ 0.47, 0.37, 0.94 },
	{ 0.39, 0.56, 1.00 },
}

local ZOOM_SPEED = 0.1
local DELAY = 0
local EVOLVE_EVERY = 0.05
local CELL_SIZE = 10
local DEBUG = false
local CELLS = {}
local GENERATION = 0
local POP_DENSITY = 0.2

function love.load(args)
	print("FIXME fix border glitches with padding")
	print("FIXME implement display of generations, time and number of cells")
	print("FIXME fix wrong cell selection after zoom")
	print("FIXME implement start, pause, time x")

	local parser = argparse("gol", "Game of live")
	parser:flag("-d --debug", "turn on debugging")
	parser:option("-f --freq", "frequency [s]", EVOLVE_EVERY):convert(tonumber)
	parser:option("-s --cellsize", "cell size", CELL_SIZE):convert(tonumber)
	parser:option("-p --density", "start population density", POP_DENSITY):convert(tonumber)
	local pargs = parser:parse(args)

	EVOLVE_EVERY = pargs.freq
	CELL_SIZE = pargs.cellsize
	DEBUG = pargs.debug
	POP_DENSITY = pargs.density

	WIN_WIDTH = love.graphics.getWidth()
	WIN_HEIGHT = love.graphics.getHeight()

	CANVAS_WIDTH = WIN_WIDTH * 3
	CANVAS_HEIGHT = WIN_HEIGHT * 3

	NROWS, row_padding = math.modf(CANVAS_HEIGHT / CELL_SIZE)
	NCOLS, col_padding = math.modf(CANVAS_WIDTH / CELL_SIZE)
	-- FIXME pad rows and cols and make padding local

	CAMERA.x = (CANVAS_WIDTH - WIN_WIDTH) / 2
	CAMERA.y = (CANVAS_HEIGHT - WIN_HEIGHT) / 2

	populate()
end

function love.update(dt)
	if PANNING.active then
		local x, y = love.mouse.getPosition()
		local dx, dy = x - PANNING.last_mouse_x, y - PANNING.last_mouse_y
		local world_dx = dx / (CAMERA.zoom * PANNING.speed)
		local world_dy = dy / (CAMERA.zoom * PANNING.speed)
		CAMERA.x = CAMERA.x - world_dx
		CAMERA.y = CAMERA.y - world_dy
		PANNING.last_mouse_x, PANNING.last_mouse_y = x, y
	end

	DELAY = DELAY + dt -- dt is in seconds
	if DELAY > EVOLVE_EVERY then
		evolve()
		DELAY = 0
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(WIN_WIDTH / 2, WIN_HEIGHT / 2)
	love.graphics.scale(CAMERA.zoom, CAMERA.zoom)
	love.graphics.translate(-WIN_WIDTH / 2 - CAMERA.x, -WIN_HEIGHT / 2 - CAMERA.y)

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

	love.graphics.setLineWidth(2)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	-- FIXME score, generations, time etc.
	love.graphics.pop()
	-- love.graphics.print(generations, 10, 10)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
	end
end

function love.wheelmoved(x, y)
	if y > 0 then -- scrolled up (zoom in)
		CAMERA.zoom = CAMERA.zoom + ZOOM_SPEED
	elseif y < 0 then -- scrolled down (zoom out)
		CAMERA.zoom = CAMERA.zoom - ZOOM_SPEED
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if button == 2 then
		print("FIXME doesn't account for translation. compute correct world coords")
		local c = math.floor(x / CELL_SIZE)
		local r = math.floor(y / CELL_SIZE)
		print("pressed on cell", r, c, "which has", #list_neighbours(r, c), "neighbours")
		if CELLS[r][c] == 0 then
			CELLS[r][c] = 3
		else
			CELLS[r][c] = 0
		end
	elseif button == 1 then
		PANNING.active = true
		PANNING.last_mouse_x, PANNING.last_mouse_y = x, y
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		PANNING.active = false
	end
end

function populate()
	math.randomseed(os.time())
	for i = 1, NROWS do
		CELLS[i] = {}
		for j = 1, NCOLS do
			local state = 0
			if math.random() < POP_DENSITY then
				state = math.random(#COLORS)
			end
			CELLS[i][j] = state
		end
	end
	if DEBUG then
		print_cells()
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

function color_consensus(neighbours)
	local freq = {}
	local max_count = 0
	local max_col = 0
	for _, col in pairs(neighbours) do
		freq[col] = (freq[col] or 0) + 1
		if freq[col] > max_count then
			max_count = freq[col]
			max_col = col
		end
	end
	-- returning first/random color on tie
	return max_col
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
			if CELLS[i][j] ~= 0 then -- alive
				if #neighbours < 2 or #neighbours > 3 then
					NEW_CELLS[i][j] = 0
				end
			elseif #neighbours == 3 then
				local state = color_consensus(neighbours)
				NEW_CELLS[i][j] = state
			end
		end
	end
	CELLS = copy(NEW_CELLS)
	GENERATION = GENERATION + 1

	if GENERATION % 100 == 0 then
		print("Generation", GENERATION)
	end
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
