local function c_Slime(world, map)
    local slime = {
        sprite = love.graphics.newImage('assets/sprite/entities/slime.png'),
        animSpeed = 0.4,
        idleSpeed = 0.2,
        instances = {}
    }
    slime.grid = anim8.newGrid(32, 32, slime.sprite:getDimensions())
    slime.animate = {
        spawn = anim8.newAnimation(slime.grid('1-10', 1), slime.animSpeed, function(anim) anim.onLoop = nil end),
        idle  = anim8.newAnimation(slime.grid('11-14', 1), slime.idleSpeed),
        right = anim8.newAnimation(slime.grid('11-14', 2), slime.animSpeed),
        left  = anim8.newAnimation(slime.grid('11-14', 3), slime.animSpeed),
        alert = anim8.newAnimation(slime.grid('11-14', 1), slime.animSpeed * 0.6),
        dash = anim8.newAnimation(slime.grid('11-14', 4), slime.animSpeed),
        die   = anim8.newAnimation(slime.grid('15-20', 1), 0.1, function(anim) anim.onLoop = nil end),
        -- dash = anim8.newAnimation(slime.grid('15-15', 2), 0.1),
        shadow = anim8.newAnimation(slime.grid('15-15', 3), 0.1),
    }

    local detectRadius = 300 -- idle -> alert
    local chaseRadius = 300 -- above this (but within detect), chase
    local dashRadius = 150 -- below this, dash instead of chase
    local loseRadius = 300 -- beyond this while alert, go back to idle
    local wanderRadius = 60
    local wanderSpeed = 90
    local chaseSpeed = 120
    local dashSpeed = 550
    local dashWindup = 0.45  -- pause before dashing
    local dashDuration = 0.4
    local dashCooldown = 1.4
    local maxHP = 3

    -- Spawn a single slime instance
    -- Used both for map-placed slimes and for boss-summoned slimes.
    function slime:spawnAt(x, y)
        local inst = {
            x = x, y = y,
            startX = x, startY = y,
            hp = maxHP,
            state = "spawning", -- "spawning" | "idle" | "alert" | "dying"
            dead = false,
            scaleX = 1,
            flashTimer = 0,

            wanderDir = vector(0, 0),
            wanderTimer = 0.5 + math.random() * 1.5,

            dashState = "none", -- "none" | "windup" | "dashing" | "cooldown"
            dashTimer = 0,
            dashDir = vector(1, 0),

            hitCd = 0,

            anim = slime.animate.spawn:clone(),
        }

        inst.collider = world:newBSGRectangleCollider(x - 10, y - 10, 20, 20, 4)
        inst.collider:setCollisionClass("Enemy")
        inst.collider:setFixedRotation(true)
        inst.collider:setObject(inst) -- lets queryCircleArea hits resolve back here

        inst.anim.onLoop = function()
            inst.state = "idle"
            inst.anim = slime.animate.idle:clone()
        end

        function inst:hit()
            if self.state == "dying" then return end
            self.hp = self.hp - 1
            self.flashTimer = 0.15
            self.state = "alert" -- getting hit always alerts the slime

            if self.hp <= 0 then
                self.state = "dying"
                self.anim = slime.animate.die:clone()
                self.anim.onLoop = function()
                    self.dead = true
                end
            end
        end

        table.insert(slime.instances, inst)
        return inst
    end

    -- Boss-facing API: summon a slime with the spawn animation playing.
    function slime:summon(x, y)
        return self:spawnAt(x, y)
    end

    -- Load spawn points named "slime"
    local objLayer = map and map.layers["objects"]
    if objLayer then
        for _, obj in ipairs(objLayer.objects) do
            if obj.name == "slime" then
                local inst = slime:spawnAt(obj.x * 3, obj.y * 3)
                inst.state = "idle"
                inst.anim = slime.animate.idle:clone()
            end
        end
    end

    -- Per-instance behaviour
    local function faceTowards(inst, dx)
        if dx ~= 0 then
            inst.scaleX = dx > 0 and 1 or -1
        end
    end
    local mathUtil = require 'src/util/math'
    local function wander(inst, dt)
        inst.wanderTimer = inst.wanderTimer - dt
        if inst.wanderTimer <= 0 then
            inst.wanderTimer = 0.5 + math.random() * 1.5
            inst.wanderDir = vector(math.random(-1, 1), math.random(-1, 1))
        end

        if inst.wanderDir.x ~= 0 or inst.wanderDir.y ~= 0 then
            local dir = inst.wanderDir:normalized()
            local vx, vy = dir.x * wanderSpeed, dir.y * wanderSpeed
            inst.collider:setLinearVelocity(vx, vy)
            faceTowards(inst, dir.x)
        else
            inst.collider:setLinearVelocity(0, 0)
        end

        -- keep within wander radius of spawn point
        if mathUtil.distanceBetween(inst.x, inst.y, inst.startX, inst.startY) > wanderRadius then
            local back = vector(inst.startX - inst.x, inst.startY - inst.y):normalized()
            inst.collider:setLinearVelocity(back.x * wanderSpeed, back.y * wanderSpeed)
            faceTowards(inst, back.x)
        end
    end

    local function tryDetectPlayer(inst)
        local d = mathUtil.distanceBetween(inst.x, inst.y, player.x, player.y)
        if d < detectRadius then
            inst.state = "alert"
            inst.anim = slime.animate.alert:clone()
        end
    end

    local function alertBehaviour(inst, dt)
        local dx, dy = player.x - inst.x, player.y - inst.y
        local d = math.sqrt(dx*dx + dy*dy)

        if d > loseRadius then
            inst.state = "idle"
            inst.anim = slime.animate.idle:clone()
            inst.dashState = "none"
            return
        end

        if inst.dashState == "windup" then
            inst.collider:setLinearVelocity(0, 0)
            inst.dashTimer = inst.dashTimer - dt
            if inst.dashTimer <= 0 then
                inst.dashState = "dashing"
                inst.dashTimer = dashDuration
                inst.dashDir = vector(dx, dy):normalized()
            end
            return
        elseif inst.dashState == "dashing" then
            inst.collider:setLinearVelocity(inst.dashDir.x * dashSpeed, inst.dashDir.y * dashSpeed)
            faceTowards(inst, inst.dashDir.x)
            inst.dashTimer = inst.dashTimer - dt
            slime.anim = slime.animate.left
            if inst.dashTimer <= 0 then
                inst.dashState = "cooldown"
                inst.dashTimer = dashCooldown
                inst.collider:setLinearVelocity(0, 0)
                inst.anim = slime.animate.alert:clone()
            end
            return
        elseif inst.dashState == "cooldown" then
            inst.dashTimer = inst.dashTimer - dt
            inst.collider:setLinearVelocity(0, 0)
            if inst.dashTimer <= 0 then
                inst.dashState = "none"
            end
            return
        end

        -- dashState == "none": decide chase vs dash windup based on range
        if d > chaseRadius then
            local dir = vector(dx, dy):normalized()
            inst.collider:setLinearVelocity(dir.x * chaseSpeed, dir.y * chaseSpeed)
            faceTowards(inst, dir.x)
        elseif d <= dashRadius then
            inst.dashState = "windup"
            inst.dashTimer = dashWindup
            inst.collider:setLinearVelocity(0, 0)
            inst.anim = slime.animate.dash:clone() -- play dash anim starting at windup
            inst.anim:pauseAtStart()
        else
            -- mid range but not yet in dash trigger distance: close in slowly
            local dir = vector(dx, dy):normalized()
            inst.collider:setLinearVelocity(dir.x * (chaseSpeed * 0.6), dir.y * (chaseSpeed * 0.6))
            faceTowards(inst, dir.x)
        end
    end

    function slime:update(dt)
        for i = #self.instances, 1, -1 do
            local inst = self.instances[i]
            if inst.dead then
                if inst.collider then inst.collider:destroy() end
                table.remove(self.instances, i)
                goto continue
            end
            if inst.flashTimer > 0 then
                inst.flashTimer = inst.flashTimer - dt
                if inst.flashTimer < 0 then inst.flashTimer = 0 end
            end

            inst.anim:update(dt)

            if inst.state == "spawning" then
                inst.collider:setLinearVelocity(0, 0)
            elseif inst.state == "idle" then
                wander(inst, dt)
                tryDetectPlayer(inst)
            elseif inst.state == "alert" then
                alertBehaviour(inst, dt)
            elseif inst.state == "dying" then
                inst.collider:setLinearVelocity(0, 0)
            end

            if inst.collider then
                inst.x, inst.y = inst.collider:getPosition()
            end

            ::continue::
        end
    end

    function slime:draw()
        for _, inst in ipairs(self.instances) do
            if inst.flashTimer > 0 then
                love.graphics.setShader(shaders.whiteout)
            end
            
            inst.anim:draw(self.sprite, inst.x, inst.y, nil, 2 * inst.scaleX, 2, 16, 16)
            love.graphics.setShader()
        end
    end

    function slime:destroy()
        for _, inst in ipairs(self.instances) do
            if inst.collider then inst.collider:destroy() end
        end
        self.instances = {}
    end

    return slime
end
return c_Slime