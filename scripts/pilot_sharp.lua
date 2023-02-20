local this = {}

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local previewer = mod.libs.weaponPreview
local pawnMove = require(path .."libs/pawnMoveSkill")
local moveskill = require(path .."libs/pilotSkill_move")
local saveData = require(path.."libs/saveData")

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

local pilot = {
	Id = "Pilot_Sharp",
	Personality = "Sharp",
	Name = "Sharp",
	Sex = SEX_MALE, --SEX_FEMALE
	Skill = "SharpSkill",
	Voice = "/voice/ralph", --or other voice
	PowerCost = 1,
}

function this:GetPilot()
	return pilot
end

function this:init(mod)
	CreatePilot(pilot)
	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Bionic Strike", "Replaces Repair with a melee punch that does 1 + (cores/3) damage."))

	-- art, icons, animations


	--Skill
	SharpSkill = {}
	NAH_Hek_InvisibleInc_repairApi:SetRepairSkill{
		Weapon = "SharpSkill_Link",
		Icon = "img/weapons/repair_sharp.png",
		IsActive = function(pawn)
			return pawn:IsAbility(pilot.Skill)
		end
	}

	SharpSkill_Link = Skill:new {
		Name = "Bionic Strike",
		Description = "Meele punch that does \n1 + (cores/3) damage.",
		DamageTip = "1 + (cores/3)",
		TipDamageCustom = "1 + (cores/3)", --Doesn't work on replace repairs ):
		LaunchSound = "/weapons/titan_fist",
		PathSize = 1,
		TipImage = StandardTips.Melee,
	}


	function SharpSkill_Link:GetSkillEffect(p1, p2)
		local myid = Pawn:GetId()
		local ret = SkillEffect()
		local direction = GetDirection(p2 - p1)
		local damage = 1
		local reactorTable = saveData.getPawnKey(myid, "reactor")
		if reactorTable ~= nil then
			local reactors = reactorTable["iNormalPower"] + reactorTable["iUsedPower"] + reactorTable["iBonusPower"] + reactorTable["iUsedBonus"] -- Keep Bonus?
			damage = 1 + math.floor(reactors/3)
		end

		local d = SpaceDamage(p2, damage, direction)
		if damage > 2 then
			d.sAnimation = "NAH_bionic_strike_big_"..direction
		else
			d.sAnimation = "NAH_bionic_strike_small_"..direction
		end

		ret:AddDamage(d)
		return ret
	end
end

--[[
local function EVENT_onModsLoaded()
	modApiExt.dialog:addRuledDialog("Pilot_Skill_AZ", {
		Odds = 5,
		{ main = "Pilot_Skill_AZ" },
	})

	modApi:addPawnSelectedHook(function(pawn)
		if pawn:IsAbility(pilot.Skill) then
			local reactors = saveData.getPawnKey(pawn:GetId(), "reactor")
			LOG(reactors["iNormalPower"])
		end
	end)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

--]]

return this
