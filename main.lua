
-- This could be a map of a sequence, to a 2d to 1d transformation and a newQuad call.
function generateQuads(width, height, rows, columns, tilesetWidth, tilesetHeight)
  local quads = {}
  for y=1,rows do
    for x=1,columns do
      local quad = love.graphics.newQuad((x-1)*width, (y-1)*height, width, height, tilesetWidth, tilesetHeight)
      table.insert(quads, quad)
    end
  end
  return quads
end

function loadMap(path)
  f = loadfile(path)
  return f()
end

function love.load() 
  local tileset = love.graphics.newImage("assets/tileset.png") 
  -- Generate a list of quads for a tileset.
  local tilesPerRow = 2
  local tilesRows = 2
  local tileWidth, tileHeight = 32, 32
  local quads = generateQuads(tileWidth, tileHeight, tilesPerRow, tilesRows, tileset:getWidth(), tileset:getHeight())  

  local map = loadMap("map_01.lua")
  
  Global = {}
  Global.tileset = tileset
  Global.tileWidth = tileWidth
  Global.tileHeight = tileHeight
  Global.quads = quads
  Global.map = map
end

function drawMap(map, tileset, quads, tileWidth, tileHeight)
  -- Two dimensional iterator. Could be made by composing 2 maps and a draw clousure. 
  for i, row in ipairs(map) do
    for j, val in ipairs(row) do
      love.graphics.draw(Global.tileset, Global.quads[val], (i-1)*tileWidth, (j-1)*tileHeight)
    end
  end
end

function love.draw()
  drawMap(Global.map, Global.tileset, Global.quads, Global.tileWidth, Global.tileHeight)
end
