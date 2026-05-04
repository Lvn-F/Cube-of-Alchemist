local function c_Shadowball(world)
    local Vector = require 'lib/hump/vector'
    local Camera = require 'lib/hump/camera'
    
    Shadowballs = {
        -- speed = 100,
        -- core = love.graphics.newImage('assets/sprite/player/skill/shadowball.png'),
        -- outline = love.graphics.newImage('assets/sprite/player/skill/shadowball_base.png'),
        projectile = love.graphics.newImage('assets/sprite/player/skill/Shadowballs.png')
        -- collider = world:newBSGRectangleCollider(400, 400, 40, 40, 5)
    }
    Shadowballs.grid = anim8.newGrid(64, 64, Shadowballs.projectile:getWidth(), Shadowballs.projectile:getHeight())
    Shadowballs.animate = {
        spawn = anim8.newAnimation(Shadowballs.grid('1-6', 1), 0.15)
    }
    Shadowballs.anim = Shadowballs.animate.spawn
    
    function toMouseVector(px, py)
            local mx, my = love.mouse.getPosition()
            local wx, wy = cam:worldCoords(mx, my)
            return Vector(wx - px, wy - py):normalized()

        -- local mx, my = love.mouse.getPosition()
        -- local dx, dy = mx - px, my - py
        -- local len = math.sqrt(dx*dx + dy*dy)
        -- if len == 0 then len = 1 end
        -- return { x = dx / len, y = dy / len }
    end

    function S_shadowball(x, y)
        -- require 'gatau/collisionClasses'
        local dir = toMouseVector(x, y)
        -- local len = math.sqrt(direction.x^2 + direction.y^2)
        -- if len == 0 then 
        --     len = 1
        -- end
        -- direction.x, direction.y = direction.x / len, direction.y / len

        local shadowball = {
            x = x,
            y = y,
            pos = Vector(x, y),
            timer = 4,
            dead = false,
            dir = dir,
            -- dirVec = direction,
            rotation = dir:angleTo(Vector(1, 0)),
            rad = 3,
            speed = 400 + player.chargeTime * 500
        }
        -- local sx, sy = shadowball.pos.x, shadowball.pos.y
        shadowball.collider = world:newBSGRectangleCollider(x - 64/2, y - 64/2, 64, 64, 16)
        shadowball.collider:setCollisionClass("Projectile")
        -- shadowball.collider:setObject(Projectile)
        shadowball.collider:setLinearVelocity(dir.x + shadowball.speed, dir.y + shadowball.speed)
        
        function shadowball:update(dt)
            self.timer = self.timer - dt
            if self.timer < 0 then
                self.dead = true
                self.collider:destroy()
                return
            end
            -- self.x = self.x + self.dir.x * self.speed * dt
            -- self.y = self.y + self.dir.y * self.speed * dt
            self.pos = self.pos + self.dir * self.speed * dt
            shadowball.collider:setPosition(self.pos.x, self.pos.y)
            -- self.pos.x, self.pos.y = self.collider:getPosition()
        end
        table.insert(Shadowballs, shadowball)
    end

    function Shadowballs:update(dt)
        self.anim = Shadowballs.animate.spawn
        self.anim:update(dt)
        for i = #Shadowballs, 1, -1 do
            local b = Shadowballs[i]
            b:update(dt)
            if b.dead then
                table.remove(Shadowballs, i)
                -- shadowball.collider:destroy()
            end
        end
        
        -- for _,b in ipairs(Shadowballs) do
        --     b:update(dt)
        -- end
        -- local i = #Shadowballs
        -- while i > 1 do
        --     if Shadowball[i].dead then
        --         table.remove(Shadowballs, i)
        --     end
        --     i = i - 1
        -- end
    end

    function Shadowballs:draw()
        for _,a in ipairs(Shadowballs) do
            -- if (layer == -1 and a.y < player:getY() or (layer == 1 and a.y >= player:getY())) then
            -- love.graphics.draw(self.outline, a.pos.x, a.pos.y, a.rotation, 2, 2, self.outline:getWidth()/2, self.outline:getHeight()/2)
            -- love.graphics.draw(self.core, a.pos.x, a.pos.y, a.rotation, 2, 2, self.outline:getWidth()/2, self.outline:getHeight()/2)
            self.anim:draw(self.projectile, a.pos.x, a.pos.y, a.rotation, 1.5, 1.5, self.projectile:getWidth()/13, self.projectile:getHeight()/2)
            -- end
        end
    end




    -- local Shadowballs = {}
    -- Shadowballs._index = Shadowballs

    -- function Shadowballs.new(world, x, y, dirX, dirY, power)
    --     local self = setmetatable({}, Shadowballs)
    --     local len = math.sqrt(dirX*dirX + dirY*dirY)
    --     dirX, dirY = dirX/len, dirY/len
        
    --     self.collider = world:newCircleCollider(x, y, 5)
    --     self.collider:setCollisionClass("Projectile")
    --     self.collider:setLinearVelocity(dirX * 400 * power, dirY * 400 * power)
    --     return self
    -- end

    -- function Shadowballs:update(dt)
    --     local vx, vy = self.collider:getLinearVelocity()
    --     if math.abs(vx) < 1 and math.abs(vy) < 1 then
    --         self.collider:destroy()
    --         return false
    --     end
    --     return true
    -- end

    -- function Shadowballs:draw()
    --     love.graphics.circle("fill", self.collider:getX(), self.collider:getY(), 5)
    -- end

    -- function Shadowballs(x, y, angle)
    --     Shadowballs = {
    --         speed = 100,
    --         core = love.graphics.newImage('assets/sprite/player/skill/shadowball.png')
    --     }
    --     return {
    --         x = x,
    --         y = y,
    --         draw = function (self)
                
    --             love.graphics.draw(Shadowball.core, self.x, self.y)
    --         end
    --     }
    -- end
end
return c_Shadowball