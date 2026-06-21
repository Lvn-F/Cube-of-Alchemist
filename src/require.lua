function getRequire()
    mapCollider = require 'map/mapCollider'
    require 'map/drawMap'
    Fog = require("hadeh/fog")
    fog = Fog
    fog:load()

    --
    pathImg = {
        consumable = "assets/sprite/item/consumable/",
        collectible = "assets/sprite/item/collectible/",
        player = "assets/sprite/player/",
        skill = "assets/sprite/player/skill/",
        plant = "assets/sprite/object/plant/",
        gui = "assets/sprite/gui/"
    }
    --
    
    shaders = require 'src/shaders'
    require 'src/update'
    require 'src/collisionClasses'
    createCollisionClasses()

    require 'src/gui/stat'
    require 'src/gui/guiAssets'
    local Window = require 'src/gui/window'
    Window:load()

    -- Spell
    c_Shadowball = require 'src/player/skillset/shadowball'
    c_LightShard = require 'src/player/skillset/lightShard'
    c_WindCharge = require 'src/player/skillset/windCharge'
    -- Spell Call
    shadowball = c_Shadowball(world)
    lightShards = c_LightShard(world)
    windCharges = c_WindCharge(world)
    
    c_Player = require 'src/player/player'
    player = c_Player(world)
    
    -- Object
    c_Herb = require 'src/object/plant/herb'
    c_Fire = require 'src/object/fire'
    c_Grass = require 'src/object/grass'
    -- Object Call
    herbs = c_Herb(world, map)
    fire = c_Fire(world)
    grass = c_Grass(world, map)

    -- Entities
    c_wolf = require 'src/entities/wolf'
    -- Entities Call
    wolf = c_wolf(world)
end
return require