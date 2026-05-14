package.loaded["source.game.utils.Shared"] = nil
local shared = require("source.game.utils.Shared")

local font = assetManager.getFont("pixel_font", 18)
local buttons = assetManager.getImage("ui_actions_button")
local buttonQuads = love.graphics.getQuadsFromAtlas(buttons, 4, 1)

local function newButtonData(spriteIdx, pushable, action)
    return {
        quadIdx = spriteIdx,
        pushable = pushable,
        action = action
    }
end

return function(new)
    local buttonSize = 64
    local buttonCount = #buttonQuads

    local frame = new("panel")
    frame:SetY(24)
    frame:SetHeight(buttonSize)
    frame:SetWidth(buttonSize * buttonCount)
    frame:CenterX()
    frame.OnMouseEnter = function(obj)
        EditorState.registers.canPlace = false
    end
    frame.OnMouseExit = function(obj)
        EditorState.registers.canPlace = true
    end
    frame:SetHover(true)

    local buttonList = {}

    local buttonData = {
        newButtonData(1, false, function(state)
            -- config --
        end),
        newButtonData(2, true, function(state)
            -- fill mode --
            EditorState.toolState.fillmode = not EditorState.toolState.fillmode
        end),
        newButtonData(3, false, function(state)
            -- undo --
        end),
        newButtonData(4, false, function(state)
            -- redo --
        end)
    }

    local grid = new("grid")
    grid:SetParent(frame)
    grid:SetColumns(buttonCount)
    grid:SetRows(1)
    grid:SetCellPadding(0)
    grid:SetItemAutoSize(false)
    grid:SetCellSize(buttonSize, buttonSize)
    grid:SetHover(true)
    grid.drawfunc = shared.blank

    --[[grid.OnMouseEnter = function(obj)
        EditorState.registers.canPlace = true
    end
    grid.OnMouseExit = function(obj)
        EditorState.registers.canPlace = false
    end]]


    for idx, btndata in ipairs(buttonData) do
        local btn = new("button")
        btn:SetSize(buttonSize, buttonSize)
        btn:SetHover(true)
        btn:SetText("")
        if btndata.pushable then
            btn:SetProperty("active", false)
        end
        btn.drawfunc = btndata.pushable and shared.buttonSelectable or shared.buttonHitbox
        btn.OnClick = function()
            if btndata.pushable then
                btn:SetProperty("active", not btn:GetProperty("active"))
                btndata.action(btn:GetProperty("active"))
            end
        end

        grid:AddItem(btn, 1, idx, "center")

        local img = new("image")
        img:SetProperty("quad", buttonQuads[idx])
        img:SetImage(buttons)
        img:SetScale(buttonSize / buttons:getHeight())
        img.drawfunc = shared.imgQuadSupport
        img:SetPos(btn:GetPos())
        img:SetOffsetY((buttons:getHeight() * 0.5) * 0.55)
        grid:AddItem(img, 1, idx, "left")
        local imgX, imgY = img:GetPos()
        --btn:
        table.insert(buttonList, btn)
    end
end
