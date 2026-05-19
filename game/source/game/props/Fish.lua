local Entity = require 'source.game.core.Entity'
local animationComponent = require 'source.game.core.components.Animation'
local hitboxComponent = require 'source.game.core.components.Hitbox'
local editorDebugComponent = require 'source.game.core.components.EditorDebug'
--function Fish:__construct()
--    Fish.super.__construct(Fish)
--    self.animation = animationComponent()
--end

return function()
    local Fish = Entity()
    local sprite = assetManager.getImage("ent_fish")

    Fish.speed = 50
    Fish.direction = "right"
    Fish.targetScale = Fish.sx
    Fish.ox = sprite:getWidth() * 0.5
    Fish.oy = sprite:getHeight() * 0.5


    if Fish.isEditorMode then
        Fish.editorDebug = editorDebugComponent()

        Fish.editorDebug.editorDraw = function(self)
            love.graphics.setColor(0, 0.4, 1)
            love.graphics.line()
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    Fish.animation = animationComponent()
    Fish.animation.sprite = sprite
    Fish.hitbox = hitboxComponent("hazard", Fish.x, Fish.y, sprite:getWidth(), sprite:getHeight())

    local animUpdate = Fish.animation.update
    local animDraw = Fish.animation.update

    Fish.draw = function(self, elapsed)
        animDraw(self)
    end

    Fish.update = function(self, elapsed)
        animUpdate(self, elapsed)
    end



    return Fish
end
