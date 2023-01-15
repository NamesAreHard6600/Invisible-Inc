
-- internal private library.

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local lib = mod.id .."_movespeed"
local getCurrentMission = require(path .."movespeed/getCurrentMission")
local isPowered = require(path .."movespeed/isPowered")
local this = {}

-- pawn.SetMoveSpeed (built-in function):
-- sets base move speed of a unit.
-- Move Upgrade, Kickoff Boosters and other Movement Bonuses applies on top of this.
-- pawn.SetMoveSpeed

-- gets the current base movement speed of a unit.
function this:get(id)
	local pawn = Game:GetPawn(id)
	assert(pawn)
	
	local grappled = pawn:IsGrappled() and pawn:GetSpace()
	local powered = isPowered(id)
	
	if grappled then
		pawn:SetSpace(Point(-1,-1))
	end
	
	if not powered then
		pawn:SetPowered(true)
	end
	
	local total = pawn:GetMoveSpeed()
	pawn:SetMoveSpeed(0)
	local bonus = pawn:GetMoveSpeed()
	pawn:SetMoveSpeed(total - bonus)
	
	if grappled then
		pawn:SetSpace(grappled)
	end
	
	if not powered then
		pawn:SetPowered(false)
	end
	
	return total - bonus
end

-- adds to the base movement speed of a unit.
function this:add(id, amount)
	assert(Game)
	local pawn = Game:GetPawn(id)
	assert(pawn)
	
	local grappled = pawn:IsGrappled() and pawn:GetSpace()
	
	if grappled then
		pawn:SetSpace(Point(-1,-1))
	end
	
	local curr = self:get(id)
	amount = math.max(-curr, amount)
	pawn:SetMoveSpeed(curr + amount)
	
	if grappled then
		pawn:SetSpace(grappled)
	end
	
	return amount
end

-- subtracts from the base movement speed of a unit.
function this:sub(id, amount)
	return self:add(id, -amount)
end

-- sets the base movement speed of a unit
function this:set(id, value)
	local curr = self:get(id)
	return self:add(id, value - curr)
end

-- saves movespeed changes of units.
function this:save(id, amount)
	local m = getCurrentMission()
	assert(m and m ~= Mission_Test, "You cannot change movespeed outside of missions.")
	
	m[lib] = m[lib] or {}
	m[lib].pawns = m[lib].pawns or {}
	m[lib].pawns[id] = m[lib].pawns[id] or 0
	
	m[lib].pawns[id] = m[lib].pawns[id] + amount
end

return this