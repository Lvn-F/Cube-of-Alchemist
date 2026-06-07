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
    lightShards.anim = lightShards.animate.charge
    
    function lightShards:startCharge()
        if player.spell == 2 then
            player.state = 2
            player.chargeTime = 0
            self.animate.charge:gotoFrame(1)
        end
    end
    function lightShards:charge(dt)
        if player.spell == 2 and player.state == 2 then
            player.speed = 200
            player.chargeTime = math.min(player.chargeTime + dt, 1)
            player.anim = player.animate.down
            self.anim:update(dt)
        end
    end
    function lightShards:endCharge()
        if player.spell == 2 then
            if player.chargeTime <= 0.9 then
                player.isCharging = false
                player.state = 1
                return
            end
            -- self.animate.chargeFull:gotoFrame(1)
            self.anim = self.animate.charge
            self.flashActive = true
            self.flashTimer = 0.2
            player.state = 1
            player.isCharging = false
        else
            return
        end
    end
    
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
            self.anim:draw(self.sprite, player.x, player.y + 10, nil, 2, 2, 32, 32)
                if self.animate.charge.position == 9 then
                    self.anim = self.animate.chargeFull
                    self.anim:draw(self.sprite, player.x, player.y + 10, nil, 2, 2, 32, 32)
                end
        elseif self.flashActive then
            self.animate.chargeFull:draw(self.sprite, player.x, player.y + 20, nil, 2, 2, 32, 32)
        else
            player.anim:draw(player.spriteSheet, player.x, player.y, nil, 3, nil, 16, 22)
        end
    end
    return lightShards
end
return c_LightShard