Mapa = {}

local COR_PARA_TILE = {

  -- formato: ["RRGGBB"] = "nome_do_quad"

  -- Paredes
  ["4a3728"] = "parede_mei_1",
  ["5c4a38"] = "parede_mei_2",
  ["3d2e1e"] = "parede_sup_esq",
  ["6b5a47"] = "parede_sup_dir",
  ["7a6a57"] = "parede_sup_mei_1",
  ["8a7a67"] = "parede_sup_mei_2",
  ["2e2018"] = "parede_dir",
  ["1e1008"] = "parede_esq",
  ["3a2a1a"] = "parede_inf_dir",
  ["4a3a2a"] = "parede_inf_mei",
  ["5a4a3a"] = "parede_inf_esq",

  -- Chão
  ["c8b88a"] = "chao_esq",
  ["d8c89a"] = "chao_mei_1",
  ["e8d8aa"] = "chao_mei_2",
  ["b8a87a"] = "chao_dir",

  -- Chão com tapete
  ["8b3a3a"] = "chao_tap_esq",
  ["9b4a4a"] = "chao_tap_mei_1",
  ["ab5a5a"] = "chao_tap_mei_2",
  ["7b2a2a"] = "chao_tap_dir",

  -- Plataforma
  ["6aaa6a"] = "pataforma_esq",
  ["7aba7a"] = "pataforma_mei_1",
  ["8aca8a"] = "pataforma_mei_2",
  ["5a9a5a"] = "pataforma_dir",

  -- Arcos
  ["4a6a8a"] = "arco_sup_esq",
  ["5a7a9a"] = "arco_sup_mei",
  ["6a8aaa"] = "arco_sup_dir",
  ["3a5a7a"] = "arco_mei_esq",
  ["7a9aba"] = "arco_mei_dir",
  ["2a4a6a"] = "arco_inf_esq",
  ["8aaaaa"] = "arco_inf_dir",

  -- Colunas
  ["9a7a5a"] = "coluna_sup_esq",
  ["aa8a6a"] = "coluna_sup_dir",
  ["8a6a4a"] = "coluna_mei_esq",
  ["ba9a7a"] = "coluna_mei_dir",
  ["7a5a3a"] = "coluna_inf_esq",
  ["ca9a7a"] = "coluna_inf_dir",
  ["b87a00"] = "coluna_base_esq",
  ["d4a017"] = "coluna_base_dir",
  
  -- Especiais
  ["ff0000"] = "espinhos",
  ["ffff00"] = "merlao",
  ["0000ff"] = "janela_sup",
  ["0000cc"] = "janela_mei",
  ["000099"] = "janela_inf",
  ["000000"] = "vazio",
}


local TILE = 32
local ESCALA = 1

function Mapa.load()
  local img = love.graphics.newImage("assets/tiles/Tileset_map.png")
  local SW = img:getWidth()
  local SH = img:getHeight()  
  Mapa.tileset = img
  
  Mapa.q = {
    -- Vazio: tudo preto
    vazio = love.graphics.newQuad(224, 0, 32, 32, SW, SH),
    
    -- Arco de tijolos: janelas abertas
    arco_sup_esq     = love.graphics.newQuad(0, 0, 32, 32, SW, SH),
    arco_sup_mei     = love.graphics.newQuad(32, 0, 32, 32, SW, SH),
    arco_sup_dir     = love.graphics.newQuad(64, 0, 32, 32, SW, SH),
    arco_mei_esq     = love.graphics.newQuad(96, 0, 32, 32, SW, SH),
    arco_mei_dir     = love.graphics.newQuad(128, 0, 32, 32, SW, SH),
    arco_inf_esq     = love.graphics.newQuad(160, 0, 32, 32, SW, SH),
    arco_inf_dir     = love.graphics.newQuad(192, 0, 32, 32, SW, SH),
    
    -- Parede: tijolos
    parede_mei_1     = love.graphics.newQuad(256, 0, 32, 32, SW, SH),
    parede_mei_2     = love.graphics.newQuad(288, 0, 32, 32, SW, SH),
    parede_sup_esq   = love.graphics.newQuad(320, 0, 32, 32, SW, SH),
    parede_sup_mei_1 = love.graphics.newQuad(352, 0, 32, 32, SW, SH),
    parede_sup_mei_2 = love.graphics.newQuad(384, 0, 32, 32, SW, SH),
    parede_sup_dir   = love.graphics.newQuad(416, 0, 32, 32, SW, SH),
    parede_dir       = love.graphics.newQuad(448, 0, 32, 32, SW, SH),
    parede_esq       = love.graphics.newQuad(480, 0, 32, 32, SW, SH),
    parede_inf_dir   = love.graphics.newQuad(0, 32, 32, 32, SW, SH),
    parede_inf_mei   = love.graphics.newQuad(32, 32, 32, 32, SW, SH),
    parede_inf_esq   = love.graphics.newQuad(64, 32, 32, 32, SW, SH),
    
    -- Coluna: parede
    coluna_sup_esq   = love.graphics.newQuad(96, 32, 32, 32, SW, SH),
    coluna_sup_dir   = love.graphics.newQuad(128, 32, 32, 32, SW, SH),
    coluna_mei_esq   = love.graphics.newQuad(160, 32, 32, 32, SW, SH),
    coluna_mei_dir   = love.graphics.newQuad(192, 32, 32, 32, SW, SH),
    coluna_inf_esq   = love.graphics.newQuad(224, 32, 32, 32, SW, SH),
    coluna_inf_dir   = love.graphics.newQuad(256, 32, 32, 32, SW, SH),
    coluna_base_esq  = love.graphics.newQuad(288, 64, 32, 32, SW, SH),
    coluna_base_dir  = love.graphics.newQuad(320, 64, 32, 32, SW, SH),
    
    -- Châo: sem tapete
    chao_dir         = love.graphics.newQuad(288, 32, 32, 32, SW, SH),
    chao_mei_1       = love.graphics.newQuad(320, 32, 32, 32, SW, SH),
    chao_mei_2       = love.graphics.newQuad(352, 32, 32, 32, SW, SH),
    chao_esq         = love.graphics.newQuad(384, 32, 32, 32, SW, SH),
    
    -- Châo: com tapete
    chao_tap_dir     = love.graphics.newQuad(416, 32, 32, 32, SW, SH),
    chao_tap_mei_1   = love.graphics.newQuad(448, 32, 32, 32, SW, SH),
    chao_tap_mei_2   = love.graphics.newQuad(480, 32, 32, 32, SW, SH),
    chao_tap_esq     = love.graphics.newQuad(0, 64, 32, 32, SW, SH),
    
    -- Merlão
    merlao           =  love.graphics.newQuad(32, 64, 32, 32, SW, SH),
    
    -- Plataforma
    pataforma_esq    = love.graphics.newQuad(64, 64, 32, 32, SW, SH),
    pataforma_mei_1  = love.graphics.newQuad(96, 64, 32, 32, SW, SH),
    pataforma_mei_2  = love.graphics.newQuad(128, 64, 32, 32, SW, SH),
    pataforma_dir    = love.graphics.newQuad(160, 64, 32, 32, SW, SH),
    
    -- Escadas: com tapete
    escada_1         = love.graphics.newQuad(192, 64, 32, 32, SW, SH),
    escada_2         = love.graphics.newQuad(224, 64, 32, 32, SW, SH),
    
    -- Espinhos: no châo
    espinhos         = love.graphics.newQuad(156, 64, 32, 32, SW, SH),
    
    -- Janela
    janela_sup       = love.graphics.newQuad(480, 96, 32, 32, SW, SH),
    janela_mei       = love.graphics.newQuad(480, 128, 32, 32, SW, SH),
    janela_inf       = love.graphics.newQuad(480, 160, 32, 32, SW, SH)
    
  }
  
  Mapa.plataformas = {}
  Mapa.grid = {}
  
  local dados = love.image.newImageData("assets/tiles/Mapa.png")
  Mapa.colunas = dados:getWidth()
  Mapa.linhas = dados:getHeight()
  
  for linha = 0, Mapa.linhas - 1 do
    Mapa.grid[linha] = {}
    
    for col = 0, Mapa.colunas - 1 do
      local r, g, b, a = dados:getPixel(col, linha)
      
      local hex = string.format("%02x%02x%02x",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5)
      )
      
      Mapa.grid[linha][col] = COR_PARA_TILE[hex]
    end
  end
  
  local tiles_solidos = {
    parede_sup_esq = true, parede_sup_dir = true,
    chao_esq = true, chao_mei_1 = true, chao_mei_2 = true, chao_dir = true,
    chao_tap_esq = true, chao_tap_mei_1 = true, chao_tap_mei_2 = true, chao_tap_dir = true,
    pataforma_esq = true, pataforma_mei_1 = true, pataforma_mei_2 = true, pataforma_dir = true,
    espinhos = true
  }
  
  for linha = 0, Mapa.linhas - 1 do
    local col = 0
    while col < Mapa.colunas do
      local tile = Mapa.grid[linha][col]
      if tile and tiles_solidos[tile] then
        local inicio = col
        while col < Mapa.colunas and Mapa.grid[linha][col] and tiles_solidos[Mapa.grid[linha][col]] do
          col = col + 1
        end
        table.insert(Mapa.plataformas, {
            x = inicio * TILE * ESCALA,
            y = linha * TILE * ESCALA,
            largura = (col - inicio) * TILE * ESCALA,
            altura = TILE * ESCALA
          })
      else
        col = col + 1
      end
    end
  end
end

function Mapa.draw()
  love.graphics.setColor(1, 1, 1)
  
  for linha = 0, Mapa.linhas - 1 do 
    for col = 0, Mapa.colunas - 1 do
      local nome = Mapa.grid[linha][col]
      if nome and Mapa.q[nome] then
        love.graphics.draw(
          Mapa.tileset,
          Mapa.q[nome],
          col * TILE * ESCALA,
          linha * TILE * ESCALA,
          0, ESCALA, ESCALA
        )
      end
    end
  end
end