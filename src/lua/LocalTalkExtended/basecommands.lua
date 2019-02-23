local GetOwner = Server.GetOwner

local voice_teamonly = table.array(100)

Server.HookNetworkMessage("LocalTalkExtended_teamonly", function(client, msg)
	voice_teamonly[client:GetId()] = msg.on
end)

local old = Plugin.CanPlayerHearLocalVoice
function Plugin:CanPlayerHearLocalVoice(gamerules, listener, speaker, speaker_client)
	-- Also avoids sending teamonly_notify network message!
	if listener == speaker then return true end

	local listener_client = GetOwner(listener)

	if
		self:IsLocalAllTalkDisabled(listener_client)
		or self:IsLocalAllTalkDisabled(speaker_client)
		or not self:ArePlayersInLocalVoiceRange(speaker, listener)
	then
		return
	end

	local speaker_team  = speaker:GetTeamNumber()
	local listener_team = listener:GetTeamNumber()

	local team_only = voice_teamonly[speaker_client:GetId()] or false

	if self:IsSpectatorAllTalk(listener) or speaker_team == listener_team then
		-- Notify the listener of the team-only state
		Server.SendNetworkMessage(
			listener_client,
			"LocalTalkExtended_teamonly_notify",
			{client = speaker_client:GetId(), on = team_only},
			true
		)
		return true
	elseif not team_only then
		return true
	end
end
