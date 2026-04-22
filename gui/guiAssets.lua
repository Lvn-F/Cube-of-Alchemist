function loadGuiAssets()
    playerStat.healthFull = love.graphics.newImage('assets/sprite/gui/health-filled.png')
    playerStat.healthThreeQuarters = love.graphics.newImage('assets/sprite/gui/health-3-quarter.png')
    playerStat.healthHalf = love.graphics.newImage('assets/sprite/gui/health-half.png')
    playerStat.healthOneQuarters = love.graphics.newImage('assets/sprite/gui/health-1-quarter.png')
    playerStat.healthEmpty = love.graphics.newImage('assets/sprite/gui/health-empty.png')
    playerStat.leftBorder = love.graphics.newImage('assets/sprite/gui/health-left-border.png')
    playerStat.rightBorder = love.graphics.newImage('assets/sprite/gui/health-right-bordert.png')

    playerStat.healthSheet = love.graphics.newImage('assets/sprite/gui/healthbar.png')
    playerStat.healthGrid = anim8.newGrid(16, 16, playerStat.healthSheet:getWidth(), playerStat.healthSheet:getHeight())
end