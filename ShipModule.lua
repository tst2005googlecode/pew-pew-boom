require('passion.init')

ShipModule = passion.ActorWithBody:subclass('ShipModule')

function ShipModule:initialize(quad, centerX, centerY)
  super.initialize(self)
  self:newBody()
  self:setMass(centerX, centerY, 0.1, 0.1)
  self:setCenter(centerX, centerY)
  self.quad = quad
end

function ShipModule:attach(slot)
  self.slot = slot
  self.ship = slot.ship
end

function ShipModule:getDrawOrder()
  if(self.drawOrder~=nil) then return self.drawOrder end

  local ship = self.ship
  if(ship==nil) then return end

  local so = ship:getDrawOrder()
  if(so~=nil) then return so-1 end
end

function ShipModule:update(dt)
  local ship, slot = self.ship, self.slot
  if(ship==nil or slot==nil) then return end
  
  local x,y = self.ship:getWorldPoint(slot.x, slot.y)
  self:setPosition(x,y)
  self:setAngle(ship:getAngle() + slot.angle ) -- FIXME: the slot.angle isn't ok
end

function ShipModule:draw()
  love.graphics.setColor(unpack(passion.white))
  local x, y = self:getPosition()
  local cx, cy = self:getCenter()
  passion.graphics.drawq(self.quad, x, y, self:getAngle(), 1, 1, cx, cy)
end



