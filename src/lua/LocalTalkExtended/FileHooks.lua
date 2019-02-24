for _, v in ipairs {
	"InputHandler",
	"BindingsDialog",
	"NetworkMessages",
} do
	ModLoader.SetupFileHook("lua/"..v..".lua", "lua/LocalTalkExtended/"..v..".lua", "post")
end

ModLoader.SetupFileHook("lua/GUIVoiceChat.lua", "lua/LocalTalkExtended/GUIVoiceChat.lua", "replace")
ModLoader.SetupFileHook("lua/NS2Plus/Client/CHUD_Options.lua", "lua/LocalTalkExtended/CHUD_Options.lua", "post")
