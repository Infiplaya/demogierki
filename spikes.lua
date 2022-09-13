local Spike = {img = love.graphics.newImage("assets/spikes.png")}
Spike.__index = Spike
Spike.width = Spike.img:getWidth()
Spike.height = Spike.img:getHeight()

local ActiveSpikes = {}
local Player = require("player")

function Spike.new(x,y)
    local instance = setmetatable({}, Spike)
    instance.x = x
    instance.y = y
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.damage = 1
    instance.scale = 1.5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveSpikes, instance)
end


function Spike:update(dt)
    
end

function Spike:removeAll()
    for i,instance in ipairs(ActiveSpikes) do
        instance.physics.body:destroy()
    end
    ActiveSpikes = {}
end


function Spike:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale, self.width / 2, self.height)
end

function Spike.updateAll()
    for i,instance in ipairs(ActiveSpikes) do
        instance:update(dt)
    end

end

function Spike.drawAll()
    for i,instance in ipairs(ActiveSpikes) do
        instance:draw()
    end

end

function Spike.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveSpikes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
                return true
            end
        end
    end
end

return Spike