local offset_x = -19
local offset_y = 0
local mod = mod_loader.mods[modApi.currentMod]


local anims = {
	["big_"] = "bionic_strike_",
	["small_"] = "bionic_strike_",
}

for tag, name in pairs(anims) do
	for dir = DIR_START, DIR_END do
		local anim_path = "weapons/anims/"..name..tag..dir..".png"
		local img_path = "img/"..anim_path
		modApi:appendAsset(img_path,mod.resourcePath..img_path)
		
		ANIMS["NAH_"..name..tag..dir] = ANIMS.Animation:new{
			Image = anim_path,
			NumFrames = 9,
			Time = 0.06,
			PosX = offset_x,
			PosY = offset_y,
		}
		
	end
end