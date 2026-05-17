EditorState = {}

local autoTile = require 'source.game.utils.Autotile'
local newTilesetData = require 'source.game.utils.TilesetData'
local LevelDataUtils = require 'source.game.editor.LevelDataUtils'
local layerUtils = require 'source.game.editor.LayerUtils'
local layer = require 'source.game.editor.Layer'

EditorState.GRID_SIZE = 96

local editorGrid = require 'source.game.editor.LevelGrid'

---Used to fill a area of a grid
---@param grid table<table<number>>
---@param startX number
---@param startY number
---@param targetValue number
---@param replaceValue number
local function floodFill(grid, startX, startY, targetValue, replaceValue)
    -- Check if the starting point is already the replacement color
    if targetValue == replaceValue then return end

    -- Queue to store the points to be processed
    local queue = {}

    -- Add the starting point to the queue
    table.insert(queue, { x = startX, y = startY })

    -- Process each point in the queue
    while #queue > 0 do
        -- Get the current point from the queue
        local point = table.remove(queue, 1)
        local x, y = point.x, point.y

        -- Make sure the point is within bounds and has the target color
        if x >= 1 and x <= #grid[1] and y >= 1 and y <= #grid and grid[y][x] == targetValue then
            -- Fill the current point with the replacement color
            grid[y][x] = replaceValue

            -- Add the neighboring points to the queue (left, right, up, down)
            table.insert(queue, { x = x - 1, y = y }) -- left
            table.insert(queue, { x = x + 1, y = y }) -- right
            table.insert(queue, { x = x, y = y - 1 }) -- up
            table.insert(queue, { x = x, y = y + 1 }) -- down
        end
    end
    table.clear(queue)
end

function EditorState:updateBatches(currentSelectedLayer)
    for key, tileset in pairs(self.tilesetBatches) do
        tileset.batch:clear()
    end

    if currentSelectedLayer.type == "tiles" then
        for y = 1, currentSelectedLayer.h, 1 do
            for x = 1, currentSelectedLayer.w, 1 do
                local currentTile = currentSelectedLayer.data[y][x]
                if currentTile then
                    local tx, ty = x * EditorState.GRID_SIZE - EditorState.GRID_SIZE, y * EditorState.GRID_SIZE - EditorState.GRID_SIZE
                    local ct = autoTile.getFrame(currentSelectedLayer, x, y)

                    for key, sprbatch in spairs(self.tilesetBatches) do
                        if sprbatch.config.useQuads then
                            sprbatch.batch:add(self.tileBorder.quads[ct + 1], tx, ty, sprbatch.config.rotation, sprbatch.config.scaleX, sprbatch.config.scaleY)
                        else
                            sprbatch.batch:add(tx, ty, sprbatch.config.rotation, sprbatch.config.scaleX, sprbatch.config.scaleY)
                        end
                    end
                end
            end
        end
    end
end

function EditorState:enter()
    local img = assetManager.getImage("tiles_border")
    local imgBack = assetManager.getImage("tiles_border_shadow")

    self.tileBorder = {
        img = img,
        quads = love.graphics.getQuadsFromAtlas(img, 12, 4)
    }
    self.tileBorderGlow = {
        img = imgBack,
        quads = love.graphics.getQuadsFromAtlas(imgBack, 12, 4)
    }
    self.bgSprite = assetManager.getImage("tile_bg")

    self.registers = {
        UIState = {
            showCreateLevelWindow = false,
            showCreateLayerWindow = false
        },
        isLevelLoaded = false,
        isUIShowing = false,
        canPlace = true,
        useSnapToGrid = true,
        updateObjectBehaviour = true,
        drawObjectPath = true,
    }

    self.editorCam = camera()
    self.editorCam.speed = 5
    self.editorCam.scrollZoom = 1
    self.editorCam.targetZoom = 1
    self.mouseX, self.mouseY = 0, 0
    self.mouseUse = true
    self.tileX, self.tileY = 0, 0

    self.currentLayer = 1

    self.toolState = {
        fillmode = false,
        isAddingTile = false,
        isObjectMode = false,
    }

    -- store all the spritebatches --
    self.tilesetBatches = {}
    self.tilesetBatches["glow"] = newTilesetData(love.graphics.newSpriteBatch(self.tileBorder.img), {
        blendMode = "add",
        useQuads = true,
    })
    self.tilesetBatches["block"] = newTilesetData(love.graphics.newSpriteBatch(self.bgSprite), {
        scaleX = 96 / self.bgSprite:getWidth(),
        scaleY = 96 / self.bgSprite:getHeight()
    })
    self.tilesetBatches["shadow"] = newTilesetData(love.graphics.newSpriteBatch(self.tileBorderGlow.img), {
        useQuads = true
    })

    self.levelData = LevelDataUtils.newLevelData()

    self.selectionArea = {
        visible = false,
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        normalizedW = 0,
        normalizedH = 0
    }


    editorGrid.newGrid(
        self.levelData.properties.width,
        self.levelData.properties.height,
        EditorState.GRID_SIZE
    )
    -- default layers --
    LevelDataUtils.addLayer(self.levelData, layer.new("tiles", "blocks", self.levelData.properties.width, self.levelData.properties.height))
    LevelDataUtils.addLayer(self.levelData, layer.new("objects", "objects"))

    loveframes.SetActiveSkin("Dark crimson")

    -- load all views --
    loveView.unloadView()
    loveView.registerLoveframesEvents()

    local base = "source/game/views"
    local views = fsutil.scanFolder(base)

    for idx, path in ipairs(views) do
        loveView.addView(path)
    end
end

function EditorState:draw()
    self.editorCam:attach(0, 0, shove.getViewportWidth(), shove.getViewportHeight(), true)

    -- grid rendering --
    love.graphics.setBlendMode("replace")
    editorGrid.draw()
    love.graphics.setBlendMode("alpha")

    for key, sprbatch in spairs(self.tilesetBatches) do
        love.graphics.setBlendMode(sprbatch.config.blendMode)
        love.graphics.draw(sprbatch.batch)
        love.graphics.setBlendMode("alpha")
    end


    -- rendering objects --
    for idx, layerData in ipairs(self.levelData.layers) do
        if layerData.type == "objects" then
            for _, object in ipairs(layerData.data) do
                if object.draw then
                    object:draw()
                end
            end
        end
    end


    -- cursor --
    if self.mouseUse and not self.selectionArea.visible then
        love.graphics.setLineWidth(5)
        local toolTypeColor = {
            ["pencil"] = { 0, 1, 0 },
            ["fill"] = { 242 / 255, 167 / 255, 36 / 255 },
            ["eraser"] = { 1, 0, 0 },
        }

        love.graphics.setColor(toolTypeColor[self.toolState.isAddingTile and "pencil" or "eraser"])
        love.graphics.rectangle("line", self.mouseX, self.mouseY, EditorState.GRID_SIZE, EditorState.GRID_SIZE)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
    end

    -- map bounds --
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", 0, 0, self.levelData.properties.width * EditorState.GRID_SIZE, self.levelData.properties.height * EditorState.GRID_SIZE)
    love.graphics.setLineWidth(1)
    love.graphics.setBlendMode("alpha")

    self.editorCam:detach()

    loveView.draw()
end

function EditorState:update(elapsed)
    local inside, vx, vy = shove.mouseToViewport()

    -- mouse updates --
    local mx, my = self.editorCam:worldCoords(vx, vy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())
    self.mouseX = self.registers.useSnapToGrid and (math.floor(mx / EditorState.GRID_SIZE) * EditorState.GRID_SIZE) or mx
    self.mouseY = self.registers.useSnapToGrid and (math.floor(my / EditorState.GRID_SIZE) * EditorState.GRID_SIZE) or my

    loveView.update(elapsed)
    self.registers.canPlace = not loveframes.GetHover()

    -- zoom smooth --
    self.editorCam.scrollZoom = self.editorCam.scrollZoom - (self.editorCam.scrollZoom - self.editorCam.targetZoom) * 0.05
    self.editorCam.scale = self.editorCam.scrollZoom

    self.mouseUse = self.mouseX >= 0
        and self.mouseX <= self.levelData.properties.width * EditorState.GRID_SIZE
        and self.mouseY >= 0
        and self.mouseY <= self.levelData.properties.height * EditorState.GRID_SIZE
        and self.registers.canPlace
        and self.registers.isLevelLoaded

    -- updateing objects behaviours --
    for idx, layerData in ipairs(self.levelData.layers) do
        if layerData.type == "objects" and self.registers.updateObjectBehaviour then
            for _, object in ipairs(layerData.data) do
                if object.update then
                    object:update(elapsed)
                end
            end
        end
    end

    -- block place --
    local currentSelectedLayer = self.levelData.layers[self.currentLayer]
    local cx, cy = math.floor(mx / EditorState.GRID_SIZE) + 1, math.floor(my / EditorState.GRID_SIZE) + 1

    if not self.toolState.fillmode and currentSelectedLayer.type == "tiles" then
        if love.mouse.isDown(1) and self.mouseUse and not currentSelectedLayer.locked then
            if layerUtils.inBounds(currentSelectedLayer, cx, cy) then
                currentSelectedLayer.data[cy][cx] = true
            end

            self:updateBatches(currentSelectedLayer)
            self.toolState.isAddingTile = true
        elseif love.mouse.isDown(2) and self.mouseUse and not currentSelectedLayer.locked then
            if layerUtils.inBounds(currentSelectedLayer, cx, cy) then
                currentSelectedLayer.data[cy][cx] = false
            end

            self:updateBatches(currentSelectedLayer)
        end
    end

    -- zoom clamp --
    if self.editorCam.targetZoom < 0.15 then
        self.editorCam.targetZoom = 0.15
    end
    if self.editorCam.targetZoom > 3.5 then
        self.editorCam.targetZoom = 3.5
    end
end

function EditorState:mousepressed(x, y, button)
    local inside, vx, vy = shove.mouseToViewport()

    local mx, my = self.editorCam:worldCoords(vx, vy, 0, 0, shove.getViewportWidth(), shove.getViewportHeight())

    local currentSelectedLayer = self.levelData.layers[self.currentLayer]
    local cx, cy = math.floor(mx / EditorState.GRID_SIZE) + 1, math.floor(my / EditorState.GRID_SIZE) + 1

    if self.toolState.fillmode and self.mouseUse and currentSelectedLayer.type == "tiles" and not currentSelectedLayer.locked then
        local modes = {
            [1] = function()
                floodFill(currentSelectedLayer.data, cx, cy, false, true)
            end,
            [2] = function()
                floodFill(currentSelectedLayer.data, cx, cy, true, false)
            end
        }

        if modes[button] then
            modes[button]()
        end
        self:updateBatches(currentSelectedLayer)
    end
end

function EditorState:wheelmoved(x, y)
    if y < 0 then
        self.editorCam.targetZoom = self.editorCam.targetZoom - 0.05
    end
    if y > 0 then
        self.editorCam.targetZoom = self.editorCam.targetZoom + 0.05
    end
end

function EditorState:mousemoved(x, y, dx, dy)
    -- mouse scroll --
    if love.mouse.isDown(3) then
        self.editorCam.x = self.editorCam.x - dx / self.editorCam.scale
        self.editorCam.y = self.editorCam.y - dy / self.editorCam.scale
    end
end

function EditorState:leave()
    loveView.unloadView()
end

return EditorState
