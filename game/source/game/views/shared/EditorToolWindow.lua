package.loaded["source.game.utils.Shared"] = nil
local shared = require 'source.game.utils.Shared'

local font = assetManager.getFont("pixel_font", 18)
local buttons = assetManager.getImage("ui_actions_button")
local buttonQuads = love.graphics.getQuadsFromAtlas(buttons, SharedConstants.iconQuadsCount, 1)

local function newButtonData(spriteIdx, pushable, action)
    return {
        quadIdx = spriteIdx,
        pushable = pushable,
        action = action
    }
end

return function(new)
    local buttonSize = 64
    local buttonCount = 4

    local frame = new("panel")
    frame:SetY(24)
    frame:SetHeight(buttonSize)
    frame:SetWidth(buttonSize * buttonCount)
    frame:CenterX()
    frame:SetAlwaysUpdate(true)
    frame.OnMouseEnter = function(obj)
        EditorState.registers.canPlace = false
    end
    frame.OnMouseExit = function(obj)
        EditorState.registers.canPlace = true
    end
    frame:SetHover(true)
    frame.Update = function(this)
        this:SetVisible(EditorState.registers.isLevelLoaded)
    end

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

    for idx, btndata in ipairs(buttonData) do
        local btn = new("button")
        btn:SetSize(buttonSize, buttonSize)
        btn:SetHover(true)
        btn:SetText("")

        if btndata.pushable then
            btn:SetProperty("active", false)
        end

        btn.drawfunc = btndata.pushable
            and shared.buttonSelectable
            or shared.buttonHitbox

        btn.OnClick = function()
            if not EditorState.registers.isLevelLoaded then return end

            if btndata.pushable then
                btn:SetProperty("active", not btn:GetProperty("active"))
                btndata.action(btn:GetProperty("active"))
            else
                btndata.action()
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

        table.insert(buttonList, btn)
    end
end
