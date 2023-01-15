
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local lib = mod.id .."_movespeed"
local internal = require(path .."movespeed/internal")
local getCurrentMission = require(path .."movespeed/getCurrentMission")

local old = LoadGame
function LoadGame(...)
	old(...)
	-- check if we are loading into a mission
	if GetCurrentRegion() then
		-- mission does not exist yet.
		-- run this function as soon as we see one,
		-- or expire this function if we exit to main menu.
		modApi:conditionalHook(function()
				return not GAME or not Game or getCurrentMission()
			end,
			function()
				if not Game or not Game then return end
				
				local m = getCurrentMission()
				m[lib] = m[lib] or {}
				m[lib].pawns = m[lib].pawns or {}
				
				for id, amount in pairs(m[lib].pawns) do
					if Game:GetPawn(id) then
						internal:add(id, amount)
					end
				end
			end
		)
	end
end

local old = Mission.MissionEnd
function Mission:MissionEnd(...)
	
	local m = self
	m[lib] = m[lib] or {}
	m[lib].pawns = m[lib].pawns or {}
	
	
	for id, amount in pairs(m[lib].pawns) do
		if Game:GetPawn(id) then
			internal:sub(id, amount)
		end
	end
	
	m[lib].pawns = {}
	
	old(self, ...)
end