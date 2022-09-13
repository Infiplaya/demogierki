love.graphics.setDefaultFilter("nearest", "nearest")
local STI = require("sti")
local Player = require("player")
local Heart = require("heart")
local GUI = require("gui")
local Spike = require("spikes")
local Camera = require("camera")
local Enemy = require("enemy")
local Map = require("map")

function love.load()
    Enemy.loadAssets()
    Map:load()
    background = love.graphics.newImage("assets/background.png")
    cs50 = love.graphics.newImage("assets/cs50.png")
    GUI:load()
    Player:load()
end

function love.update(dt)
    World:update(dt)
    Player:update(dt)
    Heart.updateAll(dt)
    Spike.updateAll(dt)
    Enemy.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, 0)
    Map:update(dt)
end

function love.draw()
    if Map.currentLevel == 3 then
        love.graphics.draw(cs50)
    else
        love.graphics.draw(background)
    end
    Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
    
    Camera:apply()
    Player:draw()
    Heart.drawAll()
    Spike.drawAll()
    Enemy.drawAll()
    Camera:clear()

    GUI:draw()
end

function love.keypressed(key)
    Player:jump(key)
end

function beginContact(a, b, collision)
    if Heart.beginContact(a,b, collision) then return end
    if Spike.beginContact(a,b, collision) then return end
    Player:beginContact(a, b, collision)
    Enemy.beginContact(a,b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end
