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

function Enemy.load()
  Enemy.x = 500
  Enemy.y = 350

  Enemy.largura = 32
  Enemy.altura = 32

  Enemy.velocidade = 100
  Enemy.raio_visao = 250
  Enemy.dist_ataque = 60

  Enemy.estado = "idle"

  Enemy.sprite_idle, Enemy.quads_idle, Enemy.frame_w, Enemy.frame_h =
    carrega_sheet("assets/sprites/Goblin/idle.png", 4)
  
  Enemy.sprite_run, Enemy.quads_run, Enemy.frame_w_r, Enemy.frame_h_r =
    carrega_sheet("assets/sprites/Goblin/Run.png", 8)

  Enemy.sprite_attack, Enemy.quads_attack, Enemy.frame_w_a, Enemy.frame_h_a =
    carrega_sheet("assets/sprites/Goblin/attack.png", 8)

  Enemy.frame_atual = 1
  Enemy.tempo_animacao = 0

  Enemy.vel_anim = {
    idle = 0.15,
    run = 0.12,
    attack = 0.08
  }

  Enemy.escala = 3
  Enemy.direcao = -1

  Enemy.offset_x = 0
  Enemy.offset_y = 0
  
  Enemy.y_velocidade = 0
  Enemy.gravidade = 1200
  Enemy.no_chao = false
end

function Enemy.update(dt, player, plataformas)
  local dx = player.x - Enemy.x
  local dist = math.abs(dx)

  -- direção (depende da posição do player)
  if dx > 0 then
    Enemy.direcao = 1
  else
    Enemy.direcao = -1
  end

  -- estados
  if dist < Enemy.dist_ataque then
    Enemy.estado = "attack"
  elseif dist < Enemy.raio_visao then
    Enemy.estado = "run"
  else
    Enemy.estado = "idle"
  end

  -- movimento horizontal
  if Enemy.estado == "run" then
    Enemy.x = Enemy.x + Enemy.velocidade * Enemy.direcao * dt
  end

  -- gravidade
  Enemy.y_velocidade = Enemy.y_velocidade + Enemy.gravidade * dt
  Enemy.y = Enemy.y + Enemy.y_velocidade * dt
  Enemy.no_chao = false

  -- colisão
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

  -- animação
  local vel = Enemy.vel_anim[Enemy.estado] or 0.1
  Enemy.tempo_animacao = Enemy.tempo_animacao + dt

  if Enemy.tempo_animacao >= vel then
    Enemy.tempo_animacao = 0
    Enemy.frame_atual = Enemy.frame_atual + 1

    local limite = 1
    if Enemy.estado == "idle" then
      limite = #Enemy.quads_idle
    elseif Enemy.estado == "run" then
      limite = #Enemy.quads_run
    elseif Enemy.estado == "attack" then
      limite = #Enemy.quads_attack
    end

    if Enemy.frame_atual > limite then
      Enemy.frame_atual = 1
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
  elseif Enemy.estado == "idle" then
    sprite = Enemy.sprite_idle
    quads = Enemy.quads_idle
    frame_w = Enemy.frame_w
    frame_h = Enemy.frame_h
  else
    sprite = Enemy.sprite_run
    quads = Enemy.quads_run
    frame_w = Enemy.frame_w_r
    frame_h = Enemy.frame_h_r
  end

  local quad = quads[Enemy.frame_atual] or quads[1]

  local pivot_x = Enemy.x + (Enemy.largura / 2) + Enemy.offset_x
  local ajuste_visual = 148
  local pivot_y = Enemy.y + Enemy.altura + ajuste_visual

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