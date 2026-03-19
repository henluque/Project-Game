Camera = {}

Camera.x = 0
Camera.y = 0

function Camera.update(alvo_x, alvo_y)
  Camera.x = alvo_x - (800/2)
  Camera.y = 0
  
end

function Camera.set()
  love.graphics.push()
  love.graphics.translate(-Camera.x, -Camera.y)
end

function Camera.unset()
  love.graphics.pop()
end