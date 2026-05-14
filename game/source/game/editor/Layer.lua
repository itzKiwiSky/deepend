local Layer = class:extend("Layer")

---@class LayerScrollMeta
---@field scrollX number
---@field scrollY number

---@alias LayerType
---| "tiles"
---| "objects"

---@class Layer
---@field name string
---@field type LayerType
---@field visible boolean
---@field locked boolean
---@field w number
---@field h number
---@field data any
---@field scrolling LayerScrollMeta
---@field scale number
---@field opacity number
function Layer:__construct(type, layerName, w, h)
    self.name = selfName
    self.type = type or "tile"
    self.visible = true
    self.locked = false
    self.w, self.h = w, h
    self.data = {}
    self.scrolling = {
        scrollX = 1,
        scrollY = 1,
    }
    self.scale = 1
    self.opacity = 1


    local layerTypes = {
        ["tiles"] = function()
            for y = 1, self.h, 1 do
                self.data[y] = {}
                for x = 1, self.w, 1 do
                    self.data[y][x] = false
                end
            end
        end,
        ["objects"] = function() self.data = {} end
    }

    layerTypes[self.type]()
end

function Layer:inBounds(...)
    local a = { ... }
    local typeImpl = {
        ["tiles"] = function()
            local x, y = a[1], a[2]
            return
                x >= 1 and
                x <= self.w and
                y >= 1 and
                y <= self.h
        end,
        ["objects"] = function()
            local rect1 = {
                x = 0,
                y = 0,
                w = self.w,
                h = self.h
            }
            -- expect object to be the argument --
            local obj = a[1]
            return
                rect1.x + rect1.w > obj.x and -- right  rect1 > left   rect2
                rect1.y + rect1.h > obj.y and -- bottom rect1 > top    rect2
                rect1.x < obj.x + obj.w and   -- left   rect1 > left   rect2
                rect1.y < obj.y + obj.h       -- top    rect1 > bottom rect2
        end
    }

    return typeImpl[self.type]()
end

function Layer:setLock(lock)
    self.locked = lock
end

return Layer
