local function newImage(key, name)
    local root = "assets/images"
    local path = string.format("%s/%s", root, name)

    assetManager.loadImage(key, path)
end

local function newAudio(key, name, importMode)
    local root = "assets/sounds"
    local path = string.format("%s/%s", root, name)

    assetManager.loadAudio(key, path, importMode)
end

local function newFont(key, name)
    local root = "assets/fonts"
    local path = string.format("%s/%s", root, name)

    assetManager.loadFont(key, path)
end

return function()
    newImage("tiles_border", "game/tilesets/tiles_border.png")
    newImage("tiles_border_shadow", "game/tilesets/tiles_border_shadow.png")
    newImage("tile_bg", "game/tilesets/block_deco.png")

    newImage("ui_actions_button", "ui/icons_buttons.png")
    newImage("ui_lock", "ui/lock.png")

    -- props --
    newImage("ent_fish", "game/props/gamerfish.png")
    newImage("ent_bomb", "game/props/bomb.png")
    newImage("ent_geiser", "game/props/geiser.png")
    newImage("ent_pufferfish", "game/props/pufferfish.png")
    newImage("ent_bomb_chain", "game/props/chain_bomb.png")
    newImage("ent_pearl", "game/props/pearl.png")

    newFont("pixel_font", "pixel_font.ttf")
    newFont("pixel_font_bold", "pixel_font_bold.ttf")
end
