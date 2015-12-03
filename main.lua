fun = require("fun")()
local lib = require("lib") 

Character = {}
Character.x = 320
Character.y = 320
Character.state = "idle"     
Character.move_up_target = 0
Character.walk_speed = 8  
Character.quads = {
  ["moving_down"] = love.graphics.newQuad(0, 0, 32, 32, 384, 246),
  ["moving_left"] = love.graphics.newQuad(0, 32, 32, 32, 384, 246),
  ["moving_right"] = love.graphics.newQuad(0, 64, 32, 32, 384, 246),
  ["moving_up"] = love.graphics.newQuad(0, 96, 32, 32, 384, 246),
  ["idle"] = love.graphics.newQuad(0, 0, 32, 32, 384, 246) 
} 
function Character:isBusy()
  return self.state ~= "idle"
end

function Character:getCurrentQuad()
  return self.quads[self.state]  
end

function Character:moveLeft()
  if self:isBusy() then
    return
  end
  self.state = "moving_left"
  self.state_target_value = self.x - 32
end

function Character:moveRight()
  if self:isBusy() then
    return
  end
  self.state = "moving_right"
  self.state_target_value = self.x + 32 
end

function Character:moveUp()
  if self:isBusy() then
    return
  end
  self.state = "moving_up"
  self.state_target_value = self.y - 32
end

function Character:moveDown()
  if self:isBusy() then
    return
  end
  self.state = "moving_down"
  self.state_target_value = self.y + 32
end

function Character:movingUpNext()
  self.y = self.y - 8
  if self.y < self.state_target_value then
      self.y = self.state_target_value
      self.state = "idle"
    end
end

function Character:movingDownNext()
  self.y = self.y + self.walk_speed 
  if self.y > self.state_target_value then
    self.y = self.state_target_value
    self.state = "idle"
  end
end

function Character:movingLeftNext()
  self.x = self.x - self.walk_speed 
  if self.x < self.state_target_value then
    self.x = self.state_target_value
    self.state = "idle"
  end
end

function Character:movingRightNext()
  self.x = self.x + self.walk_speed
  if self.x > self.state_target_value then
    self.x = self.state_target_value
    self.state = "idle"
  end
end

function Character:update()
  if self.state == "moving_up" then
    self:movingUpNext()
  elseif self.state == "moving_down" then
    self:movingDownNext()
  elseif self.state == "moving_left" then
    self:movingLeftNext()
  elseif self.state == "moving_right" then
    self:movingRightNext()
  end
end

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

function drawCharacter(character)
  local characterQuad = character:getCurrentQuad() 
  love.graphics.draw(character.sprite, characterQuad, character.x, character.y)
end

function loadCharacterSprite(path)
  return love.graphics.newImage(path)
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
  Global.character = Character 
  Global.character.sprite = loadCharacterSprite("assets/hetalia_sprite_uk.png")
end

function isScrollChangeKey(key)
  return key == "right" or key == "left"
end

function isCharacterMoveKey(key)
  return key == "h" or key == "j" or key == "k" or key == "l" 
end

-- Thispatch player commands based on command keys
function moveCharacter(character, key)
  if key == "h" then
    character:moveLeft()
  elseif key == "j" then
    character:moveDown()
  elseif key == "k" then
    character:moveUp()
  elseif key == "l" then
    character:moveRight()
  end
end

function love.keypressed(key, isrepeat)
  print('key pressed:' .. key)
  if isScrollChangeKey(key) then
    Global.scrollDirection = key 
  elseif isCharacterMoveKey(key) then
    moveCharacter(Global.character, key)
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

totaldt = 0
function love.update(dt)
  local newOffset = normalizeOffset(calculateOffset(Global.stageOffset, Global.scrollDirection, Global.scrollOffsetDelta), 0, calculateMaxOffset(Global.maxStageWidthPixels, Global.screenWidthPixels))
  --Global.stageOffset = newOffset 
  local character = Global.character  
  totaldt = totaldt + dt
  framedt = 1 / 30
  if totaldt >= framedt then
    totaldt = 0 
    character:update()
  end
end

function love.draw()
  love.graphics.translate(Global.stageOffset, 0)
  drawMap(Global.map, Global.tileset, Global.quads, Global.tileWidth, Global.tileHeight)
  drawCharacter(Global.character)
end

