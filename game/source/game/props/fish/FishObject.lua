local object = require 'source.game.core.Object'
local IFish = require 'source.game.props.fish.IFish'

local Fish = object:extend("Fish")
Fish:implements(IFish)

function Fish:__construct()
    Fish.super.__construct(Fish)
end

return Fish
