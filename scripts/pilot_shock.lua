local this = {}

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local previewer = mod.libs.weaponPreview
local pawnMove = require(path .."libs/pawnMoveSkill")
local moveskill = require(path .."libs/pilotSkill_move")
local movespeed = require(path .."movespeed/api")

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

local pilot = {
	Id = "Pilot_Shock",
	Personality = "Shock",
	Name = "Dr.Xu",
	Sex = SEX_MALE, --SEX_FEMALE
	Skill = "ShockSkill",
	Voice = "/voice/kwan", --or other voice
}

function this:GetPilot()
	return pilot
end

function this:init(mod)
	CreatePilot(pilot)
	require(mod.scriptPath .."libs/pilotSkill_tooltip").Add(pilot.Skill, PilotSkill("Experimental Circuits", "Adds a one damage electric whip attack to repair. -1 move."))

	-- art, icons, animations


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

	ShockSkill_Link = Skill:new {
		Name = "Electric Whip",
		Description = "Chain damage through adjacent targets.",
		Damage = 1,
		--PathSize = 1,
		Buildings = false,
		FriendlyDamage = true,
		TipImage = {
			Unit = Point(2,3),
			Target = Point(2,2),
			Enemy1 = Point(2,2),
			Enemy2 = Point(2,1),
			Enemy3 = Point(3,1),
		}
	}

	function ShockSkill_Link:GetTargetArea(point)
		local ret = PointList()
		for i = DIR_START, DIR_END do
			local curr = DIR_VECTORS[i] + point
			if Board:IsValid(curr) then
				ret:push_back(curr)
			end
		end


		return ret
	end


	function ShockSkill_Link:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		ret:AddDamage(SpaceDamage(p1,-1))
		previewer:AddDamage(SpaceDamage(p1,-1))
		local damage = SpaceDamage(p2,self.Damage)
		local hash = function(point) return point.x + point.y*10 end
		local explored = {[hash(p1)] = true}
		local todo = {p2}
		local origin = { [hash(p2)] = p1 }

		if Board:IsPawnSpace(p2) or (self.Buildings and Board:IsBuilding(p2)) then
			ret:AddAnimation(p1,"Lightning_Hit")
		end

		while #todo ~= 0 do
			local current = pop_back(todo)

			if not explored[hash(current)] then
				explored[hash(current)] = true

				if Board:IsPawnSpace(current) or (self.Buildings and Board:IsBuilding(current)) then

					local direction = GetDirection(current - origin[hash(current)])
					damage.sAnimation = "Lightning_Attack_"..direction
					damage.loc = current
					damage.iDamage = Board:IsBuilding(current) and DAMAGE_ZERO or self.Damage

					if not self.FriendlyDamage and Board:IsPawnTeam(current, TEAM_PLAYER) then
						damage.iDamage = DAMAGE_ZERO
					end

					ret:AddDamage(damage)

					if not Board:IsBuilding(current) then
						ret:AddAnimation(current,"Lightning_Hit")
					end

					for i = DIR_START, DIR_END do
						local neighbor = current + DIR_VECTORS[i]
						if not explored[hash(neighbor)] then
							todo[#todo + 1] = neighbor
							origin[hash(neighbor)] = current
						end
					end
				end
			end
		end

		return ret
	end


	--  -1 move  --
	moveskill.AddTargetArea(pilot.Personality, ShockSkill)
	--moveskill.AddSkillEffect(pilot.Personality, ShockSkill)
	function ShockSkill:GetTargetArea(point)
		if not pawnMove.IsTargetAreaExt() or not pawnMove.IsSkillEffectExt() then
			return pawnMove.GetTargetArea(p1)
		end

		local mission = GetCurrentMission()
		if not mission then return end

		local moveSpeed = Pawn:GetMoveSpeed() - 1
		--LOG(moveSpeed)
		return pawnMove.GetTargetArea(point, moveSpeed)
	end
	--
end



--[[
function this:load(modApiExt, options)
	modApiExt.dialog:addRuledDialog("Pilot_Skill_AZ", {
		Odds = 5,
		{ main = "Pilot_Skill_AZ" },
	})

	modApi:addMissionStartHook(function(mission)
		for id = 0, 2 do
			if Board:GetPawn(id):IsAbility(pilot.Skill) then
				movespeed:Sub(id, 1)
				LOG("Subtracting")
			end
		end
	end)
end
--]]
return this
