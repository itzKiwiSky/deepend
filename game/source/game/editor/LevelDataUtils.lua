local LevelDataUtils = {}

function LevelDataUtils.newLevelData()
    return {
        levelName = "",
        properties = {
            width = 10,
            height = 10,
            gravity = 0.125,
            -- flags --
            allowScriptedEvents = false,
            resetPlayerState = false,
            useFlashlight = false,
            isLinearLevel = false,
        },
        layers = {}
    }
end

function LevelDataUtils.clearLayers(levelData)
    table.clear(levelData)
end

function LevelDataUtils.addLayer(levelData, layer)
    table.insert(levelData.layers, layer)
end

return LevelDataUtils
