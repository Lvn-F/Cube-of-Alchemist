-- src/levels/screenWipe.lua
local ScreenWipe = {}

-- state: "idle", "closing", "opening"
ScreenWipe.state  = "idle"
ScreenWipe.x      = -love.graphics.getWidth()   -- current X of the black panel
ScreenWipe.onMid  = nil   -- callback fired when screen is fully covered

local W, H
local DURATION = 0.25   -- seconds for each half (close / open)
local timer    = 0

function ScreenWipe:start(onMidpoint)
    W = love.graphics.getWidth()
    H = love.graphics.getHeight()
    self.state  = "closing"
    self.x      = -W          -- start off-screen left
    self.onMid  = onMidpoint
    timer       = 0
end

function ScreenWipe:update(dt)
    if self.state == "idle" then return end

    timer = timer + dt

    if self.state == "closing" then
        -- slide in from left to cover the screen
        local t = math.min(timer / DURATION, 1)
        self.x = -W + t * W          -- -W → 0
        if t >= 1 then
            -- screen fully covered — do the map swap now
            if self.onMid then self.onMid() end
            self.state = "opening"
            timer      = 0
        end

    elseif self.state == "opening" then
        -- slide out to the right
        local t = math.min(timer / DURATION, 1)
        self.x = t * W               -- 0 → W
        if t >= 1 then
            self.state = "idle"
        end
    end
end

function ScreenWipe:draw()
    if self.state == "idle" then return end
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.x, 0, W*1.5, H)
    love.graphics.setColor(1, 1, 1, 1)
end

return ScreenWipe