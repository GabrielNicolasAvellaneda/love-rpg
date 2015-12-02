local lu = require('luaunit')
local lib = require('lib')

TestSuite = {}
function TestSuite:test_indexToUnitGridCoordinate()
  local gridWidth = 2 
  local x, y = lib.indexToUnitGridCoordinate(gridWidth, 3)
  lu.assertEquals(x, 1)
  lu.assertEquals(y, 1)
end

function TestSuite:test_scaleGridCoordinate()
  local x, y = lib.indexToUnitGridCoordinate(2, 3)
  local xScaled, yScaled = lib.scaleGridCoordinate(32, 32, x, y)
  lu.assertEquals(xScaled, 32)
  lu.assertEquals(yScaled, 32)
end

os.exit(lu.LuaUnit.run())
