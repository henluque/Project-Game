Camera = {}

Camera.x = 0
Camera.y = 0

function Camera.update(alvo_x, alvo_y)
  Camera.x = alvo_x - (800 / 2)
  Camera.x = math.max(0, Camera.x)                        
  Camera.x = math.min(Mapa.largura - 800, Camera.x)       
  Camera.y = 0
end

function Camera.set()
  love.graphics.push()
  love.graphics.translate(-Camera.x, -Camera.y)
  for _, item in ipairs(Mapa.itens) do
    if not item.coletado then
      love.graphics.setColor(0.5, 1, 0.2)
      love.graphics.rectangle("fill", item.x, item.y, 20, 20)
      love.graphics.setColor(1, 1, 1)
    end
  end
end

function Camera.unset()
  love.graphics.pop()
end