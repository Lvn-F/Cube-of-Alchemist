local function c_Shadowball(world)
    local Vector = require 'lib/hump/vector'
    local Camera = require 'lib/hump/camera'
    
    Shadowballs = {
        projectile = love.graphics.newImage(pathImg.skill .. 'Shadowballs.png')
    }
    Shadowballs.grid = anim8.newGrid(64, 64, Shadowballs.projectile:getDimensions())
    Shadowballs.animate = {
        spawn = anim8.newAnimation(Shadowballs.grid('1-6', 1), 0.15)
    }
    Shadowballs.anim = Shadowballs.animate.spawn
    
    local function toMouseVector(px, py)
        local mx, my = love.mouse.getPosition()
        local wx, wy = cam:worldCoords(mx, my)
        return Vector(wx - px, wy - py):normalized()
    end

    function S_shadowball(x, y)
        local dir = toMouseVector(x, y)

        local shadowball = {
            x = x,
            y = y,
            pos = Vector(x, y),
            timer = 4,
            dead = false,
            dir = dir,
            rotation = dir:angleTo(Vector(1, 0)),
            rad = 3,
            speed = 400 + player.chargeTime * 500
        }
        shadowball.collider = world:newBSGRectangleCollider(x - 64/2, y - 64/2, 64, 64, 16)
        shadowball.collider:setCollisionClass("Projectile")
        shadowball.collider:setLinearVelocity(dir.x * shadowball.speed, dir.y * shadowball.speed)
        
        function shadowball:update(dt)
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
        table.insert(Shadowballs, shadowball)
    end

function Shadowballs:startCharge()
    if player.spell == 1 then
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
    function Shadowballs:charge(dt)
        if player.spell == 1 then
            if player.state == 2 and player.chargingSpell then
                player.speed = 250
                player.chargeTime = math.min(player.chargeTime + dt, 1)
                player.chargingSpell.pos = Vector(player.x , player.y)
                player.chargingSpell.scale = 1 + player.chargeTime * 0.3
                local dir = toMouseVector(player.x, player.y)
                player.chargingSpell.rotation = dir:angleTo(Vector(1,0))
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
    function Shadowballs:endCharge()
        if player.spell == 1 then
            if player.state == 2 and player.chargingSpell then
                -- self.speed = 500
                local px, py = player.x, player.y
                S_shadowball(px, py)
                player.chargingSpell = nil
                player.state = 1
                player.isCharging = false
            end
        end
    end


    function Shadowballs:update(dt)
        self.anim = Shadowballs.animate.spawn
        self.anim:update(dt)
        for i = #Shadowballs, 1, -1 do
            local b = Shadowballs[i]
            b:update(dt)
            if b.dead then
                table.remove(Shadowballs, i)
            end
        end
    end

    function Shadowballs:draw()
        for _,a in ipairs(Shadowballs) do
            self.anim:draw(self.projectile, a.pos.x, a.pos.y, a.rotation, 1.5, 1.5, self.projectile:getWidth()/13, self.projectile:getHeight()/2)
        end
    end
end
return c_Shadowball