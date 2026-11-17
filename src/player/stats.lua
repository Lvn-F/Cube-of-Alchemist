local function stats()
    require 'src/player/statsGUI'
    playerStat = {
        maxHealthContainer = 4,
        -- healthContainer = maxHealthContainer,
        health = 4
    }
    loadGuiAssets()

    function playerStat:update()
        if playerStat.maxHealthContainer < 1 then
            playerStat.maxHealthContainer = 1
        end
        if playerStat.health < 0 then
            playerStat.health = 0
        end
        if playerStat.health > playerStat.maxHealthContainer then
            playerStat.health = playerStat.maxHealthContainer
        end
        if playerStat.health <= 0 and player and player.state ~= 0 then
            player:die()
        end
    end

    function playerStat:draw()
        local width = self.healthFull:getWidth()
        for i=1, self.maxHealthContainer do
            local offset = (i-1) * width
            love.graphics.draw(self.healthFull, 30 + offset, 30)
            local heartSprite = self.healthFull
            if i > self.health then
                heartSprite = self.healthEmpty
            end
            
            if self.health % 1 ~= 0 and i == math.ceil(self.health) then
                local fraction = self.health % 1
                if fraction >= 0.75 then
                    heartSprite = self.healthThreeQuarters
                elseif fraction >= 0.5 then
                    heartSprite = self.healthHalf
                elseif fraction >= 0.25 then
                    heartSprite = self.healthOneQuarters
                else
                    heartSprite = self.healthEmpty
                end
            end
            love.graphics.draw(heartSprite, 30 + offset, 30)
        end
        
        love.graphics.draw(self.leftBorder, 30 - self.leftBorder:getWidth(), 30)
        love.graphics.draw(self.rightBorder, 30 + (self.maxHealthContainer * width), 30)

        -- love.graphics.setColor(0, 0, 0, 0.3)
        -- love.graphics.circle("fill", 100, love.graphics.getHeight() - 100, 50)
        -- love.graphics.setColor(1, 1, 1, 1)
        -- love.graphics.print(math.floor(player.spellCooldown)+1, 85, love.graphics.getHeight()-130, nil, 4)
        -- love.graphics.print("Basic Spell", 70, love.graphics.getHeight()-50)
        love.graphics.print("Left-Click", love.graphics.getWidth()/10-100, love.graphics.getHeight()-100, nil, 2)
        love.graphics.print("Right-Click", love.graphics.getWidth()/10+50, love.graphics.getHeight()-100, nil, 2)

        if player.spell == 1 then
            love.graphics.print("Fireball", 70, love.graphics.getHeight()-50, nil, 2)
        elseif player.spell == 2 then
            love.graphics.print("Light Shard", 70, love.graphics.getHeight()-50, nil, 2)
        elseif player.spell == 3 then
            love.graphics.print("Wind Charge", 70, love.graphics.getHeight()-50, nil, 2)
        end

        if player.spell == 11 then
            love.graphics.print("Fire Burst", 210, love.graphics.getHeight()-50, nil, 2)
        elseif player.spell == 12 then
            love.graphics.print("Lightning Strike", 210, love.graphics.getHeight()-50, nil, 2)
        end
        -- if player.spell == 1 and player.player
        -- end
        love.graphics.print("Spell (Tab)", 30, love.graphics.getHeight()/4, nil, 2)
        love.graphics.print("Bag (E)", 30, love.graphics.getHeight()/4+50, nil, 2)
    end
    return playerStat
end
return stats()