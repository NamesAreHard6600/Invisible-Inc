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
	Id = "Pilot_Shock",
	Personality = "Shock",
	Name = "Dr. Xu",
	Sex = SEX_MALE, --SEX_FEMALE
	Skill = "ShockSkill",
	Voice = "/voice/kwan", --or other voice
}

function this:GetPilot()
	return pilot
end

function this:init(mod)
	CreatePilot(pilot)
	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Experimental Circuits", "Adds a 1 damage electric whip attack to repair, chains through buildings. -1 move."))

	--Skill
	ShockSkill = {}
	--  Replace Repair  --
	NAH_Hek_InvisibleInc_repairApi:SetRepairSkill{
		Weapon = "ShockSkill_Link",
		Icon = "img/weapons/repair_shock.png",
		IsActive = function(pawn)
			return pawn:IsAbility(pilot.Skill)
		end
	}

	ShockSkill_Link = Prime_Lightning:new {
		Name = "Electric Whip",
		Class = "",
		Description = "Chain damage through adjacent targets, chaining through buildings.",
		Damage = 1,
		Upgrades = 0,
		Buildings = true,
	}

end

function this:load(modApiExt, options)
	modApi:addNextTurnHook(function(mission)
		if Game:GetTeamTurn() == TEAM_PLAYER then
			for id = 0, 2 do
				local pawn = Board:GetPawn(id)
				if pawn and pawn:IsAbility(pilot.Skill) then
					--Board:Ping(pawn:GetSpace(),GL_Color(255,0,0)) Get's overriden by AddMoveBonus
					pawn:AddMoveBonus(-1)
				end
			end
		end
	end)
end
--]]
return this
