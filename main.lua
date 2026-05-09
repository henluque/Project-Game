require "src/player"
require "src/mapa"
require "src/camera"
require "src/enemy"
require "src/helga"

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
  Helga.load()

  fundo = love.graphics.newImage("assets/background/Entrada_da_Floresta.png")
  escala_fundo = love.graphics.getHeight() / fundo:getHeight()
end

function love.update(dt)
  Player.update(dt, Mapa.plataformas)

  local sala_anterior = Mapa.nome_atual
  Mapa.checarPortais(Player)

  -- Recarrega os inimigos ao trocar de sala
  if Mapa.nome_atual ~= sala_anterior then
    Enemy.load()
    Helga.load()
  end

  Camera.update(Player.x, Player.y)

  if Mapa.nome_atual == "entrada_floresta" then
    Enemy.update(dt, Player, Mapa.plataformas)
  elseif Mapa.nome_atual == "coracao_floresta" then
    Helga.update(dt, Player)
  end
end

function love.draw()
  love.graphics.clear(0.1, 0.1, 0.2)
  love.graphics.setColor(1, 1, 1)

  love.graphics.draw(fundo, 0, 0, 0, escala_fundo, escala_fundo)

  Camera.set()
    Mapa.draw()
    Player.draw()

    if Mapa.nome_atual == "entrada_floresta" then
      Enemy.draw()
    elseif Mapa.nome_atual == "coracao_floresta" then
      Helga.draw()
    end
  Camera.unset()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("HP: " .. Player.vida, 10, 30)
end