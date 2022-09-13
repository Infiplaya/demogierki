local Map = {}
local STI = require("sti")
local Enemy = require("enemy")
local Heart = require("heart")
local Spike = require("spikes")
local Player = require("player")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0,0)
    World:setCallbacks(beginContact, endContact)

    self:init()
end

function Map:init()
    self.level = STI("map/"..self.currentLevel..".lua", {"box2d"})
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
    
    self.solidLayer.visible = false
    self.entityLayer.visible = false
    MapWidth = self.groundLayer.width * 16
    MapHeight = self.groundLayer.height * 16
    
    self:spawnEntities()
end

function Map:next()
    self:clean()
    if self.currentLevel == 3 then
        love.event.quit("Bye!!!")
    else
        self.currentLevel = self.currentLevel + 1
        self:init()
        Player:resetPosition()
    end
end

function Map:previous()
    self:clean()
        self.currentLevel = self.currentLevel - 1
        self:init()
        Player:resetPosition()
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    Heart.removeAll()
    Spike.removeAll()
    Enemy.removeAll()
end

function Map:update()
    if Player.x > MapWidth - 16 then
        self:next()
    end

    if Player.x < 16 then
        if self.currentLevel == 1 then
            Player:resetPosition()
        else
        self:previous()
        end
    end

    if Player.y + Player.height > MapHeight then
        Player:die()
    end

end

function Map:spawnEntities()
    for i,v in ipairs(self.entityLayer.objects) do
        if v.class == "spikes" then 
            Spike.new(v.x + v.width, v.y + v.height)
        elseif v.class == "heart" then
            Heart.new(v.x, v.y)
        elseif v.class == "enemy" then
            Enemy.new(v.x, v.y)
        end
    end
end

return Map
