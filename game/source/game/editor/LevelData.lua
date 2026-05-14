local LevelData = class:extend("LevelData")
local Layer = require 'source.game.editor.Layer'

---@class LevelData
---@field levelName string
---@field tileset string
---@field properties record<string, any>
---@field layers Layer
---@method
function LevelData:__construct()
    self.levelName = ""
    self.tileset = ""

    self.properties = {
        width = 20,
        height = 20,
        gravity = 0.125,
        -- flags --
        allowScriptedEvents = false,
        resetPlayerState = false,
        useFlashlight = false,
        isLinearLevel = false,
    }
    self.layers = {}
end

---Add a new layer on the editor --
---@param type Layer.LayerType
---@param layerName string
function LevelData:addLayer(type, layerName)
    table.insert(self.layers, Layer:new(type, layerName, self.properties.width, self.properties.height))
end

return LevelData
