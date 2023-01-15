-------------------------------------------------------------------------------
-- Save Data reading lbrary
-- v0.3
-- https://github.com/KnightMiner/ITB-KnightUtils/blob/master/libs/saveData.lua
-------------------------------------------------------------------------------
-- Contains helpers to make it easier to read information from saveData.lua
-------------------------------------------------------------------------------
local saveData = {}

--- Size of boards in tooltips
local TOOLTIP_SIZE = Point(6,6)

--[[--
  Safely gets a nested key within a table

  @param data  Data object to search
  @param ...   Key(s) to fetch
  @return Data at key, or nil if any part of the path does not exist
]]
function saveData.safeGet(data, ...)
  for _, key in ipairs({...}) do
    if type(data) ~= "table" then
      return nil
    end
    data = data[key]
  end
  return data
end

--[[--
  Converts a point to an index, given Board width
  @param point  Point to convert
  @param width  Board width, if unset uses `Board`
  @return  Index of the point for the given board width
]]
function saveData.pointIndex(point, width)
  if not width then width = Board:GetSize().x end
  return point.y * width + point.x
end

--[[--
  Checks if save data is unavailable in the current context
  @return true if we are in a tooltip or the mech tester
]]
function saveData.dataUnavailable()
  return IsTestMechScenario() or Board:GetSize() == TOOLTIP_SIZE
end

--[[--
  Gets a table from region data
  @return desired map, or empty map if missing
]]
local function getRegionTable(...)
  if saveData.dataUnavailable() then
    return {}
  end
  -- get map data from the region data
  local map = saveData.safeGet(GetCurrentRegion(), ...)
  if type(map) == "table" then
    return map
  end
  -- if missing, return empty table
  LOG('WARNING: Failed to find data in save data')
  return {}
end

--[[--
  Gets the ID from a value which may be a pawn ID
  @param value  Value that is either a pawn or an ID
  @return ID number from value
]]
local function getID(value)
  local vType = type(value)
  -- number means its an ID
  if vType == "number" then
    return value
  end
  -- table or userdata should contain a GetId function
  if vType == "userdata" or vType == "table" then
    if type(value.GetId) == "function" then
      return value:GetId()
    end
  end
  error("Invalid ID, must be a class with GetId or a number")
end

-----------
-- Pawns --
-----------

--[[--
  Gets the pawn map from the save data, or an empty table if the map is missing
  @return pawn map, or empty map if missing
]]
local function getPawnData()
  return getRegionTable("player", "map_data")
end

--[[--
  Gets data from a pawn for the given ID.
  If you need the key for multiple pawns, use getPawnKeys instead.

  @param id   Pawn instance or pawn ID
  @param ...  Key(s) from pawn data to fetch
  @return  map of pawn ID to specified key
]]
function saveData.getPawnKey(id, ...)
  id = getID(id)
  for key, pawn in pairs(getPawnData()) do
    if key:sub(1, 4) == 'pawn' and type(pawn) == "table" and pawn.id == id then
      return saveData.safeGet(pawn, ...)
    end
  end
  return nil
end

--[[--
  Gets a map of pawn ID to data for the given data key.
  Store the result as a local variable if you intend to use this data multiple times

  @param ...  Key(s) from pawn data to fetch
  @return  map of pawn ID to specified key
]]
function saveData.getAllPawns(...)
  local data = {}
  for key, pawn in pairs(getPawnData()) do
    if key:sub(1, 4) == 'pawn' then
      local value = saveData.safeGet(pawn, ...)
      if value ~= nil and pawn.id ~= nil then
        data[pawn.id] = value
      end
    end
  end
  return data
end

---------
-- Map --
---------

--[[--
  Gets the pawn map from the save data, or an empty table if the map is missing
  @return pawn map, or empty map if missing
]]
local function getSpaceData()
  return getRegionTable("player", "map_data", "map")
end

--[[--
  Gets a key from region data for a single space.
  If you need the key for multiple spaces, use getAllSpaces instead.

  @param space  Space to fetch
  @param ...  Key(s) from space data to fetch
  @return Region data for the space, or nil if empty
]]
function saveData.getSpaceKey(space, ...)
  local data = {}
  for _, data in ipairs(getSpaceData()) do
    if type(data) == "table" and data.loc == space then
      return saveData.safeGet(data, ...)
    end
  end
  return nil
end

--- Metatable for a space map, allowing you to use points as keys
--- Used since points are not allowed directly as keys for a map
local SPACE_MAP = {
  --- Lets you pretend points work as table keys
  __index = function(table, point)
    if type(point) == "userdata" then
      point = saveData.pointIndex(point)
    end
    return rawget(table, point)
  end
}

--[[--
  Gets a map of locations to space data for all spaces
  Store the result as a local variable if you intend to use this data multiple times.

  @param ...  Key(s) from space data to fetch
  @return Map of space to data, can be called with a point to get data
]]
function saveData.getAllSpaces(...)
  local all = setmetatable({}, SPACE_MAP)
  for _, data in ipairs(getSpaceData()) do
    local value = saveData.safeGet(data, ...)
    if value ~= nil and data.loc ~= nil then
      all[saveData.pointIndex(data.loc)] = value
    end
  end
  return all
end

return saveData
