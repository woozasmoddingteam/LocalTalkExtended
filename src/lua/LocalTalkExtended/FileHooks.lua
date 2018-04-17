for _, v in ipairs {
	"GUIVoiceChat",
	"InputHandler",
	"BindingsDialog",
	"NS2Gamerules",
	"NetworkMessages",
} do
	ModLoader.SetupFileHook("lua/"..v..".lua", "lua/LocalTalkExtended/"..v..".lua", "post")
end
