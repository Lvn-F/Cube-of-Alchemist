local function c_LightShard()
    lightShards = {
        sprite = love.graphics.newImage('assets/sprite/player/skill/lightShard.png'),
        animSpeed = 0.1,
        active = false,
        flashActive = false,
        flashTimer = 0
    }
    lightShards.grid = anim8.newGrid(64, 64, lightShards.sprite:getWidth(), lightShards.sprite:getHeight())
    lightShards.animate = {
        charge = anim8.newAnimation(lightShards.grid('1-9',1),lightShards.animSpeed),
        chargeFull = anim8.newAnimation(lightShards.grid('1-9', 2), lightShards.animSpeed)
    }
    
    -- function lightShard:start()
    --     player.isCharging = "true"
    --     player.chargeTime = 0
    --     lightShards.animate.charge:gotoFrame(1)
    -- end

    -- function lightShards:release()
    --     if player.isCharging == "true" then
    --     end
    -- end

    -- function lightShard:flashUpdate(dt)
    --     if self.flashActive then
    --         self.flashTimer = self.flashTimer - dt
    --         if self.flashTimer <= 0 then
    --             self.flashActive = false
    --         end
    --     end
    -- end
    -- function lightShards:flashDraw()
    --     if self.flashActive then
    --         -- local alpha = (self.flashTimer / 0.5) * 255
    --         love.graphics.setColor(1, 1, 1, 0.5)
    --         love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    --         love.graphics.setColor(1, 1, 1, 1)
    --     end
    -- end
    
    function lightShards:update(dt)
        if self.flashActive then
            self.flashTimer = self.flashTimer - dt
            if self.flashTimer <= 0 then
                self.flashActive = false
            end
        end
    end
    
    function lightShards:draw()
        if player.state == 2 and player.spell == 2 then
            lightShards.animate.charge:draw(self.sprite, player.x, player.y + 20, nil, 2, 2, 32, 32)
        elseif self.flashActive then
            lightShards.animate.chargeFull:draw(self.sprite, player.x, player.y + 20, nil, 2, 2, 32, 32)
        else
            player.anim:draw(player.spriteSheet, player.x, player.y, nil, 3, nil, 16, 22)
        end
        

        -- if self.flashActive then
        --     lightShards:flashDraw()
        -- end
        -- self:flashDraw()
    end
    return lightShards
end
return c_LightShard