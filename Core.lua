if not ModCore then
	log("[ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
	return
end

CustomAchievementsCore = CustomAchievementsCore or class(ModCore)

function CustomAchievementsCore:init()
	--Calling the base function for init from ModCore
	--self_tbl, config path, auto load modules, auto post init modules
	self.super.init(self, ModPath .. "config.xml", true, true)

	CustomAchievement = ClassCustomAchievement:new(self)
end

if not _G.CustomAchievement then
	local success, err = pcall(function() CustomAchievementsCore:new() end)
	if not success then
		log("[ERROR] An error occured on the initialization of Custom Achievements API. " .. tostring(err))
	end
end