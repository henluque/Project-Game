require "src/player"
require "src/mapa"
require "src/camera"
require "src/enemy"
require "src/helga"
require "src/magnus"

function love.keypressed(key)
  Player.keypressed(key)
  if key == "x" or key == "k" then
    Mapa.interagir(Player)
  end
end

function love.gamepadpressed(joystick, button)
  Player.gamepadpressed(button)
  if button == "x" then
    Mapa.interagir(Player)
  end
end

function love.load()
  Mapa.load()
  Player.load()
  Enemy.load()
  Helga.load()
  Magnus.load()

  fundo = love.graphics.newImage("assets/background/Entrada_da_Floresta.png")
  escala_fundo = love.graphics.getHeight() / fundo:getHeight()
end

tempo_morte = 0

function love.update(dt)
  Player.update(dt, Mapa.plataformas)
  
  if Player.vivo and Player.y > love.graphics.getHeight() + 100 then
    Player.tomarDano(0, 999)
  end

  if not Player.vivo then
    tempo_morte = tempo_morte + dt
    if tempo_morte >= 1.5 then
      tempo_morte = 0
      love.load()
    end
    return
  end

  local sala_anterior = Mapa.nome_atual
  Mapa.checarPortais(Player)

  if Mapa.nome_atual ~= sala_anterior then
    Enemy.load()
    -- só reseta Helga se ela ainda não foi morta/renascida
    if not Helga.renascida and Helga.vivo then
      Helga.load()
    end
    if Mapa.nome_atual == "sala_magnus" then
      Magnus.load()
    end
  end

  Camera.update(Player.x, Player.y)

  if Mapa.nome_atual == "entrada_floresta" then
    Enemy.update(dt, Player, Mapa.plataformas)
    for _, item in ipairs(Mapa.itens) do
      if not item.coletado then
        if Player.x < item.x + 20 and Player.x + Player.largura > item.x and
          Player.y < item.y + 20 and Player.y + Player.altura  > item.y then
          item.coletado = true
          Player.tem_item = true
        end
      end
    end
  elseif Mapa.nome_atual == "coracao_floresta" then
    Helga.update(dt, Player)
  elseif Mapa.nome_atual == "sala_magnus" then
    Magnus.update(dt, Player, Mapa.plataformas)
  end
end

function love.draw()
  love.graphics.clear(0.1, 0.1, 0.2)
  love.graphics.setColor(1, 1, 1)

  love.graphics.draw(fundo, 0, 0, 0, escala_fundo, escala_fundo)

  Camera.set()
  Mapa.draw()
    
  for _, item in ipairs(Mapa.itens) do
    if not item.coletado then
      local escala_item = 64 / Mapa.item_img:getWidth()
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(
        Mapa.item_img,
        item.x,
        item.y,
        0,
        escala_item,
        escala_item
      )
    end
  end
  
Player.draw()

  if Mapa.nome_atual == "entrada_floresta" then
    Enemy.draw()
  elseif Mapa.nome_atual == "coracao_floresta" then
    Helga.draw()
  elseif Mapa.nome_atual == "sala_magnus" then
    Magnus.draw()
  end
  Camera.unset()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("HP: " .. Player.vida, 10, 30)

  -- HUD fora da câmera
  Mapa.drawHUD()
  
end