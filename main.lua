require "src/player"
require "src/mapa"
require "src/camera"
require "src/enemy"


function love.keypressed(key)
  Player.keypressed(key)
end

function love.gamepadpressed(joystick, button)
  Player.gamepadpressed(button)
end

function love.load()
  Mapa.load()
  Player.load() 
  Enemy.load()
  
  fundo = love.graphics.newImage("assets/background/Fundo_1.png")
  escala_fundo = love.graphics.getHeight() / fundo:getHeight()
end

function love.update(dt)
  Player.update(dt, Mapa.plataformas) 
  Camera.update(Player.x, Player.y)
  Enemy.update(dt, Player, Mapa.plataformas)
end

function love.draw()
  love.graphics.clear(0.1, 0.1, 0.2) 
  love.graphics.setColor(1, 1, 1)
  
  love.graphics.draw(fundo, 0, 0, 0, escala_fundo, escala_fundo)

  Camera.set()
    Mapa.draw()
    Player.draw()
    Enemy.draw()
  Camera.unset()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Protagonista: " .. Player.nome, 10, 10)
  love.graphics.print("HP: " .. Player.vida, 10, 30)
end