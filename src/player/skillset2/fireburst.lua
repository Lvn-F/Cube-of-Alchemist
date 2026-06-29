local function c_Fireburst(world)
    local Vector = require 'lib/hump/vector'
    local Camera = require 'lib/hump/camera'

    FireBurst = {
        projectile = love.graphics.newImage(pathImg.skill .. 'fireburst.png'),
        burst = love.graphics.newImage(pathImg.skill .. 'firecharge.png'),
        animSpeed = 0.1,
    }
    FireBurst.grid = anim8.newGrid(64, 64, FireBurst.projectile:getDimensions())
    FireBurst.gridB = anim8.newGrid(32, 32, FireBurst.burst:getDimensions())
    FireBurst.animate = {
        charge     = anim8.newAnimation(FireBurst.grid('1-6', 3),   FireBurst.animSpeed),
        chargeFull = anim8.newAnimation(FireBurst.grid('7-11', 3),  FireBurst.animSpeed),
        releaseY   = anim8.newAnimation(FireBurst.grid('12-14', 3), 0.08),
        releaseO   = anim8.newAnimation(FireBurst.grid('12-14', 2), 0.08),
        releaseR   = anim8.newAnimation(FireBurst.grid('12-14', 1), 0.08),
        burst      = anim8.newAnimation(FireBurst.grid('15-22', 1), 0.07)
    }
    FireBurst.anim = FireBurst.animate.charge
    FireBurst.queue = {}
    -- FireBurst.animY = nil
    -- FireBurst.animO = nil
    -- FireBurst.animR = nil

    local function toMouseVector(px, py)
        local mx, my = love.mouse.getPosition()
        local wx, wy = cam:worldCoords(mx, my)
        return Vector(wx - px, wy - py):normalized()
    end

    function S_fireburst(x, y, dir)
        local fireburst = {
            x = x,
            y = y,
            pos = Vector(x, y),
            timer = 0.25,
            dead = false,
            bursting = false,
            dir = dir,
            rotation = dir:angleTo(Vector(1, 0)),
            rad = 3,
            speed = 200 + player.chargeTime * 500,
            animY = FireBurst.animate.releaseY:clone(),
            animO = FireBurst.animate.releaseO:clone(),
            animR = FireBurst.animate.releaseR:clone(),
        }
        fireburst.collider = world:newBSGRectangleCollider(x - 24, y - 24, 32, 32, 16)
        fireburst.collider:setCollisionClass("Projectile")
        fireburst.collider:setLinearVelocity(dir.x * fireburst.speed, dir.y * fireburst.speed)

        function fireburst:playBurst()
            if self.bursting then return end
            self.bursting = true

            self.collider:setLinearVelocity(0, 0)
            self.collider:destroy()
            self.collider = nil

            self.animY = FireBurst.animate.burst:clone()
            self.animO = FireBurst.animate.burst:clone()
            self.animR = FireBurst.animate.burst:clone()
            -- onLoop fires once the (non-repeating-in-practice) animation
            -- wraps back to frame 1 -- that's our "burst finished" signal.
            self.animY.onLoop = function()
                self.dead = true
            end
            self.animO.onLoop = function()
                self.dead = true
            end
            self.animR.onLoop = function()
                self.dead = true
            end
        end

        function fireburst:update(dt)
            self.animY:update(dt)
            self.animO:update(dt)
            self.animR:update(dt)
            if self.collider then
                self.pos.x, self.pos.y = self.collider:getPosition()
            end
            if self.bursting then
                -- nothing else to do while the burst plays; self.dead is
                -- set by the onLoop callback above once it completes
                return
            end

            self.timer = self.timer - dt
            if self.timer < 0 then
                self:playBurst()
                return
            end
            
            self.pos.x, self.pos.y = self.collider:getPosition()

            local hits = world:queryCircleArea(self.pos.x, self.pos.y, 20, {'Enemy', 'Map'})
            for _, h in ipairs(hits) do
                local obj = h:getObject()
                if obj and obj.hit then obj:hit() end
            end
            if #hits > 0 then
                self:playBurst()
            end
        end

        table.insert(FireBurst, fireburst)
    end

    function FireBurst:startCharge()
        if player.spell == 11 then
            player.state = 2
            player.chargeTime = 0
            self.anim = self.animate.charge
            self.animate.charge:gotoFrame(1)
            player.chargingSpell = {
                pos = Vector(self.x, self.y),
                rotation = 0,
                scale = 1.7
            }
        else
            return
        end
    end

    function FireBurst:charge(dt)
        if player.spell == 11 then
            if player.state == 2 and player.chargingSpell then
                player.speed = 250
                player.chargeTime = math.min(player.chargeTime + dt, 1)
                player.chargingSpell.pos = Vector(player.x, player.y)
                player.chargingSpell.scale = 2 + player.chargeTime * 0.3

                local dir = toMouseVector(player.x, player.y)
                player.chargingSpell.rotation = dir:angleTo(Vector(1, 0))

                -- Play the charge-up animation, then once frame 7 is reached,
                -- lock into the looping "fully charged" animation.
                if self.anim == self.animate.charge then
                    self.anim:update(dt)
                    if self.animate.charge.position >= 6 then
                        self.anim = self.animate.chargeFull
                    end
                else
                    self.anim:update(dt)
                end

                if dir.x >= 0 then
                    player.facing = "right"
                    player.anim = player.animate.chargeR
                    player.chargingSpell.pos.x = player.x - 8
                else
                    player.facing = "left"
                    player.anim = player.animate.chargeL
                    player.chargingSpell.pos.x = player.x - 32
                end
            end
        end
    end

    function FireBurst:endCharge()
        if player.spell == 11 then
            if player.state == 2 and player.chargingSpell then
                -- if player.chargeTime <= 0.7 then
                if self.anim ~= self.animate.chargeFull then
                    player.isCharging = false
                    player.state = 1
                    return
                end
                local px, py = player.x, player.y
                local dir = toMouseVector(px, py)
                local dirup = toMouseVector(px-24, py-24)
                local dirup2 = toMouseVector(px-32, py-32)
                local dirdown = toMouseVector(px+24, py+24)
                local dirdown2 = toMouseVector(px+32, py+32)

                S_fireburst(px, py, dir)
                S_fireburst(px, py, dirup)
                S_fireburst(px, py, dirup2)
                S_fireburst(px, py, dirdown)
                S_fireburst(px, py, dirdown2)

                S_fireburst(px, py, dir/1.2)
                S_fireburst(px, py, dirup/1.2)
                S_fireburst(px, py, dirup2/1.2)
                S_fireburst(px, py, dirdown/1.2)
                S_fireburst(px, py, dirdown2/1.2)

                S_fireburst(px, py, dir/1.4)
                S_fireburst(px, py, dirup/1.4)
                S_fireburst(px, py, dirup2/1.4)
                S_fireburst(px, py, dirdown/1.4)
                S_fireburst(px, py, dirdown2/1.4)
                -- local shots = {
                --     -- Wave 1
                --     { dir = dir,       speedMod = 1 },
                --     { dir = dirup,     speedMod = 1 },
                --     { dir = dirdown,   speedMod = 1 },
                --     -- Wave 2
                --     { dir = dir/1.2,   speedMod = 1/2 },
                --     { dir = dirup/1.2, speedMod = 1/2 },
                --     { dir = dirdown/1.2, speedMod = 1/2 },
                --     -- Wave 3
                --     { dir = dir/1.4,   speedMod = 1/4 },
                --     { dir = dirup/1.4, speedMod = 1/4 },
                --     { dir = dirdown/1.4, speedMod = 1/4 }
                -- }

                -- -- Queue them up with a staggering delay gap
                -- local delayBetweenShots = 0.01 -- Change this to adjust pacing!
                -- for i, shot in ipairs(shots) do
                --     table.insert(FireBurst.queue, {
                --         x = px,
                --         y = py,
                --         -- Re-normalize the vector if you divided it, so speed math stays clean
                --         dir = shot.dir:normalized(), 
                --         timer = (i - 1) * delayBetweenShots
                --     })
                -- end

                -- reset charge animation, ready for the next cast
                self.anim = self.animate.charge
                self.animate.charge:gotoFrame(1)

                player.chargingSpell = nil
                player.state = 1
                player.isCharging = false
            end
        end
    end

    function FireBurst:update(dt)
        for i = #FireBurst.queue, 1, -1 do
            local q = FireBurst.queue[i]
            q.timer = q.timer - dt
            if q.timer <= 0 then
                S_fireburst(q.x, q.y, q.dir)
                table.remove(FireBurst.queue, i)
            end
        end
        for i = #FireBurst, 1, -1 do
            local b = FireBurst[i]
            b:update(dt)
            if b.dead then
                table.remove(FireBurst, i)
            end
        end
    end

    function FireBurst:draw()
        for _, a in ipairs(FireBurst) do
            a.animR:draw(
                self.projectile,
                a.pos.x, a.pos.y,
                a.rotation,
                2, 2,
                32,
                32
            )
        end
        for _, b in ipairs(FireBurst) do
            b.animO:draw(
                self.projectile,
                b.pos.x, b.pos.y,
                b.rotation,
                2, 2,
                32,
                32
            )
        end
        for _, c in ipairs(FireBurst) do
            c.animY:draw(
                self.projectile,
                c.pos.x, c.pos.y,
                c.rotation,
                2, 2,
                32,
                32
            )
        end
    end
    function FireBurst:drawRelease()
    end
end
return c_Fireburst