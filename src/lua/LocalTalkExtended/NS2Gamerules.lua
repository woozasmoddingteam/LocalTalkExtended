if not Server then return end

local voice_teamonly = table.array(100)
local voice_teamonly_for_client = setmetatable({}, {__mode = "kv"})

Server.HookNetworkMessage("LocalTalkExtended_teamonly", function(client, msg)
	voice_teamonly[client:GetId()] = msg.on
end)

local kMaxWorldSoundDistanceSquared = debug.getupvaluex(
	NS2Gamerules.GetCanPlayerHearPlayer, "kMaxWorldSoundDistance")^2

if not Shine then
	local old = NS2Gamerules.GetCanPlayerHearPlayer
	debug.replacemethod("NS2Gamerules", "GetCanPlayerHearPlayer",
	function(self, listener, speaker, channel)
		return old(self, listener, speaker, channel) or
			channel ~= VoiceChannel.Global and
			voice_teamonly[speaker:GetClientIndex()] == false and
			listener:GetDistanceSquared(speaker) < kMaxWorldSoundDistanceSquared
	end)
end

-- Fuck you shine
-- You're the reason I have to do this
-- Why can't you just be a normal fucking
-- mod?
local old = Script.Load
function Script.Load(path, reload)
	old(path, reload)
	if path == "lua/shine/extensions/basecommands/server.lua" then
		assert(Plugin and Plugin.CanPlayerHearPlayer)
		local old = Plugin.CanPlayerHearPlayer
		local GetOwner
		local DisableLocalAllTalkClients
		local IsPregameAllTalk
		local IsSpectatorAllTalk
		function Plugin:CanPlayerHearPlayer(gamerules, listener, speaker, channel)
			local speaker_client = GetOwner(speaker)
			if not speaker_client then return end

			local listener_client = GetOwner(listener)
			if not listener_client then return end

			if
				self:IsClientGagged(speaker_client) or
				listener:GetClientMuted(speaker_client:GetId())
			then return false end

			if channel and channel ~= VoiceChannel.Global then
				-- Also avoids sending teamonly_notify network message!
				if listener == speaker then return true end

				local speaker_team  = speaker:GetTeamNumber()
				local listener_team = listener:GetTeamNumber()

				local team_only = voice_teamonly[speaker_client:GetId()]

				local hearable =
					not DisableLocalAllTalkClients[listener_client] and
					not DisableLocalAllTalkClients[speaker_client] and
					(
						team_only == false or
						speaker_team == listener_team
					) and listener:GetDistanceSquared(speaker) < kMaxWorldSoundDistanceSquared

				-- Need to update client's teamonly table
				if hearable and speaker_team == listener_team then
					voice_teamonly_for_client[listener_client] = voice_teamonly_for_client[listener_client] or {}
					if voice_teamonly_for_client[listener_client][speaker_client] ~= team_only then
						Server.SendNetworkMessage(
							listener_client,
							"LocalTalkExtended_teamonly_notify",
							{client = speaker_client:GetId(), on = team_only},
							true
						)
						voice_teamonly_for_client[listener_client][speaker_client] = team_only
					end
				end

				return hearable
			elseif
				self.Config.AllTalk or
				IsPregameAllTalk(self, gamerules) or
				IsSpectatorAllTalk(self, listener)
			then
				return true
			end
		end
		debug.joinupvalues(Plugin.CanPlayerHearPlayer, old)
	end
end
