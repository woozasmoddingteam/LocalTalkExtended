local ClearAllBars
local GetFreeBar
local kBackgroundOffset
local kBackgroundYSpace
local kBackgroundSize
local kBackgroundTexture
local kVoiceChatIconOffset

debug.replacemethod("GUIVoiceChat", "SendKeyEvent",
function(self, key, down, amount)
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

debug.replacemethod("GUIVoiceChat", "Update",
function(self, delta_time)
	PROFILE("GUIVoiceChat:Update")

	if self.recordEndTime and self.recordEndTime < Shared.GetTime() then
		Client.VoiceRecordStop()
		self.recordEndTime = nil
	end

	ClearAllBars(self)

	local players = ScoreboardUI_GetAllScores()
	local bar_position = Vector(kBackgroundOffset)

	for i = 1, #players do
		local player = players[i]

		local client_index = player.ClientIndex
		local channel = client_index and ChatUI_GetVoiceChannelForClient(client_index) or VoiceChannel.Invalid

		if channel ~= VoiceChannel.Invalid then
			local bar = GetFreeBar(self)

			local team = player.EntityTeamNumber

			local color =
				player.IsCommander and GUIVoiceChat.kCommanderFontColor or
				team == 1 and GUIVoiceChat.kMarineFontColor or
				team == 2 and GUIVoiceChat.kAlienFontColor or
				GUIVoiceChat.kSpectatorFontColor

			bar.Name:SetText(player.Name)
			bar.Name:SetColor(color)

			bar.Background:SetTexture(string.format(kBackgroundTexture, team == 2 and "alien" or "marine"))
			bar.Background:SetColor(team ~= 1 and team ~= 2 and Color(1, 200/255, 150/255, 1) or Color(1, 1, 1, 1))
			bar.Background:SetLayer(kGUILayerDeathScreen+1)
			bar.Background:SetIsVisible(self.visible)
			bar.Background:SetPosition(bar_position)

			bar_position.y = bar_position.y + kBackgroundSize.y + kBackgroundYSpace
		end
	end
end)

debug.replaceupvalue(debug.getupvaluex(GUIVoiceChat.Update, "GetFreeBar"), "CreateChatBar",
function()
	local background = GUIManager:CreateGraphicItem()
	background:SetSize(kBackgroundSize)
	background:SetAnchor(GUIItem.Right, GUIItem.Center)
	background:SetPosition(kBackgroundOffset)
	background:SetIsVisible(false)

	local name = GUIManager:CreateTextItem()
	name:SetFontName(Fonts.kAgencyFB_Small)
	name:SetAnchor(GUIItem.Right, GUIItem.Center)
	name:SetScale(GetScaledVector())
	name:SetTextAlignmentX(GUIItem.Align_Max)
	name:SetTextAlignmentY(GUIItem.Align_Center)
	name:SetPosition(Vector(-GUIScale(30), 0, 0))
	GUIMakeFontScale(name)
	background:AddChild(name)

	return {Background = background, Name = name}
end)

debug.replaceupvalue(GUIVoiceChat.Uninitialize, "DestroyChatBar",
function(bar)
	GUI.DestroyItem(bar.Name)
	bar.Name = nil

	GUI.DestroyItem(bar.Background)
	bar.Background = nil
end)
