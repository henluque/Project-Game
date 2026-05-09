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
end

function Camera.unset()
  love.graphics.pop()
end