--- The virtual representation of a layer inside the editor and the game area
local Layer = {}

---@alias LayerType
---|"tiles"
---|"objects"

---Create a new layer object data
---@param type LayerType
---@param layerName string
---@param w number
---@param h number
---@return table
function Layer.new(type, layerName, w, h)
    local layer = {
        name = layerName,
        type = type or "tiles",

        z = 0,

        visible = true,
        locked = false,

        w = w,
        h = h,

        data = {},

        scrolling = {
            scrollX = 1,
            scrollY = 1,
        },

        scale = 1,
        opacity = 1,
    }

    -- this section is used to the define the type of data stored inside the layer
    -- derivates from the type
    local layerTypes = {
        ["tiles"] = function()
            for y = 1, h do
                layer.data[y] = {}
                for x = 1, w do
                    layer.data[y][x] = false
                end
            end
        end,

        ["objects"] = function()
            layer.data = {}
        end
    }

    if layerTypes[layer.type] then
        layerTypes[layer.type]()
    end

    return layer
end

return Layer
