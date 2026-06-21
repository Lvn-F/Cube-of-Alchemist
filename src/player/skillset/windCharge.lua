local function c_windcharge(world)
    local Vector = require 'lib/hump/vector'
    local Camera = require 'lib/hump/camera'
    
    WindCharges = {
        projectile = love.graphics.newImage(pathImg.skill .. 'windCharge.png')
    }
    WindCharges.grid = anim8.newGrid(32, 32, WindCharges.projectile:getDimensions())
    WindCharges.animate = {
        spawn = anim8.newAnimation(WindCharges.grid('5-8', 1), 0.05),
        release = anim8.newAnimation(WindCharges.grid('5-8', 1), 0.05)
    }
    WindCharges.anim = WindCharges.animate.spawn
    
    local function toMouseVector(px, py)
        local mx, my = love.mouse.getPosition()
        local wx, wy = cam:worldCoords(mx, my)
        return Vector(wx - px, wy - py):normalized()
    end

    function S_windcharge(x, y)
        local dir = toMouseVector(x, y)

        local windcharge = {
            x = x,
            y = y,
            pos = Vector(x, y),
            timer = 4,
            dead = false,
            dir = dir,
            rotation = dir:angleTo(Vector(1, 0)),
            rad = 3,
            speed = 700 + player.chargeTime * 500
        }
        windcharge.collider = world:newBSGRectangleCollider(x - 64/2, y - 64/2, 32, 32, 16)
        windcharge.collider:setCollisionClass("Projectile")
        windcharge.collider:setLinearVelocity(dir.x * windcharge.speed, dir.y * windcharge.speed)
        
        function windcharge:update(dt)
            self.timer = self.timer - dt
            if self.timer < 0 then
                self.dead = true
                self.collider:destroy()
                return
            end
            if self.speed < self.speed then
                self.dead = true
                self.collider:destroy()
            end
            self.pos = self.pos + self.dir * self.speed * dt
            self.pos.x, self.pos.y = self.collider:getPosition()
        end
        table.insert(WindCharges, windcharge)
    end

function WindCharges:startCharge()
    if player.spell == 3 then
        player.state = 2
        player.chargeTime = 0
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
                if dir.x >= 0 then
                    player.facing = "right"
                    player.anim = player.animate.right
                else
                    player.facing = "left"
                    player.anim = player.animate.left
                end
            end
        end
    end
    function WindCharges:endCharge()
        if player.spell == 3 then
            if player.state == 2 and player.chargingSpell then
                -- self.speed = 500
                local px, py = player.x, player.y
                S_windcharge(px, py)
                player.chargingSpell = nil
                player.state = 1
                player.isCharging = false
            end
        end
    end


    function WindCharges:update(dt)
        self.anim = WindCharges.animate.spawn
        self.anim:update(dt)
        for i = #WindCharges, 1, -1 do
            local b = WindCharges[i]
            b:update(dt)
            if b.dead then
                table.remove(WindCharges, i)
            end
        end
        
    end

    function WindCharges:draw()
        for _,a in ipairs(WindCharges) do
            self.anim:draw(self.projectile, a.pos.x, a.pos.y, a.rotation, 1.5, 1.5, self.projectile:getWidth()/13, self.projectile:getHeight()/2)
            if self.animate.spawn.position == 4 then
                self.anim = self.animate.release
                self.anim:draw(self.projectile, a.pos.x, a.pos.y, a.rotation, 1.5, 1.5, self.projectile:getWidth()/13, self.projectile:getHeight()/2)
            end
        end
    end
end
return c_windcharge