Mapa = {}

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
        -- Saída pela direita → Floresta Corrompida
        {
          x            = 2126 * s,
          y            = 0 * s,
          largura      = 50,
          altura       = 524 * s,
          proxima_sala = "coracao_floresta",
          entrada_x    = 60,
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
        -- Volta para a Floresta Corrompida pela esquerda
        {
          x            = 0,
          y            = 0 * s,
          largura      = 10,
          altura       = 790 * s,
          proxima_sala = "entrada_floresta",
          entrada_x    = 1700,
          entrada_y    = 400,
          entrada_lado = "direita",
        },
      }
    end,
  }
end

-- ============================================================
--  FUNÇÕES PÚBLICAS
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

  local s = love.graphics.getHeight() / img_temp:getHeight()

  local dados = salas[nome_sala](s)

  Mapa.fundo         = img_temp
  Mapa.escala_fundo  = s
  Mapa.largura       = Mapa.fundo:getWidth() * s
  Mapa.plataformas   = dados.plataformas
  Mapa.portais_lista = dados.portais(Mapa.largura)
  Mapa.nome_atual    = nome_sala
end

function Mapa.checarPortais(player)
  if not Mapa.portais_lista then return end

  for _, portal in ipairs(Mapa.portais_lista) do
    local centro_y = player.y + player.altura / 2

    local dentro_y = centro_y >= portal.y and centro_y <= portal.y + portal.altura
    local toca_dir = player.x + player.largura >= portal.x and portal.entrada_lado ~= "direita"
    local toca_esq = player.x <= portal.x + portal.largura  and portal.entrada_lado == "direita"

    if dentro_y and (toca_dir or toca_esq) then
      Mapa.carregar(portal.proxima_sala)
      player.x = portal.entrada_x
      player.y = portal.entrada_y or 0
      player.y_velocidade = 0
      return
    end
  end
end

function Mapa.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Mapa.fundo, 0, 0, 0, Mapa.escala_fundo, Mapa.escala_fundo)
end