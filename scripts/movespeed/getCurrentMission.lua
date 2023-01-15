
-- updates current mission more often than mod loader's GetCurrentMission()

local mission

sdlext.addGameExitedHook(function()
	mission = nil
end)

local old = Mission.BaseUpdate
function Mission:BaseUpdate(...)
	mission = self
	old(self, ...)
end

local old = Mission.BaseDeployment
function Mission:BaseDeployment(...)
	mission = self
	old(self, ...)
end

local old = Mission.MissionEnd
function Mission:MissionEnd(...)
	old(self, ...)
	mission = nil
end

return function()
	return Board and mission
end