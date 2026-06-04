Mimic = {}

local spr = nil

local function carrega_sheet(caminho, num_frames)
  local img = love.graphics.newImage(caminho)
  local w   = img:getWidth()
  local h   = img:getHeight()
  local slot = w / num_frames
  local quads = {}
  for i = 0, num_frames - 1 do
    table.insert(quads, love.graphics.newQuad(i * slot, 0, slot, h, w, h))
  end
  return img, quads, slot, h
end

local function carrega_sprites()
  if spr then return end
  spr = {}
  spr.closed_img, spr.closed_q, spr.closed_w, spr.closed_h =
    carrega_sheet("assets/sprites/mimic/Idle_closed.png", 1)
  spr.walk_img,   spr.walk_q,   spr.walk_w,   spr.walk_h   =
    carrega_sheet("assets/sprites/mimic/walk.png",        6)
  spr.death_img,  spr.death_q,  spr.death_w,  spr.death_h  =
    carrega_sheet("assets/sprites/mimic/death.png",       6)
  spr.chave_img = love.graphics.newImage("assets/items/key.png")
  spr.som_ataque = love.audio.newSource("assets/audio/mimic/Attack.wav", "static")
end

local function colide(a, b)
  return a.x < b.x + b.largura and
         a.x + a.largura > b.x and
         a.y < b.y + b.altura and
         a.y + a.altura > b.y
end

local function getHitboxAtaque(m)
  local largura = 70
  local altura  = m.altura + 10
  if m.direcao == 1 then
    return { x = m.x + m.largura, y = m.y, largura = largura, altura = altura }
  else
    return { x = m.x - largura,   y = m.y, largura = largura, altura = altura }
  end
end

-- Estado inicial
function Mimic.load()
  carrega_sprites()

  Mimic.x       = 1000
  Mimic.y       = 150
  Mimic.largura = 48
  Mimic.altura  = 48

  Mimic.vivo    = true
  Mimic.vida    = 60
  --  "fechado" → player bate uma vez -> "alerta" -> player bate de novo -> "walk/attack"
  Mimic.estado  = "fechado"
  Mimic.direcao = -1
  Mimic.som_tocou = false

  Mimic.velocidade   = 90
  Mimic.raio_visao   = 220
  Mimic.dist_ataque  = 55

  -- animação
  Mimic.frame_atual        = 1
  Mimic.tempo_animacao     = 0
  Mimic.frame_delay_closed = 0.20
  Mimic.frame_delay_walk   = 0.10
  Mimic.frame_delay_death  = 0.12

  -- dano recebido
  Mimic.pode_tomar_dano = true
  Mimic.tempo_dano      = 0
  Mimic.cooldown_dano   = 0.5

  -- ataque
  Mimic.pode_atacar     = true
  Mimic.tempo_ataque    = 0
  Mimic.cooldown_ataque = 1.2
  Mimic.frame_dano      = 4
  Mimic.dano_aplicado   = false

  -- gravidade
  Mimic.y_velocidade = 0
  Mimic.gravidade    = 1200
  Mimic.no_chao      = false

  -- escala visual
  Mimic.escala   = 2.0
  Mimic.offset_y = 125

  -- chave dropada
  Mimic.chave = nil
end

-- Update 
function Mimic.update(dt, player, plataformas)
  if not player.vivo then return end

  if not Mimic.vivo then
    Mimic.atualizarChave(player)

    if Mimic.estado == "death" then
      Mimic.tempo_animacao = Mimic.tempo_animacao + dt
      if Mimic.tempo_animacao >= Mimic.frame_delay_death then
        Mimic.tempo_animacao = 0
        if Mimic.frame_atual < #spr.death_q then
          Mimic.frame_atual = Mimic.frame_atual + 1
        end
        -- congela no último frame
      end
    end
    return
  end

  -- cooldown dano
  if not Mimic.pode_tomar_dano then
    Mimic.tempo_dano = Mimic.tempo_dano + dt
    if Mimic.tempo_dano >= Mimic.cooldown_dano then
      Mimic.pode_tomar_dano = true
      Mimic.tempo_dano = 0
    end
  end

  -- cooldown ataque
  if not Mimic.pode_atacar then
    Mimic.tempo_ataque = Mimic.tempo_ataque + dt
    if Mimic.tempo_ataque >= Mimic.cooldown_ataque then
      Mimic.pode_atacar = true
      Mimic.tempo_ataque = 0
    end
  end

  -- receber dano do player
  local hitbox_player = player.getHitboxAtaque and player.getHitboxAtaque()
  if hitbox_player and colide(Mimic, hitbox_player) and Mimic.pode_tomar_dano and Mimic.vivo then

    if Mimic.estado == "fechado" then
      Mimic.estado = "alerta"
      Mimic.frame_atual = 1
      Mimic.tempo_animacao = 0
    end

    -- segunda pancada em diante: desconta vida normalmente
    Mimic.vida = Mimic.vida - 10
    Mimic.pode_tomar_dano = false

    if Mimic.vida <= 0 then
      Mimic.estado = "death"
      Mimic.frame_atual = 1
      Mimic.tempo_animacao = 0
      Mimic.vivo = false
      Mimic.chave = { x = Mimic.x, y = Mimic.y, coletada = false }
    else
      if Mimic.estado == "alerta" then
        -- segunda pancada enquanto ainda está em alerta
        Mimic.estado = "walk"
        Mimic.frame_atual = 1
        Mimic.tempo_animacao = 0
      end
      -- knockback
      Mimic.x = Mimic.x + (player.direcao * 50)
    end
  end

  -- não roda se fechado, em alerta, ou em death
  if Mimic.vivo and Mimic.estado ~= "death"
                and Mimic.estado ~= "fechado"
                and Mimic.estado ~= "alerta" then

    local dx     = player.x - Mimic.x
    local dy     = player.y - Mimic.y
    local dist_x = math.abs(dx)
    local dist_y = math.abs(dy)

    Mimic.direcao = (dx > 0) and 1 or -1

    local alinhado = dist_y < 60

    if Mimic.estado ~= "attack" then
      if dist_x < Mimic.dist_ataque and alinhado and Mimic.pode_atacar then
        Mimic.estado = "attack"
        Mimic.frame_atual = 1
        Mimic.tempo_animacao = 0
        Mimic.dano_aplicado = false
        Mimic.pode_atacar = false
        Mimic.tempo_ataque = 0
      elseif dist_x < Mimic.raio_visao and alinhado then
        Mimic.estado = "walk"
        Mimic.x = Mimic.x + Mimic.velocidade * Mimic.direcao * dt
      else
        Mimic.estado = "walk"
      end
    end
  end

  -- no estado "alerta" só vira na direção do player, fica parado
  if Mimic.estado == "alerta" then
    local dx = player.x - Mimic.x
    Mimic.direcao = (dx > 0) and 1 or -1
  end

  -- gravidade
  Mimic.y_velocidade = Mimic.y_velocidade + Mimic.gravidade * dt
  Mimic.y = Mimic.y + Mimic.y_velocidade * dt
  Mimic.no_chao = false

  for _, plat in ipairs(plataformas or {}) do
    if Mimic.y + Mimic.altura >= plat.y and
       Mimic.y + Mimic.altura <= plat.y + 60 and
       Mimic.x + Mimic.largura > plat.x and
       Mimic.x < plat.x + plat.largura and
       Mimic.y_velocidade >= 0 then

      Mimic.y = plat.y - Mimic.altura
      Mimic.y_velocidade = 0
      Mimic.no_chao = true
    end
  end

  -- avança frame (só para estados que usam walk/closed; death é tratado acima)
  if Mimic.estado ~= "death" then
    local delay
    if Mimic.estado == "fechado" or Mimic.estado == "alerta" then
      delay = Mimic.frame_delay_closed
    else
      delay = Mimic.frame_delay_walk
    end

    Mimic.tempo_animacao = Mimic.tempo_animacao + dt
    if Mimic.tempo_animacao >= delay then
      Mimic.tempo_animacao = 0
      Mimic.frame_atual = Mimic.frame_atual + 1

      local limite
      if Mimic.estado == "fechado" or Mimic.estado == "alerta" then
        limite = #spr.closed_q
      else
        limite = #spr.walk_q
      end

      if Mimic.frame_atual > limite then
        if Mimic.estado == "attack" then
          Mimic.estado = "walk"
          Mimic.dano_aplicado = false
        end
        Mimic.frame_atual = 1
      end
    end
  end

  -- aplica dano no player
  if Mimic.estado == "attack" and Mimic.vivo and player.vivo then
    if Mimic.frame_atual == Mimic.frame_dano and not Mimic.dano_aplicado then
      local hb = getHitboxAtaque(Mimic)
      if colide(player, hb) then
        player.tomarDano(Mimic.direcao, 15)
      end
      if not Mimic.som_tocou then
        spr.som_ataque:stop()
        spr.som_ataque:play()
        Mimic.som_tocou = true
      end
      Mimic.dano_aplicado = true
    end
  end
  if Mimic.frame_atual ~= Mimic.frame_dano then
    Mimic.dano_aplicado = false
    Mimic.som_tocou = false
  end

  Mimic.atualizarChave(player)
end

function Mimic.atualizarChave(player)
  if not Mimic.chave or Mimic.chave.coletada then return end
  local c = Mimic.chave
  if player.x < c.x + 32 and player.x + player.largura > c.x and
     player.y < c.y + 32 and player.y + player.altura  > c.y then
    c.coletada = true
    Player.tem_chave = true
    Mapa.som_item:play()
  end
end

function Mimic.draw()
  if not spr then return end

  local img, quads, fw, fh

  if Mimic.estado == "fechado" or Mimic.estado == "alerta" then
    img, quads, fw, fh = spr.closed_img, spr.closed_q, spr.closed_w, spr.closed_h
  elseif Mimic.estado == "death" then
    img, quads, fw, fh = spr.death_img, spr.death_q, spr.death_w, spr.death_h
  else
    img, quads, fw, fh = spr.walk_img, spr.walk_q, spr.walk_w, spr.walk_h
  end

  local quad    = quads[Mimic.frame_atual] or quads[1]
  local pivot_x = Mimic.x + (Mimic.largura / 2)
  local pivot_y = Mimic.y + Mimic.altura + Mimic.offset_y

  -- pisca em laranja no estado "alerta"
  if Mimic.estado == "alerta" then
    local pulso = 0.7 + math.sin(love.timer.getTime() * 10) * 0.3
    love.graphics.setColor(1, pulso * 0.5, 0, 1)
  else
    love.graphics.setColor(1, 1, 1)
  end

  love.graphics.draw(
    img, quad,
    pivot_x, pivot_y,
    0,
    Mimic.escala * Mimic.direcao,
    Mimic.escala,
    fw / 2,
    fh
  )
  love.graphics.setColor(1, 1, 1)

  -- barra de vida (só quando acordado e vivo)
  if Mimic.vivo and Mimic.estado ~= "fechado" and Mimic.estado ~= "alerta" then
    local barra_w = 80
    local barra_x = pivot_x - barra_w / 2
    local barra_y = Mimic.y - 16
    local pct     = math.max(0, Mimic.vida / 60)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barra_x, barra_y, barra_w, 6)
    love.graphics.setColor(0.8, 0.3, 0.1)
    love.graphics.rectangle("fill", barra_x, barra_y, barra_w * pct, 6)
    love.graphics.setColor(1, 1, 1)
  end

  -- chave no chão
  if Mimic.chave and not Mimic.chave.coletada then
    local c = Mimic.chave
    local escala_chave = 48 / math.max(spr.chave_img:getWidth(), spr.chave_img:getHeight())
    local pulso = 0.7 + math.sin(love.timer.getTime() * 5) * 0.3
    love.graphics.setColor(1, 1, 0.4, pulso)
    love.graphics.draw(spr.chave_img, c.x, c.y, 0, escala_chave, escala_chave)
    love.graphics.setColor(1, 1, 1)
  end
end