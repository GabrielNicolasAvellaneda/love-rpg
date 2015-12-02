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

function initializeWindow()
  love.window.setMode(800, 600)
end


function love.load() 
  initializeWindow()
  local tileset = love.graphics.newImage("assets/tileset.png") 
  -- Generate a list of quads for a tileset.
  local tilesPerRow = 2
  local tilesRows = 2
  local tileWidth, tileHeight = 32, 32
  local quads = generateQuads(tileWidth, tileHeight, tilesPerRow, tilesRows, tileset:getWidth(), tileset:getHeight())  

  Global = {}
  Global.tileset = tileset
  Global.tileWidth = tileWidth
  Global.tileHeight = tileHeight
  Global.quads = quads
  Global.stageHorizontalTileCount = 30 
  Global.maxStageWidthPixels = Global.tileWidth * Global.stageHorizontalTileCount
  Global.scrollDirection = "right" 
  Global.scrollOffsetDelta = 4
  Global.stageOffset = 0
  Global.screenWidthPixels = 800 
  --local map = loadMap("map_01.lua")
  --
  local map = generateRandomMap(Global.stageHorizontalTileCount, 64)
  Global.map = map
end

function isScrollChangeKey(key)
  return key == "right" or key == "left"
end

function love.keypressed(key, isrepeat)
  if isScrollChangeKey(key) then
    Global.scrollDirection = key 
  end
end

-- Refactor 
function normalizeOffset(offset, minOffset, maxOffset)
  if offset < -maxOffset then
    offset = -maxOffset
  elseif offset > minOffset then
    offset = minOffset 
  end
  return offset 
end

function calculateOffset(currentOffset, direction, dx)
  local factor = (direction == "right" and -1) or 1
  local newOffset = currentOffset + factor * dx 
  return newOffset
end

function calculateMaxOffset(stageWidthPixels, screenWidthPixels)
  return stageWidthPixels - screenWidthPixels
end

function love.update()
  local newOffset = normalizeOffset(calculateOffset(Global.stageOffset, Global.scrollDirection, Global.scrollOffsetDelta), 0, calculateMaxOffset(Global.maxStageWidthPixels, Global.screenWidthPixels))
  print(newOffset)
  Global.stageOffset = newOffset 
end

function love.draw()
  love.graphics.translate(Global.stageOffset, 0)
  drawMap(Global.map, Global.tileset, Global.quads, Global.tileWidth, Global.tileHeight)
end

