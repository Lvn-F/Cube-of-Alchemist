local function c_LightningStrike(world)
    local Vector = require 'lib/hump/vector'

    LightningStrike = {
        markSprite   = love.graphics.newImage(pathImg.skill .. 'lightningMark.png'),
        strikeSprite = love.graphics.newImage(pathImg.skill .. 'lightningStrike.png'),
        animSpeed    = 0.08,

        active       = false,   
        timer        = 0,
        focusDuration = 0.5,    
        markRadius   = 250,     -- detection radius around the player

        cooldownDuration = 0.8, -- seconds you must wait after a strike ends
        cooldownTimer    = 0,   -- counts down to 0; spell usable when <= 0

        marked       = {},      -- { {obj=enemyObj, markAnim=anim8instance}, ... }
        strikes      = {},      

        strikeImpactFrame = 5,
        strikeRadius      = 22,
        dropHeight        = 48,
    }

    LightningStrike.markGrid   = anim8.newGrid(32, 32, LightningStrike.markSprite:getDimensions())
    LightningStrike.strikeGrid = anim8.newGrid(32, 64, LightningStrike.strikeSprite:getDimensions())

    LightningStrike.animate = {
        mark   = anim8.newAnimation(LightningStrike.markGrid('1-4', 1), LightningStrike.animSpeed),
        strike = anim8.newAnimation(LightningStrike.strikeGrid('1-6', 1), 0.05),
    }


    function LightningStrike:focusStart()
        if player.spell ~= 12 then return end
        if self.active then
            return
        end
        if self.cooldownTimer > 0 then
            return 
        end

        self.active = true
        self.timer  = self.focusDuration
        self.marked = {}

        player.state = 4
        
    end

    -- Returns true if `obj` is already marked, to avoid double-marking.
    local function isMarked(self, obj)
        for _, m in ipairs(self.marked) do
            if m.obj == obj then return true end
        end
        return false
    end

    function LightningStrike:focus(dt)
        if not self.active then return end

        -- keep player locked in place / animation locked while focusing
        player.state = 4
        player.anim  = player.animate.focus
        player.collider:setLinearVelocity(0, 0)

        self.timer = self.timer - dt

        local hits = world:queryCircleArea(player.x, player.y, self.markRadius, {'Enemy'})
        for _, h in ipairs(hits) do
            local obj = h:getObject()
            if obj and not isMarked(self, obj) then
                table.insert(self.marked, {
                    obj     = obj,
                    markAnim = self.animate.mark:clone(),
                })
            end
        end

        -- keep mark animations playing on every currently-marked enemy
        for _, m in ipairs(self.marked) do
            m.markAnim:update(dt)
        end

        if self.timer <= 0 then
            self.active = false
            self:focusRelease()
        end
    end

    -- Spawns a falling-strike visual+hitbox for one marked enemy.
    -- NOTE: entities in this project (slime, dummy, wolf) store their
    -- windfield collider as `.collider`, not `.physics` (that field name
    -- belongs to the older src/enemies/* system). Support both just in case.
    function LightningStrike:spawnStrikeFor(obj)
        local body = obj and (obj.collider or obj.physics)
        if not body then return end

        local tx, ty = body:getX(), body:getY()

        local strike = {
            targetX = tx,
            targetY = ty,
            dead    = false,
            spawned = false, -- whether the hit/collider has landed yet
            anim    = self.animate.strike:clone(),
        }

        strike.anim.onLoop = function()
            strike.dead = true
        end
        dj.play(sound.struct, "stream")
        table.insert(self.strikes, strike)
    end

    function LightningStrike:focusRelease()
        for _, m in ipairs(self.marked) do
            self:spawnStrikeFor(m.obj)
            
        end
        self.marked = {}

        self.cooldownTimer = self.cooldownDuration
        player.state = 1
        -- if player.facing == "right" then
        --     player.anim = player.animate.right
        -- elseif player.facing == "left" then
        --     player.anim = player.animate.left
        -- elseif player.facing == "up" then
        --     player.anim = player.animate.up
        -- else
        --     player.anim = player.animate.down
        -- end
        player.anim = player.animate.down
        player.anim:gotoFrame(1)
    end

    function LightningStrike:drawArea()
        love.graphics.setColor(1, 1, 0, 0.35)
        -- love.graphics.circle('fill', player.x, player.y, lightningStrike.markRadius)
        love.graphics.circle('fill', player.x, player.y, 50)
        love.graphics.setColor(1, 1, 1, 1)
    end
    function LightningStrike:drawAreaDebug()
        love.graphics.setColor(1, 1, 0, 0.35)
        love.graphics.circle('fill', player.x, player.y, lightningStrike.markRadius)
        -- love.graphics.circle('fill', player.x, player.y, 50)
        love.graphics.setColor(1, 1, 1, 1)
    end
    function LightningStrike:update(dt)
        if self.cooldownTimer > 0 then
            self.cooldownTimer = self.cooldownTimer - dt
            if self.cooldownTimer < 0 then self.cooldownTimer = 0 end
        end

        if self.active then
            self:focus(dt)
        end

        for i = #self.strikes, 1, -1 do
            local s = self.strikes[i]
            s.anim:update(dt)

            if not s.spawned and s.anim.position >= self.strikeImpactFrame then
                s.spawned = true
                
                local hits = world:queryCircleArea(s.targetX, s.targetY, self.strikeRadius, {'Enemy'})
                for _, h in ipairs(hits) do
                    local o = h:getObject()
                    if o and o.hit then
                        o:hit(damageMod[12] or 2)
                    end
                end
            end

            if s.dead then
                table.remove(self.strikes, i)
            end
        end
    end

    function LightningStrike:draw()
        -- Marks hover above each currently-marked enemy's head
        for _, m in ipairs(self.marked) do
            local body = m.obj and (m.obj.collider or m.obj.physics)
            if body then
                local ex, ey = body:getX(), body:getY()
                m.markAnim:draw(self.markSprite, ex, ey , nil, 1.5, 1.5, 16, 16)
            end
        end

        for _, s in ipairs(self.strikes) do
            s.anim:draw(
                self.strikeSprite,
                s.targetX, s.targetY - self.dropHeight,
                nil, 1.5, 1.5,
                16, 32
            )
        end
    end
    
    return LightningStrike
end
return c_LightningStrike