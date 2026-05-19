package.loaded["source.game.utils.Shared"] = nil
local shared = require 'source.game.utils.Shared'

local font = assetManager.getFont("pixel_font", 17)

return function(new)
    local frame = new("frame")
    frame:SetName("Objects")
    frame:SetResizable(false)
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetHover(true)
    frame:SetSize(250, 350)
    frame.Update = function(this)
        this:SetVisible(EditorState.registers.isLevelLoaded)
    end
    frame:SetPos(0, 28)

    local layerList = new("list")
    local offsetY = 28
    layerList:SetParent(frame)
    layerList:SetY(layerList:GetY() + offsetY)
    layerList:SetWidth(frame:GetWidth())
    layerList:SetHeight(frame:GetHeight() - offsetY)
    layerList:SetPadding(0)
    layerList:SetSpacing(5)
    layerList:SetHover(true)

    --local grid = new("grid")
    --grid:SetParent(frame)
    --grid:SetY(grid:GetY() + 36)
    --grid:SetColumns(4)
    --grid:SetRows(1)
    --grid:SetItemAutoSize(false)
    --grid:SetCellPadding(0)
    --grid:SetCellSize(buttonSize, buttonSize)
    --grid.drawfunc = shared.blank

    local btns = {}

    local function createLayerItem(layerData, idx)
        local panel = new("panel")
        panel:SetHeight(64)

        local clickHitbox = new("button")
        clickHitbox:SetText("")
        clickHitbox:SetSize(panel:GetSize())
        clickHitbox:SetPos(5, 5)
        clickHitbox:SetParent(panel)
        clickHitbox:SetHover(true)
        clickHitbox.drawfunc = shared.buttonHitbox
        clickHitbox:SetProperty("active", idx == EditorState.currentLayer)
        clickHitbox.drawfunc = shared.buttonSelectable
        clickHitbox.OnClick = function()
            for i, btn in ipairs(btns) do
                btn:SetProperty("active", false)
            end
            EditorState.currentLayer = idx
            clickHitbox:SetProperty("active", idx == EditorState.currentLayer)
        end
        table.insert(panel.children, clickHitbox)
        table.insert(btns, clickHitbox)

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

        local objectSprite = new("image")
        objectSprite:SetImage()
        --listGrid:AddItem(lockIcon, 2, listGrid:GetColumns() - 1, "center")

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

    --if EditorState.registers.isLevelLoaded then
    --    for idx, ly in ipairs(EditorState.levelData.layers) do
    --        createLayerItem(ly, idx)
    --    end
    --end
end
