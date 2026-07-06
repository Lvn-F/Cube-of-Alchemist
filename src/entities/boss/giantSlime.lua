-- src/entities/boss/giantSlime.lua
local mathUtil = require 'src/util/math'

local function c_GiantSlime(world, map)
    local giantSlime = {
        sprite = love.graphics.newImage('assets/sprite/entities/bossSlime.png'),
        bullet = love.graphics.newImage('assets/sprite/entities/gelBullet.png'),
        animSpeed = 0.1,
        instance = nil,
        bullets = {},
        drops = {},
    }

    giantSlime.grid = anim8.newGrid(128, 128, giantSlime.sprite:getDimensions())
    giantSlime.bulletGrid = anim8.newGrid(32, 32, giantSlime.bullet:getDimensions())

    giantSlime.animate = {
        idle       = anim8.newAnimation(giantSlime.grid('1-5', 1), giantSlime.animSpeed),
        alert      = anim8.newAnimation(giantSlime.grid('1-5', 1), giantSlime.animSpeed * 0.6),
        die        = anim8.newAnimation(giantSlime.grid('1-5', 1), giantSlime.animSpeed),
    }
    giantSlime.bulletAnim = {
        charge = anim8.newAnimation(giantSlime.bulletGrid('1-7', 1), giantSlime.animSpeed),
        shot   = anim8.newAnimation(giantSlime.bulletGrid('8-8', 1), giantSlime.animSpeed),
    }

    -- ── Tunables ─────────────────────────────────────────────────────────
    local detectRadius     = 260
    local maxHP            = 60
    local enrageThreshold   = 0.25

    local summonCooldownBase = 10
    local shootCooldownBase  = 3
    local restDuration        = 2

    local summonCount    = 10
    local summonRadius   = 840

    local bulletCount    = 5
    local bulletChargeTime = 0.7   
    local bulletOrbitRadius = 500
    local bulletSpeed    = 620

    local dropCount = 10

    -- Loot 
    local gelDef = {
        name    = "Slime Gel",
        imgPath = pathImg.collectible .. "gel.png",
        desc    = "",
    }
    local gelSpriteCache = nil
    local function getGelSprite()
        if not gelSpriteCache then
            gelSpriteCache = love.graphics.newImage(gelDef.imgPath)
        end
        return gelSpriteCache
    end

    -- Spawn the boss instance 
    function giantSlime:spawnAt(x, y)
        local inst = {
            x = x, y = y,
            hp = maxHP,
            maxHp = maxHP,
            state = "idle", -- "idle" | "alert" | "dying"
            subState = nil, -- "decision" | "rest" | "enraged" (only while alert)
            dead = false,
            flashTimer = 0,
            enraged = false,

            summonCd = 0,
            shootCd  = 0,
            restTimer = 0,

            anim = giantSlime.animate.idle:clone(),
        }

        -- Stationary boss: static body, still tagged Enemy so spells/melee hit it
        inst.collider = world:newBSGRectangleCollider(x - 64, y - 64, 128, 128, 20)
        inst.collider:setCollisionClass("Enemy")
        inst.collider:setFixedRotation(true)
        inst.collider:setType('static')
        inst.collider:setObject(inst)

        function inst:hit(damageMod)
            if self.state == "dying" then return end
            if self.flashTimer <= 0 then
                self.hp = self.hp - (damageMod or 1)
            end
            self.flashTimer = 0.15

            if self.state == "idle" then
                self:enterAlert()
            end

            if not self.enraged and self.hp / self.maxHp <= enrageThreshold then
                self.enraged = true
                self.subState = "decision" -- kick out of rest immediately
                self.restTimer = 0
            end

            if self.hp <= 0 then
                self.hp = 0
                self.state = "dying"
                self.subState = nil
                self.anim = giantSlime.animate.die:clone()
                giantSlime:onDeath(self)
                self.anim.onLoop = function()
                    self.dead = true
                end
            end
        end

        function inst:enterAlert()
            self.state = "alert"
            self.subState = "decision"
            self.anim = giantSlime.animate.alert:clone()
        end

        giantSlime.instance = inst
        return inst
    end

    -- Load spawn point named "boss" from the object layer
    local objLayer = map and map.layers["objects"]
    if objLayer then
        for _, obj in ipairs(objLayer.objects) do
            if obj.name == "boss" then
                giantSlime:spawnAt(obj.x * 3, obj.y * 3)
            end
        end
    end

    -- ── Actions ──────────────────────────────────────────────────────────
    local function cooldownScale(inst)
        return inst.enraged and 0.5 or 1
    end

    function giantSlime:doSummon(inst)
        for i = 1, summonCount do
            local angle = math.random() * math.pi * 2
            local dist  = math.random() * summonRadius
            local sx = inst.x + math.cos(angle) * dist
            local sy = inst.y + math.sin(angle) * dist

            local s = slime:summon(sx, sy)
            s.state = "alert" -- summoned slimes always chase the player immediately
            s.anim = slime.animate.alert:clone()
        end
        inst.summonCd = summonCooldownBase * cooldownScale(inst)
    end

    function giantSlime:doShoot(inst)
        local targetX, targetY = player.x, player.y -- last known player location

        for i = 1, bulletCount do
            local angleOffset = (i - 1) * (math.pi * 2 / bulletCount)
            local bullet = {
                ownerX = inst.x,
                ownerY = inst.y,
                angle  = angleOffset,
                x = inst.x + math.cos(angleOffset) * bulletOrbitRadius,
                y = inst.y + math.sin(angleOffset) * bulletOrbitRadius,
                state  = "charging",
                chargeTimer = bulletChargeTime,
                targetX = targetX,
                targetY = targetY,
                speed = bulletSpeed,
                dead = false,
                anim = giantSlime.bulletAnim.charge:clone(),
            }
            table.insert(self.bullets, bullet)
        end
        inst.shootCd = shootCooldownBase * cooldownScale(inst)
    end

    -- ── Boss "brain": decision / rest / enraged sub-states ──────────────
    local function updateAlert(inst, dt)
        if inst.summonCd > 0 then inst.summonCd = inst.summonCd - dt end
        if inst.shootCd  > 0 then inst.shootCd  = inst.shootCd  - dt end

        if inst.subState == "rest" then
            inst.restTimer = inst.restTimer - dt
            if inst.restTimer <= 0 then
                inst.subState = "decision"
            end
            return
        end

        if inst.subState == "decision" or inst.subState == "enraged" then
            local canSummon = inst.summonCd <= 0
            local canShoot  = inst.shootCd  <= 0

            local action = nil
            if canSummon and canShoot then
                action = (math.random() < 0.5) and "summon" or "shoot"
            elseif canSummon then
                action = "summon"
            elseif canShoot then
                action = "shoot"
            end

            if action then
                if action == "summon" then
                    giantSlime:doSummon(inst)
                else
                    giantSlime:doShoot(inst)
                end

                if inst.enraged then
                    -- enraged bosses never rest, drop straight back to deciding
                    inst.subState = "enraged"
                else
                    inst.subState = "rest"
                    inst.restTimer = restDuration
                end
            end
        end
    end

    -- ── Bullet update ────────────────────────────────────────────────────
    local function updateBullets(dt)
        for i = #giantSlime.bullets, 1, -1 do
            local b = giantSlime.bullets[i]
            b.anim:update(dt)

            if b.state == "charging" then
                b.chargeTimer = b.chargeTimer - dt
                b.angle = b.angle + dt * 2
                b.x = b.ownerX + math.cos(b.angle) * bulletOrbitRadius
                b.y = b.ownerY + math.sin(b.angle) * bulletOrbitRadius

                if b.chargeTimer <= 0 then
                    b.state = "shot"
                    b.anim = giantSlime.bulletAnim.shot:clone()
                    local dir = vector(b.targetX - b.x, b.targetY - b.y):normalized()
                    b.dirX, b.dirY = dir.x, dir.y
                    b.collider = world:newCircleCollider(b.x, b.y, 5)
                    b.collider:setCollisionClass("enemyBullet")
                    b.collider:setFixedRotation(true)
                    b.collider:setLinearVelocity(b.dirX * b.speed, b.dirY * b.speed)
                    b.timer = 3
                end
            elseif b.state == "shot" then
                b.timer = b.timer - dt
                if b.collider then
                    b.x, b.y = b.collider:getPosition()

                    local hits = world:queryCircleArea(b.x, b.y, 6, {'Player'})
                    if #hits > 0 and player.hitTakeCd <= 0 and player.iframe == false then
                        playerStat.health = playerStat.health - 0.25
                        player.hitTakeCd = 0.5

                        local kb = vector(player.x - b.x, player.y - b.y):normalized() * 220
                        player.collider:setLinearVelocity(kb.x, kb.y)

                        b.dead = true
                    end

                    local walls = world:queryCircleArea(b.x, b.y, 6, {'Map'})
                    if #walls > 0 then
                        b.dead = true
                    end
                end
                if b.timer <= 0 then b.dead = true end
            end

            if b.dead then
                if b.collider then b.collider:destroy() end
                table.remove(giantSlime.bullets, i)
            end
        end
    end

    -- ── Death drops ──────────────────────────────────────────────────────
    function giantSlime:onDeath(inst)
        for i = 1, dropCount do
            local angle = math.random() * math.pi * 2
            local dist  = math.random() * 60
            table.insert(self.drops, {
                x = inst.x + math.cos(angle) * dist,
                y = inst.y + math.sin(angle) * dist,
                name = gelDef.name,
                imgPath = gelDef.imgPath,
                desc = gelDef.desc,
                looted = false,
                sprite = getGelSprite(),
            })
        end
    end

    function giantSlime:tryLoot(inventory)
        for _, d in ipairs(self.drops) do
            if not d.looted then
                local dist = mathUtil.distanceBetween(player.x, player.y, d.x, d.y)
                if dist < 80 then
                    local itm = item.new(d.name, d.imgPath, d.desc)
                    inventory:addItem(itm)
                    d.looted = true
                end
            end
        end
    end

    -- ── Update / Draw ───────────────────────────────────────────────────
    function giantSlime:update(dt)
        updateBullets(dt)

        local inst = self.instance
        if not inst then return end

        if inst.dead then
            if inst.collider then
                inst.collider:destroy()
                inst.collider = nil
            end
            self.instance = nil -- boss is gone; drops/bullets remain and still update/draw
            return
        end

        if inst.flashTimer > 0 then
            inst.flashTimer = inst.flashTimer - dt
            if inst.flashTimer < 0 then inst.flashTimer = 0 end
        end

        inst.anim:update(dt)

        if inst.state == "idle" then
            local d = mathUtil.distanceBetween(inst.x, inst.y, player.x, player.y)
            if d < detectRadius then
                inst:enterAlert()
            end
        elseif inst.state == "alert" then
            updateAlert(inst, dt)
        end
        -- inst.state == "dying": just let the anim play until onLoop sets inst.dead
    end

    function giantSlime:drawHealthBar(inst)
        local barW, barH = 200, 14
        local bx = inst.x - barW / 2
        local by = inst.y - 130

        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", bx - 2, by - 2, barW + 4, barH + 4, 3, 3)

        local pct = math.max(0, inst.hp / inst.maxHp)
        local fillColor = inst.enraged and {0.9, 0.15, 0.15} or {0.35, 0.8, 0.35}
        love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3], 1)
        love.graphics.rectangle("fill", bx, by, barW * pct, barH, 3, 3)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", bx, by, barW, barH, 3, 3)
    end

    function giantSlime:draw()
        local inst = self.instance
        if not inst then return end

        if inst.flashTimer > 0 then love.graphics.setShader(shaders.whiteout) end
        inst.anim:draw(self.sprite, inst.x, inst.y-32, nil, 2, 2, 64, 64)
        love.graphics.setShader()

        if inst.state == "alert" then
            self:drawHealthBar(inst)
        end

        for _, b in ipairs(self.bullets) do
            b.anim:draw(self.bullet, b.x, b.y, nil, 1.5, 1.5, 16, 16)
        end

        love.graphics.setColor(1, 1, 1, 1)
        for _, d in ipairs(self.drops) do
            if not d.looted then
                love.graphics.draw(d.sprite, d.x, d.y, nil, 2, 2, 16, 16)
                if mathUtil.distanceBetween(player.x, player.y, d.x, d.y) < 80 then
                    love.graphics.print("[F]", d.x - 10, d.y - 20, nil, 1.5)
                end
            end
        end
    end

    function giantSlime:destroy()
        if self.instance and self.instance.collider then
            self.instance.collider:destroy()
        end
        for _, b in ipairs(self.bullets) do
            if b.collider then b.collider:destroy() end
        end
        self.instance = nil
        self.bullets = {}
        self.drops = {}
    end

    return giantSlime
end

return c_GiantSlime