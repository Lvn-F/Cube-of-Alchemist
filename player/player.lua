local function c_Player(world)
    -- player = world:newBSGRectangleCollider(600, 600, 40, 45, 10)
    local Vector = require 'lib/hump/vector'
    require 'player/skillset/lightShard'
    player = {
        speed = 500,

        spell = 1,

        -- 1 = normal
        state = 1,
        -- 2 = charging
        isCharging = "false",
        chargeTime = 0,
        -- 3 = dash
        isDash = "false",
        dashTimer = 0.3,

        x = 100,
        y =600,

        
        spriteSheet = love.graphics.newImage('assets/sprite/player/player_32x32.png'),
        animSpeed = 0.15,
        -- facingRot = 0,
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
        dash = anim8.newAnimation(player.grid('1-2', 5), player.animSpeed),
        dashL = anim8.newAnimation(player.grid('1-2', 6), player.animSpeed)
    }
    player.anim = player.animate.down
    player.facing = "down"



    function player:control(dt)
        --
        vxPlayer = 0
        vyPlayer = 0
        local isMoving = false
        -- local dash = 100
        -- local cooldown = 1

        -- local lastDash = 0
        -- lastDash = lastDash - dt
        --

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
        --

        --
        -- if love.keyboard.isDown('lshift') and lastDash < 0 then
        --     vx = vx * 1.5
        --     vy = vy * 1.5
        --     lastDash = self.cooldown
        -- end
        -- if love.keyboard.isDown("space") and lastDash < 0 then
        --     if player.anim == player.animate.right then
        --         player.x = vx + dash + player.x
        --     end
        --     if love.keyboard.isDown("a") then
        --         player.x = player.x - dash
        --     end
        --     if love.keyboard.isDown("w") then
        --         player.y = player.y - dash
        --     end
        --     if love.keyboard.isDown("s") then
        --         player.y = player.y + dash
        --     end

        --     lastDash = self.cooldown
        -- end
        
        self.collider:setLinearVelocity(vxPlayer * dt * 40, vyPlayer * dt * 40)
        -- self.collider:setPosition(vx, vy)
        self.x = self.collider:getX()
        self.y = self.collider:getY()
        self.pos = Vector(self.x, self.y)
    end
    --

    -- spell selection
    function player:spellSelect()
        if player.spell == 0 then
            player.spell = 2
        end
        if player.spell == 3 then
            player.spell = 1
        end
    end
    --

    --
    function player:handleState(dt)
        if player.state == 1 then
            player.isCharging = "false"
            player.speed = 500
        end

        if player.state == 2 then
            player.isCharging = "true"
        end
        if player.isCharging == "true" then
            player.chargeTime = player.chargeTime + dt
            if player.chargeTime > 1 then
                player.chargeTime = 1
            end
        else
            player.chargeTime = 0
        end

        if player.state == 3 then
            player.dashTimer = player.dashTimer - dt
            isDash = "true"
            if isDash == "true" then
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
    -- function player:chargeLogic()
        
    -- end
    -- function player:useSpell(dt)
    --     local px, py = self.x, self.y
    --     if self.spell == 1 then
    --         S_shadowball(self.pos.x, self.pos.y)
    --     end
    -- end
    function player:startCharging()
        if player.spell == 1 then
            self.state = 2
            self.chargeTime = 0
            self.chargingSpell = {
                pos = Vector(self.x, self.y),
                rotation = 0,
                scale = 1.7
            }
        end
        if player.spell == 2 then
            self.state = 2
            self.chargeTime = 0
            lightShards.animate.charge:gotoFrame(1)
            if self.chargeTime == 1 then
                lightShards.animate.chargeFull:gotoFrame(1)
                
            end
        end
    end
    function player:updateCharging(dt)
        if player.spell == 1 then
            if self.state == 2 and self.chargingSpell then
                self.speed = 250
                self.chargeTime = math.min(self.chargeTime + dt, 1)
                self.chargingSpell.pos = Vector(self.x , self.y)
                self.chargingSpell.scale = 1 + self.chargeTime * 0.3
                local dir = toMouseVector(self.x, self.y)
                self.chargingSpell.rotation = dir:angleTo(Vector(1,0))
                if dir.x >= 0 then
                    self.facing = "right"
                    self.anim = self.animate.right
                else
                    self.facing = "left"
                    self.anim = self.animate.left
                end
            end
        end
        if player.spell == 2 and player.state == 2 then
            self.speed = 200
            self.chargeTime = math.min(self.chargeTime + dt, 1)
            lightShards.animate.charge:update(dt)
            self.anim = self.animate.down
            lightShards.animate.chargeFull:update(dt)
            if lightShards.animate.charge.position == 9 then
                lightShards.animate.charge:pause()
            else
                lightShards.animate.charge:resume()
            end
        end
    end
    function player:releaseCharging()
        if player.spell == 1 then
            if self.state == 2 and self.chargingSpell then
                -- self.speed = 500
                local px, py = self.x, self.y
                S_shadowball(px, py)
                self.chargingSpell = nil
                self.state = 1
                self.isCharging = "false"
            end
        end
        if player.spell == 2 then
            lightShards.animate.chargeFull:gotoFrame(1)
            lightShards.flashActive = true
            lightShards.flashTimer = 0.2
            self.state = 1
            self.isCharging = "false"
        end
    end

    function player:update(dt)
        player:control(dt)
        player:spellSelect()
        player:handleState(dt)
        Shadowballs.anim = Shadowballs.animate.spawn
        Shadowballs.anim:update(dt)
        player:updateCharging(dt)
        self.anim:update(dt)
    end


    function player:draw()
        self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2.5, nil, 16, 23)
        if self.state == 2 then
            if self.spell == 1 then
                Shadowballs.anim:draw(Shadowballs.projectile,self.chargingSpell.pos.x, self.chargingSpell.pos.y,self.chargingSpell.rotation,self.chargingSpell.scale, self.chargingSpell.scale,Shadowballs.projectile:getWidth()/120,Shadowballs.projectile:getHeight()/2)
            elseif self.spell == 2 then
                lightShards:draw(player.x, player.y)
                
            end
        end
        
        -- for _, sb in ipairs(Shadowballs) do
        --     sb:draw()
        -- end
    end
    return player
end
return c_Player