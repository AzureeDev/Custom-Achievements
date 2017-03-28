function ChatManager:achievement_unlocked_message(channel_id, message)
	self:_receive_message(channel_id, managers.localization:to_upper_text("achievement_global_chat"), message, Color(255, 240, 212, 255) / 255)
end