Helga = {}
Helga.projeteis = {}

function Helga.spawnProjetil(player)
  local dir_x = Helga.direcao
  local offset_x = 50 * Helga.direcao
  local offset_y = Helga.y_offset - 20

  table.insert(Helga.projeteis, {
    x = Helga.x + offset_x,
    y = Helga.y + offset_y,
    vx = dir_x * 250,
    vy = 0,
    frame = 1,
    tempo = 0,
    vivo = true
  })
end

local function carrega_sheet(caminho, num_frames)
  local img = love.graphics.newImage(caminho)
  local w = img:getWidth()
  local h = img:getHeight()
  local slot = w / num_frames
  local quads = {}
  for i = 0, num_frames - 1 do
    table.insert(quads, love.graphics.newQuad(i * slot, 0, slot, h, w, h))
  end
  return img, quads, slot, h
end

function Helga.setAnim(nome)
  if Helga.animacao_atual ~= nome then
    Helga.animacao_atual = nome
    Helga.frame_atual = 1
    Helga.tempo_animacao = 0
  end
end

local function colide(a, b)
  return a.x < b.x + b.largura and
         b.x < a.x + a.largura and
         a.y < b.y + b.altura and
         b.y < a.y + a.altura
end

function Helga.load()
  Helga.vida = 30
  Helga.x = 600
  Helga.y = 300
  Helga.largura = 64
  Helga.altura = 64
  Helga.velocidade = 80
  Helga.dist_ataque = 300
  Helga.vivo = true
  Helga.estado = "idle"
  Helga.direcao = 1

  Helga.cooldown_ataque = 2
  Helga.tempo_ataque = 0
  Helga.pode_atacar = true

  Helga.pode_tomar_dano = true
  Helga.tempo_dano = 0
  Helga.cooldown_dano = 0.5
  Helga.dano_aplicado = false

  Helga.animacoes = {}
  Helga.animacao_atual = "idle"
  Helga.frame_atual = 1
  Helga.tempo_animacao = 0
  Helga.frame_delay = 0.1
  Helga.escala = 2.5
  Helga.y_offset = 145

  local function carregarAnim(nome, frames)
    local img, quads, w, h = carrega_sheet("assets/sprites/helga/corrupted/" .. nome .. ".png", frames)
    return { img = img, quads = quads, w = w, h = h }
  end

  Helga.animacoes.idle   = carregarAnim("Idle",    10)
  Helga.animacoes.walk   = carregarAnim("Walk",     8)
  Helga.animacoes.attack = carregarAnim("Attack",  13)
  Helga.animacoes.hit    = carregarAnim("Get_hit",  3)
  Helga.animacoes.death  = carregarAnim("Death",   18)

  Helga.frame_tiro = 8
  Helga.atirou = false
  Helga.projetil = {}
  Helga.projetil.img, Helga.projetil.quads, Helga.projetil.w, Helga.projetil.h =
    carrega_sheet("assets/sprites/helga/corrupted/projectile/Moving.png", 4)
  Helga.projeteis = {}
end

function Helga.update(dt, player)

  -- 1. HELGA MORREU
  if not Helga.vivo then
    Helga.setAnim("death")
    local anim = Helga.animacoes[Helga.animacao_atual]
    Helga.tempo_animacao = Helga.tempo_animacao + dt
    if Helga.tempo_animacao >= Helga.frame_delay then
      Helga.tempo_animacao = 0
      Helga.frame_atual = Helga.frame_atual + 1
      if Helga.frame_atual > #anim.quads then
        Helga.frame_atual = #anim.quads
      end
    end
    return
  end

  -- 2. PLAYER MORREU
  if not player.vivo then
    Helga.setAnim("idle")
    return
  end

  -- 3. COOLDOWNS
  if not Helga.pode_atacar then
    Helga.tempo_ataque = Helga.tempo_ataque + dt
    if Helga.tempo_ataque >= Helga.cooldown_ataque then
      Helga.pode_atacar = true
      Helga.tempo_ataque = 0
    end
  end

  if not Helga.pode_tomar_dano then
    Helga.tempo_dano = Helga.tempo_dano + dt
    if Helga.tempo_dano >= Helga.cooldown_dano then
      Helga.pode_tomar_dano = true
      Helga.tempo_dano = 0
    end
  end

  -- 4. RECEBER DANO
  local hitbox = player.getHitboxAtaque and player.getHitboxAtaque()
  local helga_corpo = {
    x = Helga.x - 40,
    y = Helga.y + 80,
    largura = 100,
    altura  = 120
  }

  if hitbox and colide(helga_corpo, hitbox) and Helga.pode_tomar_dano then
    Helga.vida = Helga.vida - 10
    Helga.pode_tomar_dano = false

    if Helga.vida <= 0 then
      Helga.estado = "death"
      Helga.vivo = false
      Helga.frame_atual = 1
      Helga.tempo_animacao = 0
    else
      Helga.estado = "hit"
      Helga.frame_atual = 1
      Helga.tempo_animacao = 0
      Helga.x = Helga.x + (player.direcao * 60)
    end
  end

  -- 5. LÓGICA DE IA
  local dx = player.x - Helga.x
  local dist_x = math.abs(dx)
  Helga.direcao = (dx > 0) and 1 or -1

  if Helga.estado ~= "hit" and Helga.estado ~= "death" and Helga.estado ~= "attack" then

    if dist_x >= Helga.dist_ataque then
      -- longe: persegue
      Helga.estado = "run"
      Helga.x = Helga.x + Helga.direcao * Helga.velocidade * dt

    elseif Helga.pode_atacar then
      -- dentro do range e pode atacar: ataca (sem checar dist_y, ela atira horizontal)
      Helga.estado = "attack"
      Helga.frame_atual = 1
      Helga.tempo_animacao = 0
      Helga.atirou = false

    else
      -- dentro do range mas cooldown ativo: espera
      Helga.estado = "idle"
    end
  end

  -- 6. SINCRONIZA ANIMAÇÃO
  if Helga.estado == "idle" then
    Helga.setAnim("idle")
  elseif Helga.estado == "run" then
    Helga.setAnim("walk")
  elseif Helga.estado == "attack" then
    Helga.setAnim("attack")
  elseif Helga.estado == "hit" then
    Helga.setAnim("hit")
  elseif Helga.estado == "death" then
    Helga.setAnim("death")
  end

  -- 7. AVANÇA FRAME
  local anim = Helga.animacoes[Helga.animacao_atual]
  Helga.tempo_animacao = Helga.tempo_animacao + dt
  if Helga.tempo_animacao >= Helga.frame_delay then
    Helga.tempo_animacao = 0
    Helga.frame_atual = Helga.frame_atual + 1

    if Helga.frame_atual > #anim.quads then
      if Helga.estado == "death" then
        Helga.frame_atual = #anim.quads
      elseif Helga.estado == "hit" then
        Helga.estado = "idle"
        Helga.frame_atual = 1
      elseif Helga.estado == "attack" then
        Helga.estado = "idle"
        Helga.frame_atual = 1
        Helga.atirou = false
      else
        Helga.frame_atual = 1
      end
    end
  end

  -- 8. DISPARO
  if Helga.estado == "attack" then
    if Helga.frame_atual == Helga.frame_tiro and not Helga.atirou then
      Helga.spawnProjetil(player)
      Helga.atirou = true
      Helga.pode_atacar = false
      Helga.tempo_ataque = 0
    end
    if Helga.frame_atual == 1 then
      Helga.atirou = false
    end
  end

  -- 9. PROJÉTEIS
  for _, p in ipairs(Helga.projeteis) do
    if p.vivo then
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt

      p.tempo = p.tempo + dt
      if p.tempo >= 0.1 then
        p.tempo = 0
        p.frame = p.frame + 1
        if p.frame > #Helga.projetil.quads then p.frame = 1 end
      end

      local caixa_projetil = {
        x       = p.x - (Helga.projetil.w / 2),
        y       = p.y - (Helga.projetil.h / 2),
        largura = Helga.projetil.w * Helga.escala,
        altura  = Helga.projetil.h * Helga.escala
      }

      if colide(caixa_projetil, player) then
        p.vivo = false
        player.tomarDano(Helga.direcao, 20)
      end

      if p.x < 0 or p.x > love.graphics.getWidth() then
        p.vivo = false
      end
    end
  end
end

function Helga.draw()
  if not Helga.vivo and Helga.animacao_atual ~= "death" then return end

  local anim = Helga.animacoes[Helga.animacao_atual]

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    anim.img,
    anim.quads[Helga.frame_atual],
    Helga.x,
    Helga.y + Helga.y_offset,
    0,
    Helga.direcao * Helga.escala,
    Helga.escala,
    anim.w / 2,
    anim.h / 2
  )

  -- debug: remova quando não precisar mais
  love.graphics.setColor(1, 0, 0, 0.4)
  love.graphics.rectangle("fill", Helga.x - 40, Helga.y + 80, 100, 120)
  love.graphics.setColor(1, 1, 1)

  for _, p in ipairs(Helga.projeteis) do
    if p.vivo then
      local p_direcao = p.vx > 0 and 1 or -1
      love.graphics.draw(
        Helga.projetil.img,
        Helga.projetil.quads[p.frame],
        p.x,
        p.y,
        0,
        p_direcao * Helga.escala,
        Helga.escala,
        Helga.projetil.w / 2,
        Helga.projetil.h / 2
      )
    end
  end
end
