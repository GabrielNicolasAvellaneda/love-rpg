


function love.load() 
  local tileset = love.graphics.newImage("assets/tileset.png") 
  local quad = love.graphics.newQuad(0, 0, 32, 32, tileset:getWidth(), tileset:getHeight())  

  Global = {}
  Global.tileset = tileset
  Global.quads = { quad }
end

function love.draw()
  love.graphics.draw(Global.tileset, Global.quads[1], 0, 0)
end
