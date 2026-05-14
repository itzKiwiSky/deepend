local Autotile = {}

function Autotile.isTile(layer, x, y)
    x = x or 0
    y = y or 0

    -- Validação de bounds (1-based indexing para Lua)
    if
        y < 1 or y > layer.h or
        x < 1 or x > layer.w
    then
        return false
    end

    -- Verifica se há um tile na coordenada (0 significa vazio)
    return layer.data[y] and layer.data[y][x] and layer.data[y][x] ~= false
end

function Autotile.getFrame(layer, x, y)
    local u = Autotile.isTile(layer, x, y - 1) and 1 or 0
    local r = Autotile.isTile(layer, x + 1, y) and 2 or 0
    local d = Autotile.isTile(layer, x, y + 1) and 4 or 0
    local l = Autotile.isTile(layer, x - 1, y) and 8 or 0

    local ul = Autotile.isTile(layer, x - 1, y - 1) and 1 or 0
    local ur = Autotile.isTile(layer, x + 1, y - 1) and 2 or 0
    local dr = Autotile.isTile(layer, x + 1, y + 1) and 4 or 0
    local dl = Autotile.isTile(layer, x - 1, y + 1) and 8 or 0

    local edges = u + r + d + l

    local corners = 0

    -- Validação correta: só soma corner se ambos edges adjacentes existem
    if u ~= 0 and l ~= 0 then
        corners = corners + ul
    end

    if u ~= 0 and r ~= 0 then
        corners = corners + ur
    end

    if d ~= 0 and r ~= 0 then
        corners = corners + dr
    end

    if d ~= 0 and l ~= 0 then
        corners = corners + dl
    end

    local key = tostring(edges) .. "_" .. tostring(corners)

    local frameTable = {
        ["0_0"] = 0,
        ["1_0"] = 1,
        ["2_0"] = 2,
        ["3_0"] = 3,
        ["3_2"] = 4,
        ["4_0"] = 5,
        ["5_0"] = 6,
        ["6_0"] = 7,
        ["6_4"] = 8,
        ["7_0"] = 9,
        ["7_2"] = 10,
        ["7_4"] = 11,
        ["7_6"] = 12,
        ["8_0"] = 13,
        ["9_0"] = 14,
        ["9_1"] = 15,
        ["10_0"] = 16,
        ["11_0"] = 17,
        ["11_1"] = 18,
        ["11_2"] = 19,
        ["11_3"] = 20,
        ["12_0"] = 21,
        ["12_8"] = 22,
        ["13_0"] = 23,
        ["13_1"] = 24,
        ["13_8"] = 25,
        ["13_9"] = 26,
        ["14_0"] = 27,
        ["14_4"] = 28,
        ["14_8"] = 29,
        ["14_12"] = 30,
        ["15_0"] = 31,
        ["15_1"] = 32,
        ["15_2"] = 33,
        ["15_3"] = 34,
        ["15_4"] = 35,
        ["15_5"] = 36,
        ["15_6"] = 37,
        ["15_7"] = 38,
        ["15_8"] = 39,
        ["15_9"] = 40,
        ["15_10"] = 41,
        ["15_11"] = 42,
        ["15_12"] = 43,
        ["15_13"] = 44,
        ["15_14"] = 45,
        ["15_15"] = 46
    }

    return frameTable[key] or 0
end

return Autotile
