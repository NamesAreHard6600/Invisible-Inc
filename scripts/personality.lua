
local this = { Label = "NULL" }
CreateClass(this)

function this:GetPilotDialog(event)
	if self[event] ~= nil then
		if type(self[event]) == "table" then
			return random_element(self[event]) or ""
		end
		
		return self[event]
	end
	
	LOG("No pilot dialog found for ".. event .." event in ".. self.Label)
	return ""
end

function this:AddDialog(t, flag)
	assert(type(t) == 'table')
	
	for event, texts in pairs(t) do
		if
			type(texts) == 'string' and
			type(texts) ~= 'table'
		then
			texts = {texts}
		end
		
		assert(type(texts) == 'table')
		if flag then
			self[event] = texts
		else
			self[event] = self[event] or {}
			for i, v in ipairs(texts) do
				self[event][i] = v
			end
		end
	end
end

return this