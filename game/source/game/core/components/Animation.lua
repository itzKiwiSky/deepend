return function()
    return {
        spriteID = "",
        sprite = nil,
        frame = 0,
        frameTime = 0,
        speed = 30,
        loop = false,
        reverse = false,
        frames = {},
        isAnimationRunning = false,
        currentPlayingAnimation = "",
        animationCount = 0,

        animations = {},

        addAnimation = function(self, animationName, indexes, loop)
            if self.animations[animationName] then
                return
            end

            local function createAnimation(idxs)
                return {
                    indexes = idxs,
                    frames = #idxs,
                }
            end


            self.animation.loop = loop or false
            self.animation.animations[animationName] = createAnimation(indexes)
            self.animation.animationCount = self.animation.animationCount + 1
        end,

        play = function(self, animationName, resetFrame)
            if not self.animation.animations[animationName] then
                return
            end

            self.animation.currentPlayingAnimation = animationName

            self.animation.isAnimationRunning = true
            self.animation.frame = 1

            self.animation:onAnimationStart()
        end,

        draw = function(self)
            if type(self.animation.sprite) ~= "nil" then
                if self.animation.animationCount > 0 then
                    local currentAnimation = self.animation.animations[self.animation.currentPlayingAnimation]
                    if currentAnimation.frames[self.frame] then
                        love.graphics.draw(
                            self.animation.sprite, currentAnimation.frames[self.frame],
                            self.x, self.y, self.r, self.scaleX, self.scaleY, self.originX, self.originY
                        )
                    end
                else
                    love.graphics.draw(
                        self.animation.sprite, self.x, self.y, self.r, self.scaleX,
                        self.scaleY, self.originX, self.originY
                    )
                end
            end
        end,

        update = function(self, elapsed)
            if not self.animation.isAnimationRunning then
                return
            end

            self.animation.frameTime = self.animation.frameTime + elapsed

            local currentAnimation = self.animation.animations[self.animation.currentPlayingAnimation]

            if self.animation.frameTime >= 1 / self.animation.speed then
                self.animation.frameTime = 0
                self.animation.frame = self.frame + 1
                if self.animation.frame > #currentAnimation.frames then
                    if self.animation.loop then
                        self.animation.frame = 1
                    else
                        self.animation.isAnimationRunning = false
                        self.animation.frame = #currentAnimation.frames
                        self.animation:onAnimationEnd()
                    end
                end
            end
        end,

        onAnimationEnd = function() end,
        onAnimationStart = function() end,
    }
end
