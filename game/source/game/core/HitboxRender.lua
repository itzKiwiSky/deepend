return function(self)
    local selfHitbox = self.editorDebug.editorHitbox

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", selfHitbox.x - selfHitbox.w * 0.5, selfHitbox.y - selfHitbox.h * 0.5, selfHitbox.w, selfHitbox.h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", selfHitbox.x - selfHitbox.w * 0.5, selfHitbox.y - selfHitbox.h * 0.5, selfHitbox.w, selfHitbox.h)
    love.graphics.setColor(1, 1, 1, 1)
end
