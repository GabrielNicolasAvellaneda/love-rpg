
function love.load() 
  Tileset = love.graphics.newImage("assets/tileset.png") 
end

function love.draw()
  love.graphics.draw(Tileset, 0, 0)
end
