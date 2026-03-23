require "src/player"
require "src/mapa"
require "src/camera"


function love.keypressed(key)
  Player.keypressed(key)
end

function love.gamepadpressed(joystick, button)
  Player.gamepadpressed(button)
end

function love.load()
  Mapa.load()
  Player.load() 
end

function love.update(dt)
  Player.update(dt, Mapa.plataformas) 
  Camera.update(Player.x, Player.y)
end

function love.draw()
  love.graphics.clear(0.1, 0.1, 0.2) 
  
  Camera.set()
    Mapa.draw()
    Player.draw()
  Camera.unset()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Protagonista: " .. Player.nome, 10, 10)
  love.graphics.print("HP: " .. Player.vida, 10, 30)
end