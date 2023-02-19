local path = mod_loader.mods[modApi.currentMod].scriptPath

local new_filelist = {
	{file = GetWorkingDir() .. path .."/personalities/Invinc_pilots_4.csv", start = 3 }
}
modApi:loadPersonalityCSV(new_filelist)
