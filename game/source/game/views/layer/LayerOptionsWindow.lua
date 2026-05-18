package.loaded["source.game.utils.Shared"] = nil
local shared = require 'source.game.utils.Shared'



return function(new)
    local elements = {}

    local frame = new("frame")
    frame:SetName("Layer {name} Option")
    frame:SetResizable(false)
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetHover(true)
    frame:SetSize(370, 350)
    frame.Update = function(this)
        --this:SetVisible(EditorState.registers.isLevelLoaded)
    end
    frame:SetPos(shove.getViewportWidth() - (frame:GetWidth() + 10), 40)

    local layerList = new("list")
    local offsetY = 28
    layerList:SetParent(frame)
    layerList:SetY(layerList:GetY() + offsetY)
    layerList:SetWidth(frame:GetWidth())
    layerList:SetHeight(frame:GetHeight() - offsetY)
    layerList:SetPadding(0)
    layerList:SetSpacing(5)
    layerList:SetHover(true)

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
end
