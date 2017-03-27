if not ModCore then
	log("[ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
	return
end

CustomAchievementsCore = CustomAchievementsCore or class(ModCore)

function CustomAchievementsCore:init()
	--Calling the base function for init from ModCore
	--self_tbl, config path, auto load modules, auto post init modules
	self.super.init(self, ModPath .. "config.xml", true, true)
end

if not _G.CustomAchievement then
	local success, err = pcall(function() CustomAchievementsCore:new() end)
	if not success then
		log("[ERROR] An error occured on the initialization of Custom Achievements API. " .. tostring(err))
	end
end

Hooks:Add("MenuManagerOnOpenMenu", "CustomAchievement_Menu_Unlocked", function( menu_manager, menu, position)
	if menu == "menu_main" then
		
		function CustomAchievement:Display_Unlocked_Achievement(id_achievement)
			CustomAchievement:Load(id_achievement)

			if CustomAchievement.achievement_opened == true then
				
				if CustomAchievement.data["unlocked"] == true and CustomAchievement.data["displayed"] == false then
					
					local achievement_title = managers.localization:text(CustomAchievement.data["name"])
					local achievement_desc = managers.localization:text(CustomAchievement.data["desc"])

					local menu_title = managers.localization:text("achievement_unlocked_menu")
					local menu_message = achievement_title .. "\n\n" .. achievement_desc
					local menu_options = {
					    [1] = {
					        text = managers.localization:text("achievement_unlocked_ok"),
					        is_cancel_button = true,
					    },
					}
					QuickMenu:new( menu_title, menu_message, menu_options, true )

					CustomAchievement.data["displayed"] = true
					CustomAchievement:Save(id_achievement)

				else
					log("error 1")
				end
			else
				log("error 2")
			end
		end

		-- Define our own achievements
		CustomAchievement:_set_json_directory("Custom Achievements API", "Achievements")
		CustomAchievement:IncreaseCounter("achievement_reload_1", 1)
		CustomAchievement:IncreaseCounter("achievement_reload_2", 1)
		CustomAchievement:IncreaseCounter("achievement_reload_3", 1)
		CustomAchievement:IncreaseCounter("achievement_reload_4", 1)

		CustomAchievement:Load("achievement_reload_1")

		if CustomAchievement.data["unlocked"] ~= true then
			if CustomAchievement.data["number"] >= 1 then
				CustomAchievement:Unlock("achievement_reload_1")
				CustomAchievement:Display_Unlocked_Achievement("achievement_reload_1")
			end
		end

		CustomAchievement:Load("achievement_reload_2")

		if CustomAchievement.data["unlocked"] ~= true then
			if CustomAchievement.data["number"] >= 10 then
				CustomAchievement:Unlock("achievement_reload_2")
				CustomAchievement:Display_Unlocked_Achievement("achievement_reload_2")
			end
		end

		CustomAchievement:Load("achievement_reload_3")

		if CustomAchievement.data["unlocked"] ~= true then
			if CustomAchievement.data["number"] >= 50 then
				CustomAchievement:Unlock("achievement_reload_3")
				CustomAchievement:Display_Unlocked_Achievement("achievement_reload_3")
			end
		end

		CustomAchievement:Load("achievement_reload_4")

		if CustomAchievement.data["unlocked"] ~= true then
			if CustomAchievement.data["number"] >= 100 then
				CustomAchievement:Unlock("achievement_reload_4")
				CustomAchievement:Display_Unlocked_Achievement("achievement_reload_4")
			end
		end
	end
end)