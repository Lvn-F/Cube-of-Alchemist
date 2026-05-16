function getRequire()
    mapCollider = require 'map/mapCollider'
    require 'map/drawMap'
    Fog = require("hadeh/fog")
    fog = Fog
    fog:load()
    drawSort = require 'src/drawSort'
    
    
    shaders = require 'src/shaders'
    require 'src/update'
    require 'src/keypressed'
    require 'src/collisionClasses'
    createCollisionClasses()

    require 'src/gui/stat'
    require 'src/gui/guiAssets'

    
    c_Shadowball = require 'src/player/skillset/shadowball'
    c_LightShard = require 'src/player/skillset/lightShard'
    
    c_Player = require 'src/player/player'
    
    c_Fire = require 'src/object/fire'
    c_Grass = require 'src/object/grass'

    c_wolf = require 'src/entities/wolf'
end
return require