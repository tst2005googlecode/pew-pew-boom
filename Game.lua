require('passion.init')
require('actors/PlayerAI')
require('actors/space/vehicles/LensCulinaris')
require('actors/space/vehicles/Razor')
require('actors/space/modules/PlasmaCannons')
require('actors/space/modules/Thrusters')
require('actors/space/modules/Gyroscopes')
require('actors/space/other/Asteroids')
require('actors/FollowField')

showDebugInfo = false

Game = class('Game', StatefulObject)
Game:includes(Beholder)

-- load some functions using passion's built-in resource manager
Game.fonts = {
  title = passion.fonts.getFont('fonts/SVBasicManual.ttf', 70),
  button = passion.fonts.getFont('fonts/SVBasicManual.ttf', 40)
}

function Game:initialize()
  super.initialize(self)

  self:gotoState('MainMenu')
  self:observe('keypressed_tab', 'toggleDebug')
end

function Game:toggleDebug()
  showDebugInfo = not showDebugInfo
end

function Game:draw()
end

local MainMenu = Game:addState('MainMenu')

function MainMenu:enterState()
  self.title = passion.gui.Label:new({
    text='pew pew BOOM!', 
    x=200, y=20, width=400, align='center',
    font=Game.fonts.title
  })

  self.startButton = passion.gui.Button:new({
    text='pew pew',
    x=150, y=200, width=500, valign='center',
    cornerRadius=10,
    font=Game.fonts.button,
    onClick = function(b) game:gotoState('Play') end
  })

  self.exitButton = passion.gui.Button:new({
    text='BOOM!',
    x=150, y=400, width=500,
    cornerRadius=10,
    font=Game.fonts.button,
    onClick = function(b) passion.exit() end
  })
end

function MainMenu:exitState()
  self.title:destroy()
  self.title = nil
  self.startButton:destroy()
  self.startButton = nil
  self.exitButton:destroy()
  self.exitButton = nil
end

local Play = Game:addState('Play')

function Play:enterState()

  passion.physics.newWorld(3000, 3000)
  self.quadTree = passion.ai.QuadTree:new(3000, 3000)
  self.ship = LensCulinaris:new(PlayerAI:new(), 100,100, self.quadTree)
  self.field = FollowField:new(self.ship, 200, 200, self.quadTree)

  self.ship:attach('frontLeft', PlasmaCannon1:new() )
  self.ship:attach('frontRight', PlasmaCannon2:new())
  self.ship:attach('utility', Gyroscope1:new())
  self.ship:attach('back', Thruster1:new())

  local asteroidClasses = {
    BigAsteroid1,
    BigAsteroid2,
    MediumAsteroid1,
    MediumAsteroid2,
    MediumAsteroid3,
    SmallAsteroid1,
    SmallAsteroid2,
    SmallAsteroid3,
    SmallAsteroid4
  }

  self.asteroids = {}

  for i=1,20 do
    table.insert(self.asteroids,
      asteroidClasses[math.random(1,#asteroidClasses)]:new(
        math.random(150, 650),
        math.random(150, 450),
        self.quadTree
      )
    )
  end
end

function Play:exitState()
  self.ship:destroy()
  self.ship = nil

  for _,asteroid in ipairs(self.asteroids) do
    asteroid:destroy()
  end
  self.asteroids = nil

  passion.destroyWorld()
end

function Play:draw()
  if(showDebugInfo) then
    game.quadTree:draw()
  end
end
