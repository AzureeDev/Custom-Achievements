ClassCustomAchievement = ClassCustomAchievement or class()

ClassCustomAchievement.Directory = nil
ClassCustomAchievement.id_data = {}

function ClassCustomAchievement:_set_json_directory(mod_name, directory)
	local modname = mod_name
	local dir = directory

	ClassCustomAchievement.Directory = "mods/" .. modname .. "/" .. dir .. "/"
end

function ClassCustomAchievement:Load(id_achievement)

	self.id_data.data = id_achievement and {}

	if ClassCustomAchievement.Directory ~= nil then
		local file = io.open(ClassCustomAchievement.Directory .. id_achievement .. ".json", "r")

		if file then
			for k, v in pairs(json.decode(file:read("*all")) or {}) do
				if k then
					self.id_data.data[k] = v
				end
			end
			file:close()
			--log("[CustomAchievement] Loaded Achievement data ID: " .. id_achievement)
		else
			log("[CustomAchievement] ERROR: Couldn't load the achievement " .. id_achievement .. ". Path is correctly set? The file exist? Current path: " .. ClassCustomAchievement.Directory .. id_achievement .. ".json")
		end
	else
		log("[CustomAchievement] ERROR: JSON path directory not set! Use ClassCustomAchievement:_set_json_directory(mod_name, directory) first!!")
	end
end

function ClassCustomAchievement:Save(id_achievement)
	if ClassCustomAchievement.Directory ~= nil then
		local file = io.open( ClassCustomAchievement.Directory .. id_achievement .. ".json" , "w+")
		if file then
			file:write(json.encode(self.id_data.data))
			file:close()
			--log("[CustomAchievement] Saved achievement data : " .. id_achievement)
		end
	else
		log("[CustomAchievement] ERROR: JSON path directory not set! Use ClassCustomAchievement:_set_json_directory(mod_name, directory) first!!")
	end
end

function ClassCustomAchievement:Unlock(id_achievement) -- Once it's done, you unlock it
	Hooks:Add("MenuManagerOnOpenMenu", "CustomAchievement_Menu_Unlocked", function( menu_manager, menu, position)
		if menu == "menu_main" then
			ClassCustomAchievement:Load(id_achievement)
	
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
				ClassCustomAchievement:Save(id_achievement)

			else
				log("error 1")
			end
		end
	end)

	Hooks:Call( "CustomAchievement_Menu_Unlocked", menu_manager, menu, position)

	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then
		self.id_data.data["unlocked"] = true
	end

	self:Save(id_achievement)
end

function ClassCustomAchievement:Lock(id_achievement) -- Sometimes it's useful to lock achievements..
	self:Load(id_achievement)
	self.id_data.data["unlocked"] = false
	self.id_data.data["displayed"] = false
	self.id_data.data["number"] = 0
	self:Save(id_achievement)
end

function ClassCustomAchievement:IncreaseCounter(id_achievement, amount) -- Increases "number" key in the json by amount. Useful of custom weapon kill counters and stuff.
	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
		original_number = self.id_data.data["number"]
		new_number = original_number + amount
		self.id_data.data["number"] = new_number
	end

	ClassCustomAchievement:Save(id_achievement)
end

function ClassCustomAchievement:DecreaseCounter(id_achievement, amount, prevent_negative) -- Decreases "number" key in the json by amount.
	self:Load(id_achievement)

	if prevent_negative == true then
		if self.id_data.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
			local calc = (self.id_data.data["number"]) - amount
			if calc > 0 then
				original_number = self.id_data.data["number"]
				new_number = original_number - amount
				self.id_data.data["number"] = new_number
			else
				self.id_data.data["number"] = 0
			end
		end
	else
		original_number = self.id_data.data["number"]
		new_number = original_number - amount
		self.id_data.data["number"] = new_number
	end

	ClassCustomAchievement:Save(id_achievement)
end

function ClassCustomAchievement:IncreaseWeaponKillCounter(weapon_id, id_achievement, amount)
	self:Load(id_achievement)
	if self.id_data.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
		
	end
end

function ClassCustomAchievement:RetrieveData(id_achievement, key)
	self:Load(id_achievement)
	log("[CustomAchievement] Data retrieved for " .. id_achievement .. ": " .. tostring(self.id_data.data[key]))
	return self.id_data.data[key]
end