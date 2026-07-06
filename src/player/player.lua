local function c_Player(world)
    local Vector = require 'lib/hump/vector'
    player = {
        speed = 500,

        spell = 1,
        mainSpell   = 1,   -- default
        secondSpell = nil,
        spellCooldown = -1.0,

        -- 1 = normal --
        -- 2 = charging --
        -- 3 = dash --
        state = 1,
        isCharging = false,
        chargeTime = 0,
        isDash = false,
        dashTimer = 0.3,
        iframe = false,
        hitTake = false,
        hitTakeCd = 0,

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
    -- player.collider:setLinearDamping(player.baseDamping)
    -- player.collider:setAngularDamping(1)
    -- player.collider:setFriction(0)
    -- player.collider:setMass(1)
    player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animate = {
        right = anim8.newAnimation(player.grid('1-4', 1), player.animSpeed),
        left = anim8.newAnimation(player.grid('1-4', 2), player.animSpeed),
        up = anim8.newAnimation(player.grid('1-4', 3), player.animSpeed),
        down = anim8.newAnimation(player.grid('1-4', 4), player.animSpeed),
        dash = anim8.newAnimation(player.grid('1-2', 5), player.animSpeed),
        dashL = anim8.newAnimation(player.grid('1-2', 6), player.animSpeed),
        shadow = anim8.newAnimation(player.grid('3-3', 5), player.animSpeed),
        chargeL = anim8.newAnimation(player.grid('1-4',7), player.animSpeed),
        chargeR = anim8.newAnimation(player.grid('1-4',8), player.animSpeed),
        focus = anim8.newAnimation(player.grid('4-4', 5), 1),
        die = anim8.newAnimation(player.grid('3-3',6), 1)
    }
    player.anim = player.animate.down
    player.facing = "down"


    -- # Player:Control
    function player:control(dt)
        --
        vxPlayer = 0
        vyPlayer = 0
        local isMoving = false

        --
        if player.state ~= 4 then
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
            if vxPlayer ~= 0 and vyPlayer ~= 0 then -- prevent double speed while moving diagonally
                local xy = math.sqrt(vxPlayer*vxPlayer + vyPlayer*vyPlayer)
                vxPlayer = vxPlayer / xy * self.speed
                vyPlayer = vyPlayer / xy * self.speed
            end
        end
        if isMoving == false then -- reset while idle
            self.anim:gotoFrame(1)
        end
        
        self.collider:setLinearVelocity(vxPlayer * dt * 40, vyPlayer * dt * 40) -- calculate speed with dt for constant frame
        self.x = self.collider:getX() -- attach collider along player pos
        self.y = self.collider:getY()
        -- self.pos = Vector(self.x, self.y)
    end
    --

    -- -- spell selection
    -- function player:spellSelect()
    --     local maxSpells = 3
    --     if player.spell < 1 then
    --         player.spell = maxSpells
    --     end
    --     if player.spell > maxSpells then
    --         player.spell = 1
    --     end
    -- end
    -- --

    -- State Handler
    function player:handleState(dt)
        if player.state == 1 then -- normal gameplay
            player.isCharging = false
            player.iframe = false
            player.speed = 500
            player.animSpeed = 0.13
        end

        if player.state == 2 then -- for charging spell
            player.isCharging = true
        end
        if player.isCharging == true then
            player.chargeTime = player.chargeTime + dt
            if player.chargeTime > 1 then
                player.chargeTime = 1
            end
            player.animSpeed = 1
        else
            player.chargeTime = 0
        end

        if player.state == 3 then -- for dash, (i know it's hardcoded, atleast it work)
            player.dashTimer = player.dashTimer - dt
            player.isDash = true
            player.iframe = true
            if player.isDash == true then
                if love.keyboard.isDown('d') or love.keyboard.isDown('a') then
                    self.speed = 1000
                    if player.facing == "right" then
                        self.anim = self.animate.dash
                        -- self.collider:setLinearVelocity(800, 0)
                    end
                    if player.facing == "left" then
                        self.anim = self.animate.dashL
                        -- self.collider:setLinearVelocity(-800, 0)
                    end
                elseif love.keyboard.isDown('w') or love.keyboard.isDown('s') then
                    self.speed = 1000
                end
                if love.keyboard.isDown('w') or love.keyboard.isDown('s')then
                    if love.keyboard.isDown('d') then
                        self.anim = self.animate.dash
                    end
                end
                if love.keyboard.isDown('w') or love.keyboard.isDown('s')then
                    if love.keyboard.isDown('a') then
                        self.anim = self.animate.dashL
                    end
                end
            end
            if player.dashTimer < 0 then
                if love.keyboard.isDown ~= 'w' or love.keyboard.isDown ~= 'd' or love.keyboard.isDown ~= 's' or love.keyboard.isDown ~= 'a'then
                    
                end
                self.state = 1
                self.dashTimer = 0.2
            end
        end

        if player.state == 4 then
            self.anim  = player.animate.down
            self.anim:gotoFrame(1)

            self.collider:setLinearVelocity(0, 0)
        end
    end

    -- collision check
    function player:collide(dt)
        if self.hitTakeCd > 0 then
            self.hitTakeCd = self.hitTakeCd - dt
            if self.hitTakeCd < 0 then self.hitTakeCd = 0 end
        end

        local hits = world:queryCircleArea(self.x, self.y, 20, {'Enemy'})

        if #hits > 0 and self.hitTakeCd <= 0 and player.iframe == false then
            playerStat.health = playerStat.health - 0.25
            self.hitTakeCd = 0.5

            -- Knock the player away from the first enemy touched
            local h = hits[1]
            local kb = Vector(self.x - h:getX(), self.y - h:getY()):normalized() * 220
            self.collider:setLinearVelocity(kb.x, kb.y)
        end
    end
    
    -- # Spell
    function player:startCharging()
        if self.spellCooldown <= 0 then
            Shadowballs:startCharge()
            lightShards:startCharge()
            WindCharges:startCharge()
            Firecharges:startCharge()
            FireBurst:startCharge()
        end
    end
    function player:updateCharging(dt)
        Shadowballs:charge(dt)
        lightShards:charge(dt)
        WindCharges:charge(dt)
        Firecharges:charge(dt)
        FireBurst:charge(dt)
    end
    function player:releaseCharging()
        Shadowballs:endCharge()
        lightShards:endCharge()
        WindCharges:endCharge()
        Firecharges:endCharge()
        FireBurst:endCharge()
    end

    -- # Player:Update
    function player:update(dt)
        player:control(dt)
        -- player:spellSelect()
        player:handleState(dt)
        player:updateCharging(dt)
        player:collide(dt)
        self.anim:update(dt)
        if self.spellCooldown > 0 then
            self.spellCooldown = self.spellCooldown - dt
        end
    end

    -- # Player:Draw
    function player:draw()
        self.animate.shadow:draw(self.spriteSheet, self.x, self.y + 30, nil, 2.5, nil, 16, 23)
        self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2.5, nil, 16, 23)
    end
    function player:drawSpell()
        if self.state == 2 then
            -- if self.spell == 1 then
            --     Shadowballs.anim:draw(Shadowballs.projectile,self.chargingSpell.pos.x, self.chargingSpell.pos.y,self.chargingSpell.rotation,self.chargingSpell.scale, self.chargingSpell.scale,Shadowballs.projectile:getWidth()/120,Shadowballs.projectile:getHeight()/2)
            if self.spell == 1 then
                Firecharges.anim:draw(Firecharges.projectile, self.chargingSpell.pos.x, self.chargingSpell.pos.y, nil, self.chargingSpell.scale, self.chargingSpell.scale, Firecharges.projectile:getWidth()/120, Firecharges.projectile:getHeight()/2)
            elseif self.spell == 2 then
                lightShards:draw(player.x, player.y)
            elseif self.spell == 3 then
                WindCharges.anim:draw(WindCharges.projectile,self.chargingSpell.pos.x, self.chargingSpell.pos.y, nil, self.chargingSpell.scale, self.chargingSpell.scale,WindCharges.projectile:getWidth()/120,WindCharges.projectile:getHeight()/2)
            elseif self.spell == 11 then
                FireBurst.anim:draw(FireBurst.projectile,self.chargingSpell.pos.x, self.chargingSpell.pos.y, nil, self.chargingSpell.scale, self.chargingSpell.scale,24,FireBurst.projectile:getHeight()/6)
            end
        end
    end
    return player
end
return c_Player