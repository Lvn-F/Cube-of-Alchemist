function love.load()
    -- require
    require 'lib/libAll'
    libAll()
    --
    
    --
    love.graphics.setDefaultFilter("nearest", "nearest")
    world = wf.newWorld(0, 0, true)
    map = sti('map/tile.lua')
    require 'src/require'
    getRequire()
    --

    -- Entities/Object Call
    player = c_Player(world)
    shadowball = c_Shadowball(world)
    lightShards = c_LightShard(world)
    fire = c_Fire(world)
    grass = c_Grass(world)
    wolf = c_wolf(world)
    --

    --
    mapCollider()
    --
    time = 0
    timeS = 0
    
    -- world:on("Projectile", "Map", function(pjCol, mCol, contact)
    --     local pj = pjCol:getObject()
    --     local map = mCol:getObject()
    --     pj.dead = true
    --     pj.collider:destroy()
    -- end)
end

function love.update(dt)
    world:update(dt)

    updateGame(dt)
    
    shaders.light:send("firePosition", {fire.x + 90, fire.y - 90})
    
    cam:lookAt(player.x, player.y)
    local w = love.graphics.getWidth()
    local  h = love.graphics.getHeight()
    local mapW = map.width * map.tilewidth
    local mapH = map.height * map.tileheight

    if cam.x < w / 2 then
        cam.x = w / 2
    end
    if cam.y < h / 2 then
        cam.y = h / 2
    end
    -- if cam.x > (mapW - w/2) then
    --     cam.x = mapW - w/2
    -- end
    -- if cam.y > (mapH - h/2) then
    --     cam.y = (mapH - h/2)
    -- end
    -- cam:lockPosition(player.x, player.y)
    local debug = require 'src/debug'
    -- debug:player()
     
    fog:update(dt)
    
end

function love.draw()
    --

    love.graphics.setColor(1, 1, 1, 1)
    --
    
    --
    cam:attach()
        -- love.graphics.setShader(shaders.white)
        love.graphics.push()
            love.graphics.scale(3,3)
            drawBefore()
        love.graphics.pop()
        drawSort.draw(map, 3)
        -- love.graphics.setShader()
        -- love.graphics.setShader(shaders.white)
        
        -- fire:draw()
        -- Shadowballs:draw()
        
        -- wolf:draw()
        -- player:draw()
        player:drawSpell()
        
        
        -- love.graphics.setShader()
        -- world:draw()
        love.graphics.push()
            love.graphics.scale(3,3)
            -- map:drawLayer(map.layers["environtmentTop"])
            drawAfter()
        love.graphics.pop()
        -- love.graphics.setShader(shaders.light)
        --     shaders:darken()
        -- love.graphics.setShader()
    --
    cam:detach()
    playerStat:draw()
    if lightShards.flashActive then
        -- local alpha = player.chargeTime / 0.5 
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
    -- fog:draw(function()love.graphics.rectangle("fill", 0, 0, 800, 600)end)
    --
    local debug = require 'src/debug'
    debug:player()
    --
end


