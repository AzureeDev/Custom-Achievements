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

CustomAchievement = {}

CustomAchievement.Directory = nil
CustomAchievement.id_data = {}

function CustomAchievement:_set_json_directory(mod_name, directory)
	local modname = mod_name
	local dir = directory

	self.Directory = "mods/" .. modname .. "/" .. dir .. "/"
end

function CustomAchievement:Load(id_achievement)

	self.id_data.data = id_achievement and {}

	if self.Directory ~= nil then
		local file = io.open(self.Directory .. id_achievement .. ".json", "r")

		if file then
			for k, v in pairs(json.decode(file:read("*all")) or {}) do
				if k then
					self.id_data.data[k] = v
				end
			end
			file:close()
			--log("[CustomAchievement] Loaded Achievement data ID: " .. id_achievement)
		else
			log("[CustomAchievement] ERROR: Couldn't load the achievement " .. id_achievement .. ". Path is correctly set? The file exist? Current path: " .. self.Directory .. id_achievement .. ".json")
		end
	else
		log("[CustomAchievement] ERROR: JSON path directory not set! Use CustomAchievement:_set_json_directory(mod_name, directory) first!!")
	end
end

function CustomAchievement:Save(id_achievement)
	if self.Directory ~= nil then
		local file = io.open( self.Directory .. id_achievement .. ".json" , "w+")
		if file then
			file:write(json.encode(self.id_data.data))
			file:close()
			log("[CustomAchievement] Saved achievement data : " .. id_achievement)
		end
	else
		log("[CustomAchievement] ERROR: JSON path directory not set! Use CustomAchievement:_set_json_directory(mod_name, directory) first!!")
	end
end

function CustomAchievement:Unlock(id_achievement) -- Once it's done, you unlock it
	Hooks:Add("MenuManagerOnOpenMenu", "CustomAchievement_Menu_Unlocked", function( menu_manager, menu, position)
		if menu == "menu_main" then
			CustomAchievement:Load(id_achievement)
	
			if self.id_data.data["displayed"] == false then
				
				local achievement_title = managers.localization:text(self.id_data.data["name"])
				local achievement_desc = managers.localization:text(self.id_data.data["desc"])

				local menu_title = managers.localization:text("achievement_unlocked_menu")
				local menu_message = achievement_title .. "\n\n" .. achievement_desc
				local menu_options = {
				    [1] = {
				        text = managers.localization:text("achievement_unlocked_ok"),
				        is_cancel_button = true,
				    },
				}
				QuickMenu:new( menu_title, menu_message, menu_options, true )

				self.id_data.data["displayed"] = true
				CustomAchievement:Save(id_achievement)

			else
				log("error 1")
			end
		end
	end)

	Hooks:Call( "CustomAchievement_Menu_Unlocked", menu_manager, menu, position )

	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then
		self.id_data.data["unlocked"] = true
	end

	self:Save(id_achievement)
end

function CustomAchievement:Lock(id_achievement) -- Sometimes it's useful to lock achievements..
	self:Load(id_achievement)
	self.id_data.data["unlocked"] = false
	self:Save(id_achievement)
end

function CustomAchievement:IncreaseCounter(id_achievement, amount) -- Increases "number" key in the json by amount. Useful of custom weapon kill counters and stuff.
	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
		original_number = self.id_data.data["number"]
		new_number = original_number + amount
		self.id_data.data["number"] = new_number
	end

	CustomAchievement:Save(id_achievement)
end

function CustomAchievement:IncreaseWeaponKillCounter(weapon_id, id_achievement, amount)
	self:Load(id_achievement)
	if self.id_data.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
		
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