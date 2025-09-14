local love = require("love") -- shut up LSP
local argparse = require("lib/argparse/argparse")
local uilib = require("ui")

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

local DEBUG = false

local ZOOM_SPEED = 0.1

local EVOLVE_EVERY = 0.05
local GENERATION = 0
local CELL_SIZE = 10
local POP_DENSITY = 0.2
local CELLS = {} -- 2D array of cells. 0=dead, other values are colors

local DELAY = 0

function love.load(args)
	print("FIXME fix wrong cell selection after zoom")
	print("FIXME support reading of patterns")
	print("FIXME stop zoom once map can be entirely seen")
	print("FIXME opt: update neighbours on the fly")

	-- won't fix, but add to doc
	print("FIXME border overwrites cells")
	print("FIXME for some canvas size and cell size combinations we need border")

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

	add_ui()
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

	ui:update(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(WIN_WIDTH / 2, WIN_HEIGHT / 2)
	love.graphics.scale(CAMERA.zoom, CAMERA.zoom)
	love.graphics.translate(-WIN_WIDTH / 2 - CAMERA.x, -WIN_HEIGHT / 2 - CAMERA.y)

	-- love.graphics.translate(-player.x + 400, -player.y + 300)
	for r, row in ipairs(CELLS) do
		for c, _col in ipairs(row) do
			local y = (r - 1) * CELL_SIZE
			local x = (c - 1) * CELL_SIZE
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

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	love.graphics.pop()
	love.graphics.print("Generation " .. GENERATION, 10, 10)

	ui:draw()
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
		local c = math.floor(x / CELL_SIZE)()
		local r = math.floor(y / CELL_SIZE)
		print("pressed on cell", r, c, "which has", #list_neighbours(r, c), "neighbours")
		if CELLS[r][c] == 0 then
			CELLS[r][c] = 3
		else
			CELLS[r][c] = 0
		end
	elseif button == 1 then
		local ui_button_pressed = false
		for _, uiButton in ipairs(ui.buttons) do
			if x > uiButton.x and x < uiButton.x + uiButton.width then
				if y > uiButton.y and y < uiButton.y + uiButton.height then
					-- brittle hack to go via text
					if uiButton.text == "<<" then
						EVOLVE_EVERY = EVOLVE_EVERY / 2
					else
						EVOLVE_EVERY = EVOLVE_EVERY * 2
					end
					-- here is the alternative but also as a hack here
					ui.buttons[2].text = EVOLVE_EVERY .. " [s]"
				end
			end
		end
		if not ui_button_pressed then
			PANNING.active = true
			PANNING.last_mouse_x, PANNING.last_mouse_y = x, y
		end
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		PANNING.active = false
	end
end

function add_ui()
	local ui_h = 30
	local ui_w = 150
	local ui_x = (WIN_WIDTH / 2) - (ui_w / 2)
	local ui_y = WIN_HEIGHT - ui_h
	local button_h = 30
	local button_w = 80
	ui = uilib:new(ui_x, ui_y, ui_w, ui_h)
	local x = ui_x
	local y = ui_y
	ui:addButton("<<", x, y, button_w, button_h)
	x = x + button_w
	ui:addButton(EVOLVE_EVERY .. " [s]", x, y, button_w, button_h)
	x = x + button_w
	ui:addButton(">>", x, y, button_w, button_h)
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
						table.insert(neighbours, cell)
					end
				end
			end
		end
	end
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
			if CELLS[i][j] ~= 0 then
				-- alive at the moment
				if #neighbours < 2 or #neighbours > 3 then
					NEW_CELLS[i][j] = 0
				end
			elseif #neighbours == 3 then
				-- newly alive
				local state = color_consensus(neighbours)
				NEW_CELLS[i][j] = state
			end
		end
	end
	CELLS = copy(NEW_CELLS)

	GENERATION = GENERATION + 1
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
