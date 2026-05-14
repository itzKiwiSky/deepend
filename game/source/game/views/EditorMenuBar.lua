package.loaded["source.game.utils.Shared"] = nil
local shared = require("source.game.utils.Shared")

local font = assetManager.getFont("pixel_font", 18)

local function newTabItem(name, action)
    return {
        name = name,
        action = action
    }
end

local function newTab(name, items)
    return {
        name = name,
        items = items or {}
    }
end

local function setTabVisible(tab, visible)
    tab.panel:SetVisible(visible)

    for _, element in ipairs(tab.elements) do
        element:SetVisible(visible)
    end
end

local function createItemList(new, parent, x, items, hideAllTabs)
    local panel = new("panel")
    panel:SetParent(parent)
    panel:SetX(x)
    panel:SetY(parent.height)

    local elements = {}
    local measuredTexts = {}

    local paddingLeft = 8
    local btnH = 28
    local maxWidth = 0

    -- PASSO 1: medir maior texto
    for _, item in ipairs(items) do
        local text = new("text")
        text:SetFont(font)
        text:SetDefaultColor(1, 1, 1, 1)
        text:SetText(item.name)

        maxWidth = math.max(maxWidth, text.width)

        table.insert(measuredTexts, {
            item = item,
            text = text
        })
    end

    local finalWidth = maxWidth + paddingLeft * 2

    -- PASSO 2: criar elementos
    for idx, entry in ipairs(measuredTexts) do
        local item = entry.item
        local text = entry.text
        local y = (idx - 1) * btnH

        local btn = new("button")
        btn:SetParent(panel)
        btn:SetX(0)
        btn:SetY(y)
        btn:SetSize(finalWidth, btnH)
        btn:SetHover(true)
        btn.drawfunc = shared.buttonHitbox
        btn.OnClick = function()
            if item.action then
                item.action()
            end
            if hideAllTabs then
                hideAllTabs()
            end
        end

        btn.OnMouseEnter = function(obj)
            EditorState.registers.canPlace = false
        end
        btn.OnMouseExit = function(obj)
            EditorState.registers.canPlace = true
        end

        text:SetParent(panel)
        text:SetX(paddingLeft)
        text:SetY(y + (btnH - text.height) / 2)

        table.insert(elements, btn)
        table.insert(elements, text)
    end

    panel:SetSize(finalWidth, #items * btnH)

    -- invisível por padrão
    panel:SetVisible(false)
    for _, element in ipairs(elements) do
        element:SetVisible(false)
    end

    return {
        panel = panel,
        elements = elements
    }
end

return function(new)
    local tabs = {}
    local openedTab = nil
    local topButtons = {}

    local function hideAllTabs()
        for _, tab in ipairs(tabs) do
            setTabVisible(tab, false)
        end
        openedTab = nil
    end

    local options = {
        newTab("File", {
            newTabItem("New Level", function()
                EditorState.registers.UIState.showCreateLevelWindow = true
                EditorState.registers.isUIShowing = true
            end),
            newTabItem("Open Level", function()
                --shared.filesytemDialog:loadDialog(loveframes, nil, { "Nexia level | *.nex", "All | *.*" })
            end),
            newTabItem("Save", function()
                print("save")
            end),
            newTabItem("Exit", function()
                print("exit")
            end)
        }),

        newTab("Edit", {
            newTabItem("Undo", function()
                print("undo")
            end),
            newTabItem("Redo", function()
                print("redo")
            end)
        })
    }

    local panel = new("panel")
    panel:SetSize(shove.getViewportWidth(), 26)

    local paddingX = 20
    local currentX = 0

    for _, tab in ipairs(options) do
        -- mede texto primeiro
        local txt = new("text")
        txt:SetFont(font)
        txt:SetDefaultColor(1, 1, 1, 1)
        txt:SetText(tab.name)

        local btnWidth = txt.width + paddingX

        -- botão/hitbox
        local btn = new("button")
        btn:SetParent(panel)
        btn:SetX(currentX)
        btn:SetY(0)
        btn:SetSize(btnWidth, panel.height)
        btn:SetHover(true)
        btn.drawfunc = shared.buttonHitbox

        btn.OnMouseEnter = function(obj)
            EditorState.registers.canPlace = false
        end
        btn.OnMouseExit = function(obj)
            EditorState.registers.canPlace = true
        end

        -- texto separado (posição ABSOLUTA)
        txt:SetParent(panel)
        txt:SetX(currentX + (btnWidth - txt.width) / 2)
        txt:SetY((panel.height - txt.height) / 2)

        local dropdown = createItemList(new, panel, currentX, tab.items, hideAllTabs)

        table.insert(topButtons, btn)
        table.insert(topButtons, txt)
        table.insert(tabs, dropdown)

        btn.OnClick = function()
            if openedTab == dropdown then
                hideAllTabs()
                return
            end

            hideAllTabs()
            setTabVisible(dropdown, true)
            openedTab = dropdown
        end

        currentX = currentX + btnWidth
    end

    return {
        panel = panel,
        tabs = tabs,
        hideAllTabs = hideAllTabs
    }
end
