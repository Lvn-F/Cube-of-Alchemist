local function c_Player(world)
    local Vector = require 'lib/hump/vector'
    player = {
        speed = 500,

        spell = 1,

        -- 1 = normal --
        -- 2 = charging --
        -- 3 = dash --
        state = 1,
        isCharging = false,
        chargeTime = 0,
        isDash = false,
        dashTimer = 0.3,

        x = 875,
        y =530,

        equipment = {spell = nil, armor = nil, accessory = nil},

        spriteSheet = love.graphics.newImage(pathImg.player .. 'player_32x32.png'),
        animSpeed = 0.13,
        baseDamping = 0,
        key = "nil"
    }
    player.collider = world:newBSGRectangleCollider(player.x, player.y, 40, 40, 12)
    player.collider:setCollisionClass("Player")
    player.collider:setFixedRotation(true)
    player.collider:setLinearDamping(player.baseDamping)
    player.collider:setAngularDamping(1)
    player.collider:setFriction(0)
    player.collider:setMass(1)
    player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animate = {
        right = anim8.newAnimation(player.grid('1-4', 1), player.animSpeed),
        left = anim8.newAnimation(player.grid('1-4', 2), player.animSpeed),
        up = anim8.newAnimation(player.grid('1-4', 3), player.animSpeed),
        down = anim8.newAnimation(player.grid('1-4', 4), player.animSpeed),
        dash = anim8.newAnimation(player.grid('1-1', 5), player.animSpeed),
        dashL = anim8.newAnimation(player.grid('1-1', 6), player.animSpeed),
        shadow = anim8.newAnimation(player.grid('1-1', 7), player.animSpeed)
    }
    player.anim = player.animate.down
    player.facing = "down"



    function player:control(dt)
        --
        vxPlayer = 0
        vyPlayer = 0
        local isMoving = false

        --
        if love.keyboard.isDown('d') then
            vxPlayer = self.speed
            self.anim = self.animate.right
            isMoving = true
            self.facing = "right"
        elseif love.keyboard.isDown('a') then
            vxPlayer = -self.speed
            self.anim = self.animate.left
            isMoving = true
            self.facing = "left"
        end
        if love.keyboard.isDown ('w') then
            vyPlayer = -self.speed
            self.anim = self.animate.up
            isMoving = true
            self.facing = "up"
        elseif love.keyboard.isDown ('s') then
            vyPlayer = self.speed
            self.anim = self.animate.down
            isMoving = true
            self.facing = "down"
        end
        if vxPlayer ~= 0 and vyPlayer ~= 0 then
            local xy = math.sqrt(vxPlayer*vxPlayer + vyPlayer*vyPlayer)
            vxPlayer = vxPlayer / xy * self.speed
            vyPlayer = vyPlayer / xy * self.speed
        end

        if isMoving == false then
            self.anim:gotoFrame(1)
        end
        
        self.collider:setLinearVelocity(vxPlayer * dt * 40, vyPlayer * dt * 40)
        self.x = self.collider:getX()
        self.y = self.collider:getY()
        self.pos = Vector(self.x, self.y)
    end
    --

    -- spell selection
    function player:spellSelect()
        local maxSpells = 3
        if player.spell < 1 then
            player.spell = maxSpells
        end
        if player.spell > maxSpells then
            player.spell = 1
        end
    end
    --

    --
    function player:handleState(dt)
        if player.state == 1 then
            player.isCharging = false
            player.speed = 500
        end

        if player.state == 2 then
            player.isCharging = true
        end
        if player.isCharging == true then
            player.chargeTime = player.chargeTime + dt
            if player.chargeTime > 1 then
                player.chargeTime = 1
            end
        else
            player.chargeTime = 0
        end

        if player.state == 3 then
            player.dashTimer = player.dashTimer - dt
            player.isDash = true
            if player.isDash == true then
                if love.keyboard.isDown('d') or love.keyboard.isDown('a') then
                    self.speed = 1000
                    if player.facing == "right" then
                        self.anim = self.animate.dash
                    elseif player.facing == "left" then
                        self.anim = self.animate.dashL
                    end
                    if self.animate.dash.position == 2 then
                        self.animate.dash:pause()
                    elseif self.animate.dashL.position == 2 then
                        self.animate.dashL:pause()
                    end
                elseif love.keyboard.isDown('w') or love.keyboard.isDown('s') then
                    self.speed = 1000
                end
            end
            if player.dashTimer < 0 then
                self.state = 1
                self.dashTimer = 0.3
            end
        end
    end
    
    function player:startCharging()
        Shadowballs:startCharge()
        lightShards:startCharge()
        WindCharges:startCharge()
    end
    function player:updateCharging(dt)
        Shadowballs:charge(dt)
        lightShards:charge(dt)
        WindCharges:charge(dt)
    end
    function player:releaseCharging()
        Shadowballs:endCharge()
        lightShards:endCharge()
        WindCharges:endCharge()
    end

    function player:update(dt)
        player:control(dt)
        player:spellSelect()
        player:handleState(dt)
        Shadowballs.anim = Shadowballs.animate.spawn
        Shadowballs.anim:update(dt)
        WindCharges.anim = WindCharges.animate.spawn
        WindCharges.anim:update(dt)
        player:updateCharging(dt)
        self.anim:update(dt)
    end

    function player:draw()
        self.animate.shadow:draw(self.spriteSheet, self.x, self.y + 30, nil, 2.5, nil, 16, 23)
        self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2.5, nil, 16, 23)
    end
    function player:drawSpell()
        if self.state == 2 then
            if self.spell == 1 then
                Shadowballs.anim:draw(Shadowballs.projectile,self.chargingSpell.pos.x, self.chargingSpell.pos.y,self.chargingSpell.rotation,self.chargingSpell.scale, self.chargingSpell.scale,Shadowballs.projectile:getWidth()/120,Shadowballs.projectile:getHeight()/2)
            elseif self.spell == 2 then
                lightShards:draw(player.x, player.y)
            elseif self.spell == 3 then
                WindCharges.anim:draw(WindCharges.projectile,self.chargingSpell.pos.x, self.chargingSpell.pos.y,self.chargingSpell.rotation,self.chargingSpell.scale, self.chargingSpell.scale,WindCharges.projectile:getWidth()/120,WindCharges.projectile:getHeight()/2)
            end
        end
    end
    return player
end
return c_Player