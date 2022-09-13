local Player = {}

function Player:load()
    self.x = 100
    self.y = 0
    self.startX = self.x
    self.startY = self.y
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 150
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1500
    self.jumpAmount = -500
    self.hearts = 0
    self.health = {current = 10, max = 10}
    self.exp = {current = 0, max = 100}
    self.level = {current = 1, max = 10}
    self.damage = 1

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3,
     }

    self.graceTime = 0
    self.graceDuration = 0.1

    self.alive = true
    self.grounded = false
    self.hasDoubleJump = true
    self.attacking = false
    
    self.direction = "right"
    self.state = "idle"

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

end

function Player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
 
    self.animation.run = {total = 10, current = 1, img = {}}
    for i=1, self.animation.run.total do
       self.animation.run.img[i] = love.graphics.newImage("assets/player/run/"..i..".png")
    end
 
    self.animation.idle = {total = 10, current = 1, img = {}}
    for i=1, self.animation.idle.total do
       self.animation.idle.img[i] = love.graphics.newImage("assets/player/idle/"..i..".png")
    end
 
    self.animation.jump = {total = 3, current = 1, img = {}}
    for i=1, self.animation.jump.total do
       self.animation.jump.img[i] = love.graphics.newImage("assets/player/jump/"..i..".png")
    end

    self.animation.attack = {total = 4, current = 1, img = {}}
    for i=1, self.animation.attack.total do
       self.animation.attack.img[i] = love.graphics.newImage("assets/player/attack/"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()

    if self.state == "attack" then
        self.width = self.animation.attack.img[2]:getWidth()
        self.height = self.animation.attack.img[2]:getHeight()
    else
        self.width = self.animation.idle.img[1]:getWidth()
        self.height = self.animation.idle.img[1]:getHeight()
    end

 end

 function Player:takeDamage(amount)
    self:tintRed()
    if self.health.current - amount > 0 then
        self.health.current = self.health.current - amount
    else
        self.health.current = 0
        self:die()
    end
 end


function Player:die()
    self.alive = false
 end

 function Player:respawn()
    if not self.alive then
       self:resetPosition()
       self.health.current = self.health.max
       self.alive = true
    end
 end

 function Player:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
 end


function Player:tintRed()
    self.color.green = 0
    self.color.blue = 0
 end

 function Player:addHearts()
    self.hearts = self.hearts + 1
    self.health.current = self.health.current + 1
    self.health.max = self.health.max + 1
    
 end

 function Player:getExp(amount)
    self.exp.current = self.exp.current + amount
    if self.exp.current > 100 then
        self:levelUp()
        self.exp.current = 0
    end
 end

function Player:levelUp()
    self.level = self.level + 1
end

function Player:update(dt)
    self:unTint(dt)
    self:respawn()
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
    self:decreaseGraceTime(dt)
    self:attack()
end

function Player:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:setState()
    if self.attacking then
        self.state = "attack"
        self.attacking = false
    elseif not self.grounded then
        self.state = "jump"
    elseif self.xVel == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
end

function Player:attack()
    if love.keyboard.isDown("x") then
        self.attacking = true
    end
end

function Player:setDirection()
    if self.xVel < 0 then
        self.direction = "left"
    elseif self.xVel > 0 then
        self.direction = "right"
    end
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
       self.animation.timer = 0
       self:setNewFrame()
    end
 end

 function Player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
       anim.current = anim.current + 1
    else
       anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
 end

function Player:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime * dt
    end
end

function Player:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Player:move(dt)
    if love.keyboard.isDown("d", "right") then
       self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
    elseif love.keyboard.isDown("a", "left") then
       self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
    else
        self:applyFriction(dt)
    end
 end

function Player:applyFriction(dt)
    if self.xVel > 0 then
        self.xVel = math.max(self.xVel - self.friction * dt, 0)
    elseif self.xVel < 0 then
        self.xVel = math.min(self.xVel + self.friction * dt, 0)
    end
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a, b, collision)
    if self.grounded then return end
    
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yVel = 0
        end
    end
end

function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.hasDoubleJump = true
    self.graceTime = self.graceDuration
end

function Player:jump(key)
    if key == "space" then
        if self.grounded or self.graceTime > 0 then
            self.yVel = self.jumpAmount
            self.grounded = false
            self.graceTime = 0
        elseif self.hasDoubleJump then
            self.hasDoubleJump = false
            self.yVel = self.jumpAmount * 0.75
        end
    end
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:draw()
    local scaleX = 1
    if self.direction == "left" then
       scaleX = -1
    end
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
    love.graphics.setColor(1,1,1,1)

end

 
 return Player