local this = {}

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local previewer = mod.libs.weaponPreview
local pawnMove = require(path .."libs/pawnMoveSkill")
local moveskill = require(path .."libs/pilotSkill_move")

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
	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Wireless Shielding", "Grants all buildings a temporary shield before attacking, and removes them after."))

	-- art, icons, animations
	modApi:appendAsset("img/combat/icons/NAH_temp_shield.png",mod.resourcePath.."img/combat/icons/NAH_temp_shield.png")
		Location["combat/icons/NAH_temp_shield.png"] = Point(-13,5)
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

local function NAH_GridShield(mission, skillEffect)
	--Save Shielded Buildings in Weapon
	mission.buildingStates = {}
	for i = 1, skillEffect.effect:size() do
		local damage = skillEffect.effect:index(i);
		if damage.iShield == EFFECT_CREATE then
			local point = damage.loc
			if Board:IsBuilding(point) then
				mission.buildingStates[point:GetString()] = true
			end
		end
	end
	local buildings = extract_table(Board:GetBuildings())
	--Shield needs to go in front, which requires making a copy, reseting, and  then adding the copy back in
	--Save old effect
	local oldEffect = skillEffect.effect
	local oldEffectCopy = DamageList()
	--Make a copy
	for i = 1, oldEffect:size() do
		local oldDamage = oldEffect:index(i);
		oldEffectCopy:push_back(oldDamage)
	end
	--Reset
	skillEffect.effect = DamageList()
	--Add Buildings
	for _, point in pairs(buildings) do
		if Board:GetTerrain(point) ~= TERRAIN_RUBBLE then --Dead buildings
			saveState(mission, point)
			local damage = SpaceDamage(point)
			damage.iShield = EFFECT_CREATE
			skillEffect.effect:push_back(damage)
		end
	end
	--Add in old effects
	for i = 1, oldEffectCopy:size() do
		local oldDamage = oldEffectCopy:index(i);
		skillEffect.effect:push_back(oldDamage)
	end
	--Unfortunalty doesn't override damage and stuff, but still is custom
	--Could maybe add bHide to all attacks on buildings, but that could cause
	--issues for push and could just not work
	for _, point in pairs(buildings) do
		local image = SpaceDamage(point)
		image.sImageMark = "combat/icons/NAH_temp_shield.png"
		skillEffect.effect:push_back(image)
	end
end

local function NAH_GridUnshield(mission)
	local effect = SkillEffect()
	effect:AddDelay(0.4)
	--skillEffect:AddDelay(1)
	local buildings = extract_table(Board:GetBuildings())
	for _, point in pairs(buildings) do
		if Board:IsBuilding(point) then
			local damage = SpaceDamage(point, 0)
			if mission.buildingStates[point:GetString()] then
				damage.iShield = EFFECT_CREATE
			else
				damage.iShield = -1
			end
			effect:AddDamage(damage)
		end
	end
	Board:AddEffect(effect) --This is weird implementaion but the better implementaion I was using earlier wasn't working so...
end

local function EVENT_onModsLoaded()
	--for k, v in pairs(GetCurrentMission().buildingStates) do LOG(k); LOG(v) end
	modApiExt = NAH_Hek_InvisibleInc_ModApiExt

	modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		if pawn and pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
			NAH_GridShield(mission,skillEffect)
		end
	end)

	modApiExt:addFinalEffectBuildHook(function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
		if pawn and pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
			NAH_GridShield(mission,skillEffect)
		end
	end)

	modApiExt:addSkillEndHook(function(mission, pawn, weaponId, p1, p2)--, skillEffect)
		if pawn and pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
			NAH_GridUnshield(mission)
		end
	end)

	modApiExt:addFinalEffectEndHook(function(mission, pawn, weaponId, p1, p2, p3)
		if pawn and pawn:IsAbility(pilot.Skill) and tostring(weaponId) ~= "Move" then
			NAH_GridUnshield(mission)
		end
	end)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return this
