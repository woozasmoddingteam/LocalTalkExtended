local defaults = debug.getupvaluex(GetDefaultInputValue, "defaults")
table.insert(defaults, {"LocalVoiceChat", "None"})
table.insert(defaults, {"LocalVoiceChatTeam", "None"})

local bindings = debug.getupvaluex(BindingsUI_GetBindingsData, "globalControlBindings")
for _, v in ipairs {
	"LocalVoiceChat",     "input", "Proximity Communication (can be heard by enemy)",     "None",
	"LocalVoiceChatTeam", "input", "Proximity Communication (can be heard by team only)", "None",
} do
	table.insert(bindings, v)
end
