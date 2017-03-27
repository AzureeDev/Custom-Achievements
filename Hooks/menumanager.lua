CustomAchievement = {}

CustomAchievement.Directory = nil
CustomAchievement.data = {}

function CustomAchievement:_set_json_directory(mod_name, directory)
	local modname = mod_name
	local dir = directory

	self.Directory = "mods/" .. modname .. "/" .. dir
end

function CustomAchievement:Load(id_achievement)
	if self.Directory ~= nil then
		self.achievement_opened = false
		local file = io.open(self.Directory .. id_achievement .. ".json", "r")

		if file then
			for k, v in pairs(json.decode(file:read("*all")) or {}) do
				if k then
					CustomAchievement.data[k] = v
				end
			end
			file:close()
			--log("[CustomAchievement] Loaded Achievement data ID: " .. id_achievement)
			self.achievement_opened = true
		else
			log("[CustomAchievement] ERROR: Couldn't load the achievement " .. id_achievement .. ". Path is correctly set? The file exist? Current path: " .. self.Directory .. id_achievement .. ".json")
		end
	else
		log("[CustomAchievement] ERROR: JSON path directory not set! Use CustomAchievement:_set_json_directory(path) first!!")
	end
end

function CustomAchievement:Save(id_achievement)
	if self.Directory ~= nil then
		self.achievement_opened = false
		local file = io.open( self.Directory .. id_achievement .. ".json" , "w+")
		if file then
			file:write(json.encode(self.data))
			file:close()
			--log("[CustomAchievement] Saved achievement data : " .. id_achievement)
			self.achievement_opened = true
		end
	else
		log("[CustomAchievement] ERROR: JSON path directory not set! Use CustomAchievement:_set_json_directory(path) first!!")
	end
end

function CustomAchievement:Unlock(id_achievement) -- Once it's done, you unlock it
	self:Load(id_achievement)

	if self.achievement_opened == true then
		self.data["unlocked"] = true
	end

	self:Save(id_achievement)
end

function CustomAchievement:Lock(id_achievement) -- Sometimes it's useful to lock achievements..
	self:Load(id_achievement)

	if self.achievement_opened == true then
		self.data["unlocked"] = false
	end

	self:Save(id_achievement)
end

function CustomAchievement:IncreaseCounter(id_achievement, amount) -- Increases "number" key in the json by amount. Useful of custom weapon kill counters and stuff.
	self:Load(id_achievement)
	if self.achievement_opened == true then
		if self.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
			original_number = self.data["number"]
			new_number = original_number + amount
			self.data["number"] = new_number
		end
	end

	CustomAchievement:Save(id_achievement)
end

function CustomAchievement:IncreaseWeaponKillCounter(weapon_id, id_achievement, amount)
	self:Load(id_achievement)
	if self.achievement_opened == true then
		if self.data["unlocked"] ~= true then -- No need to write 5000 things if already unlocked
			
		end
	end
end