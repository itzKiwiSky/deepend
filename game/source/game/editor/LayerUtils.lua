--- Simple module used to make operations with layers
local LayerUtils = {}

---Check if the selected position are inside layer bounds
---@param layer any
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

return LayerUtils
