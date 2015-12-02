
local function indexToUnitGridCoordinate(gridWidth, index)
  local y = math.floor(index / gridWidth)
  local x = index - y * gridWidth
  return x, y
end

local function scaleGridCoordinate(gridUnitWidth, gridUnitHeight, x, y)
  return x * gridUnitWidth, y * gridUnitHeight
end

-- Function exporting
local exports = {}
exports.indexToUnitGridCoordinate = indexToUnitGridCoordinate
exports.scaleGridCoordinate = scaleGridCoordinate
return exports
