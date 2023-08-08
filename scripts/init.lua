--self needs to be mod?
--Might have extra stuff for Replace Repair

--I really hate this way of "init"ing but it's too late now
local mod = {
  id = "NamesAreHard/Hekateras - Invisible Inc Pilots",
  name = "Invisible Inc Pilots",
	icon = "modIcon.png",
	description = "The ultimate crossover, Invisible Inc Agents join the pilot pool.",
  modApiVersion = "2.8.0",
	gameVersion = "1.2.83",
	version = "1.0.2",
	requirements = { "kf_ModUtils" },
  dependencies = {
		modApiExt = "1.17",
    memedit = "1.0.1",
	},
}

local function getModOptions(mod)
    return mod_loader:getModConfig()[mod.id].options
end

local function getOption(options, name, defaultVal)
	if options and options[name] then
		return options[name].enabled
	end
	if defaultVal then return defaultVal end
	return true
end

local pilotnames = {
	["Pilot_Shock"] = "Dr. Xu",
	["Pilot_Grid"] = "Internationale",
	["Pilot_Sharp"] = "Sharp",
}

function mod:init(self)
	--init variables
	local path = mod_loader.mods[modApi.currentMod].scriptPath
  local mod = mod_loader.mods[modApi.currentMod]
	local resourcePath = mod.resourcePath
	local scriptPath = mod.scriptPath
	local options = mod_loader.currentModContent[mod.id].options

  --modApiExt
  mod.libs = {}
	mod.libs.modApiExt = modapiext
	mod.libs.weaponPreview = require(scriptPath.."libs/weaponPreview")
	NAH_Hek_InvisibleInc_ModApiExt = mod.libs.modApiExt
  --Replace Repair
  NAH_Hek_InvisibleInc_repairApi = require(path.. "replaceRepair/api")
	NAH_Hek_InvisibleInc_repairApi:init(self, NAH_Hek_InvisibleInc_ModApiExt)

	--require(mod.scriptPath .."LApi/LApi")
	require(mod.scriptPath.."animations")
  require(mod.scriptPath.."personalities/personalities")

	local options = getModOptions(mod)
	--LOG(mod.resourcePath)
	for id, name in pairs(pilotnames) do
		if getOption(options, "enable_"..string.lower(id)) then
			modApi:appendAsset("img/portraits/pilots/"..id..".png",mod.resourcePath.."img/portraits/pilots/"..id..".png")
			modApi:appendAsset("img/portraits/pilots/"..id.."_2.png",mod.resourcePath.."img/portraits/pilots/"..id.."_2.png")
			modApi:appendAsset("img/portraits/pilots/"..id.."_blink.png",mod.resourcePath.."img/portraits/pilots/"..id.."_blink.png")

			mod[id] = require(mod.scriptPath .. string.lower(id))
			mod[id]:init(mod)
		end
	end

	--Repair Icons
	modApi:appendAsset("img/weapons/repair_shock.png",mod.resourcePath.."img/weapons/repair_shock.png")
	modApi:appendAsset("img/weapons/repair_sharp.png",mod.resourcePath.."img/weapons/repair_sharp.png")

	--LOG(mod.resourcePath)
	--CEO Reskin
	modApi:appendAsset("img/portraits/ceo/ceo_pinnacle_incognita.png",mod.resourcePath.."img/portraits/ceo/ceo_pinnacle_incognita.png")
	modApi:appendAsset("img/ui/corps/pinnacle_incognita.png",mod.resourcePath.."img/ui/corps/pinnacle_incognita.png")
	modApi:appendAsset("img/ui/corps/pinnacle_small_incognita.png",mod.resourcePath.."img/ui/corps/pinnacle_small_incognita.png")

	local personality = require(mod.scriptPath.."personality")

	Personality["Incognita"] = personality:new()

	Corp_Snow.CEO_Name = "Incognita"
	--Scripts
	--require(self.scriptPath.."pawns")

end

function mod:load(self,options,version)
	NAH_Hek_InvisibleInc_repairApi:load(self, options, version)

	require(mod.scriptPath .."replaceRepair/api"):load()
end

function mod:metadata()
	for id, name in pairs(pilotnames) do
		modApi:addGenerationOption(
			"enable_" .. string.lower(id), "Pilot: "..name,
			"Enable this pilot.",
			{enabled = true}
		)
    end
end

return mod
