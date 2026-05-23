local Object = class:extend("Object")

function Object:__construct()
    self.x = 0
    self.y = 0
    self.hitbox = {}
    self.isEditorMode = registers.isEditorMode
end

function Object:draw()

end

function Object:update(elapsed)

end

return Object
