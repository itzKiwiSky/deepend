return {
    blank = function() end,
    roundedPanel = function(obj)
        local skin = obj:GetSkin()
        local x = obj:GetX()
        local y = obj:GetY()
        local width = obj:GetWidth()
        local height = obj:GetHeight()
        local bornerRadius = obj:GetBorderRadius()

        love.graphics.setColor(skin.controls.color_back1)
        love.graphics.rectangle("fill", x, y, width, height, bornerRadius)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(skin.controls.color_fore1)
        love.graphics.rectangle("line", x, y, width, height, bornerRadius)
        love.graphics.setLineWidth(1)
    end,
    buttonHitbox = function(obj)
        local skin   = obj:GetSkin()
        local x      = obj:GetX()
        local y      = obj:GetY()
        local width  = obj:GetWidth()
        local height = obj:GetHeight()
        local hover  = obj:GetHover()

        local top    = hover and skin.controls.color_active or { 0, 0, 0, 0 }

        love.graphics.setColor(top)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(1, 1, 1, 1)
    end,
    buttonSelectable = function(obj)
        local skin   = obj:GetSkin()
        local x      = obj:GetX()
        local y      = obj:GetY()
        local width  = obj:GetWidth()
        local height = obj:GetHeight()
        local hover  = obj:GetHover()

        local top    = (obj:GetProperty("active") or hover) and skin.controls.color_active or { 0, 0, 0, 0 }

        love.graphics.setColor(top)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(1, 1, 1, 1)
    end,
    imgQuadSupport = function(object)
        local skin = object:GetSkin()
        local x = object:GetX()
        local y = object:GetY()
        local orientation = object:GetOrientation()
        local scalex = object:GetScaleX()
        local scaley = object:GetScaleY()
        local offsetx = object:GetOffsetX()
        local offsety = object:GetOffsetY()
        local shearx = object:GetShearX()
        local sheary = object:GetShearY()
        local image = object.image
        local imagecolor = object.imagecolor or skin.controls.color_image
        local stretch = object.stretch
        local quad = object:GetProperty("quad")

        if stretch then
            scalex, scaley = object:GetWidth() / image:getWidth(), object:GetHeight() / image:getHeight()
        end

        love.graphics.setColor(imagecolor)
        if quad then
            love.graphics.draw(image, quad, x, y, orientation, scalex, scaley, offsetx, offsety, shearx, sheary)
        else
            love.graphics.draw(image, x, y, orientation, scalex, scaley, offsetx, offsety, shearx, sheary)
        end
    end,
}
