local Hitbox = class:extend("Hitbox")

function Hitbox:__construct(type, x, y, w, h)
    self.type = type
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Hitbox:render()
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1, 1)
end

return Hitbox
