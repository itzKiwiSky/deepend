package.loaded["source.game.utils.Shared"] = nil
local shared = require 'source.game.utils.Shared'

local editorGrid = require 'source.game.editor.LevelGrid'
local LevelDataUtils = require 'source.game.editor.LevelDataUtils'
local layerUtils = require 'source.game.editor.LayerUtils'
local layer = require 'source.game.editor.Layer'

local function deepCopy(orig, copies)
    copies = copies or {}

    if type(orig) ~= "table" then
        return orig
    end

    if copies[orig] then
        return copies[orig]
    end

    local copy = {}
    copies[orig] = copy

    for k, v in pairs(orig) do
        copy[deepCopy(k, copies)] = deepCopy(v, copies)
    end

    return copy
end

local function addShowHideEvents(element, callbacks)
    -- Inicializa o state anterior
    element:SetProperty("_wasVisible", element:GetVisible())

    -- Guarda o Update anterior
    local previousUpdate = element.Update

    -- Cria um novo Update que rastreia visibilidade
    element.Update = function(self, elapsed)
        -- Executa o Update anterior se existir
        if previousUpdate then
            previousUpdate(self, elapsed)
        end

        -- Rastreia mudanças de visibilidade
        local wasVisible = self:GetProperty("_wasVisible") or false
        local isVisible = self:GetVisible()

        -- Detecta transição invisível → visível
        if not wasVisible and isVisible then
            self:SetProperty("_wasVisible", true)
            if callbacks and callbacks.OnShow then
                callbacks.OnShow(self)
            end

            -- Detecta transição visível → invisível
        elseif wasVisible and not isVisible then
            self:SetProperty("_wasVisible", false)
            if callbacks and callbacks.OnHide then
                callbacks.OnHide(self)
            end
        end
    end
end

local function createLabeledInput(new, elements, grid, fonts, inputType, labelText, yPos, targetTable, targetKey, options)
    local paddingText = 2
    local paddingInput = 10

    options = options or {
        min = 1,
        max = 9,
        defaultValue = 0,
    }

    local addedElements = {}

    if inputType ~= "checkbox" then
        local label = new("text")
        label:SetFont(fonts.label)
        label:SetDefaultColor(1, 1, 1, 1)
        label:SetText(labelText)
        grid:AddItem(label, yPos, paddingText, "left")
        addedElements["text"] = label
    end

    switch(inputType, {
        ["textinput"] = function()
            local input = new("textinput")
            input:SetSize(176, addedElements["text"]:GetHeight())
            input:SetFont(fonts.input)
            input:SetText("")
            input:SetHover(true)
            input:SetAlwaysUpdate(true)
            input.Update = function(this, elapsed)
                local value = this:GetValue()

                if tonumber(value) ~= nil then
                    targetTable[targetKey] = tonumber(value)
                else
                    targetTable[targetKey] = value
                end
            end
            grid:AddItem(input, yPos, paddingInput, "left")
            addedElements["input"] = input
        end,
        ["checkbox"] = function()
            local checkbox = new("checkbox")
            checkbox:SetFont(fonts.label)
            checkbox:SetText(labelText)
            checkbox:SetHover(true)
            checkbox.OnChanged = function(this, value)
                targetTable[targetKey] = value
            end
            grid:AddItem(checkbox, yPos, paddingText, "left")
            addedElements["checkbox"] = checkbox
        end,
        ["numberbox"] = function()
            -- Im gonna make my own bc the lf numberbox sucks --
            local function updateNumberboxText(text)
                text:SetText(text:GetProperty("count"))
                targetTable[targetKey] = tonumber(text:GetText())
            end

            local numberbox = new("textinput")
            numberbox:SetProperty("count", options.defaultValue)
            numberbox:SetSize(64, addedElements["text"]:GetHeight())
            numberbox:SetFont(fonts.input)
            numberbox:SetText(tostring(options.defaultValue))
            numberbox:SetHover(true)
            numberbox:SetUsable({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "-" })
            numberbox:SetAlwaysUpdate(true)

            -- Track previous text to detect user input changes
            numberbox:SetProperty("_lastText", tostring(options.defaultValue))

            local size = addedElements["text"]:GetHeight()

            local function syncCountFromDisplay()
                local currentText = numberbox:GetValue()

                -- If empty or just "-", reset to min
                if currentText == "" or currentText == "-" then
                    numberbox:SetProperty("count", options.min)
                else
                    -- Try to parse as number
                    local value = tonumber(currentText)
                    if value ~= nil then
                        -- Clamp to min/max
                        if value < options.min then
                            value = options.min
                        elseif value > options.max then
                            value = options.max
                        end
                        numberbox:SetProperty("count", value)
                    end
                end

                -- Update the table with the new value
                targetTable[targetKey] = numberbox:GetProperty("count")
            end

            local addNumberButton = new("button")
            addNumberButton:SetText("+")
            addNumberButton:SetSize(size, size)
            addNumberButton:SetHover(true)
            addNumberButton.OnClick = function(this)
                local c = numberbox:GetProperty("count")
                if c < options.max then
                    c = c + 1
                end
                numberbox:SetProperty("count", c)
                updateNumberboxText(numberbox)
            end

            local subNumberButton = new("button")
            subNumberButton:SetText("-")
            subNumberButton:SetSize(size, size)
            subNumberButton:SetHover(true)
            subNumberButton.OnClick = function(this)
                local c = numberbox:GetProperty("count")
                if c > options.min then
                    c = c - 1
                end
                numberbox:SetProperty("count", c)
                updateNumberboxText(numberbox)
            end

            -- Add Update function to sync typed values
            local previousUpdate = numberbox.Update
            numberbox.Update = function(this, elapsed)
                if previousUpdate then
                    previousUpdate(this, elapsed)
                end

                local currentText = this:GetValue()
                local lastText = this:GetProperty("_lastText") or ""

                -- Only process if text changed
                if currentText ~= lastText then
                    this:SetProperty("_lastText", currentText)
                    -- Sync count property but DON'T update display during typing
                    syncCountFromDisplay()
                end
            end

            grid:AddItem(numberbox, yPos, paddingInput + 2, "left")
            grid:AddItem(subNumberButton, yPos, paddingInput, "left")
            grid:AddItem(addNumberButton, yPos, paddingInput + 7, "left")

            addedElements["numberbox"] = {
                add = addNumberButton,
                sub = subNumberButton,
                display = numberbox
            }
        end
    })

    table.insert(elements, addedElements)
end

return function(new)
    local font = assetManager.getFont("pixel_font", 20)
    local fontInput = assetManager.getFont("pixel_font", 16)
    local elements = {}
    local tempLevelData = LevelDataUtils.newLevelData()

    local frame = new("frame")
    frame:SetSize(320, 480)
    frame:SetName("New Level")
    frame:ShowCloseButton(false)
    frame:Center()
    frame:SetAlwaysUpdate(true)
    frame:SetHover(true)
    --frame:SetProperty("triggeredVisible", false)
    frame.Update = function(this)
        frame:SetVisible(EditorState.registers.UIState.showCreateLevelWindow)
    end

    local function reset()
        tempLevelData.levelName = ""
        tempLevelData.properties.width = 20
        tempLevelData.properties.height = 40
        tempLevelData.properties.gravity = 0.125

        -- Reseta os layers
        tempLevelData.layers = {}
    end

    addShowHideEvents(frame, {
        OnShow = function(self)
            reset()
        end,
        OnHide = function(self)
            reset()
        end
    })

    local gridSize = 14
    local grid = new("grid")
    grid:SetParent(frame)
    grid:SetCellSize(gridSize, gridSize)
    grid:SetRows(math.floor(frame.height / gridSize) - 1)
    grid:SetColumns(math.floor(frame.width / gridSize) - 1)
    grid:SetCellPadding(0)
    grid:SetY(29)
    grid:SetVisible(false)
    grid.drawfunc = shared.blank

    local fonts = {
        label = font,
        input = fontInput
    }

    createLabeledInput(new, elements, grid, fonts, "textinput", "Name", 2, tempLevelData, "levelName")
    createLabeledInput(new, elements, grid, fonts, "numberbox", "Width", 5, tempLevelData.properties, "width", { defaultValue = 20, min = 1, max = 999 })
    createLabeledInput(new, elements, grid, fonts, "numberbox", "Height", 8, tempLevelData.properties, "height", { defaultValue = 40, min = 1, max = 999 })
    createLabeledInput(new, elements, grid, fonts, "numberbox", "Gravity", 11, tempLevelData.properties, "gravity", { defaultValue = 0.125, min = 0.065, max = 5 })

    local function createLevel()
        LevelDataUtils.addLayer(tempLevelData,
            layer.new("tiles", "blocks",
                tempLevelData.properties.width,
                tempLevelData.properties.height
            )
        )
        LevelDataUtils.addLayer(tempLevelData, layer.new("objects", "objects"))

        EditorState.levelData = deepCopy(tempLevelData)

        -- update grid sprite --
        editorGrid.newGrid(
            tempLevelData.properties.width,
            tempLevelData.properties.height,
            EditorState.GRID_SIZE
        )

        -- updat sprite batches --
        for idx, l in ipairs(tempLevelData.layers) do
            if l.type == "tiles" then
                EditorState:updateBatches(l)
            end
        end
        EditorState.registers.isLevelLoaded = true

        -- close window --
        loveView.reloadAll()
        EditorState.registers.UIState.showCreateLevelWindow = false
    end

    local buttonConfirm = new("button")
    buttonConfirm:SetText("Create")
    buttonConfirm:SetSize(64, 28)
    buttonConfirm:SetHover(true)
    buttonConfirm.OnClick = function(this)
        if EditorState.registers.isLevelLoaded then
            local msgButtons = {
                "Yes",
                "Cancel"
            }
            local msg = love.window.showMessageBox("Warning", "All the level data erased. Are you sure you want to continue?", msgButtons, "warning")
            if msg == 0 or msg == 2 then
                EditorState.registers.UIState.showCreateLevelWindow = false
            else
                createLevel()
            end
        else
            createLevel()
        end
    end
    grid:AddItem(buttonConfirm, 31, 18, "left")

    local buttonCancel = new("button")
    buttonCancel:SetText("Cancel")
    buttonCancel:SetSize(64, 28)
    buttonCancel:SetHover(true)
    buttonCancel.OnClick = function(this)
        if EditorState.registers.isLevelLoaded then
            EditorState.registers.UIState.showCreateLevelWindow = false
        else
            gamestate.pop()
        end
    end
    grid:AddItem(buttonCancel, 31, 2, "left")
end
