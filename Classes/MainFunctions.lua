ClassCustomAchievement = ClassCustomAchievement or class()

ClassCustomAchievement.Directory = nil
ClassCustomAchievement.id_data = {}
ClassCustomAchievement.VERSION = 1 -- If the version changes, you need to update your mod in order.
ClassCustomAchievement.Directory = "mods/Custom Achievements Addons/"
ClassCustomAchievement.addons_path = "mods/Custom Achievements Addons/"

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
		log("[CustomAchievement] ERROR: JSON path directory not set! Use ClassCustomAchievement:_set_json_directory(mod_name) first!!")
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
		log("[CustomAchievement] ERROR: JSON path directory not set! Use ClassCustomAchievement:_set_json_directory(mod_name) first!!")
	end
end

function ClassCustomAchievement:Unlock(id_achievement) -- Once it's done, you unlock it
	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then
		self.id_data.data["unlocked"] = true
	end

	if game_state_machine then
		if self.id_data.data["displayed"] == false then	
			local achievement_name = self.id_data.data["name"]
			local achievement_desc = self.id_data.data["objective"]

			--managers.mission:call_global_event(Message.OnSideJobComplete)
			managers.chat:achievement_unlocked_message(ChatManager.GAME, managers.localization:text("achievement_unlocked_chat"))
			managers.chat:achievement_unlocked_message(ChatManager.GAME, managers.localization:text(achievement_name))
			managers.chat:achievement_unlocked_message(ChatManager.GAME, managers.localization:text(achievement_desc))

			self.id_data.data["displayed"] = true
		end
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

		if self.id_data.data["number"] >= self.id_data.data["goal"] then
			self:Unlock(id_achievement)
		end
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

function ClassCustomAchievement:RetrieveData(id_achievement, key)
	self:Load(id_achievement)
	log("[CustomAchievement] Data retrieved for " .. id_achievement .. ": " .. tostring(self.id_data.data[key]))
	return self.id_data.data[key]
end