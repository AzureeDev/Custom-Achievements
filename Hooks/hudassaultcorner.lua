Hooks:PostHook( HUDAssaultCorner, "init", "CustomAchievement_Hud_Element", function(self, hud, full_hud, tweak_hud)

	self.achievement_unlocked_panel = self._hud_panel:panel({
		visible = false,
		name = "achievement_unlocked_panel",
		w = 350,
		h = 95,
		color = Color(0,1,1,1)
	})

	self.achievement_unlocked_box = HUDBGBox_create(self.achievement_unlocked_panel, {
		w = 350,
		h = 95,
		x = 0,
		y = 0
	}, {
		blend_mode = "add"
	})

	self.achievement_unlocked_image = self.achievement_unlocked_panel:bitmap({
		name = "achievement_unlocked_image",
		texture = "guis/textures/mods/CustomAchievement/m4a1s_tried_ads",
		texture_rect = {
			0,
			0,
			512,
			256
		},
		layer = 40,
		w = 128,
		h = 64,
		x = 5,
		y = 5
	})

	self.trophy_rank_image = self.achievement_unlocked_panel:bitmap({
		name = "trophy_rank_image",
		texture = "guis/textures/mods/CustomAchievement/trophy_icon_platinum",
		texture_rect = {
			0,
			0,
			256,
			256
		},
		
		layer = 40,
		w = 24,
		h = 24,
		x = 5,
		y = 8
	})

	self.achievement_unlocked_text = self.achievement_unlocked_box:text({
		name = "achievement_unlocked_text",
		text = "Achievement Unlocked!",
		align = "left",
		w = self.achievement_unlocked_box:w(),
		h = self.achievement_unlocked_box:h(),
		layer = 1,
		x = 5,
		y = 8,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = 18
	})

	self.achievement_unlocked_desc = self.achievement_unlocked_box:text({
		name = "achievement_unlocked_desc",
		text = "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
		align = "left",
		w = self.achievement_unlocked_box:w(),
		h = self.achievement_unlocked_box:h(),
		layer = 1,
		x = 5,
		y = 8,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = 14
	})

	self.achievement_unlocked_text:set_left(self.achievement_unlocked_image:right() + 5)
	self.achievement_unlocked_panel:set_top(self._hostages_bg_box:bottom() + 200)
    self.achievement_unlocked_panel:set_left(self._hostages_bg_box:left())
end)