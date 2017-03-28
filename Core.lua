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

--[[ Define our own achievements
CustomAchievement:_set_json_directory("Custom Achievements API", "Achievements")
CustomAchievement:IncreaseCounter("achievement_reload_2", 1)
CustomAchievement:IncreaseCounter("achievement_reload_3", 1)
CustomAchievement:IncreaseCounter("achievement_reload_4", 1)

CustomAchievement:Load("achievement_reload_1")
CustomAchievement:Unlock("achievement_reload_1")


CustomAchievement:Load("achievement_reload_2")

if self.id_data.data["number"] >= 10 then
	CustomAchievement:Unlock("achievement_reload_2")
end

CustomAchievement:Load("achievement_reload_3")

if self.id_data.data["number"] >= 50 then
	CustomAchievement:Unlock("achievement_reload_3")
end

CustomAchievement:Load("achievement_reload_4")

if self.id_data.data["number"] >= 100 then
	CustomAchievement:Unlock("achievement_reload_4")
end]]--