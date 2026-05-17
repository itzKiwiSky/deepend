package.loaded["source.game.utils.Shared"] = nil
local shared = require("source.game.utils.Shared")

local buttons = assetManager.getImage("ui_actions_button")
local buttonQuads = love.graphics.getQuadsFromAtlas(buttons, 8, 1)
local buttonSize = 50

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
        --this:SetVisible(EditorState.registers.isLevelLoaded)
    end
    frame:SetPos(shove.getViewportWidth() - (frame:GetWidth() + 10), shove.getViewportHeight() - (frame:GetHeight() + 10))

    local layerList = new("list")
    local offsetY = 90
    layerList:SetParent(frame)
    layerList:SetY(layerList:GetY() + offsetY)
    layerList:SetWidth(frame:GetWidth())
    layerList:SetHeight(frame:GetHeight() - offsetY)
    layerList:SetPadding(5)
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


    addButton(new, grid, 5, 1, function()

    end)

    addButton(new, grid, 6, 2, function()

    end)

    addButton(new, grid, 7, 3, function()

    end)

    addButton(new, grid, 8, 4, function()

    end)
end
