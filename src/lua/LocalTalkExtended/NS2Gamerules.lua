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

local function GetActualOrigin(ent)
	local followed = ent:isa "Spectator" and Shared.GetEntity(ent:GetFollowingPlayerId())
	if followed then
		return followed:GetOrigin()
	else
		return ent:GetOrigin()
	end
end
