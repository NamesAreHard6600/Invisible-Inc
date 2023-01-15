
--[[
	Movespeed 1.0
	-------------
	small helper library providing functions to change
	movespeed of units with fire and forget functions.
	all values will be reapplied when loading a game
	and reset when finishing a mission.
	
	the library operates fully with additions and subtractions,
	in an attempt to provide compatiblity between
	several mods changing movespeed, without them having
	to transfer information between each other.
	
	the library will not allow changing movespeed of grappled units,
	as it is not possible to know the current movespeed of those units.
	
	the library will only allow changing the base movespeed of units.
	
	terms:
	------
	base movespeed: movement speed before bonus movespeed has been applied.
	bonus movespeed: movespeed provided by mech upgrade, kickoff boosters, etc.
	total movespeed: listed movespeed in-game.
	
	
	request library:
	----------------
	local mod = mod_loader.mods[modApi.currentMod]
	local path = mod.scriptPath
	
	local movespeed = require(path .."movespeed/api")
	
	
	functions:
	----------
	movespeed:Add(pawnId, amount)
	adds to a unit's base movespeed.
	
	movespeed:Sub(pawnId, amount)
	subtracts from a unit's base movespeed.
	
	movespeed:Set(pawnId, value)
	sets a unit's base movespeed.
	(if base movespeed is set to 0,
	the unit cannot move, even if
	it has a higher total movespeed.)
]]

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local internal = require(path .."movespeed/internal")
local getCurrentMission = require(path .."movespeed/getCurrentMission")
require(path .."movespeed/init")

local this = {}

-- gets the current base movement speed of a unit.
function this:Get(id)
	local m = getCurrentMission()
	assert(m and m ~= Mission_Test, "You cannot get movespeed outside of missions.")
	
	return internal:get(id)
end

-- adds to the base movement speed of a unit.
function this:Add(id, amount)
	local m = getCurrentMission()
	assert(m and m ~= Mission_Test, "You cannot change movespeed outside of missions.")
	
	local amount = internal:add(id, amount)
	internal:save(id, amount)
end

-- subtracts from the base movement speed of a unit.
function this:Sub(id, amount)
	local m = getCurrentMission()
	assert(m and m ~= Mission_Test, "You cannot change movespeed outside of missions.")
	
	local amount = internal:sub(id, amount)
	internal:save(id, amount)
end

-- sets the total movement speed of a unit (not base)
function this:Set(id, value)
	local m = getCurrentMission()
	assert(m and m ~= Mission_Test, "You cannot change movespeed outside of missions.")
	
	local amount = internal:set(id, value)
	internal:save(id, amount)
end

return this