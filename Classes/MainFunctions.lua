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
			for k, v in pairs(json.custom_decode(file:read("*all")) or {}) do
				if k then
					self.id_data.data[k] = v
				end
			end
			file:close()
			--log("[CustomAchievement] Loaded Achievement data ID: " .. id_achievement)
		else
			log("[CustomAchievement] ERROR: Couldn't load the achievement " .. id_achievement .. ". Path is correctly set? The file exist? Current path: " .. ClassCustomAchievement.Directory .. id_achievement .. ".json")
		end
	end
end

function ClassCustomAchievement:Save(id_achievement)
	if ClassCustomAchievement.Directory ~= nil then
		local file = io.open( ClassCustomAchievement.Directory .. id_achievement .. ".json" , "w+")
		if file then
			file:write(json.custom_encode(self.id_data.data))
			file:close()
			--log("[CustomAchievement] Saved achievement data : " .. id_achievement)
		end
	end
end

function ClassCustomAchievement:Unlock(id_achievement) -- Once it's done, you unlock it
	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then
		self:Reward()
		self.id_data.data["unlocked"] = true
	end

	if game_state_machine then
		if self.id_data.data["displayed"] == false then	
			local achievement_name = self.id_data.data["name"]
			local achievement_desc = self.id_data.data["objective"]

			if managers.hud then
				managers.hud:post_event("Achievement_challenge")
				
				hudac = managers.hud._hud_assault_corner
				
				if hudac then
					if self.id_data.data["rank"] then
						hudac.trophy_rank_image:set_image("guis/textures/mods/CustomAchievement/trophy_icon_" .. self.id_data.data["rank"])
					else
						hudac.trophy_rank_image:set_visible(false)
					end
				    hudac.achievement_unlocked_image:set_image("guis/textures/mods/CustomAchievement/" .. self.id_data.data["texture"])
				    hudac.trophy_rank_image:set_right(hudac.achievement_unlocked_panel:right() - 9)
				    hudac.achievement_unlocked_text:set_text("Achievement Unlocked!\n\n" .. managers.localization:text(self.id_data.data["name"]))
				    hudac.achievement_unlocked_desc:set_text(managers.localization:text(self.id_data.data["objective"]))
				    hudac.achievement_unlocked_desc:set_top(hudac.achievement_unlocked_image:bottom() + 4)
				    hudac.achievement_unlocked_desc:set_left(hudac.achievement_unlocked_image:right() + 5)
				    hudac.achievement_unlocked_panel:set_visible(true)
					
				    DelayedCalls:Add( "DelayedVisibleToFalse", 10, function()
				    	hudac.achievement_unlocked_panel:set_visible(false)
					end)
				end
			end

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

function ClassCustomAchievement:Reward()
	-- Types supported: 
	-- cc (continental coins)
	-- money (spendable cash)
	-- experience
	-- offshore

	if self.id_data.data then
		if self.id_data.data["reward_type"] and self.id_data.data["reward_amount"] then
			if self.id_data.data["unlocked"] == false then
				local json_reward_type = string.lower(self.id_data.data["reward_type"])
				local json_reward_amount = self.id_data.data["reward_amount"]

				if json_reward_amount < 0 then
					json_reward_amount = 0
				end

				if json_reward_type == "cc" then

					if json_reward_amount > 10 then
						json_reward_amount = 0
					end

					local current = Application:digest_value(managers.custom_safehouse._global.total)
					local future_cc = current + json_reward_amount
					Global.custom_safehouse_manager.total = Application:digest_value(future_cc, true)

				elseif json_reward_type == "money" then
					if json_reward_amount > 1000000 then
						json_reward_amount = 0
					end

					managers.money:_add_to_total(json_reward_amount, {no_offshore = true})

				elseif json_reward_type == "offshore" then
					
					if json_reward_amount > 2000000 then
						json_reward_amount = 0
					end

					managers.money:add_to_offshore(json_reward_amount)

				elseif json_reward_type == "experience" then
					if json_reward_amount > 500000 then
						json_reward_amount = 0
					end

					local current_level = managers.experience:current_level()
					local lv_div = current_level / 100
					local new_reward = json_reward_amount * lv_div
					local real_xp = new_reward

					managers.experience:debug_add_points(real_xp, false)
				else
					log("[CustomAchievement] AVERT : No rewards or invalid type. Skipping reward")					
				end
			end
		else
			log("[CustomAchievement] AVERT : Cannot give rewards for the achievement " .. self.id_data.data["id"] .. ". You need to update your JSON file with 'reward_type' and 'reward_amount'. Skipping reward")
		end
	else
		log("[CustomAchievement] ERROR : No data loaded. Skipping reward")
	end
end

function ClassCustomAchievement:init_achievement_rank()
	self.total_points = 0

	self.rank = {}
	self.rank.none = {}
	self.rank.none.name = "None"
	self.rank.none.color = tweak_data.screen_colors.title
	self.rank.none.points = 0

	self.rank.bronze = {}
	self.rank.bronze.name = "Bronze"
	self.rank.bronze.color = Color(255, 188, 94, 0) / 255
	self.rank.bronze.points = 5

	self.rank.silver = {}
	self.rank.silver.name = "Silver"
	self.rank.silver.color = Color(255, 160, 160, 160) / 255
	self.rank.silver.points = 20

	self.rank.gold = {}
	self.rank.gold.name = "Gold"
	self.rank.gold.color = Color(255, 255, 188, 0) / 255
	self.rank.gold.points = 100

	self.rank.platinum = {}
	self.rank.platinum.name = "Platinum"
	self.rank.platinum.color = Color(255, 0, 213, 255) / 255
	self.rank.platinum.points = 500
end

function ClassCustomAchievement:init_achievement_rank_levels()
	self.rank_level = {}
	self.rank_level.experience = 20
	self.level_calculation = self.total_points / self.rank_level.experience
	return self.level_calculation
end

function ClassCustomAchievement:get_rank_level()
	return math.floor(self:init_achievement_rank_levels()) + 1
end

function ClassCustomAchievement:get_achievement_rank_string(id_achievement)
	self:Load(id_achievement)

	if self.id_data.data["rank"] then
		return self.id_data.data["rank"]
	end

	return "none"
end

function ClassCustomAchievement:get_achievement_rank_icon(id_achievement)
	self:Load(id_achievement)

	if self.id_data.data["rank"] then
		if self.id_data.data["rank"] == "bronze" then
			return "guis/textures/mods/CustomAchievement/trophy_icon_bronze"
		elseif self.id_data.data["rank"] == "silver" then
			return "guis/textures/mods/CustomAchievement/trophy_icon_silver"
		elseif self.id_data.data["rank"] == "gold" then
			return "guis/textures/mods/CustomAchievement/trophy_icon_gold"
		elseif self.id_data.data["rank"] == "platinum" then
			return "guis/textures/mods/CustomAchievement/trophy_icon_platinum"
		else
			return "guis/textures/mods/CustomAchievement/trophy_icon_silver"
		end
	end
end

function ClassCustomAchievement:IncreaseCounter(id_achievement, amount)
	self:Load(id_achievement)

	if self.id_data.data["unlocked"] ~= true then
		local original_number = self.id_data.data["number"]
		local new_number = original_number + amount
		self.id_data.data["number"] = new_number

		if self.id_data.data["number"] >= self.id_data.data["goal"] then
			self:Unlock(id_achievement)
		end
	end

	self:Save(id_achievement)
end

function ClassCustomAchievement:DecreaseCounter(id_achievement, amount, prevent_negative)
	self:Load(id_achievement)

	if prevent_negative == true then
		if self.id_data.data["unlocked"] ~= true then
			local calc = (self.id_data.data["number"]) - amount
			if calc > 0 then
				local original_number = self.id_data.data["number"]
				local new_number = original_number - amount
				self.id_data.data["number"] = new_number
			else
				self.id_data.data["number"] = 0
			end
		end
	else
		local original_number = self.id_data.data["number"]
		local new_number = original_number - amount
		self.id_data.data["number"] = new_number
	end

	ClassCustomAchievement:Save(id_achievement)
end

function ClassCustomAchievement:isHeistCompleted(id_achievement, id_level, id_diff)
	if game_state_machine then
		local required_level = id_level
		local required_difficulty = id_diff
		local current_level = managers.job:current_level_id()
		local current_diff = Global.game_settings.difficulty

		if required_level == current_level then
			if required_difficulty == current_diff then
				if managers.job:stage_success() then
					if managers.job:on_last_stage() then
						self:Unlock(id_achievement)
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isHeistCountCompleted(id_achievement, id_level, id_diff)
	if game_state_machine then
		local required_level = id_level
		local required_difficulty = id_diff
		local current_level = managers.job:current_level_id()
		local current_diff = Global.game_settings.difficulty

		if required_level == current_level then
			if required_difficulty == current_diff then
				if managers.job:stage_success() then
					if managers.job:on_last_stage() then
						self:IncreaseCounter(id_achievement, 1)

						if self.id_data.data["number"] >= self.id_data.data["goal"] then
							self:Unlock(id_achievement)
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isDifficultyCompleted(id_achievement, id_diff)
	if game_state_machine then
		local required_difficulty = id_diff
		local current_diff = Global.game_settings.difficulty

		if required_difficulty == current_diff then
			if managers.job:stage_success() then
				if managers.job:on_last_stage() then
					self:Unlock(id_achievement)
				end
			end
		end
	end
end

function ClassCustomAchievement:isDifficultyCountCompleted(id_achievement, id_diff)
	if game_state_machine then
		local required_difficulty = id_diff
		local current_diff = Global.game_settings.difficulty

		if required_difficulty == current_diff then
			self:IncreaseCounter(id_achievement, 1)

			if self.id_data.data["number"] >= self.id_data.data["goal"] then
				self:Unlock(id_achievement)
			end
		end
	end
end

function ClassCustomAchievement:isPrimaryWeaponEquipped(id_achievement, id_weapon)
	local current_primary = managers.blackmarket:equipped_primary()
	local wanted_primary = id_weapon

	if current_primary and current_primary.weapon_id == wanted_primary then
		self:Unlock(id_achievement)
	end
end

function ClassCustomAchievement:isPrimaryWeaponCountEquipped(id_achievement, id_weapon)
	local current_primary = managers.blackmarket:equipped_primary()
	local wanted_primary = id_weapon

	if current_primary and current_primary.weapon_id == wanted_primary then
		self:IncreaseCounter(id_achievement, 1)
	end
end

function ClassCustomAchievement:isSecondaryWeaponEquipped(id_achievement, id_weapon)
	local current_secondary = managers.blackmarket:equipped_secondary()
	local wanted_secondary = id_weapon

	if current_secondary and current_secondary.weapon_id == wanted_secondary then
		self:Unlock(id_achievement)
	end
end

function ClassCustomAchievement:isSecondaryWeaponCountEquipped(id_achievement, id_weapon)
	local current_secondary = managers.blackmarket:equipped_secondary()
	local wanted_secondary = id_weapon

	if current_secondary and current_secondary.weapon_id == wanted_secondary then
		self:IncreaseCounter(id_achievement, 1)
	end
end

function ClassCustomAchievement:AddKillsByWeaponTotal(id_achievement, id_weapon)
	if game_state_machine then
		self:Load(id_achievement)

		local current_state = managers.player:get_current_state()
		
		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
				if current_weapon.name_id == id_weapon then
					if not self.id_data.data["unlocked"] then
						self.id_data.data["number"] = self.id_data.data["number"] + 1
						self:Save(id_achievement)

						if self.id_data.data["number"] >= self.id_data.data["goal"] then
							self:Unlock(id_achievement)
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isKillsFilledByWeaponSession(id_achievement, id_weapon)
	if game_state_machine then
		self:Load(id_achievement)

		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if current_weapon.name_id == id_weapon then
				if not self.id_data.data["unlocked"] then
					if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count >= self.id_data.data["goal"] then
						self:Unlock(id_achievement)
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:AddKillsByWeaponTotalOnMap(id_achievement, id_weapon, id_level)
	if game_state_machine then
		self:Load(id_achievement)

		local required_level = id_level
		local current_level = managers.job:current_level_id()
		local current_state = managers.player:get_current_state()

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if current_level == required_level then
				if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
					if current_weapon.name_id == id_weapon then
						if not self.id_data.data["unlocked"] then
							self.id_data.data["number"] = self.id_data.data["number"] + 1
							self:Save(id_achievement)

							if self.id_data.data["number"] >= self.id_data.data["goal"] then
								self:Unlock(id_achievement)
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isKillsFilledByWeaponSessionOnMap(id_achievement, id_weapon, id_level)
	if game_state_machine then
		self:Load(id_achievement)

		local required_level = id_level
		local current_level = managers.job:current_level_id()
		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if required_level == current_level then
				if current_weapon.name_id == id_weapon then
					if not self.id_data.data["unlocked"] then
						if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count >= self.id_data.data["goal"] then
							self:Unlock(id_achievement)
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:AddKillsByWeaponTotalOnDifficulty(id_achievement, id_weapon, id_diff)
	if game_state_machine then
		self:Load(id_achievement)

		local required_difficulty = id_diff
		local current_diff = Global.game_settings.difficulty
		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if current_diff == required_diff then
				if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
					if current_weapon.name_id == id_weapon then
						if not self.id_data.data["unlocked"] then
							self.id_data.data["number"] = self.id_data.data["number"] + 1
							self:Save(id_achievement)

							if self.id_data.data["number"] >= self.id_data.data["goal"] then
								self:Unlock(id_achievement)
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isKillsFilledByWeaponSessionOnDifficulty(id_achievement, id_weapon, id_diff)
	if game_state_machine then
		self:Load(id_achievement)

		local required_difficulty = id_diff
		local current_diff = Global.game_settings.difficulty
		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if required_difficulty == current_diff then
				if current_weapon.name_id == id_weapon then
					if not self.id_data.data["unlocked"] then
						if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count >= self.id_data.data["goal"] then
							self:Unlock(id_achievement)
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:AddKillsByWeaponTotalOnMapAndDifficulty(id_achievement, id_weapon, id_level, id_diff)
	if game_state_machine then
		self:Load(id_achievement)

		local required_level = id_level
		local current_level = managers.job:current_level_id()
		local required_difficulty = id_diff
		local current_diff = Global.game_settings.difficulty
		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if current_level == required_level then
				if current_diff == required_diff then
					if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
						if current_weapon.name_id == id_weapon then
							if not self.id_data.data["unlocked"] then
								self.id_data.data["number"] = self.id_data.data["number"] + 1
								self:Save(id_achievement)

								if self.id_data.data["number"] >= self.id_data.data["goal"] then
									self:Unlock(id_achievement)
								end
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isKillsFilledByWeaponSessionOnMapAndDifficulty(id_achievement, id_weapon, id_level, id_diff)
	if game_state_machine then
		self:Load(id_achievement)

		local required_level = id_level
		local current_level = managers.job:current_level_id()
		local required_difficulty = id_diff
		local current_diff = Global.game_settings.difficulty
		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if required_level == current_level then
				if required_difficulty == current_diff then
					if current_weapon.name_id == id_weapon then
						if not self.id_data.data["unlocked"] then
							if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count >= self.id_data.data["goal"] then
								self:Unlock(id_achievement)
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:WeaponEquippedOnMapAndDiff(ach_id, id_level, weapon_id, diff_id)
	if game_state_machine then
		self:Load(ach_id)
		local current_primary = managers.blackmarket:equipped_primary()
		local wanted_primary = weapon_id
		local required_level = id_level
		local current_level = managers.job:current_level_id()
		local required_difficulty = diff_id
		local current_diff = Global.game_settings.difficulty

		if current_primary and current_primary.weapon_id == wanted_primary then
			if required_level == current_level then
				if required_difficulty == current_diff then
					if managers.job:on_last_stage() then
						if managers.job:stage_success() then
							self:Unlock(ach_id)
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:WeaponEquippedOnDiff(ach_id, weapon_id, diff_id)
	if game_state_machine then
		self:Load(ach_id)
		local current_primary = managers.blackmarket:equipped_primary()
		local wanted_primary = weapon_id
		local required_difficulty = diff_id
		local current_diff = Global.game_settings.difficulty

		if current_primary and current_primary.weapon_id == wanted_primary then
			if required_difficulty == current_diff then
				if managers.job:on_last_stage() then
					if managers.job:stage_success() then
						self:Unlock(ach_id)
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isSpecialKilled(id_achievement, id_special, data)	-- Must be hooked on StatisticsManager:killed
	self:Load(id_achievement)
	
	if data then
		if data.name == id_special then
			self:IncreaseCounter(id_achievement, 1)
		end
	end
end

function ClassCustomAchievement:isSpecialKilledWithWeapon(id_achievement, id_weapon, id_special, data) -- Must be hooked on StatisticsManager:killed
	self:Load(id_achievement)

	if data then
		
		local current_state = managers.player:get_current_state()
		
		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if data.name == id_special then
				if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
					if current_weapon.name_id == id_weapon then
						if not self.id_data.data["unlocked"] then
							self.id_data.data["number"] = self.id_data.data["number"] + 1
							self:Save(id_achievement)

							if self.id_data.data["number"] >= self.id_data.data["goal"] then
								self:Unlock(id_achievement)
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isSpecialKilledOnMap(id_achievement, id_map, id_special, data) -- Must be hooked on StatisticsManager:killed
	local required_level = id_map
	local current_level = managers.job:current_level_id()
	self:Load(id_achievement)

	if data then
		if current_level == required_level then
			if data.name == id_special then
				if not self.id_data.data["unlocked"] then
					self:IncreaseCounter(id_achievement, 1)
				end
			end
		end
	end
end

function ClassCustomAchievement:isSpecialKilledOnDifficulty(id_achievement, id_diff, id_special, data) -- Must be hooked on StatisticsManager:killed
	local required_difficulty = id_diff
	local current_diff = Global.game_settings.difficulty

	self:Load(id_achievement)

	if data then
		if required_difficulty == current_diff then
			if data.name == id_special then
				if not self.id_data.data["unlocked"] then
					self:IncreaseCounter(id_achievement, 1)
				end
			end
		end
	end
end

function ClassCustomAchievement:isSpecialKilledOnMapWithWeapon(id_achievement, id_map, id_weapon, id_special, data) -- Must be hooked on StatisticsManager:killed
	local required_level = id_map
	local current_level = managers.job:current_level_id()
	self:Load(id_achievement)

	if data then
		
		local current_state = managers.player:get_current_state()
		

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if required_level == current_level then
				if data.name == id_special then
					if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
						if current_weapon.name_id == id_weapon then
							if not self.id_data.data["unlocked"] then
								self.id_data.data["number"] = self.id_data.data["number"] + 1
								self:Save(id_achievement)

								if self.id_data.data["number"] >= self.id_data.data["goal"] then
									self:Unlock(id_achievement)
								end
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isSpecialKilledOnMapAndDifficultyWithWeapon(id_achievement, id_map, id_diff, id_weapon, id_special, data)
	local required_level = id_map
	local current_level = managers.job:current_level_id()
	local required_difficulty = id_diff
	local current_diff = Global.game_settings.difficulty

	self:Load(id_achievement)

	if data then
		local current_state = managers.player:get_current_state()

		if current_state then
			local current_weapon = current_state:get_equipped_weapon()
			if required_level == current_level then
				if required_difficulty == current_diff then
					if data.name == id_special then
						if managers.statistics._global.session.killed_by_weapon[id_weapon] and managers.statistics._global.session.killed_by_weapon[id_weapon].count then
							if current_weapon.name_id == id_weapon then
								if not self.id_data.data["unlocked"] then
									self.id_data.data["number"] = self.id_data.data["number"] + 1
									self:Save(id_achievement)

									if self.id_data.data["number"] >= self.id_data.data["goal"] then
										self:Unlock(id_achievement)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function ClassCustomAchievement:isStealth()
	if managers.groupai:state():whisper_mode() then
		return true
	else
		return false
	end
end

function ClassCustomAchievement:isHeadshot(data) -- Must be hooked on StatisticsManager:killed
	if data then
		if data.head_shot == 1 then
			return true
		else
			return false
		end
	end
end

function ClassCustomAchievement:RetrieveData(id_achievement, key)
	self:Load(id_achievement)
	log("[CustomAchievement] Data retrieved for " .. id_achievement .. ": " .. tostring(self.id_data.data[key]))
	return self.id_data.data[key]
end