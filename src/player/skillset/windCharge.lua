local function c_windcharge(world)
    local Vector = require 'lib/hump/vector'
    local Camera = require 'lib/hump/camera'
    
    WindCharges = {
        projectile = love.graphics.newImage(pathImg.skill .. 'windCharge.png'),
        animSpeed = 0.1
    }
    WindCharges.grid = anim8.newGrid(32, 32, WindCharges.projectile:getDimensions())
    WindCharges.animate = {
        charge = anim8.newAnimation(WindCharges.grid('1-5', 1), WindCharges.animSpeed),
        chargeFull = anim8.newAnimation(WindCharges.grid('6-9', 1), WindCharges.animSpeed),
        release = anim8.newAnimation(WindCharges.grid('10-12', 1), 0.05),
        burst = anim8.newAnimation(WindCharges.grid('13-17', 1), 0.05),
    }
    WindCharges.anim = WindCharges.animate.charge
    
    local function toMouseVector(px, py)
        local mx, my = love.mouse.getPosition()
        local wx, wy = cam:worldCoords(mx, my)
        return Vector(wx - px, wy - py):normalized()
    end

    function S_windcharge(x, y, dir)
        local windcharge = {
            x = x,
            y = y,
            pos = Vector(x, y),
            timer = 4,
            dead = false,
            bursting = false,
            dir = dir,
            rotation = dir:angleTo(Vector(1, 0)),
            rad = 3,
            speed = 700 + player.chargeTime * 500,
            anim = WindCharges.animate.release:clone()
        }
        windcharge.collider = world:newBSGRectangleCollider(x - 32/2, y - 32/2, 32, 32, 16)
        windcharge.collider:setCollisionClass("Projectile")
        windcharge.collider:setLinearVelocity(dir.x * windcharge.speed, dir.y * windcharge.speed)
        
        function windcharge:playBurst()
            if self.bursting then
                return
            end
            self.bursting = true
            self.collider:setLinearVelocity(0, 0)
            self.collider:destroy()
            self.collider = nil

            self.anim = WindCharges.animate.burst:clone()
            self.anim.onLoop = function()
                self.dead = true
            end
        end

        function windcharge:update(dt)
            self.anim:update(dt)
            if self.bursting then
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
                if obj and obj.hit then
                    obj:hit()
                end
            end
            if #hits > 0 then
                self:playBurst()  
            end
            -- self.pos = self.pos + self.dir * self.speed * dt
        end
        table.insert(WindCharges, windcharge)
    end

    function WindCharges:startCharge()
        if player.spell == 3 then
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

    function WindCharges:charge(dt)
        if player.spell == 3 then
            if player.state == 2 and player.chargingSpell then
                player.speed = 250
                player.chargeTime = math.min(player.chargeTime + dt, 1)
                player.chargingSpell.pos = Vector(player.x , player.y)
                player.chargingSpell.scale = 1 + player.chargeTime * 0.3
                local dir = toMouseVector(player.x, player.y)
                player.chargingSpell.rotation = dir:angleTo(Vector(1,0))
                -- self.anim = self.animate.spawn
                -- self.anim:update(dt)

                if self.anim == self.animate.charge then
                    self.anim:update(dt)
                    if self.animate.charge.position >= 5 then
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
    function WindCharges:endCharge()
        if player.spell == 3 then
            if player.state == 2 and player.chargingSpell then
                if self.anim ~= self.animate.chargeFull then
                    player.isCharging = false
                    player.state = 1
                    return
                end
                local px, py = player.x, player.y
                local dir = toMouseVector(px, py)
                -- self.speed = 500
                self.anim = self.animate.charge
                self.animate.charge:gotoFrame(1)

                S_windcharge(px, py, dir)
                player.chargingSpell = nil
                player.state = 1
                player.isCharging = false
                player.spellCooldown = 0.3
            end
        end
    end


    function WindCharges:update(dt)
        -- self.anim = WindCharges.animate.spawn
        -- self.anim:update(dt)
        for i = #WindCharges, 1, -1 do
            local b = WindCharges[i]
            b:update(dt)
            if b.dead then
                table.remove(WindCharges, i)
            end
        end
        
    end

    function WindCharges:draw()
        for _, a in ipairs(WindCharges) do
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
return c_windcharge