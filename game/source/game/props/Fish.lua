local object = require 'source.game.core.Object'
local IEditorObject = require 'source.game.core.IEditorObject'
local IObject = require 'source.game.core.IObject'

local IFish = IObject:extend()
local IFishEditor = IEditorObject:extend()

local Fish = object:extend("Fish")
Fish:implements(IFish)
Fish:implements(IFishEditor)

local fishScale = 5


function Fish:__construct(x, y)
    Fish.super.__construct(Fish)
    self.x = x or self.x
    self.y = y or self.y
    self.sprite = "ent_fish"

    local sprite = assetManager.getImage(self.sprite)
    self.drawable = sprite

    self.speed = 50
    self.direction = "right"
    self.targetScaleX = fishScale
    self.scaleX = fishScale
    self.scaleY = fishScale

    self.originX = sprite:getWidth() * 0.5
    self.originY = sprite:getHeight() * 0.5

    self.distanceToTravel = 120
    self.startX = self.x
    self.endX = self.x + self.distanceToTravel
end

function Fish:draw()
    love.graphics.draw(self.drawable, self.x, self.y, 0, self.scaleX, self.scaleY, self.originX, self.originY)
    if registers.isEditorMode then
        love.graphics.setColor(0, 0.4, 1)
        love.graphics.line(self.startX, self.y, self.endX, self.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Fish:update(elapsed)
    if registers.isEditorMode then
        --self.editorDebug.editorHitbox.x = self.x + ((sprite:getWidth() * 0.5) - self.originX) * self.scaleX
        --self.editorDebug.editorHitbox.y = self.y + ((sprite:getHeight() * 0.5) - self.originY) * self.scaleY
    end

    if self.direction == "right" then
        self.x = self.x + self.speed * elapsed

        if self.x >= self.endX then
            self.targetScaleX = -fishScale
            self.direction = "left"
        end
    elseif self.direction == "left" then
        self.x = self.x - self.speed * elapsed

        if self.x <= self.startX then
            self.targetScaleX = fishScale
            self.direction = "right"
        end
    end

    self.scaleX = math.lerp(self.scaleX, self.targetScaleX, 0.086)
end

function Fish:serialize()

end

function Fish:load()

end

return Fish
