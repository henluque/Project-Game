HUD = {}

local nomes_salas = {
  entrada_floresta = "Entrada da Floresta",
  coracao_floresta = "Coração da Floresta",
  saida_floresta   = "Saída da Floresta",
  entrada_castelo  = "Entrada do Castelo",
  sala_magnus      = "Sala de Magnus",
}

function HUD.load()
  HUD.avatar    = love.graphics.newImage("assets/sprites/player/Avatar.png")
  HUD.chave_img = love.graphics.newImage("assets/items/key.png")
end

function HUD.update()
end

function HUD.draw()
  local sw = LARGURA_JOGO
  local sh = ALTURA_JOGO

  local bar_h = 80
  local bar_y = sh - bar_h

  -- fundo escuro semi-transparente
  love.graphics.setColor(0.06, 0.06, 0.12, 0.92)
  love.graphics.rectangle("fill", 0, bar_y, sw, bar_h)

  -- linha separadora no topo
  love.graphics.setColor(0.30, 0.30, 0.55, 0.8)
  love.graphics.setLineWidth(1)
  love.graphics.line(0, bar_y, sw, bar_y)

 -- ── AVATAR CIRCULAR ──────────────────────────────────────
  local av_cx = 60
  local av_cy = bar_y + bar_h / 2
  local av_r  = 28

-- ── AVATAR CIRCULAR ──────────────────────────────────────
  local av_cx = 60
  local av_cy = bar_y + bar_h / 2
  local av_r  = 28

  -- fundo do círculo
  love.graphics.setColor(0.12, 0.10, 0.22, 1)
  love.graphics.circle("fill", av_cx, av_cy, av_r - 2)

  -- imagem do avatar (sem stencil)
  local img_w = HUD.avatar:getWidth()
  local img_h = HUD.avatar:getHeight()
  local escala_av = (av_r * 2) / math.max(img_w, img_h)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    HUD.avatar,
    av_cx - (img_w * escala_av) / 2,
    av_cy - (img_h * escala_av) / 2,
    0,
    escala_av,
    escala_av
  )

  -- anel externo (desenhado por cima pra esconder as bordas)
  love.graphics.setColor(0.45, 0.35, 0.80, 1)
  love.graphics.setLineWidth(3)
  love.graphics.circle("line", av_cx, av_cy, av_r)

  -- ── NOME + BARRA DE VIDA ─────────────────────────────────
  local info_x     = av_cx + av_r + 16
  local nome_y     = bar_y + 14
  local hp_y       = nome_y + 20
  local bar_vida_w = 240
  local bar_vida_h = 14
  local vida_pct   = math.max(0, Player.vida / 100)

  love.graphics.setColor(1, 1, 1, 0.95)
  love.graphics.print("Boris", info_x, nome_y)

  love.graphics.setColor(0.65, 0.65, 0.75, 0.9)
  love.graphics.print("HP", info_x, hp_y + 1)

  local hp_bar_x = info_x + 28
  love.graphics.setColor(0.15, 0.15, 0.20, 1)
  love.graphics.rectangle("fill", hp_bar_x, hp_y, bar_vida_w, bar_vida_h, 3, 3)

  local cor
  if vida_pct > 0.55 then
    cor = { 0.18, 0.78, 0.28, 1 }
  elseif vida_pct > 0.25 then
    cor = { 0.85, 0.70, 0.10, 1 }
  else
    cor = { 0.85, 0.18, 0.18, 1 }
  end
  love.graphics.setColor(cor)
  love.graphics.rectangle("fill", hp_bar_x, hp_y, bar_vida_w * vida_pct, bar_vida_h, 3, 3)

  love.graphics.setColor(1, 1, 1, 0.12)
  love.graphics.rectangle("fill", hp_bar_x, hp_y, bar_vida_w * vida_pct, bar_vida_h / 2, 3, 3)

  love.graphics.setColor(0.35, 0.35, 0.45, 0.8)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", hp_bar_x, hp_y, bar_vida_w, bar_vida_h, 3, 3)

  love.graphics.setColor(1, 1, 1, 0.85)
  love.graphics.print(Player.vida .. " / 100", hp_bar_x + bar_vida_w + 10, hp_y)

  -- ── SLOTS DE ITEM (canto direito) ────────────────────────
  local slot_size      = 40
  local slot_gap       = 8
  local n_slots        = 3
  local total_slots_w  = n_slots * slot_size + (n_slots - 1) * slot_gap
  local slots_x        = sw - total_slots_w - 20
  local slots_y        = bar_y + (bar_h - slot_size) / 2

  for i = 1, n_slots do
    local sx = slots_x + (i - 1) * (slot_size + slot_gap)

    love.graphics.setColor(0.12, 0.12, 0.20, 0.9)
    love.graphics.rectangle("fill", sx, slots_y, slot_size, slot_size, 4, 4)

    love.graphics.setColor(0.32, 0.32, 0.50, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", sx, slots_y, slot_size, slot_size, 4, 4)

    -- slot 1: imagem real do item
    -- slot 1: chave (quando tiver) ou coracao da floresta
    if i == 1 then
      local img = nil
      if Player.tem_chave then
        img = HUD.chave_img
      elseif Player.tem_item and not Helga.renascida then
        img = Mapa.item_img
      end

      if img then
        local escala_slot = (slot_size - 8) / math.max(img:getWidth(), img:getHeight())
        local iw = img:getWidth()  * escala_slot
        local ih = img:getHeight() * escala_slot
        if Player.tem_chave then
          local pulso = 0.75 + math.sin(love.timer.getTime() * 4) * 0.25
          love.graphics.setColor(1, 1, 0.4, pulso)
        else
          love.graphics.setColor(1, 1, 1)
        end
        love.graphics.draw(
          img,
          sx + (slot_size - iw) / 2,
          slots_y + (slot_size - ih) / 2,
          0,
          escala_slot,
          escala_slot
        )
        love.graphics.setColor(1, 1, 1)
      end
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(1)
end