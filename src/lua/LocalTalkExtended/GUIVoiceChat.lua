class 'GUIVoiceChat' (GUIScript)

kLocalVoiceFontColor         = kLocalVoiceFontColor         or Color(0.50, 1.00, 0.50, 1)
kLocalVoiceTeamOnlyFontColor = kLocalVoiceTeamOnlyFontColor or Color(0.75, 0.15, 0.75, 1)

GUIVoiceChat.kCommanderFontColor = Color(1, 1, 0, 1)
GUIVoiceChat.kMarineFontColor    = Color(147/255, 206/255, 1, 1)
GUIVoiceChat.kAlienFontColor     = Color(207/255, 139/255, 41/255, 1)
GUIVoiceChat.kSpectatorFontColor = Color(1, 1, 1, 1)

local kBackgroundTextureMarine = PrecacheAsset("ui/marine_HUD_presbg.dds")
local kBackgroundTextureAlien  = PrecacheAsset("ui/alien_HUD_presbg.dds")

local kGlobalSpeakerIcon = PrecacheAsset("ui/speaker.dds")

local chat_bars

local function ResetBarForPlayer(pie)
	local bar = pie.voice_chat_bar
	if not bar then return end

	pie.voice_chat_bar = nil
	pie.voice_channel  = nil
	bar.player = Entity.invalidId
	bar.background:SetIsVisible(false)
end

local function ResetBarForClient(client)
	for _, pie in ientitylist(Shared.GetEntitiesWithClassname "PlayerInfoEntity") do
		if pie.clientId == client then
			return ResetBarForPlayer(pie)
		end
	end
end

local function IsRelevant(pie)
	return Shared.GetEntity(pie.playerId) ~= nil
end

local function GetVoiceChannel(client)
	local channel
	if Client.GetLocalClientIndex() == client then
		channel = Client.GetVoiceChannelForRecording()
	else
		channel = Client.GetVoiceChannelForClient(client)
	end
	return channel or VoiceChannel.Invalid
end

function GUIVoiceChat:Initialize()
	self.visible = true

	local kBackgroundSize   = Vector(GUIScale(250), GUIScale(28), 0)
	local kBackgroundYSpace = GUIScale(4)

	local kVoiceChatIconSize   = Vector(kBackgroundSize.y, kBackgroundSize.y, 0)
	local kVoiceChatIconOffset = Vector(-kBackgroundSize.y * 2, -kVoiceChatIconSize.x / 2, 0)

	local kNameOffsetFromChatIcon = Vector(-kBackgroundSize.y - GUIScale(6), 0, 0)

	local num_chat_bars = math.ceil(Client.GetScreenHeight() / 2 / (kBackgroundYSpace + kBackgroundSize.y))
	chat_bars = table.array(num_chat_bars + 1)

	local bar_position = Vector(-kBackgroundSize.x, 0, 0)
	for i = 1, num_chat_bars do
		local background = GUIManager:CreateGraphicItem()
		background:SetSize(kBackgroundSize)
		background:SetAnchor(GUIItem.Right, GUIItem.Center)
		background:SetLayer(kGUILayerDeathScreen+1)
		background:SetPosition(bar_position)
		background:SetIsVisible(false)

		local icon = GUIManager:CreateGraphicItem()
		icon:SetSize(kVoiceChatIconSize)
		icon:SetAnchor(GUIItem.Right, GUIItem.Center)
		icon:SetPosition(kVoiceChatIconOffset)
		icon:SetTexture(kGlobalSpeakerIcon)
		background:AddChild(icon)

		local name = GUIManager:CreateTextItem()
		name:SetFontName(Fonts.kAgencyFB_Small)
		name:SetAnchor(GUIItem.Right, GUIItem.Center)
		name:SetScale(GetScaledVector())
		name:SetTextAlignmentX(GUIItem.Align_Max)
		name:SetTextAlignmentY(GUIItem.Align_Center)
		name:SetPosition(kNameOffsetFromChatIcon)
		GUIMakeFontScale(name)
		icon:AddChild(name)

		bar_position.y = bar_position.y + kBackgroundYSpace + kBackgroundSize.y

		chat_bars[i] = {background = background, icon = icon, name = name, player = Entity.invalidId}
	end
end

function GUIVoiceChat:Uninitialize()
	for i = 1, #chat_bars do
		GUI.DestroyItem(chat_bars[i].name)
		GUI.DestroyItem(chat_bars[i].background)
		GUI.DestroyItem(chat_bars[i].icon)
	end

	chat_bars = nil
end

function GUIVoiceChat:SetIsVisible(visible)
	self.visible = visible

	for i = 1, #chat_bars do
		chat_bars[i].background:SetIsVisible(visible)
	end
end

function GUIVoiceChat:GetIsVisible()
	return self.visible
end

function GUIVoiceChat:OnResolutionChanged()
	self:Uninitialize()
	self:Initialize()
end

local team_only
function GUIVoiceChat:SendKeyEvent(key, down, amount)
	local player = Client.GetLocalPlayer()
	local client = Client.GetLocalClientIndex()

	if down then
		if ChatUI_EnteringChatMessage() then return end

		local bind = player:isa "Commander" and "VoiceChatCom" or "VoiceChat"
		if GetIsBinding(key, bind) then
			self.recordBind    = bind
			self.recordEndTime = nil
			ResetBarForClient(client)

			Client.VoiceRecordStartGlobal()
		elseif GetIsBinding(key, "LocalVoiceChat") then
			self.recordBind    = "LocalVoiceChat"
			self.recordEndTime = nil
			ResetBarForClient(client)

			if team_only ~= false then
				team_only = false
				Client.SendNetworkMessage("LocalTalkExtended_teamonly", {on = false}, true)
			end
			Client.VoiceRecordStartEntity(player, Vector.origin)
		elseif GetIsBinding(key, "LocalVoiceChatTeam") then
			self.recordBind    = "LocalVoiceChatTeam"
			self.recordEndTime = nil
			ResetBarForClient(client)

			if team_only ~= true then
				team_only = true
				Client.SendNetworkMessage("LocalTalkExtended_teamonly", {on = true}, true)
			end
			Client.VoiceRecordStartEntity(player, Vector.origin)
		end
	elseif self.recordBind and GetIsBinding(key, self.recordBind) then
		self.recordBind = nil
		self.recordEndTime = Shared.GetTime() + Client.GetOptionFloat("recordingReleaseDelay", 0.15)
	end
end

local voice_teamonly = table.array(100)

Client.HookNetworkMessage("LocalTalkExtended_teamonly_notify", function(msg)
	voice_teamonly[msg.client] = msg.on
	ResetBarForClient(msg.client)
end)

function GUIVoiceChat:Update(delta_time)
	PROFILE("GUIVoiceChat:Update")

	local time = Shared.GetTime()

	if self.recordEndTime and self.recordEndTime < time then
		Client.VoiceRecordStop()
		self.recordEndTime = nil
	end

	local local_team   = Client.GetLocalPlayer():GetTeamNumber()
	local local_client = Client.GetLocalClientIndex()

	for i = 1, #chat_bars do
		local bar = chat_bars[i]
		local id = bar.player
		if id ~= Entity.invalidId then
			local pie = Shared.GetEntity(id)
			if pie then
				local channel = GetVoiceChannel(pie.clientId)
				if channel ~= pie.voice_channel then
					-- If the channel isn't the global one, i.e. if it's proximity,
					-- we also need the network message to tell us what kind of
					-- local voice chat it is, so we delay the bar here.
					if channel ~= VoiceChannel.Global then
						pie.voice_chat_bar_time = nil
					end
					ResetBarForPlayer(pie)
				end
			else
				bar.player = Entity.invalidId
				bar.background:SetIsVisible(false)
			end
		end
	end

	for _, pie in ientitylist(Shared.GetEntitiesWithClassname "PlayerInfoEntity") do
		local client  = pie.clientId
		local channel = GetVoiceChannel(client)

		-- Edge case bug:
		-- If there are not any bars left, a player not speaking
		-- will not have their voice_chat_bar_time set to nil
		--
		-- Reasoning for IsRelevant (local function defined above) call:
		-- Sadly Spark can not handle VoiceChannel.Entity when the entity referred to is not relevant
		-- to the client.
		-- This is understandable though, since the position is a part of the entity, so a fix
		-- would be an architectural change, something too grand for a small bug like this.
		if channel ~= VoiceChannel.Invalid and not pie.voice_chat_bar and IsRelevant(pie) then
			local create_bar = true
			if channel ~= VoiceChannel.Global and client ~= local_client then
				-- We need to do this because the team-only network message
				-- arrives after the voice transmission begins
				local bar_time = pie.voice_chat_bar_time
				if not bar_time then
					pie.voice_chat_bar_time = time + 0.15
					create_bar = false
				else
					create_bar = bar_time <= time
				end
			end
			if create_bar then
				local bar
				for i = 1, #chat_bars do
					if chat_bars[i].player == Entity.invalidId then
						bar = chat_bars[i]
						break
					end
				end
				-- All bars may be occupied
				if bar then
					local team = pie.teamNumber

					local color =
						channel ~= VoiceChannel.Global and (
							team == local_team and (
								client == local_client and team_only or voice_teamonly[client]
							) and kLocalVoiceTeamOnlyFontColor or kLocalVoiceFontColor
						) or
						pie.isCommander and GUIVoiceChat.kCommanderFontColor or
						team == 1 and GUIVoiceChat.kMarineFontColor or
						team == 2 and GUIVoiceChat.kAlienFontColor or
						GUIVoiceChat.kSpectatorFontColor

					bar.name:SetText(pie.playerName)
					bar.name:SetColor(color)

					bar.icon:SetColor(color)

					bar.background:SetTexture(team == 2 and kBackgroundTextureAlien or kBackgroundTextureMarine)
					bar.background:SetColor(team ~= 1 and team ~= 2 and Color(1, 200/255, 150/255, 1) or Color(1, 1, 1, 1))
					bar.background:SetIsVisible(self.visible)

					pie.voice_chat_bar = bar
					bar.player = pie:GetId()

					pie.voice_channel = channel
				end
			end
		end
	end
end
