function getRequire()
    mapCollider = require 'map/mapCollider'
    require 'map/drawMap'
    Fog = require("hadeh/fog")
    fog = Fog
    fog:load()
    
    
    shaders = require 'gatau/shaders'
    require 'gatau/update'
    require 'gatau/keypressed'
    require 'gatau/collisionClasses'
    createCollisionClasses()

    require 'gui/stat'
    require 'gui/guiAssets'

    
    c_Shadowball = require 'player/skillset/shadowball'
    c_LightShard = require 'player/skillset/lightShard'
    
    c_Player = require 'player/player'
    
    c_Fire = require 'object/fire'

    c_wolf = require 'entities/wolf'
end
return require