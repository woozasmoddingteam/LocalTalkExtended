if Server then
	local voice_teamonly = setmetatable({}, {
		__mode = "kv"
	})

	Server.HookNetworkMessage("LocalTalkExtended_teamonly", function(client, msg)
		voice_teamonly[client] = msg.on
	end)

	local kMaxWorldSoundDistance = debug.getupvaluex(
		NS2Gamerules.GetCanPlayerHearPlayer, "kMaxWorldSoundDistance")

	-- Fuck you shine
	-- You're the reason I have to do this
	-- Why can't you just be a normal fucking
	-- mod?
	local old = Event.Hook
	function Event.Hook(hook, func, ...)
		if hook == "CanPlayerHearPlayer" then
			return old(hook, function(listener, speaker, channel)
				return GetGamerules():GetCanPlayerHearPlayer(listener, speaker, channelType) or
					channel ~= VoiceChannel.Global and
					voice_teamonly[speaker:GetClient()] == false and
					listener:GetDistanceSquaredToEntity(speaker) < kMaxWorldSoundDistance^2
			end, ...)
		else
			return old(hook, func, ...)
		end
	end
end
