--- Simple module used to make operations with layers
local LayerUtils = {}

---Check if the selected position are inside layer bounds
---@param layer Layer
---@param x number
---@param y number
---@return unknown
function LayerUtils.inBounds(layer, x, y)
    return
        x >= 1 and
        x <= layer.w and
        y >= 1 and
        y <= layer.h
end

---Set the layer lock state
---@param layer Layer
---@param lock boolean
function LayerUtils.setLock(layer, lock)
    layer.locked = lock
end

---Adda a light data for each layer --
---This field must be ignored when parsing level file --
---@param layer Layer
function LayerUtils.addLayerLightData(layer)
    local w, h = layer.w, layer.h
    local lightData = {}

    for y = 1, h, 1 do
        lightData[y] = {}
        for x = 1, w, 1 do
            lightData[y][x] = 0
        end
    end
end

return LayerUtils
