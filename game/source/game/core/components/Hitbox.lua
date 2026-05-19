return function(type, x, y, w, h)
    return {
        type = type,
        x = x,
        y = y,
        w = w,
        h = h,

        render = function(self)
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            love.graphics.setColor(1, 1, 1, 1)
        end,

        addHitbox = function(self, world)
            --world:add
        end
    }
end
