
TileWidth = 32
TileHeight = 32

-- This could be a map of a sequence, to a 2d to 1d transformation and a newQuad call.
function generateQuads(width, height, rows, columns, tilesetWidth, tilesetHeight)
  local quads = {}
  for x=1,columns do
    for y=1,rows do
      local quad = love.graphics.newQuad((x-1)*width, (y-1)*height, width, height, tilesetWidth, tilesetHeight)
      table.insert(quads, quad)
    end
  end
  return quads
end

function love.load() 
  local tileset = love.graphics.newImage("assets/tileset.png") 
  -- Generate a list of quads for a tileset.
  local tilesPerRow = 2
  local tilesRows = 2
  local quads = generateQuads(TileWidth, TileHeight, tilesPerRow, tilesRows, tileset:getWidth(), tileset:getHeight())  
  Global = {}
  Global.tileset = tileset
  Global.quads = quads
end

function love.draw()
  love.graphics.draw(Global.tileset, Global.quads[1], 0, 0)
end
