function CustomSafehouseGui:populate_tabs_data(tabs_data)
	if not self._in_game then
		table.insert(tabs_data, {
			name_id = "menu_cs_map",
			page_class = "CustomSafehouseGuiPageMap"
		})
	end
	table.insert(tabs_data, {
		name_id = "menu_cs_trophies",
		page_class = "CustomSafehouseGuiPageTrophies"
	})
	table.insert(tabs_data, {
		name_id = "achievement_menu_page_tab",
		page_class = "CustomAchievementsPage"
	})
	table.insert(tabs_data, {
		name_id = "menu_cs_daily_challenge",
		page_class = "CustomSafehouseGuiPageDaily",
		width_multiplier = 1
	})
end