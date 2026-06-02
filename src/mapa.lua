Mapa = {}

-- ============================================================
-- Música:

local musica_atual = nil
local trilha_atual_nome = nil

local trilhas = {
  entrada_floresta = "assets/audio/musica/Slay_The_Evil.mp3",
  coracao_floresta = "assets/audio/musica/Slay_The_Evil.mp3",
  saida_floresta = "assets/audio/musica/Slay_The_Evil.mp3",
  entrada_castelo = "assets/audio/musica/Slay_The_Evil.mp3",
  sala_magnus = "assets/audio/musica/Infinite_Darkness.mp3",
}

-- ============================================================
--  Portal:
--    x, y, largura, altura  →  área invisível que ativa a troca
--    proxima_sala           →  nome da sala que será carregada
--    entrada_x              →  posição X onde o player reaparece
--    entrada_lado           →  "esquerda" ou "direita" (de qual lado o player entra)
-- ============================================================

local salas = {}

-- ============================================================
--  SALA 1: Entrada da Floresta
-- ============================================================
salas["entrada_floresta"] = function(s)
  return {
    fundo = "assets/background/Entrada_da_Floresta.png",
    itens = {
    { x = 255 * s, y = 25 * s, coletado = false }  -- em cima da plataforma 1
    },
    plataformas = {
      -- primeiro chao esquerda
      { x = 0    * s, y = 475 * s, largura = 585 * s, altura = 250 },
      -- segundo chão esquerda
      { x = 688  * s, y = 475 * s, largura = 245 * s, altura = 250 },
      -- Chão Meio
      { x = 1100 * s, y = 525 * s, largura = 315 * s, altura = 200 },
      -- Primeiro chão direita
      { x = 1510 * s, y = 525 * s, largura = 180 * s, altura = 200 },
      -- Segundo chão direita
      { x = 1805 * s, y = 525 * s, largura = 365 * s, altura = 200 },
      -- plataforma 1
      { x = 200 * s, y = 100 * s, largura = 185 * s, altura = 60 },
      -- plataforma 2
      { x = 540 * s, y = 244 * s, largura = 210 * s, altura = 96 },
      -- plataforma 3
      { x = 915 * s, y = 377 * s, largura = 200 * s, altura = 57 },
      -- plataforma 4
      { x = 1187 * s, y = 276 * s, largura = 178 * s, altura = 48 },
      -- plataforma 5
      { x = 1322 * s, y = 417 * s, largura = 290 * s, altura = 45 },
      -- plataforma 6
      { x = 1543 * s, y = 228 * s, largura = 120 * s, altura = 56 },
      -- plataforma 7
      { x = 1745 * s, y = 316 * s, largura = 127 * s, altura = 55 },
    },

    portais = function(largura_mapa)
      return {
        -- Saída pela direita -> Coração da Floresta
        {
          x            = 2126 * s,
          y            = 0 * s,
          largura      = 50,
          altura       = 524 * s,
          proxima_sala = "coracao_floresta",
          entrada_x    = 100,
          entrada_y    = 400, 
          entrada_lado = "esquerda",
        },
      }
    end,
  }
end
 
-- ============================================================
--  SALA 2: Coração da Floresta
-- ============================================================
salas["coracao_floresta"] = function(s)
  return {
    fundo = "assets/background/Coracao_Floresta.png",

    plataformas = {
      -- Chão principal (caminho de pedra)
      { x = 0    * s, y = 790 * s, largura = 1672 * s, altura = 150 },
     
    },

    portais = function(largura_mapa)
      return {
        -- Volta para a Entrada da Floresta pela esquerda
        {
          x            = 0 * s,
          y            = 0 * s,
          largura      = 10,
          altura       = 790 * s,
          proxima_sala = "entrada_floresta",
          entrada_x    = 1700,
          entrada_y    = 300,
          entrada_lado = "direita",
        },
        -- Saída pela direita -> Saída da Floresta
        {
          x            = 1450 * s,
          y            = 380 * s,
          largura      = 100 * s,
          altura       = 410 * s,
          proxima_sala = "saida_floresta",
          entrada_x    = 100 * s,
          entrada_y    = 620 * s,
          entrada_lado = "esquerda",
        },
      }
    end,
  }
end

-- ============================================================
--  SALA 3: Saída da FLoresta
-- ============================================================
salas["saida_floresta"] = function(s)
  return {
    fundo = "assets/background/Saida_Floresta.png",

    plataformas = {
      -- primeiro chao
      { x = 0    * s, y = 660 * s, largura = 565 * s, altura = 40 },
      -- segundo chao
      { x = 620    * s, y = 660 * s, largura = 300 * s, altura = 40 },
      -- terceiro chao
      { x = 955    * s, y = 685 * s, largura = 492 * s, altura = 60 },
      -- quarto chao
      { x = 1500    * s, y = 705 * s, largura = 250 * s, altura = 200 },
      -- primeira plataforma
      { x = 330    * s, y = 450 * s, largura = 105 * s, altura = 35 },
      -- segunda plataforma
      { x = 436    * s, y = 275 * s, largura = 120 * s, altura = 35 },
      -- terceira plataforma
      { x = 682    * s, y = 544 * s, largura = 95 * s, altura = 35 },
      -- quarta plataforma
      { x = 852    * s, y = 343 * s, largura = 105 * s, altura = 25 },
      -- quinta plataforma
      { x = 950    * s, y = 474 * s, largura = 105 * s, altura = 35 },
    },

    portais = function(largura_mapa)
      return {
        -- Saída pela esquerda -> Coração da Floresta
        {
          x            = 0 * s,
          y            = 0 * s,
          largura      = 10,
          altura       = 660 * s,
          proxima_sala = "coracao_floresta",
          entrada_x    = 1300 * s,
          entrada_y    = 650 * s, 
          entrada_lado = "direita",
        },
        -- Saida pela direita -> Entrada do Castelo
        {
          x            = 1720 * s,
          y            = 350 * s,
          largura      = 40,
          altura       = 400 * s,
          proxima_sala = "entrada_castelo",
          entrada_x    = 100 * s,
          entrada_y    = 700 * s,
          entrada_lado = "esquerda",
        },
      }
    end,
  }
end

-- ============================================================
--  SALA 4: Entrada do castelo
-- ============================================================

salas["entrada_castelo"] = function(s)
  return {
    fundo = "assets/background/Entrada_Castelo.png",
    
    plataformas = {
      -- chão principal
      { x = 0 * s, y = 780 * s, largura = 1920 * s, altura = 100 },
      -- primeira plataforma
      { x = 0 * s,  y = 383 * s, largura = 140 * s, altura = 40 },
      -- segunda plataforma
      { x = 141 * s,  y = 342 * s, largura = 420 * s, altura = 32 },
      -- terceira plataforma
      { x = 592 * s, y = 493 * s, largura = 265 * s, altura = 34 },
      -- quarta plataforma
      { x = 1100 * s, y = 395 * s, largura = 600 * s, altura = 34 },
    },


    portais = function(largura_mapa)
      return {
        -- Saída pela esquerda -> Saída da Floresta
        {
          x            = 0 * s,
          y            = 0 * s,
          largura      = 10,
          altura       = 790 * s,
          proxima_sala = "saida_floresta",
          entrada_x    = 1665 * s,
          entrada_y    = 680 * s,
          entrada_lado = "direita",
        },
        -- Saída pela direita -> Sala de Magnus
        {
          x                 = 1670 * s,
          y                 = 0,
          largura           = 50,
          altura            = 1000 * s,
          proxima_sala      = "sala_magnus",
          entrada_x         = 120 * s,
          entrada_y         = 600 * s,
          entrada_lado      = "esquerda",
        },
      }
    end,
  }
end

-- ============================================================
--  SALA 5: Sala de Magnus  (boss arena)
-- ============================================================
salas["sala_magnus"] = function(s)
  return {
    fundo = "assets/background/Sala_Magnus.png",

    plataformas = {
      -- chão da arena
      { x = 0 * s, y = 625 * s, largura = 2000 * s, altura = 100 },
    },

    portais = function(largura_mapa)
      return {}   -- sem saída
    end,
  }
end

-- ============================================================
--  Funções Públicas
-- ============================================================

function Mapa.load()
  Mapa.carregar("entrada_floresta")
end
 
function Mapa.carregar(nome_sala)
  local img_temp = love.graphics.newImage(
    salas[nome_sala] and
    salas[nome_sala](1).fundo or
    "assets/background/Entrada_da_Floresta.png"
  )
 
  local s = ALTURA_JOGO / img_temp:getHeight()
  Mapa.escala = s
 
  local dados = salas[nome_sala](s)

  Mapa.fundo         = img_temp
  Mapa.escala_fundo  = s
  Mapa.largura       = Mapa.fundo:getWidth() * s
  Mapa.plataformas   = dados.plataformas
  Mapa.portais_lista = dados.portais(Mapa.largura)
  Mapa.nome_atual    = nome_sala
  Mapa.itens = dados.itens or {}
  Mapa.item_img = love.graphics.newImage("assets/items/heart.png")
  
  -- ------------------------------------------------------------
  --  Troca de Trílha Sonora
  -- ------------------------------------------------------------
  
  local caminho = trilhas[nome_sala]
  if caminho and caminho ~= trilha_atual_nome then
    if musica_atual then
      musica_atual:stop()
    end
    musica_atual = love.audio.newSource(caminho, "stream")
    musica_atual:setLooping(true)
    musica_atual:play()
    trilha_atual_nome = caminho
  end
end
 
function Mapa.checarPortais(player)
  if not Mapa.portais_lista then return end
 
  Mapa.portal_proximo = nil   -- limpa a cada frame
 
  for _, portal in ipairs(Mapa.portais_lista) do
    local centro_y = player.y + player.altura / 2
    local dentro_y = centro_y >= portal.y and centro_y <= portal.y + portal.altura
    local toca_dir = player.x + player.largura >= portal.x and portal.entrada_lado ~= "direita"
    local toca_esq = player.x <= portal.x + portal.largura  and portal.entrada_lado == "direita"
    local na_area  = dentro_y and (toca_dir or toca_esq)
 
    if na_area then
      if portal.proxima_sala == "saida_floresta" and not Helga.renascida then
        -- portal bloqueado
      elseif portal.requer_interacao then
        Mapa.portal_proximo = portal
      else
        Mapa.entrarPortal(player, portal)
        return
      end
    end
  end
end
 
-- Chamado por keypressed quando o jogador aperta X
function Mapa.interagir(player)
  if Mapa.portal_proximo then
    Mapa.entrarPortal(player, Mapa.portal_proximo)
    Mapa.portal_proximo = nil
  end
end
 
function Mapa.entrarPortal(player, portal)
  Mapa.carregar(portal.proxima_sala)
  player.x = portal.entrada_x
  player.y = portal.entrada_y or 0
  player.y_velocidade = 0
end
 
function Mapa.drawHUD()
  
  if (Mapa.nome_atual == "coracao_floresta" or Mapa.nome_atual == "entrada_floresta") and not Helga.vivo and not Helga.renascida then
    local texto = "Use o Coracao da Floresta para purificar Helga antes de avancar"
    local fonte  = love.graphics.getFont()
    local tw     = fonte:getWidth(texto)
    local sw     = love.graphics.getWidth()
    local px     = (sw - tw) / 2
    local py     = love.graphics.getHeight() - 110

    love.graphics.setColor(0, 0, 0, 0.60)
    love.graphics.rectangle("fill", px - 12, py - 6, tw + 24, 32, 6, 6)

    local pulso = 0.75 + math.sin(love.timer.getTime() * 4) * 0.25
    love.graphics.setColor(1, 0.4, 0.4, pulso)
    love.graphics.print(texto, px, py)
    love.graphics.setColor(1, 1, 1)
  end
  
  --if not Mapa.portal_proximo then return end
 
  --local texto  = "[X] Entrar"
  --local fonte  = love.graphics.getFont()
  --local tw     = fonte:getWidth(texto)
  --local sw     = love.graphics.getWidth()
  --local px     = (sw - tw) / 2
  --local py     = love.graphics.getHeight() - 60
 
  -- fundo semi-transparente
  --love.graphics.setColor(0, 0, 0, 0.55)
  --love.graphics.rectangle("fill", px - 12, py - 6, tw + 24, 32, 6, 6)
 
  -- texto pulsante
  --local pulso = 0.75 + math.sin(love.timer.getTime() * 4) * 0.25
  --love.graphics.setColor(1, 0.9, 0.3, pulso)
  --love.graphics.print(texto, px, py)
 
  --love.graphics.setColor(1, 1, 1)
end
 
function Mapa.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Mapa.fundo, 0, 0, 0, Mapa.escala_fundo, Mapa.escala_fundo)
end
