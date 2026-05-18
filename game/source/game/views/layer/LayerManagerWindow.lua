package.loaded["source.game.utils.Shared"] = nil
local shared = require 'source.game.utils.Shared'

local buttons = assetManager.getImage("ui_actions_button")
local buttonQuads = love.graphics.getQuadsFromAtlas(buttons, 8, 1)
local lockImage = assetManager.getImage("ui_lock")
local lockQuads = love.graphics.getQuadsFromAtlas(lockImage, 2, 1)
local buttonSize = 50
local font = assetManager.getFont("pixel_font", 18)

local LevelDataUtils = require 'source.game.editor.LevelDataUtils'
local layerUtils = require 'source.game.editor.LayerUtils'
local layer = require 'source.game.editor.Layer'

local function addButton(new, grid, quadIdx, gridIdx, action)
    local btn = new("button")
    btn:SetText("")
    btn:SetSize(buttonSize, buttonSize)
    btn:SetHover(true)
    btn.OnClick = action
    btn.drawfunc = shared.buttonHitbox
    grid:AddItem(btn, 1, gridIdx, "left")

    local img = new("image")
    img:SetProperty("quad", buttonQuads[quadIdx])
    img:SetImage(buttons)
    img:SetScale(buttonSize / buttons:getHeight())
    img.drawfunc = shared.imgQuadSupport
    img:SetPos(btn:GetPos())
    img:SetOffsetY((buttons:getHeight() * 0.5) * 0.55)

    grid:AddItem(img, 1, gridIdx, "left")
end

return function(new)
    local frame = new("frame")
    frame:SetResizable(false)
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetHover(true)
    frame:SetSize(200, 250)
    frame:SetName("Layers")
    frame:SetAlwaysUpdate(true)
    frame.Update = function(this)
        this:SetVisible(EditorState.registers.isLevelLoaded)
    end
    frame:SetPos(shove.getViewportWidth() - (frame:GetWidth() + 10), shove.getViewportHeight() - (frame:GetHeight() + 10))

    local layerList = new("list")
    local offsetY = 90
    layerList:SetParent(frame)
    layerList:SetY(layerList:GetY() + offsetY)
    layerList:SetWidth(frame:GetWidth())
    layerList:SetHeight(frame:GetHeight() - offsetY)
    layerList:SetPadding(0)
    layerList:SetSpacing(5)
    layerList:SetHover(true)

    local grid = new("grid")
    grid:SetParent(frame)
    grid:SetY(grid:GetY() + 36)
    grid:SetColumns(4)
    grid:SetRows(1)
    grid:SetItemAutoSize(false)
    grid:SetCellPadding(0)
    grid:SetCellSize(buttonSize, buttonSize)
    grid.drawfunc = shared.blank

    -- Uso:
    local btns = {}

    local function createLayerItem(layerData, idx)
        local panel = new("panel")
        panel:SetHeight(50)

        local button = new("button")
        button:SetText("")
        button:SetSize(panel:GetSize())
        button:SetPos(5, 5)
        button:SetParent(panel)
        button:SetHover(true)
        button.drawfunc = shared.buttonHitbox
        button:SetProperty("active", idx == EditorState.currentLayer)
        button.drawfunc = shared.buttonSelectable
        button.OnClick = function()
            for i, btn in ipairs(btns) do
                btn:SetProperty("active", false)
            end
            EditorState.currentLayer = idx
            button:SetProperty("active", idx == EditorState.currentLayer)
        end
        table.insert(panel.children, button)
        table.insert(btns, button)

        local listGrid = new("grid")
        listGrid:SetColumns(10)
        listGrid:SetRows(3)
        listGrid:SetItemAutoSize(false)
        listGrid:SetCellPadding(0)
        listGrid:SetCellSize(panel:GetWidth() / listGrid:GetColumns(), panel:GetHeight() / listGrid:GetRows())
        listGrid:SetParent(panel)
        listGrid.drawfunc = shared.blank
        table.insert(panel.children, listGrid)

        local text = new("text")
        text:SetDefaultColor(1, 1, 1, 1)
        text:SetFont(font)
        text:SetText(string.format("[%s] %s", idx, layerData.name))
        text:SetParent(panel)
        table.insert(panel.children, text)
        listGrid:AddItem(text, 2, 2, "left")

        local lockButton = new("button")
        lockButton:SetText("")
        lockButton:SetSize(48, 48)
        lockButton:SetPos(5, 5)
        lockButton:SetParent(panel)
        lockButton:SetHover(true)
        lockButton.drawfunc = shared.buttonHitbox
        lockButton.OnClick = function(this)
            layerUtils.setLock(layerData, not layerData.locked)
        end
        listGrid:AddItem(lockButton, 2, listGrid:GetColumns() - 1, "center")

        local lockIcon = new("image")
        lockIcon:SetImage(lockImage)
        lockIcon:SetProperty("quad", lockQuads[layerData.locked and 1 or 2])
        lockIcon:SetAlwaysUpdate(true)
        lockIcon.drawfunc = shared.imgQuadSupport
        lockIcon:SetPos(130, 5)
        lockIcon:SetParent(panel)
        lockIcon:SetOffsetY(3)
        lockIcon:SetScale(48 / buttons:getHeight())
        lockIcon.Update = function(this)
            this:SetProperty("quad", lockQuads[layerData.locked and 1 or 2])
        end
        table.insert(panel.children, lockIcon)
        listGrid:AddItem(lockIcon, 2, listGrid:GetColumns() - 1, "center")

        -- Fix offset
        panel.Update = function(self, dt)
            if self.parent and self.parent.type == "list" then
                self.x = self.parent.x + self.staticx - (self.parent.offsetx or 0)
                self.y = self.parent.y + self.staticy - (self.parent.offsety or 0)
            end
        end

        layerList:AddItem(panel)
        return panel
    end

    if EditorState.registers.isLevelLoaded then
        for idx, ly in ipairs(EditorState.levelData.layers) do
            createLayerItem(ly, idx)
        end
    end


    addButton(new, grid, 5, 1, function() -- add

    end)

    addButton(new, grid, 6, 2, function() -- move UP

    end)

    addButton(new, grid, 7, 3, function() -- move DOWN

    end)

    addButton(new, grid, 8, 4, function() -- remove

    end)
end
