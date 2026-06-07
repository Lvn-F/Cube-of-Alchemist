function loadGuiAssets()
    playerStat.healthFull = love.graphics.newImage(pathImg.gui .. 'health-filled.png')
    playerStat.healthThreeQuarters = love.graphics.newImage(pathImg.gui .. 'health-3-quarter.png')
    playerStat.healthHalf = love.graphics.newImage(pathImg.gui .. 'health-half.png')
    playerStat.healthOneQuarters = love.graphics.newImage(pathImg.gui .. 'health-1-quarter.png')
    playerStat.healthEmpty = love.graphics.newImage(pathImg.gui .. 'health-empty.png')
    playerStat.leftBorder = love.graphics.newImage(pathImg.gui .. 'health-left-border.png')
    playerStat.rightBorder = love.graphics.newImage(pathImg.gui .. 'health-right-bordert.png')

    playerStat.healthSheet = love.graphics.newImage(pathImg.gui .. 'healthbar.png')
    playerStat.healthGrid = anim8.newGrid(16, 16, playerStat.healthSheet:getWidth(), playerStat.healthSheet:getHeight())
end