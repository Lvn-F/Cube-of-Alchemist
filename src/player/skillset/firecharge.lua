local function c_Firecharge(world)
    local Vector = require 'lib/hump/vector'
    local Camera = require 'lib/hump/camera'

    Firecharges = {
        projectile = love.graphics.newImage(pathImg.skill .. 'firecharge.png'),
        animSpeed = 0.1,
    }
    Firecharges.grid = anim8.newGrid(32, 32, Firecharges.projectile:getDimensions())
    Firecharges.animate = {
        charge     = anim8.newAnimation(Firecharges.grid('1-7', 1),   Firecharges.animSpeed),
        chargeFull = anim8.newAnimation(Firecharges.grid('8-12', 1),  Firecharges.animSpeed),
        release    = anim8.newAnimation(Firecharges.grid('13-15', 1), 0.08),
        burst      = anim8.newAnimation(Firecharges.grid('16-23', 1), 0.07)
    }
    Firecharges.anim = Firecharges.animate.charge

    local function toMouseVector(px, py)
        local mx, my = love.mouse.getPosition()
        local wx, wy = cam:worldCoords(mx, my)
        return Vector(wx - px, wy - py):normalized()
    end

    -- Spawns the projectile that flies out once the player releases the cast.
    -- `dir` is the direction the player was facing/aiming at release time.
    function S_firecharge(x, y, dir)
        local firecharge = {
            x = x,
            y = y,
            pos = Vector(x, y),
            timer = 4,
            dead = false,
            bursting = false,
            dir = dir,
            rotation = dir:angleTo(Vector(1, 0)),
            rad = 3,
            speed = 450 + player.chargeTime * 500,
            anim = Firecharges.animate.release:clone(),
        }
        firecharge.collider = world:newBSGRectangleCollider(x - 32/2, y - 32/2, 32, 32, 16)
        firecharge.collider:setCollisionClass("Projectile")
        firecharge.collider:setLinearVelocity(dir.x * firecharge.speed, dir.y * firecharge.speed)

        -- Switches the projectile into its one-shot burst animation,
        -- freezes it in place, and removes its collider so it can't
        -- re-trigger more hits while the burst plays out.
        function firecharge:playBurst()
            if self.bursting then return end
            self.bursting = true

            self.collider:setLinearVelocity(0, 0)
            self.collider:destroy()
            self.collider = nil

            self.anim = Firecharges.animate.burst:clone()
            -- onLoop fires once the (non-repeating-in-practice) animation
            -- wraps back to frame 1 -- that's our "burst finished" signal.
            self.anim.onLoop = function()
                self.dead = true
            end
        end

        function firecharge:update(dt)
            self.anim:update(dt)

            if self.bursting then
                -- nothing else to do while the burst plays; self.dead is
                -- set by the onLoop callback above once it completes
                return
            end

            self.timer = self.timer - dt
            if self.timer < 0 then
                self.dead = true
                self.collider:destroy()
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

        table.insert(Firecharges, firecharge)
    end

    function Firecharges:startCharge()
        if player.spell == 4 then
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

    function Firecharges:charge(dt)
        if player.spell == 4 then
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
                    if self.animate.charge.position >= 7 then
                        self.anim = self.animate.chargeFull
                    end
                else
                    self.anim:update(dt)
                end

                if dir.x >= 0 then
                    player.facing = "right"
                    player.anim = player.animate.right
                    player.chargingSpell.pos.x = player.x - 8
                else
                    player.facing = "left"
                    player.anim = player.animate.left
                    player.chargingSpell.pos.x = player.x - 32
                end
            end
        end
    end

    function Firecharges:endCharge()
        if player.spell == 4 then
            if player.state == 2 and player.chargingSpell then
                if player.chargeTime <= 0.7 then
                    player.isCharging = false
                    player.state = 1
                    return
                end
                local px, py = player.x, player.y
                local dir = toMouseVector(px, py)

                S_firecharge(px, py, dir)

                -- reset charge animation, ready for the next cast
                self.anim = self.animate.charge
                self.animate.charge:gotoFrame(1)

                player.chargingSpell = nil
                player.state = 1
                player.isCharging = false
            end
        end
    end

    function Firecharges:update(dt)
        for i = #Firecharges, 1, -1 do
            local b = Firecharges[i]
            b:update(dt)
            if b.dead then
                table.remove(Firecharges, i)
            end
        end
    end

    function Firecharges:draw()
        for _, a in ipairs(Firecharges) do
            a.anim:draw(
                self.projectile,
                a.pos.x, a.pos.y,
                a.rotation,
                2, 2,
                self.projectile:getWidth() / 13,
                self.projectile:getHeight() / 2
            )
        end
    end
end
return c_Firecharge