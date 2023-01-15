local this = {}

local path = mod_loader.mods[modApi.currentMod].scriptPath
local pawnMove = require(path .."libs/pawnMoveSkill")
local moveskill = require(path .."libs/pilotSkill_move")
local previewer = require(path.."weaponPreview/api")
local movespeed = require(path .."movespeed/api")

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

local pilot = {
	Id = "Pilot_Grid",
	Personality = "Grid",
	Name = "Internationale",
	Sex = SEX_FEMALE, --SEX_MALE
	Skill = "GridSkill",
	Voice = "/voice/lily", --or other voice
}

function this:GetPilot()
	return pilot
end

function this:init(mod)
	CreatePilot(pilot)
	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Friendly Spirit", "Gives a temporary shield to all buildings before attacking, and removes them after."))
	
	-- art, icons, animations
	
	
	--Skill
	--ShockSkill = {}
	--It's all in the hooks
end

--LOG(tostring(Board:GetPawn(0)))   TESTING YOU CAN DELETE THIS

local function saveState(mission, point)
	--LOG(mission.buildingStates[point:GetString()])
	if not mission.buildingStates[point:GetString()] then 
		if Board:IsShield(point) then
			mission.buildingStates[point:GetString()] = true --True = is shielded
		else
			mission.buildingStates[point:GetString()] = false --False = is not shielded
		end
	end
end


function this:load(modApiExt, options)	
	--[[
	modApiExt.dialog:addRuledDialog("Pilot_Skill_AZ", {
		Odds = 5,
		{ main = "Pilot_Skill_AZ" },
	})
	]]--
	modApiExt:addSkillStartHook(function(mission, pawn, weaponId, p1, p2)
		if pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
			local board_size = Board:GetSize()
			for i = 0,  board_size.x - 1 do
				for j = 0, board_size.y - 1 do
					local curr = Point(i,j)
					if Board:IsBuilding(curr) then
						saveState(mission, curr)
						Board:SetShield(curr, true)
					end
				end
			end
		end
	end)
		
	modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		if pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
		mission.buildingStates = {}
			for i = 1, skillEffect.effect:size() do
				local damage = skillEffect.effect:index(i);
				if damage.iShield == 1 then 
					local point = damage.loc
					if Board:IsBuilding(point) then
						mission.buildingStates[point:GetString()] = true
					end
				end
			end
		end
	end)

	modApiExt:addSkillEndHook(function(mission, pawn, weaponId, p1, p2)--, skillEffect)
		if pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
			local effect = SkillEffect()
			effect:AddDelay(0.4)
			--skillEffect:AddDelay(1)
			local board_size = Board:GetSize()
			for i = 0,  board_size.x - 1 do
				for j = 0, board_size.y - 1 do
					local curr = Point(i,j)
					if Board:IsBuilding(curr) then
						-- Previewer Attempts
						local damage = SpaceDamage(curr, 0)
						if mission.buildingStates[curr:GetString()] then
							damage.iShield = 1
						else
							damage.iShield = -1
						end
						effect:AddDamage(damage)
					end
				end
			end
			Board:AddEffect(effect) --This is weird implementaion but the better implementaion I was using earlier wasn't working so...
		end
		
	end)
end

return this