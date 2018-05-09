debug.replacemethod("GUIVoiceChat", "SendKeyEvent",
function(key, down, amount)
	local player = Client.GetLocalPlayer()

	if down then
		if ChatUI_EnteringChatMessage() then return end

		local bind = player:isa "Commander" and "VoiceChatCom" or "VoiceChat"
		if GetIsBinding(key, bind) then
			self.recordBind    = bind
			self.recordEndTime = nil

			Client.VoiceRecordStartGlobal()
		elseif GetIsBinding(key, "LocalVoiceChat") then
			self.recordBind    = "LocalVoiceChat"
			self.recordEndTime = nil

			Client.SendNetworkMessage("LocalTalkExtended_teamonly", {on = false}, true)
			Client.VoiceRecordStartEntity(player, Vector.origin)
		elseif GetIsBinding(key, "LocalVoiceChatTeam") then
			self.recordBind    = "LocalVoiceChatTeam"
			self.recordEndTime = nil

			Client.SendNetworkMessage("LocalTalkExtended_teamonly", {on = true}, true)
			Client.VoiceRecordStartEntity(player, Vector.origin)
		end
	elseif self.recordBind and GetIsBinding(key, self.recordBind) then
		self.recordBind = nil
		self.recordEndTime = Shared.GetTime() + Client.GetOptionFloat("recordingReleaseDelay", 0.15)
	end
end)

local kGlobalSpeakerIcon
local ClearAllBars
local GetFreeBar
local kBackgroundOffset
debug.replacemethod("GUIVoiceChat", "Update",
function(delta_time)
	PROFILE("GUIVoiceChat:Update")

	if self.recordEndTime and self.recordEndTime < Shared.GetTime() then
		Client.VoiceRecordStop()
		self.recordEndTime = nil
	end

	ClearAllBars(self)

	local players = ScoreboardUI_GetAllScores()
	local bar_position = Vector(kBackgroundOffset)

	for i = 1, #players do
		if channel ~= VoiceChannel.Invalid then
			local bar = GetFreeBar(self)

			local team = players[i].EntityTeamNumber

			local client_index = players[i].ClientIndex
			local channel      = client_index and ChatUI_GetVoiceChannelForClient(client_index) or VoiceChannel.Invalid

			local color =
				players[i].IsCommander and GUIVoiceChat.kCommanderFontColor or
				team == 1 and GUIVoiceChat.kMarineFontColor or
				team == 2 and GUIVoiceChat.kAlienFontColor or
				GUIVoiceChat.kSpectatorFontColor

			bar.Name:SetText(players[i].Name)
			bar.Name:SetColor(color)

			bar.Icon:SetTexture(kGlobalSpeakerIcon)
			bar.Icon:SetColor(color)

			bar.Background:SetTexture(string.format(kBackgroundTexture, team == 2 and "alien" or "marine"))
			bar.Background:SetColor(team ~= 1 and team ~= 2 and Color(1, 200/255, 150/255, 1) or Color(1, 1, 1, 1))
			bar.Background:SetLayer(kGUILayerDeathScreen+1)
			bar.Background:SetIsVisible(self.visible)
			bar.Background:SetPosition(bar_position)

			bar_position.y = bar_position.y + kBackgroundSize.y + kBackgroundYSpace
		end
	end
end)
