Magnus = {}

local sprites_magnus = nil

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

local function carrega_sprites_magnus()
  if sprites_magnus then return end

  sprites_magnus = {}
  sprites_magnus.idle_img,    sprites_magnus.idle_q,    sprites_magnus.idle_w,    sprites_magnus.idle_h    = carrega_sheet("assets/sprites/magnus/Idle.png",     10)
  sprites_magnus.run_img,     sprites_magnus.run_q,     sprites_magnus.run_w,     sprites_magnus.run_h     = carrega_sheet("assets/sprites/magnus/Run.png",       8)
  sprites_magnus.attack1_img, sprites_magnus.attack1_q, sprites_magnus.attack1_w, sprites_magnus.attack1_h = carrega_sheet("assets/sprites/magnus/Attack1.png",   7)
  sprites_magnus.attack2_img, sprites_magnus.attack2_q, sprites_magnus.attack2_w, sprites_magnus.attack2_h = carrega_sheet("assets/sprites/magnus/Attack2.png",   7)
  sprites_magnus.attack3_img, sprites_magnus.attack3_q, sprites_magnus.attack3_w, sprites_magnus.attack3_h = carrega_sheet("assets/sprites/magnus/Attack3.png",   8)
  sprites_magnus.hit_img,     sprites_magnus.hit_q,     sprites_magnus.hit_w,     sprites_magnus.hit_h     = carrega_sheet("assets/sprites/magnus/Get_hit.png",  3)
  sprites_magnus.death_img,   sprites_magnus.death_q,   sprites_magnus.death_w,   sprites_magnus.death_h   = carrega_sheet("assets/sprites/magnus/Death.png",     7)
end

local function colide(a, b)
  return a.x < b.x + b.largura and
         a.x + a.largura > b.x and
         a.y < b.y + b.altura and
         a.y + a.altura > b.y
end

local function getHitboxAtaque(m)
  local largura = 100
  local altura  = m.altura + 20

  if m.direcao == 1 then
    return { x = m.x + m.largura, y = m.y, largura = largura, altura = altura }
  else
    return { x = m.x - largura,   y = m.y, largura = largura, altura = altura }
  end
end

local function atacando(m)
  return m.estado == "attack1" or m.estado == "attack2" or m.estado == "attack3"
end

local function novo_magnus(x, y)
  return {
    vivo = true,
    x = x,
    y = y,
    largura = 48,
    altura  = 64,

    vida = 150,
    velocidade = 100,
    raio_visao = 350,
    dist_ataque = 80,

    pode_tomar_dano = true,
    tempo_dano = 0,
    cooldown_dano = 0.5,

    combo_count = 0,
    combo_fila = {},

    estado = "idle",
    frame_atual = 1,
    tempo_animacao = 0,
    dano_aplicado = false,

    frame_dano = {
      attack1 = 4,
      attack2 = 4,
      attack3 = 4,
    },

    pode_atacar = true,
    tempo_ataque = 0,
    cooldown_ataque = 1.2,

    vel_anim = {
      idle    = 0.10,
      run     = 0.10,
      attack1 = 0.09,
      attack2 = 0.09,
      attack3 = 0.09,
      hit     = 0.10,
      death   = 0.12,
    },

    escala   = 2.5,
    direcao  = -1,
    offset_y = 150,

    y_velocidade = 0,
    gravidade    = 1200,
    no_chao      = false,
    som1_tocou = false,

    tempo_em_range  = 0,
    gatilho_forcado = 0.8,   
  }
end

local posicao_spawn = { x = 1250, y = 300 }

function Magnus.load()
  Magnus.som_ataque = love.audio.newSource("assets/audio/magnus/Sword_Attack1.mp3", "static")
  carrega_sprites_magnus()
  Magnus.instancia = novo_magnus(posicao_spawn.x, posicao_spawn.y)
end

local function iniciar_ataque(m, player)
  
  local dx = m.x - player.x
  local distancia_ideal = m.dist_ataque * 0.8
  if math.abs(dx) < distancia_ideal then
    m.x = player.x + (dx > 0 and distancia_ideal or -distancia_ideal)
  end
  
  m.combo_count = m.combo_count + 1

  if m.combo_count >= 3 then
    m.combo_fila = { "attack1", "attack2", "attack3" }
    m.combo_count = 0
  elseif m.combo_count == 2 then
    m.combo_fila = { "attack1", "attack2" }
  else
    m.combo_fila = { "attack1" }
  end

  m.estado = table.remove(m.combo_fila, 1)
  m.frame_atual = 1
  m.tempo_animacao = 0
  m.dano_aplicado = false
  m.pode_atacar = false
  
end

local function update_magnus(m, dt, player, plataformas)
  if not m.pode_tomar_dano then
    m.tempo_dano = m.tempo_dano + dt
    if m.tempo_dano >= m.cooldown_dano then
      m.pode_tomar_dano = true
      m.tempo_dano = 0
    end
  end

  if not m.pode_atacar then
    m.tempo_ataque = m.tempo_ataque + dt
    if m.tempo_ataque >= m.cooldown_ataque then
      m.pode_atacar = true
      m.tempo_ataque = 0
    end
  end

  local hitbox_player = player.getHitboxAtaque and player.getHitboxAtaque()
  if hitbox_player and colide(m, hitbox_player) and m.pode_tomar_dano and m.vivo then
    m.vida = m.vida - 10
    m.pode_tomar_dano = false

    if m.vida <= 0 then
      m.estado = "death"
      m.frame_atual = 1
      m.tempo_animacao = 0
      m.vivo = false
      m.combo_fila = {}
    else
      local dx_hit = math.abs(player.x - m.x)
      local prestes_a_atacar = dx_hit < m.dist_ataque and m.tempo_em_range > 0
      if not atacando(m) and not prestes_a_atacar then
        m.estado = "hit"
        m.frame_atual = 1
        m.tempo_animacao = 0
      end

    end
  end

  -- IA (bloqueada durante ataques, hit e death)
  if not atacando(m) and m.estado ~= "hit" and m.estado ~= "death" then
    local dx     = player.x - m.x
    local dy     = player.y - m.y
    local dist_x = math.abs(dx)
    local dist_y = math.abs(dy)

    m.direcao = (dx > 0) and 1 or -1

    local alinhado_vertical = dist_y < 50
    local em_range = dist_x < m.dist_ataque and alinhado_vertical

    -- acumula tempo dentro do range de ataque
    if em_range then
      m.tempo_em_range = m.tempo_em_range + dt
    else
      m.tempo_em_range = 0
    end

    -- ataque forçado: se ficou tempo suficiente em range, ignora cooldown
    local forcar_ataque = em_range and (m.tempo_em_range >= m.gatilho_forcado)

    if em_range and (m.pode_atacar or forcar_ataque) then
      m.pode_atacar   = true   -- reseta flag para forçar entrada em iniciar_ataque
      m.tempo_em_range = 0
      iniciar_ataque(m, player)

    elseif dist_x < m.raio_visao and alinhado_vertical then
      m.estado = "run"

    else
      m.estado = "idle"
    end
  end

  -- movimento
  if m.estado == "run" then
    m.x = m.x + m.velocidade * m.direcao * dt
  end

  -- gravidade
  m.y_velocidade = m.y_velocidade + m.gravidade * dt
  m.y = m.y + m.y_velocidade * dt
  m.no_chao = false

  for _, plat in ipairs(plataformas or {}) do
    if m.y + m.altura >= plat.y and
       m.y + m.altura <= plat.y + 10 and
       m.x + m.largura > plat.x and
       m.x < plat.x + plat.largura and
       m.y_velocidade >= 0 then

      m.y = plat.y - m.altura
      m.y_velocidade = 0
      m.no_chao = true
    end
  end

  -- avança animação
  local vel = m.vel_anim[m.estado] or 0.1
  m.tempo_animacao = m.tempo_animacao + dt
  if m.tempo_animacao >= vel then
    m.tempo_animacao = 0
    m.frame_atual = m.frame_atual + 1
  end

  local limites = {
    idle    = #sprites_magnus.idle_q,
    run     = #sprites_magnus.run_q,
    attack1 = #sprites_magnus.attack1_q,
    attack2 = #sprites_magnus.attack2_q,
    attack3 = #sprites_magnus.attack3_q,
    hit     = #sprites_magnus.hit_q,
    death   = #sprites_magnus.death_q,
  }
  local limite = limites[m.estado] or 1

  if m.frame_atual > limite then
    if m.estado == "hit" then
      m.estado = "idle"
      m.frame_atual = 1

    elseif m.estado == "death" then
      m.frame_atual = limite

    elseif atacando(m) then
      -- próxima animação na fila, ou fim do combo
      if #m.combo_fila > 0 then
        m.estado = table.remove(m.combo_fila, 1)
        m.frame_atual = 1
        m.tempo_animacao = 0
        m.dano_aplicado = false
      else
        m.tempo_ataque = 0
        m.estado = "idle"
        m.frame_atual = 1
      end

    else
      m.frame_atual = 1
    end
  end

  -- aplicar dano no player
  if atacando(m) and m.vivo and player.vivo then
    local fd = m.frame_dano[m.estado] or 4
    if m.frame_atual == fd and not m.dano_aplicado then
      local hb = getHitboxAtaque(m)
      if colide(player, hb) then
        player.tomarDano(m.direcao, 20)
      end
      Magnus.som_ataque:stop() 
      Magnus.som_ataque:play()  
      m.dano_aplicado = true
    end
  end

  if m.frame_atual ~= (m.frame_dano[m.estado] or 4) then
    m.dano_aplicado = false
  end
end

function Magnus.update(dt, player, plataformas)
  if not player.vivo then return end

  local m = Magnus.instancia
  if m and (m.vivo or m.estado == "death") then
    update_magnus(m, dt, player, plataformas)
  end
end

local function draw_magnus(m)
  local img, quads, fw, fh

  if m.estado == "attack1" then
    img, quads, fw, fh = sprites_magnus.attack1_img, sprites_magnus.attack1_q, sprites_magnus.attack1_w, sprites_magnus.attack1_h
  elseif m.estado == "attack2" then
    img, quads, fw, fh = sprites_magnus.attack2_img, sprites_magnus.attack2_q, sprites_magnus.attack2_w, sprites_magnus.attack2_h
  elseif m.estado == "attack3" then
    img, quads, fw, fh = sprites_magnus.attack3_img, sprites_magnus.attack3_q, sprites_magnus.attack3_w, sprites_magnus.attack3_h
  elseif m.estado == "hit" then
    img, quads, fw, fh = sprites_magnus.hit_img,     sprites_magnus.hit_q,     sprites_magnus.hit_w,     sprites_magnus.hit_h
  elseif m.estado == "death" then
    img, quads, fw, fh = sprites_magnus.death_img,   sprites_magnus.death_q,   sprites_magnus.death_w,   sprites_magnus.death_h
  elseif m.estado == "run" then
    img, quads, fw, fh = sprites_magnus.run_img,     sprites_magnus.run_q,     sprites_magnus.run_w,     sprites_magnus.run_h
  else
    img, quads, fw, fh = sprites_magnus.idle_img,    sprites_magnus.idle_q,    sprites_magnus.idle_w,    sprites_magnus.idle_h
  end

  local quad    = quads[m.frame_atual] or quads[1]
  local pivot_x = m.x + (m.largura / 2)
  local pivot_y = m.y + m.altura + m.offset_y

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    img, quad,
    pivot_x, pivot_y,
    0,
    m.escala * m.direcao,
    m.escala,
    fw / 2,
    fh
  )

  -- barra de vida
  local barra_largura = 200
  local barra_x = pivot_x - barra_largura / 2
  local barra_y = m.y - 80
  local pct = math.max(0, m.vida / 150)
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", barra_x, barra_y, barra_largura, 8)
  love.graphics.setColor(0.8, 0.1, 0.1)
  love.graphics.rectangle("fill", barra_x, barra_y, barra_largura * pct, 8)
  love.graphics.setColor(1, 1, 1)
end

function Magnus.draw()
  local m = Magnus.instancia
  if m and (m.vivo or m.estado == "death") then
    draw_magnus(m)
  end
end