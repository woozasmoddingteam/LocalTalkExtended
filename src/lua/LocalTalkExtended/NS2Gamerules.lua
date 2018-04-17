if Server then
	local voice_teamonly = setmetatable({}, {
		__mode = "kv"
	})

	Server.HookNetworkMessage("LocalTalkExtended_teamonly", function(client, msg)
		Log("%s: %s", client, msg.on)
		voice_teamonly[client] = msg.on
	end)

	local kMaxWorldSoundDistance

	local old = NS2Gamerules.GetCanPlayerHearPlayer
	debug.replacemethod("NS2Gamerules", "GetCanPlayerHearPlayer",
	function(self, listener, speaker, channel)
		return old(self, listener, speaker, channel) or
			channel ~= VoiceChannel.Global and
			(Log("team_only: %s", voice_teamonly[speaker:GetClient()]) or true) and
			not voice_teamonly[speaker:GetClient()] and
			listener:GetDistanceSquaredToEntity(speaker) < kMaxWorldSoundDistance^2
	end)
end
