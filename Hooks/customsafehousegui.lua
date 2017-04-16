Hooks:PostHook( CustomSafehouseGui, "populate_tabs_data", "custom_achievement_tab_add", function(self, tabs_data)
	table.insert(tabs_data, {
		name_id = "achievement_menu_page_tab",
		page_class = "CustomAchievementsPage"
	})
end)