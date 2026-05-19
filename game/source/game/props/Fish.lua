local Entity = require 'source.game.core.Entity'
local animationComponent = require 'source.game.core.components.Animation'
local hitboxComponent = require 'source.game.core.components.Hitbox'
local editorDebugComponent = require 'source.game.core.components.EditorDebug'
local hitboxEditorRenderer = require 'source.game.core.HitboxRender'

return function(x, y)
    local Fish = Entity()
    Fish.animation = animationComponent()
    --Fish.hitbox = hitboxComponent("hazard", Fish.x, Fish.y, sprite:getWidth(), sprite:getHeight())

    Fish.animation.spriteID = "ent_fish"
    local sprite = assetManager.getImage(Fish.animation.spriteID)

    Fish.animation.sprite = sprite

    Fish.x = x or 0
    Fish.y = y or 0

    local fishScale = 5

    Fish.speed = 50
    Fish.direction = "right"
    Fish.targetScaleX = fishScale
    Fish.scaleX = fishScale
    Fish.scaleY = fishScale

    Fish.distanceToTravel = 120
    Fish.startX = Fish.x
    Fish.endX = Fish.x + Fish.distanceToTravel

    Fish.originX = sprite:getWidth() * 0.5
    Fish.originY = sprite:getHeight() * 0.5

    if Fish.isEditorMode then
        Fish.editorDebug = editorDebugComponent()
        Fish.editorDebug.editorHitbox = hitboxComponent("editor", Fish.x, Fish.y, sprite:getWidth() * Fish.scaleX, sprite:getHeight() * Fish.scaleY)

        Fish.editorDebug.editorDraw = function(self)
            love.graphics.setColor(0, 0.4, 1)
            love.graphics.line(self.startX, self.y, self.endX, self.y)
            love.graphics.setColor(1, 1, 1, 1)

            hitboxEditorRenderer(self)
        end
    end


    Fish.draw = function(self, elapsed)
        self.animation.draw(Fish)
        if Fish.isEditorMode then
            self.editorDebug.editorDraw(Fish)
        end
    end

    Fish.update = function(self, elapsed)
        self.animation.update(Fish, elapsed)

        if self.isEditorMode then
            Fish.editorDebug.editorHitbox.x = Fish.x + ((sprite:getWidth() * 0.5) - Fish.originX) * Fish.scaleX
            Fish.editorDebug.editorHitbox.y = Fish.y + ((sprite:getHeight() * 0.5) - Fish.originY) * Fish.scaleY
        end

        if Fish.direction == "right" then
            Fish.x = Fish.x + Fish.speed * elapsed

            if Fish.x >= Fish.endX then
                Fish.targetScaleX = -fishScale
                Fish.direction = "left"
            end
        elseif Fish.direction == "left" then
            Fish.x = Fish.x - Fish.speed * elapsed

            if Fish.x <= Fish.startX then
                Fish.targetScaleX = fishScale
                Fish.direction = "right"
            end
        end

        self.scaleX = math.lerp(self.scaleX, self.targetScaleX, 0.086)
    end

    Fish.serialize = function(self)
        return {
            x = self.x,
            y = self.y,
            scaleX = self.scaleX,
            scaleY = self.scaleY,
            sprite = self.animation.spriteID
        }
    end

    return Fish
end
