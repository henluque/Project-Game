Enemy = {}

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

local function colide(a, b)
  return a.x < b.x + b.largura and
         a.x + a.largura > b.x and
         a.y < b.y + b.altura and
         a.y + a.altura > b.y
end

function Enemy.getHitboxAtaque()
  local largura = 80
  local altura = Enemy.altura + 20

  if Enemy.direcao == 1 then
    return {
      x = Enemy.x + Enemy.largura,
      y = Enemy.y,
      largura = largura,
      altura = altura
    }
  else
    return {
      x = Enemy.x - largura,
      y = Enemy.y,
      largura = largura,
      altura = altura
    }
  end
end

function Enemy.load()
  Enemy.vida = 40
  Enemy.vivo = true

  Enemy.x = 500
  Enemy.y = 350

  Enemy.largura = 32
  Enemy.altura = 32

  Enemy.velocidade = 100
  Enemy.raio_visao = 250
  Enemy.dist_ataque = 60

  Enemy.pode_tomar_dano = true
  Enemy.tempo_dano = 0
  Enemy.cooldown_dano = 0.5

  Enemy.estado = "idle"

  -- SPRITES
  Enemy.sprite_idle, Enemy.quads_idle, Enemy.frame_w, Enemy.frame_h =
    carrega_sheet("assets/sprites/goblin/Idle.png", 4)

  Enemy.sprite_run, Enemy.quads_run, Enemy.frame_w_r, Enemy.frame_h_r =
    carrega_sheet("assets/sprites/goblin/Run.png", 8)

  Enemy.sprite_attack, Enemy.quads_attack, Enemy.frame_w_a, Enemy.frame_h_a =
    carrega_sheet("assets/sprites/goblin/Attack.png", 8)

  Enemy.sprite_hit, Enemy.quads_hit, Enemy.frame_w_h, Enemy.frame_h_h =
    carrega_sheet("assets/sprites/goblin/Take_hit.png", 4)

  Enemy.sprite_death, Enemy.quads_death, Enemy.frame_w_d, Enemy.frame_h_d =
    carrega_sheet("assets/sprites/goblin/Death.png", 4)

  Enemy.frame_atual = 1
  Enemy.tempo_animacao = 0

  Enemy.vel_anim = {
    idle = 0.15,
    run = 0.12,
    attack = 0.08,
    hit = 0.1,
    death = 0.15
  }

  Enemy.escala = 3
  Enemy.direcao = -1

  Enemy.y_velocidade = 0
  Enemy.gravidade = 1200
  Enemy.no_chao = false
end

function Enemy.update(dt, player, plataformas)

  local hitbox = player.getHitboxAtaque and player.getHitboxAtaque()

  if not Enemy.pode_tomar_dano then
    Enemy.tempo_dano = Enemy.tempo_dano + dt
    if Enemy.tempo_dano >= Enemy.cooldown_dano then
      Enemy.pode_tomar_dano = true
      Enemy.tempo_dano = 0
    end
  end

  if hitbox and colide(Enemy, hitbox) and Enemy.pode_tomar_dano and Enemy.vivo then
    Enemy.vida = Enemy.vida - 10
    Enemy.pode_tomar_dano = false

    if Enemy.vida <= 0 then
      Enemy.estado = "death"
      Enemy.frame_atual = 1
      Enemy.tempo_animacao = 0
      Enemy.vivo = false
    else
      Enemy.estado = "hit"
      Enemy.frame_atual = 1
      Enemy.tempo_animacao = 0

      Enemy.x = Enemy.x + (player.direcao * 60)
    end
  end

  -- BLOQUEIA IA DURANTE HIT/DEATH
  if Enemy.estado ~= "hit" and Enemy.estado ~= "death" then

    local dx = player.x - Enemy.x
    local dy = player.y - Enemy.y

    local dist_x = math.abs(dx)
    local dist_y = math.abs(dy)

    Enemy.direcao = (dx > 0) and 1 or -1

    local alinhado_vertical = dist_y < 40

    if dist_x < Enemy.dist_ataque and alinhado_vertical then
      Enemy.estado = "attack"

    elseif dist_x < Enemy.raio_visao then
      if alinhado_vertical then
        Enemy.estado = "run"
      else
        Enemy.estado = "idle"
      end

    else
      Enemy.estado = "idle"
    end
  end

  if Enemy.estado == "run" then
    Enemy.x = Enemy.x + Enemy.velocidade * Enemy.direcao * dt
  end

  Enemy.y_velocidade = Enemy.y_velocidade + Enemy.gravidade * dt
  Enemy.y = Enemy.y + Enemy.y_velocidade * dt
  Enemy.no_chao = false

  for _, plat in ipairs(plataformas or {}) do
    if Enemy.y + Enemy.altura >= plat.y and
       Enemy.y + Enemy.altura <= plat.y + 10 and
       Enemy.x + Enemy.largura > plat.x and
       Enemy.x < plat.x + plat.largura and
       Enemy.y_velocidade >= 0 then

      Enemy.y = plat.y - Enemy.altura
      Enemy.y_velocidade = 0
      Enemy.no_chao = true
    end
  end

  local vel = Enemy.vel_anim[Enemy.estado] or 0.1
  Enemy.tempo_animacao = Enemy.tempo_animacao + dt

  if Enemy.tempo_animacao >= vel then
    Enemy.tempo_animacao = 0
    Enemy.frame_atual = Enemy.frame_atual + 1
  end

  local limite = 1

  if Enemy.estado == "idle" then
    limite = #Enemy.quads_idle
  elseif Enemy.estado == "run" then
    limite = #Enemy.quads_run
  elseif Enemy.estado == "attack" then
    limite = #Enemy.quads_attack
  elseif Enemy.estado == "hit" then
    limite = #Enemy.quads_hit
  elseif Enemy.estado == "death" then
    limite = #Enemy.quads_death
  end

  if Enemy.frame_atual > limite then
    if Enemy.estado == "hit" then
      Enemy.estado = "idle"
      Enemy.frame_atual = 1

    elseif Enemy.estado == "death" then
      Enemy.frame_atual = limite

    else
      Enemy.frame_atual = 1
    end
  end
  
  if Enemy.estado == "attack" and Enemy.vivo then
    local hitbox = Enemy.getHitboxAtaque()
    if colide(player, hitbox) then
      player.tomarDano(Enemy.direcao)
    end
  end
  
end

function Enemy.draw()
  local sprite, quads, frame_w, frame_h

  if Enemy.estado == "attack" then
    sprite = Enemy.sprite_attack
    quads = Enemy.quads_attack
    frame_w = Enemy.frame_w_a
    frame_h = Enemy.frame_h_a

  elseif Enemy.estado == "hit" then
    sprite = Enemy.sprite_hit
    quads = Enemy.quads_hit
    frame_w = Enemy.frame_w_h
    frame_h = Enemy.frame_h_h

  elseif Enemy.estado == "death" then
    sprite = Enemy.sprite_death
    quads = Enemy.quads_death
    frame_w = Enemy.frame_w_d
    frame_h = Enemy.frame_h_d

  elseif Enemy.estado == "run" then
    sprite = Enemy.sprite_run
    quads = Enemy.quads_run
    frame_w = Enemy.frame_w_r
    frame_h = Enemy.frame_h_r

  else
    sprite = Enemy.sprite_idle
    quads = Enemy.quads_idle
    frame_w = Enemy.frame_w
    frame_h = Enemy.frame_h
  end

  local quad = quads[Enemy.frame_atual] or quads[1]

  local pivot_x = Enemy.x + (Enemy.largura / 2)
  local pivot_y = Enemy.y + Enemy.altura + 148

  love.graphics.draw(
    sprite,
    quad,
    pivot_x,
    pivot_y,
    0,
    Enemy.escala * Enemy.direcao,
    Enemy.escala,
    frame_w / 2,
    frame_h
  )
end