function getRequire()
    mapCollider = require 'map/mapCollider'
    require 'src/levels/transition'
    require 'src/levels/loadMap'
    require 'map/drawMap'
    SpellCombine = require 'src/util/spellCombine'
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
    c_Firecharge = require 'src/player/skillset/firecharge'
    c_Fireburst = require 'src/player/skillset2/fireburst'
    -- Spell Call
    shadowball = c_Shadowball(world)
    lightShards = c_LightShard(world)
    windCharges = c_WindCharge(world)
    firecharges = c_Firecharge(world)

    -- Spell (Combined)
    fireburst = c_Fireburst(world)
    
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
    c_Dummy = require 'src/entities/dummy'
    c_wolf = require 'src/entities/wolf'
    -- Entities Call
    dummy = c_Dummy(world)
    wolf = c_wolf(world)
end
return require