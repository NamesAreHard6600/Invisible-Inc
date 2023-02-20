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
	Name = "Tony Xu",
	Sex = SEX_MALE, --SEX_FEMALE
	Skill = "ShockSkill",
	Voice = "/voice/kwan", --or other voice
}

function this:GetPilot()
	return pilot
end

function this:init(mod)
	CreatePilot(pilot)
	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Experimental Circuits", "Replace repair with a 1 damage electric whip attack with building chain. -1 move on turn one."))

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

	ShockSkill_Link = Prime_Lightning_A:new {
		Name = "Electric Whip",
		Class = "",
		Description = "Chain damage through adjacent targets, chaining through buildings.",
		Damage = 1,
		Upgrades = 0,
		Buildings = true,
	}
end

local function nextTurnHook(mission)
	if Game:GetTeamTurn() == TEAM_PLAYER and Board:GetTurn() == 1 then
		for id = 0, 2 do
			local pawn = Board:GetPawn(id)
			if pawn and pawn:IsAbility(pilot.Skill) then
				--Board:Ping(pawn:GetSpace(),GL_Color(255,0,0)) Get's overriden by AddMoveBonus
				pawn:AddMoveBonus(-1)
			end
		end
	end
end

local function testMechEntered(mission)
	modApi:conditionalHook (
		function()
			return Board:GetPawn(0)
		end,

		function()
			local pawn = Board:GetPawn(0)
			if pawn:IsAbility(pilot.Skill) then
				pawn:AddMoveBonus(-1)
			end
		end
	)
end

local function EVENT_onModsLoaded()
	modApi:addNextTurnHook(nextTurnHook)
	modApi:addTestMechEnteredHook(testMechEntered)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return this
