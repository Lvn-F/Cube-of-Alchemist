function love.load()
    -- Libraries
    require 'lib/libAll'
    libAll()

    love.graphics.setDefaultFilter("nearest", "nearest")
    world = wf.newWorld(0, 0, true)
    map = sti('map/tile.lua')

    require 'src/require'
    getRequire()
    mapCollider()

    GS = require 'lib/hump/gamestate'
    PlayState = require 'src/states/play'

    GS.switch(PlayState)
    GS.registerEvents()
end

-- function love.load()
    
-- end

-- function love.update(dt)
    
-- end
-- function love.draw()

-- end