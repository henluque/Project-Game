Enemy = {}
Enemy.lista = {}

local sprites = nil

local function carrega_sheet(caminho, num_frames)
  local img = love.graphics.newImage(caminho)
  local w = img:getWidth()
  local h = img:getHeight()
  local slot = w / num_frames
  local quads = {}

  for i = 0, num_frames - 1 do
    table.insert(quads, love.graphics.newQuad(
      i * slot, 0, slot, h, w, h
    ))
  end

  return img, quads, slot, h
end

local function carrega_sprites()
  if sprites then return end
  
  sprites = {}
  sprites.idle_img,   sprites.idle_q,   sprites.idle_w,   sprites.idle_h   = carrega_sheet("assets/sprites/goblin/Idle.png",     4)
  sprites.run_img,    sprites.run_q,     sprites.run_w,    sprites.run_h    = carrega_sheet("assets/sprites/goblin/Run.png",      8)
  sprites.attack_img, sprites.attack_q,  sprites.attack_w, sprites.attack_h = carrega_sheet("assets/sprites/goblin/Attack.png",   8)
  sprites.hit_img,    sprites.hit_q,     sprites.hit_w,    sprites.hit_h    = carrega_sheet("assets/sprites/goblin/Take_hit.png", 4)
  sprites.death_img,  sprites.death_q,   sprites.death_w,  sprites.death_h  = carrega_sheet("assets/sprites/goblin/Death.png",   4)
  -- audios --
  sprites.som_ataque = love.audio.newSource("assets/audio/goblin/Attack.mp3", "static")
  
end

local function colide(a, b)
  return a.x < b.x + b.largura and
         a.x + a.largura > b.x and
         a.y < b.y + b.altura and
         a.y + a.altura > b.y
end

local function goblin(x, y)
  return {
    vivo = true,
    x = x,
    y = y,
    largura = 32,
    altura = 32,

    vida = 40,
    velocidade = 100,
    raio_visao = 250,
    dist_ataque = 60,
    som_tocou = false,

    pode_tomar_dano = true,
    tempo_dano = 0,
    cooldown_dano = 0.5,

    estado = "idle",
    frame_atual = 1,
    tempo_animacao = 0,
    frame_dano = 8,
    dano_aplicado = false,

    pode_atacar = true,
    tempo_ataque = 0,
    cooldown_ataque = 1,

    vel_anim = {
      idle   = 0.15,
      run    = 0.12,
      attack = 0.08,
      hit    = 0.1,
      death  = 0.15,
    },

    escala   = 2,
    direcao  = -1,
    offset_y = 100,

    y_velocidade = 0,
    gravidade    = 1200,
    no_chao      = false,
  }
end

local posicoes_spawn = {
  { x = 450,  y = 362 },
  { x = 800,  y = 362 },
  { x = 630,  y = 170 },
  { x = 970,  y = 280 },
  { x = 1400, y = 314 },
  { x = 1800, y = 170 }
}
local function getHitboxAtaque(g)
  local largura = 80
  local altura  = g.altura + 20

  if g.direcao == 1 then
    return { x = g.x + g.largura, y = g.y, largura = largura, altura = altura }
  else
    return { x = g.x - largura,   y = g.y, largura = largura, altura = altura }
  end
end

function Enemy.load()
  carrega_sprites()
  Enemy.lista = {}
  local s = Mapa.escala or 1
  for _, pos in ipairs(posicoes_spawn) do
    local g = goblin(pos.x * s, pos.y * s)
    g.no_chao = true
    g.y_velocidade = 0
    table.insert(Enemy.lista, g)
  end
end

local function update_goblin(g, dt, player, plataformas)
  -- cooldown de dano recebido
  if not g.pode_tomar_dano then
    g.tempo_dano = g.tempo_dano + dt
    if g.tempo_dano >= g.cooldown_dano then
      g.pode_tomar_dano = true
      g.tempo_dano = 0
    end
  end

  -- cooldown de ataque
  if not g.pode_atacar then
    g.tempo_ataque = g.tempo_ataque + dt
    if g.tempo_ataque >= g.cooldown_ataque then
      g.pode_atacar = true
      g.tempo_ataque = 0
    end
  end

  -- receber dano do player
  local hitbox_player = player.getHitboxAtaque and player.getHitboxAtaque()
  if hitbox_player and colide(g, hitbox_player) and g.pode_tomar_dano and g.vivo then
    g.vida = g.vida - 10
    g.pode_tomar_dano = false

    if g.vida <= 0 then
      g.estado = "death"
      g.frame_atual = 1
      g.tempo_animacao = 0
      g.vivo = false
    else
      g.estado = "hit"
      g.frame_atual = 1
      g.tempo_animacao = 0
      g.x = g.x + (player.direcao * 60)
    end
  end

  if g.estado ~= "hit" and g.estado ~= "death" then
    local dx     = player.x - g.x
    local dy     = player.y - g.y
    local dist_x = math.abs(dx)
    local dist_y = math.abs(dy)

    g.direcao = (dx > 0) and 1 or -1

    local alinhado_vertical = dist_y < 40

    if dist_x < g.dist_ataque and alinhado_vertical then
      if g.estado ~= "attack" then
        g.estado = "attack"
        g.frame_atual = 1
        g.tempo_animacao = 0
        g.dano_aplicado = false
      end

    elseif dist_x < g.raio_visao and alinhado_vertical then
      g.estado = "run"

    else
      g.estado = "idle"
    end
  end

  if g.estado == "run" then
    local proximo_x = g.x + g.velocidade * g.direcao * dt
    local tem_chao_a_frente = false

    for _, plat in ipairs(plataformas or {}) do
      local borda_frente
      if g.direcao == 1 then
        borda_frente = proximo_x + g.largura
      else
        borda_frente = proximo_x
      end

      local dentro_plat_x = borda_frente >= plat.x and borda_frente <= plat.x + plat.largura
      local chao_logo_abaixo = plat.y >= g.y + g.altura and plat.y <= g.y + g.altura + 16

      if dentro_plat_x and chao_logo_abaixo then
        tem_chao_a_frente = true
        break
      end
    end

    if tem_chao_a_frente then
      g.x = proximo_x
    else
      g.estado = "idle"
    end
    
  end

  g.y_velocidade = g.y_velocidade + g.gravidade * dt
  g.y = g.y + g.y_velocidade * dt
  g.no_chao = false

  for _, plat in ipairs(plataformas or {}) do
    if g.y + g.altura >= plat.y and
        g.y + g.altura <= plat.y + 60 and
       g.x + g.largura > plat.x and
       g.x < plat.x + plat.largura and
       g.y_velocidade >= 0 then

      g.y = plat.y - g.altura
      g.y_velocidade = 0
      g.no_chao = true
    end
  end

  local vel = g.vel_anim[g.estado] or 0.1
  g.tempo_animacao = g.tempo_animacao + dt
  if g.tempo_animacao >= vel then
    g.tempo_animacao = 0
    g.frame_atual = g.frame_atual + 1
    
    if g.estado == "attack" and g.frame_atual == #sprites.attack_q and not g.som_tocou then
      sprites.som_ataque:stop()
      sprites.som_ataque:play()
      g.som_tocou = true
    end
  end

  local limites = {
    idle   = #sprites.idle_q,
    run    = #sprites.run_q,
    attack = #sprites.attack_q,
    hit    = #sprites.hit_q,
    death  = #sprites.death_q,
  }
  local limite = limites[g.estado] or 1

  if g.frame_atual > limite then
     g.som_tocou = false
    if g.estado == "hit" then
      g.estado = "idle"
      g.frame_atual = 1
    elseif g.estado == "death" then
      g.frame_atual = limite
    else
      g.frame_atual = 1
    end
  end

  if g.estado == "attack" and g.vivo and player.vivo then
    if g.frame_atual == g.frame_dano and not g.dano_aplicado then
      local hb = getHitboxAtaque(g)
      if colide(player, hb) then
        player.tomarDano(g.direcao, 10)
      end
      g.dano_aplicado = true
    end
  end

  if g.frame_atual ~= g.frame_dano then
    g.dano_aplicado = false
  end
end

function Enemy.update(dt, player, plataformas)
  if not player.vivo then return end

  for _, g in ipairs(Enemy.lista) do
    if g.vivo or g.estado == "death" then
      update_goblin(g, dt, player, plataformas)
    end
  end
end

local function draw_goblin(g)
  local img, quads, fw, fh

  if g.estado == "attack" then
    img, quads, fw, fh = sprites.attack_img, sprites.attack_q, sprites.attack_w, sprites.attack_h
  elseif g.estado == "hit" then
    img, quads, fw, fh = sprites.hit_img,    sprites.hit_q,    sprites.hit_w,    sprites.hit_h
  elseif g.estado == "death" then
    img, quads, fw, fh = sprites.death_img,  sprites.death_q,  sprites.death_w,  sprites.death_h
  elseif g.estado == "run" then
    img, quads, fw, fh = sprites.run_img,    sprites.run_q,    sprites.run_w,    sprites.run_h
  else
    img, quads, fw, fh = sprites.idle_img,   sprites.idle_q,   sprites.idle_w,   sprites.idle_h
  end

  local quad    = quads[g.frame_atual] or quads[1]
  local pivot_x = g.x + (g.largura / 2)
  local pivot_y = g.y + g.altura + g.offset_y

  love.graphics.draw(
    img, quad,
    pivot_x, pivot_y,
    0,
    g.escala * g.direcao,
    g.escala,
    fw / 2,
    fh
  )
end

function Enemy.draw()
  for _, g in ipairs(Enemy.lista) do
    if g.vivo or g.estado == "death" then
      draw_goblin(g)
    end
  end
end