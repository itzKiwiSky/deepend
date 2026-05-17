local LevelData = class:extend("LevelData")
local Layer = require 'source.game.editor.Layer'

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

---@class LevelData
---@field levelName string
---@field tileset string
---@field properties record<string, any>
---@field layers Layer
---@method

---constructuro
---@return LevelData
function LevelData:__construct()
    self.levelName = ""
    self.tileset = ""
    self.properties = {
        width = 10,
        height = 10,
        gravity = 0.125,
        -- flags --
        allowScriptedEvents = false,
        resetPlayerState = false,
        useFlashlight = false,
        isLinearLevel = false,
    }
    self.layers = {}
end

function LevelData:serialize()

end

---Add a new layer on the editor --
---@param type Layer.LayerType
---@param layerName string
function LevelData:addLayer(type, layerName)
    table.insert(self.layers, Layer.new(type, layerName, self.properties.width, self.properties.height))
end

function LevelData:clone()
    local copy = LevelData:new()

    for k, v in pairs(self) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end

    return copy
end

return LevelData
