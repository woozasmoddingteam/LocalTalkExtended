for _, v in ipairs {
	"GUIVoiceChat",
	"InputHandler",
	"BindingsDialog",
	"NS2Gamerules",
	"NetworkMessages",
} do
	ModLoader.SetupFileHook("lua/"..v..".lua", "lua/LocalTalkExtended/"..v..".lua", "post")
end

ModLoader.SetupFileHook("lua/NS2Plus/Client/CHUD_Options.lua", "lua/LocalTalkExtended/CHUD_Options.lua", "post")
