assert(CHUDOptions.mingui)
CHUDOptions.localvoicechat_color = {
	category     = "hud",
	name         = "LocalTalkExtended_color",
	label        = "Color of proximity chat",
	tooltip      = "This controls the color of the name you see when someone speaks using non-team-only proximity chat",
	defaultValue = 0x80FF80,
	valueType    = "color",
	applyOnLoadComplete = true,
	applyFunction = function()
		kLocalVoiceFontColor = ColorIntToColor(CHUDGetOption("localvoicechat_color"))
	end,
}

CHUDOptions.localvoicechat_color_team = {
	category     = "hud",
	name         = "LocalTalkExtended_color_team",
	label        = "Color of team-only proximity chat",
	tooltip      = "This controls the color of the name you see when someone speaks using team-only proximity chat",
	defaultValue = 0xC028C0,
	valueType    = "color",
	applyOnLoadComplete = true,
	applyFunction = function()
		kLocalVoiceTeamOnlyFontColor = ColorIntToColor(CHUDGetOption("localvoicechat_color_team"))
	end,
}
