
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local getPawnSavedata = require(path .."movespeed/getPawnSavedata")

return function(id)
	assert(Game)
	local pawn = Game:GetPawn(id)
	if not pawn then return end
	
	savedata = getPawnSavedata(id)
	if savedata and savedata.bPowered ~= nil then
		return savedata.bPowered
	end
	
	-- assume all units are powered unless set unpowered
	return true
end