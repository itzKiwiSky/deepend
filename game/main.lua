--require 'source.system.ErrHandler'
require 'source.system.Run'
SharedConstants = require 'source.game.SharedConstants'
local gitstuff = require 'source.system.GitStuff' -- super important stuff --
assetManager = require 'source.system.AssetManager'

Components = {}
Systems = {}

presence = require 'source.system.UpdatePresence'
local presenceUpdateTimer = 0

languageService = {}
languageRaw = {}

local function createUserFolders()
    local filelist = {
        root = "user",
        child = {
            "editor",
            "converted",
            "downloaded",
            "mods",
            "missionspacks"
        }
    }

    if love.filesystem.getInfo(filelist.root) == nil then
        love.filesystem.createDirectory(filelist.root)

        for index, folder in ipairs(filelist.child) do
            local path = string.format("%s/%s", filelist.root, folder)
            love.filesystem.createDirectory(path)
        end
    end
end

function love.initialize()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local languageManager = require 'source.system.utils.LanguageManager'

    local save = require 'source.system.utils.Save'

    local systems = fsutil.scanFolder("source/game/core/systems")
    local components = fsutil.scanFolder("source/game/core/components")

    for idx, path in ipairs(systems) do
        local normalizedPath = (path:gsub("/", ".")):gsub(".lua", "")
        local idxName = (path:match("[^/]+$")):gsub(".lua", "")
        Systems[idxName] = require(normalizedPath)
    end

    for idx, path in ipairs(components) do
        local normalizedPath = (path:gsub("/", ".")):gsub(".lua", "")
        local idxName = (path:match("[^/]+$")):gsub(".lua", "")
        Components[idxName] = require(normalizedPath)
    end

    print(inspect(Components))

    love.graphics.setDefaultFilter("nearest", "nearest")

    if love.arg.parseGameArguments(arg)[1] == "--test" then
        lust = require 'tests.tools.Lust'

        local tests = fsutil.scanFolder("tests/specs")

        if #tests <= 0 then
            --print("[love.Test] No tests to run")
            io.printf("{bgBrightMagenta}{brightCyan}{bold}[Love.Test]{reset}{brightWhite} : No tests to run!{reset}")
            love.event.quit()
        end

        for _, test in ipairs(tests) do
            local t = require((test:gsub("/", ".")):gsub("%.lua", ""))
            t(lust)
        end

        love.event.quit()

        return
    end

    gameSave = save.new("game")

    gameSave.save = {
        registry = {}
    }

    registers = {
        statesName = {},
        isOnline = false,
        devWindow = false,
        devWindowContent = function() return end,
        isEditorMode = false,
    }

    local configAPI = json.decode(love.filesystem.read("API.json"))
    if love.system.getDeviceType() == "desktop" then
        discordrpc.initialize(configAPI.discord.appid, false)

        local code, body = https.request("https://google.com")
        registers.isOnline = code == 200
    end

    gameSave:initialize()
    love.keyboard.setKeyRepeat(true)

    registers.devWindowContent = function()
        Slab.BeginWindow("menuNightDev", { Title = "Development" })
        for _, value in ipairs(registers.statesName) do
            if Slab.Button(value) then
                local stateStr = string.format('gamestate.switch(%s)', value)
                loadstring(stateStr)()
            end
        end
        Slab.EndWindow()
    end

    gitstuff() -- still super important --

    -- autoload states --
    local statePath = "source/states"
    local states = love.filesystem.getDirectoryItems(statePath)
    for s = 1, #states, 1 do
        if love.filesystem.getInfo(statePath .. "/" .. states[s]).type == "file" then
            local state = "source.states." .. states[s]:gsub(".lua", "")
            require(state)
            local strName = states[s]:gsub(".lua", "")
            table.insert(registers.statesName, strName)
            if love.FEATURE_FLAGS.debug then
                local str = string.format("{bgBrightMagenta}{brightCyan}{bold}[Love.AssetManager]{reset}{brightWhite} : State {bgYellow}%s{reset}{brightWhite} loaded with {brightGreen}Sucess{reset}", strName)
                io.printf(str)
            end
        end
    end

    if love.FEATURE_FLAGS.debug then
        if love.system.getDeviceType() == "desktop" then
            discordrpc.ready = function(userId, username, discriminator, avatar)
                local str = string.format("{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightWhite}: ready (%s, %s, %s, %s){reset}", userId, username, discriminator, avatar)
                io.printf(str)

                presence.largeImageKey = "placeholder"
                presence()
            end

            discordrpc.disconnected = function(errorCode, message)
                local str = string.format("{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightRed}: disconnected (%s, %s){reset}", errorCode, message)
                io.printf(str)
            end

            discordrpc.errored = function(errorCode, message)
                local str = string.format("{bgBrightBlue}{brightWhite}[Love.DiscordRPC]{reset}{brightRed}: Error (%s, %s){reset}", errorCode, message)
                io.printf(str)
            end
        end
    end

    masterMixer = love.mixer.newMixer()
    masterMixer:addChannel("music")
    masterMixer:addChannel("sfx")

    createUserFolders()

    gamestate.registerEvents()

    assetManager.targetState = EditorState
    assetManager.init(require('load'))
end

function love.update(elapsed)
    masterMixer:update()

    if love.system.getDeviceType() == "desktop" then
        presenceUpdateTimer = presenceUpdateTimer + elapsed

        if presenceUpdateTimer > 2 and registers.isOnline then
            presence()
            presenceUpdateTimer = 0
        end
        if registers.isOnline then
            discordrpc.runCallbacks()
        end
    end
end

function love.quit()
    assetManager.release()
    if love.system.getDeviceType() == "desktop" then
        discordrpc.shutdown()
    end
end
