-- simple module that bake a grid image based on the editor size
-- the editor dont need to spend drawcalls rendering each grid dot
-- just draw a damn image
local EditorGrid = {}
EditorGrid.img = 0

function EditorGrid.newGrid(w, h, gridSize)
    local dotSize = 10
    local canvas = love.graphics.newCanvas(w * gridSize, h * gridSize)
    canvas:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        w = w or shove.getViewportWidth()
        h = h or shove.getViewportHeight()
        for y = 0, h * gridSize, gridSize do
            for x = 0, w * gridSize, gridSize do
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("fill", x, y, dotSize, dotSize)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end)

    EditorGrid.img = love.graphics.newImage(canvas:newImageData())
    canvas:release()
end

function EditorGrid.draw()
    if type(EditorGrid.img) == "userdata" then
        love.graphics.draw(EditorGrid.img, 0, 0)
    end
end

return EditorGrid
