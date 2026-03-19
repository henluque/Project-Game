Mapa = {}

function Mapa.load()
  Mapa.plataformas = {
    {x = 0, y = 500, largura = 800, altura= 100},
    {x = 150, y = 350, largura = 100, altura = 20},
    {x = 350, y = 250, largura = 150, altura = 20},
    {x = 600, y = 150, largura = 100, altura = 20}
  }
end

function Mapa.draw()
  love.graphics.setColor(0.4, 0.4, 0.4)
  
  for i = 1, #Mapa.plataformas do
    local plat = Mapa.plataformas[i]
    love.graphics.rectangle("fill", plat.x, plat.y, plat.largura, plat.altura)
  end
end