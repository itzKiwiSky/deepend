package.loaded["source.game.utils.Shared"] = nil
local shared = require("source.game.utils.Shared")

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
            -- Im gonna make my onw bc the lf numberbox sucks --
            local function updateNumberboxText(text)
                text:SetText(text:GetProperty("count"))
                targetTable[targetKey] = tonumber(text:GetText())
            end

            local numberbox = new("textinput")
            numberbox:SetProperty("count", options.defaultValue)
            numberbox:SetSize(64, addedElements["text"]:GetHeight())
            numberbox:SetFont(fonts.input)
            numberbox:SetText("")
            numberbox:SetHover(true)
            numberbox:SetUsable({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "-" })
            numberbox:SetAlwaysUpdate(true)
            local size = addedElements["text"]:GetHeight()

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

            grid:AddItem(numberbox, yPos, paddingInput + 2, "left")
            grid:AddItem(subNumberButton, yPos, paddingInput, "left")
            grid:AddItem(addNumberButton, yPos, paddingInput + 7, "left")

            updateNumberboxText(numberbox)

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


    local frame = new("frame")
    frame:SetSize(320, 480)
    frame:SetName("New Level")
    frame:ShowCloseButton(false)
    frame:Center()
    frame:SetAlwaysUpdate(true)
    frame:SetHover(true)
    frame.Update = function(this)
        frame:SetVisible(EditorState.registers.UIState.showCreateLevelWindow)
    end

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

    --createLabeledInput(new, elements, grid, fonts, "textinput", "Song title", 2, tempSong.meta, "title")
    --createLabeledInput(new, elements, grid, fonts, "textinput", "Artist", 5, tempSong.meta, "artist")
    --createLabeledInput(new, elements, grid, fonts, "numberbox", "BPM", 8, tempSong.meta, "bpm", { defaultValue = 100, min = 10, max = 999 })
    --createLabeledInput(new, elements, grid, fonts, "textinput", "Description", 11, tempSong.meta, "description")
    --createLabeledInput(new, elements, grid, fonts, "textinput", "Tags", 14, tempSong.meta, "tags")
    --createLabeledInput(new, elements, grid, fonts, "textinput", "Charter", 17, tempSong.meta, "mapper")
    --createLabeledInput(new, elements, grid, fonts, "checkbox", "scripted events", 20, tempSong.meta.flags, "scriptedEvents")
    --createLabeledInput(new, elements, grid, fonts, "numberbox", "Start song", 23, tempSong.meta, "songStartOffset")
    --createLabeledInput(new, elements, grid, fonts, "numberbox", "Lanes", 26, tempSong.meta, "laneCount", { defaultValue = 1, min = 1, max = 9 })

    local buttonConfirm = new("button")
    buttonConfirm:SetText("Create")
    buttonConfirm:SetSize(64, 28)
    buttonConfirm:SetHover(true)
    buttonConfirm.OnClick = function(this)
        EditorState.registers.UIState.showCreateLevelWindow = false
        --EditorState.song = tempSong
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
