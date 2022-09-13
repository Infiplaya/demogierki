local GUI = {}
local Player = require("player")

function GUI:load()
    self.hearts = {}
    self.hearts.img = love.graphics.newImage("assets/heart.png")
    self.hearts.width = self.hearts.img:getWidth()
    self.hearts.height = self.hearts.img:getHeight()
    
    self.hearts.scale = 2
    self.hearts.x = 0
    self.hearts.y = 30
    self.hearts.spacing = self.hearts.width * self.hearts.scale + 10

    self.font = love.graphics.newFont("assets/font.ttf", 14)
end

function GUI:update(dt)

end

function GUI:draw()
    self:displayLevel()
    self:displayEXP()
    self:displayHearts()
end

function GUI:displayHearts()
    for i=1, Player.health.current do
        local x = self.hearts.x + self.hearts.spacing * i
        love.graphics.draw(self.hearts.img, x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
    end
end

function GUI:displayEXP()
    love.graphics.setFont(self.font)
    love.graphics.setColor(0,0,0,1)
    love.graphics.print("EXP: "..Player.exp.current.."/"..Player.exp.max, 10, 100)
    love.graphics.setColor(1,1,1,1)
end

function GUI:displayLevel()
    love.graphics.setFont(self.font)
    love.graphics.setColor(0,0,0,1)
    love.graphics.print("Level: "..Player.level.current.."/"..Player.level.max, 10, 120)
    love.graphics.setColor(1,1,1,1)
end
return GUI