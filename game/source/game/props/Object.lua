local Object = class:extend("Object")

function Object:__construct(x, y)
    self.x = x
    self.y = y
    self.r = 0
    self.sx = 1
    self.xy = 1
    self.ox = 1
    self.oy = 1

    self.isEditorMode = registers.isEditorMode
    self.onObjectConstructed(self, self.isEditorMode)
end

function Object:onObjectConstructed(mode) end

return Object
