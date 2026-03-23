Player = {}

local function carrega_sheet(caminho, num_frames)
  local img = love.graphics.newImage(caminho)
  local w = img:getWidth()
  local h =  img:getHeight()
  local slot = w / num_frames
  local quads = {}
  for i = 0, num_frames - 1 do
    table.insert(quads, love.graphics.newQuad(
        i * slot,
        0,
        slot,
        h,
        w,
        h
      )
    )
  end
  
  print(string.format("[%s] sheet=%d%d frames=%d slot=%.0fpx", caminho, w, h, num_frames, slot))
  return img, quads, slot, h
end

function Player.load()
  Player.nome = "Boris"
  Player.vida = 100
  Player.x = 350
  Player.y = 0 
  Player.velocidade_mov = 250
  
  Player.y_velocidade = 0
  Player.gravidade = 1200
  Player.forca_pulo = -700
  Player.no_chao = false
  
  Player.largura = 32
  Player.altura = 64
  
  -- SPRITES --
  Player.sprite_idle, Player.quads_idle, Player.frame_w_idle, Player.frame_h_idle = carrega_sheet("assets/sprites/Idle.png", 10)
  
  Player.sprite_run, Player.quads_run, Player.frame_w_run, Player.frame_h_run = carrega_sheet("assets/sprites/Run.png", 6)
  
  Player.sprite_jump, Player.quads_jump, Player.frame_w_jump, Player.frame_h_jump = carrega_sheet("assets/sprites/Jump.png", 2)
  
  Player.sprite_fall, Player.quads_fall, Player.frame_w_fall, Player.frame_h_fall = carrega_sheet("assets/sprites/Fall.png" ,2)
  
  Player.sprite_ataque1, Player.quads_ataque1, Player.frame_w_ataque1, Player.frame_h_ataque1 = carrega_sheet("assets/sprites/Attack1.png", 4)
  
  Player.sprite_ataque2, Player.quads_ataque2, Player.frame_w_ataque2, Player.frame_h_ataque2 = carrega_sheet("assets/sprites/Attack2.png", 4)
  
  Player.sprite_ataque3, Player.quads_ataque3, Player.frame_w_ataque3, Player.frame_h_ataque3 = carrega_sheet("assets/sprites/Attack3.png", 5)
  
  Player.vel_anim = {
    parado = 0.08,
    correndo = 0.12,
    pulando = 0.1,
    caindo = 0.1,
    ataque1 = 0.10,
    ataque2 = 0.09,
    ataque3 = 0.08
  }
  
  Player.frame_atual = 1
  Player.tempo_animacao = 0
  Player.estado = "parado"
  Player.estado_anterior = "parado"
  Player.direcao = 1
  Player.escala = 3
  
  Player.offset_x = 0
  Player.offset_y = 147
  
  Player.combo_passo = 0
  Player.combo_fila = 0
  Player.botao_ataque_pressionado = false
end

function Player.keypressed(key) 
  local pad = love.joystick.getJoysticks()[1]
  local eh_ataque = (key == "z" or key =="k")
  
  if eh_ataque then
    if Player.combo_passo == 0 then
      Player.combo_passo = 1
      Player.frame_atual = 1
      Player.tempo_animacao = 0
      Player.estado = "ataque1"
    elseif Player.combo_passo == 1 and Player.combo_fila == 0 then
      Player.combo_fila = 2
    elseif Player.combo_passo == 2 and Player.combo_fila == 0 then
      Player.combo_fila = 3
    end
  end
end

function Player.gamepadpressed(button)
  if button == "x" then
    Player.keypressed("z")
  end
end

function Player.update(dt, plataformas)
  local atacando = (Player.combo_passo > 0)
  local mov_dir    = 0
  local botao_pulo = (love.keyboard.isDown("up") or love.keyboard.isDown("w"))

  local pad = love.joystick.getJoysticks()[1]

  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    mov_dir =  1 
  end
  if love.keyboard.isDown("left") or love.keyboard.isDown("a") then 
    mov_dir = -1 
  end

  if pad then
    if   pad:isGamepadDown("dpright") or pad:getGamepadAxis("leftx") >  0.3 then mov_dir =  1
    elseif pad:isGamepadDown("dpleft") or pad:getGamepadAxis("leftx") < -0.3 then mov_dir = -1 end
    if pad:isGamepadDown("a") then botao_pulo = true end
  end

  if not atacando or not Player.no_chao then
    if mov_dir ~= 0 then
      Player.x = Player.x + (Player.velocidade_mov * mov_dir * dt)
      Player.direcao = mov_dir
    end
  end
  
  Player.y_velocidade = Player.y_velocidade + (Player.gravidade * dt)
  Player.y = Player.y + (Player.y_velocidade * dt)
  Player.no_chao = false

  for _, plat in ipairs(plataformas) do
    if Player.y + Player.altura >= plat.y and
       Player.y + Player.altura <= plat.y + 60 and
       Player.x + Player.largura >  plat.x and
       Player.x                  <  plat.x + plat.largura and
       Player.y_velocidade >= 0 then

      Player.y            = plat.y - Player.altura
      Player.y_velocidade = 0
      Player.no_chao      = true
    end
  end

  if botao_pulo and Player.no_chao then
    Player.y_velocidade = Player.forca_pulo
  end

  if atacando then
    local vel = Player.vel_anim[Player.estado] or 0.10
    Player.tempo_animacao = Player.tempo_animacao + dt
    
    
    if Player.tempo_animacao >= vel then
      Player.tempo_animacao = 0
      Player.frame_atual = Player.frame_atual + 1
      
      local limites = {
        ataque1 = #Player.quads_ataque1,
        ataque2 = #Player.quads_ataque2,
        ataque3 = #Player.quads_ataque3
      }
      local limite = limites[Player.estado] or 1
      
      if Player.frame_atual > limite then
        if Player.combo_fila > 0 then
          Player.combo_passo = Player.combo_fila
          Player.combo_fila = 0
          Player.estado = "ataque" .. Player.combo_passo
          Player.frame_atual = 1
          Player.tempo_animacao = 0
        else
          Player.combo_passo = 0
          Player.combo_fila = 0
          Player.frame_atual = 1
          Player.tempo_animacao = 0
        end
      end
    end
    Player.estado_anterior = Player.estado
    return
  end
  
  local novo_estado = "parado"
  if not Player.no_chao then
    if Player.y_velocidade < 0 then
      novo_estado = "pulando"
    else
      novo_estado = "caindo"
    end
  elseif mov_dir ~= 0 then
    novo_estado = "correndo"
  else
    novo_estado = "parado"
  end
  
  if novo_estado ~= Player.estado then
    Player.frame_atual = 1
    Player.tempo_animacao = 0
  end
  Player.estado = novo_estado
  Player.estado_anterior = novo_estado
  
  
  local vel = Player.vel_anim[Player.estado] or 0.08
  Player.tempo_animacao = Player.tempo_animacao + dt
  if Player.tempo_animacao >= vel then
    Player.tempo_animacao = 0
    Player.frame_atual = Player.frame_atual + 1
  end
  
  local limites = {
    parado = #Player.quads_idle,
    correndo = #Player.quads_run,
    pulando = #Player.quads_jump,
    caindo = #Player.quads_fall
  }
  local limite = limites[Player.estado] or #Player.quads_idle
  
  if Player.estado == "pulando" or Player.estado == "caindo" then 
    if Player.frame_atual > limite then 
      Player.frame_atual = limite
    end 
  else
    if Player.frame_atual > limite then
      Player.frame_atual = 1
    end
  end
end

function Player.draw()
  love.graphics.setColor(1, 0, 0, 0.4)
  love.graphics.rectangle("fill", Player.x, Player.y, Player.largura, Player.altura)
  love.graphics.setColor(1, 1, 1)

  local info = {
    parado   = { Player.sprite_idle, Player.quads_idle, Player.frame_w_idle, Player.frame_h_idle },
    correndo = { Player.sprite_run,  Player.quads_run,  Player.frame_w_run,  Player.frame_h_run  },
    pulando  = { Player.sprite_jump, Player.quads_jump, Player.frame_w_jump, Player.frame_h_jump },
    caindo   = { Player.sprite_fall, Player.quads_fall, Player.frame_w_fall, Player.frame_h_fall },
    ataque1  = { Player.sprite_ataque1, Player.quads_ataque1, Player.frame_w_ataque1, Player.frame_h_ataque1 },
    ataque2  = { Player.sprite_ataque2, Player.quads_ataque2, Player.frame_w_ataque2, Player.frame_h_ataque2 },
    ataque3  = { Player.sprite_ataque3, Player.quads_ataque3, Player.frame_w_ataque3, Player.frame_h_ataque3 }
  }

  local d = info[Player.estado] or info["parado"]
  local sprite_atual, quads, frame_w, frame_h = d[1], d[2], d[3], d[4]
  local quad_atual = quads[Player.frame_atual] or quads[1]

  local pivot_x = Player.x + (Player.largura / 2) + Player.offset_x
  local pivot_y = Player.y +  Player.altura        + Player.offset_y

  love.graphics.draw(
    sprite_atual, quad_atual,
    pivot_x, pivot_y,
    0,
    Player.escala * Player.direcao,
    Player.escala,
    frame_w / 2,
    frame_h
  )
end