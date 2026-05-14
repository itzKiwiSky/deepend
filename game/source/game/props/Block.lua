local Object = require 'source.game.props.Object'
local hitbox = require 'source.game.props.Hitbox'
local Block = Object:extend("Block")

function Block:__construct(img, x, y)
    Block.super.__construct(x, y)
    self.image = img
    self.hitbox = newHitbox("solid", self.x, self.y, self.image:getWidth(), self.image:getHeight())
    self.lineWidth = 3
end

function Block:draw()
    if self.isEditorMode then
        self.hitbox:render()
    end
    love.graphics.draw(self.image, self.hitbox.x, self.hitbox.y, self.r, self.sx, self.sy)
end

return Block
