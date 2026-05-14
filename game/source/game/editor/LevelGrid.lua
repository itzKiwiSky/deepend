return function(w, h, gridSize)
    local canvas = love.graphics.newCanvas(w * gridSize, h * gridSize)
    canvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        w = w or shove.getViewportWidth()
        h = h or shove.getViewportHeight()
        for y = 0, h * gridSize, gridSize do
            for x = 0, w * gridSize, gridSize do
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.setPointSize(3)
                love.graphics.points(x, y)
                love.graphics.setPointSize(1)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end)

    return love.graphics.newImage(canvas:newImageData())
end
