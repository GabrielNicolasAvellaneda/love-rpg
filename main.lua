fun = require("fun")()
local lib = require("lib") 




function genTransformTo2D(width, height)
  return function (n)
    local ylogical = math.floor(n / width) 
    local y = ylogical * height 
    local x = n - ylogical * width 
    return x, y
  end
end

function generateQuads(width, height, rows, columns, tilesetWidth, tilesetHeight)
  local totalQuads = rows * columns 
  local xys = map(genTransformTo2D(width, height), range(0, totalQuads-1))
  local createQuadAt = function (x, y)
      return love.graphics.newQuad(x*width, y*width, width, height, tilesetWidth, tilesetHeight)
  end
  local quads = totable(map(createQuadAt, xys))
  return quads
end

function loadMap(path)
  f = loadfile(path)
  return f()
end

function generateRandomMap(width, height)
  local map = {}
  for i=1,height do
    local row = {}
    for j=1,width do
      table.insert(row, math.random(1,2))
    end
    table.insert(map, row)
  end
  return map
end

function eachCell(func, map)
   for y, row in ipairs(map) do
    for x, val in ipairs(row) do
      func(val, x, y) 
    end
  end
end

function drawMap(map, tileset, quads, tileWidth, tileHeight)
  local drawCell = function (tileIndex, x, y)
      love.graphics.draw(Global.tileset, Global.quads[tileIndex], x, y)
  end

  eachCell(
    function (cellValue, x, y)
      drawCell(cellValue, x * tileWidth, y * tileHeight)
    end, map)
 end

-- Love callbacks

function love.load() 
  local tileset = love.graphics.newImage("assets/tileset.png") 
  -- Generate a list of quads for a tileset.
  local tilesPerRow = 2
  local tilesRows = 2
  local tileWidth, tileHeight = 32, 32
  local quads = generateQuads(tileWidth, tileHeight, tilesPerRow, tilesRows, tileset:getWidth(), tileset:getHeight())  

  --local map = loadMap("map_01.lua")
  local map = generateRandomMap(64, 64)
  
  Global = {}
  Global.tileset = tileset
  Global.tileWidth = tileWidth
  Global.tileHeight = tileHeight
  Global.quads = quads
  Global.map = map
  Global.offset = 0
end

function love.keypressed(key, isrepeat)

end

function love.update()
  Global.offset = Global.offset + 4 
end

function love.draw()
  love.graphics.translate(Global.offset, 0)
  drawMap(Global.map, Global.tileset, Global.quads, Global.tileWidth, Global.tileHeight)
end
