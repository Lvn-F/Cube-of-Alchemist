function getRequire()
    mapCollider = require 'map/mapCollider'
    require 'map/drawMap'
    Fog = require("hadeh/fog")
    fog = Fog
    fog:load()
    
    
    shaders = require 'src/shaders'
    require 'src/update'
    require 'src/collisionClasses'
    createCollisionClasses()

    require 'src/gui/stat'
    require 'src/gui/guiAssets'

    -- Spell
    c_Shadowball = require 'src/player/skillset/shadowball'
    c_LightShard = require 'src/player/skillset/lightShard'
    -- Spell Call
    shadowball = c_Shadowball(world)
    lightShards = c_LightShard(world)
    
    c_Player = require 'src/player/player'
    player = c_Player(world)
    
    -- Object
    c_Fire = require 'src/object/fire'
    c_Grass = require 'src/object/grass'
    -- Object Call
    fire = c_Fire(world)
    grass = c_Grass(world)

    -- Entities
    c_wolf = require 'src/entities/wolf'
    -- Entities Call
    wolf = c_wolf(world)
end
return require