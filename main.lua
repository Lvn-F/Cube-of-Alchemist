function love.load()
    -- Libraries
    require 'lib/libAll'
    libAll()

    love.graphics.setDefaultFilter("nearest", "nearest")
    world = wf.newWorld(0, 0, true)
    map = sti('map/home.lua')

    require 'src/require'
    getRequire()
    mapCollider()
    transitions:init(map)

    GS = require 'lib/hump/gamestate'
    PlayState = require 'src/states/play'

    GS.switch(PlayState)
    GS.registerEvents()
end

