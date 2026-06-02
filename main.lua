require "src/player"
require "src/mapa"
require "src/camera"
require "src/enemy"
require "src/helga"
require "src/magnus"
require "src/hud"

LARGURA_JOGO  = 800
ALTURA_JOGO   = 600
local canvas_jogo   = nil
local escala_render = 1
local offset_x      = 0
local offset_y      = 0

local function atualizar_escala()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  escala_render = math.min(sw / LARGURA_JOGO, sh / ALTURA_JOGO)
  offset_x = math.floor((sw - LARGURA_JOGO * escala_render) / 2)
  offset_y = math.floor((sh - ALTURA_JOGO  * escala_render) / 2)
end

-- ── Reinicia APENAS o estado do jogo, sem tocar na janela/canvas ──
local function reiniciar()
  Mapa.load()
  Player.load()
  Enemy.load()
  Helga.load()
  Magnus.load()
  HUD.load()
end

tempo_morte = 0

-- ── Chamado UMA VEZ pelo LÖVE na inicialização ────────────────────
function love.load()
  love.window.setMode(LARGURA_JOGO, ALTURA_JOGO, { resizable = false })
  canvas_jogo = love.graphics.newCanvas(LARGURA_JOGO, ALTURA_JOGO)
  atualizar_escala()
  reiniciar()
end

-- ── Atualiza letterboxing quando a janela muda (ex: alt+enter, resize) ──
function love.resize(w, h)
  atualizar_escala()
end

function love.keypressed(key)
  if key == "f11" then
    love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    atualizar_escala()
  end
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

function love.update(dt)
  -- Trava dt máximo: evita que entidades atravessem plataformas
  -- quando há spike de frame (ex: primeiro frame após carregar assets)
  dt = math.min(dt, 0.05)

  Player.update(dt, Mapa.plataformas)

  if Player.vivo and Player.y > ALTURA_JOGO + 100 then
    Player.tomarDano(0, 999)
  end

  if not Player.vivo then
    tempo_morte = tempo_morte + dt
    if tempo_morte >= 1.5 then
      tempo_morte = 0
      reiniciar()  -- NÃO chama love.load() → janela e fullscreen preservados
    end
    return
  end

  local sala_anterior = Mapa.nome_atual
  Mapa.checarPortais(Player)

  if Mapa.nome_atual ~= sala_anterior then
    Enemy.load()
    if not Helga.renascida and Helga.vivo then
      Helga.load()
    end
    if Mapa.nome_atual == "sala_magnus" then
      Magnus.load()
    end
  end

  Camera.update(Player.x, Player.y)
  HUD.update()

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
  -- ── Renderiza o jogo no canvas 800x600 ───────────────────────────
  love.graphics.setCanvas(canvas_jogo)
  love.graphics.clear(0.1, 0.1, 0.2)
  love.graphics.setColor(1, 1, 1)

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

  Mapa.drawHUD()
  HUD.draw()

  -- ── Joga o canvas na tela com letterboxing ────────────────────────
  love.graphics.setCanvas()
  love.graphics.clear(0, 0, 0)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(canvas_jogo, offset_x, offset_y, 0, escala_render, escala_render)
end