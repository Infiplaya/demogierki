local Enemy = {}

Enemy.__index = Enemy
local Player = require("player")


local ActiveEnemies = {}

function Enemy.removeAll()
   for i,v in ipairs(ActiveEnemies) do
      v.physics.body:destroy()
   end
   ActiveEnemies = {}
end

function Enemy.new(x,y)
   local instance = setmetatable({}, Enemy)
   instance.x = x
   instance.y = y
   instance.r = 0

   instance.startX = x
   instance.startY = y

   instance.state = "walk"
   
   instance.damage = 1
   instance.speed = 50
   instance.expWorth = 10
   instance.health = {current = 2, max = 2}
   instance.xVel = instance.speed
   instance.takenDamage = false
   instance.alive = true

   instance.color = {
      red = 1,
      green = 1,
      blue = 1,
      speed = 3,
   }
   
   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.idle = {total = 8, current = 1, img = Enemy.idleAnim}
   instance.animation.walk = {total = 8, current = 1, img = Enemy.walkAnim}
   instance.animation.draw = instance.animation.walk.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height * 0.9)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveEnemies, instance)
end

function Enemy.loadAssets()

    Enemy.walkAnim = {}
    for i = 1,8 do
        Enemy.walkAnim[i] = love.graphics.newImage("assets/enemies/bringer/Walk/"..i..".png")
    end

    Enemy.width = Enemy.walkAnim[1]:getWidth()
    Enemy.height = Enemy.walkAnim[1]:getHeight()
end

function Enemy:takeDamage(amount)
   for i = #ActiveEnemies, 1, -1 do
      if ActiveEnemies[i].takenDamage then
         ActiveEnemies[i]:tintRed()
         if ActiveEnemies[i].health.current - amount > 0 then
            ActiveEnemies[i].health.current = ActiveEnemies[i].health.current - amount
         else
            ActiveEnemies[i].health.current = 0
            ActiveEnemies[i]:die()
         end
      end
   end
end

function Enemy:die()
   self.alive = false
end

function Enemy:remove()
   for i = #ActiveEnemies, 1, -1 do
      if not ActiveEnemies[i].alive then
         Player:getExp(ActiveEnemies[i].expWorth)
         ActiveEnemies[i].physics.body:destroy()
         table.remove(ActiveEnemies, i)
      end
    end
end

function Enemy:tintRed()
   self.color.green = 0
   self.color.blue = 0
end

function Enemy:update(dt)
   self:unTint(dt)
   self:syncPhysics()
   self:animate(dt)
   self:remove()
end

function Enemy:changeDirection(dt)
   self.xVel = -self.xVel
end

function Enemy:unTint(dt)
   self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
   self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
   self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Enemy:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
       self.animation.timer = 0
       self:setNewFrame()
    end
 end

 function Enemy:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
       anim.current = anim.current + 1
    else
       anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
 end


function Enemy:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, 100)
end

function Enemy:draw()
   local scaleX = -1
   if self.xVel < 0 then
      scaleX = 1
   end
   love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
   love.graphics.draw(self.animation.draw, self.x, self.y, self.r, scaleX, 1, self.width / 2, self.height / 2)
   love.graphics.setColor(1,1,1,1)
end

function Enemy.updateAll(dt)
   for i,instance in ipairs(ActiveEnemies) do
      instance:update(dt)
   end
end

function Enemy.drawAll()
   for i,instance in ipairs(ActiveEnemies) do
      instance:draw()
   end
end

function Enemy.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveEnemies) do
       if a == instance.physics.fixture or b == instance.physics.fixture then
           if a == Player.physics.fixture or b == Player.physics.fixture then
               if Player.state == "attack" then
                  instance:takeDamage(Player.damage)
                  instance.takenDamage = true
               else
                  Player:takeDamage(instance.damage)
               end
           end
           instance:changeDirection()
       end
   end
end


return Enemy