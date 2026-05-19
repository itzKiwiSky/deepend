return function()
    return {
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


            self.loop = loop or false
            self.animations[animationName] = createAnimation(indexes)
            self.animationCount = self.animationCount + 1
        end,

        play = function(self, animationName, resetFrame)
            if not self.animations[animationName] then
                return
            end

            self.currentPlayingAnimation = animationName

            self.isAnimationRunning = true
            self.frame = 1

            self:onAnimationStart()
        end,

        draw = function(self)
            if type(self.sprite) ~= "nil" then
                if self.animationCount > 0 then
                    local currentAnimation = self.animations[self.currentPlayingAnimation]
                    if currentAnimation.frames[self.frame] then
                        love.graphics.draw(self.sprite, currentAnimation.frames[self.frame], self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
                    end
                else
                    love.graphics.draw(self.sprite, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
                end
            end
        end,

        update = function(self, elapsed)
            if not self.isAnimationRunning then
                return
            end

            self.frameTime = self.frameTime + elapsed

            local currentAnimation = self.animations[self.currentPlayingAnimation]

            if self.frameTime >= 1 / self.speed then
                self.frameTime = 0
                self.frame = self.frame + 1
                if self.frame > #currentAnimation.frames then
                    if self.loop then
                        self.frame = 1
                    else
                        self.isAnimationRunning = false
                        self.frame = #currentAnimation.frames
                        self:onAnimationEnd()
                    end
                end
            end
        end,

        onAnimationEnd = function() end,
        onAnimationStart = function() end,
    }
end
