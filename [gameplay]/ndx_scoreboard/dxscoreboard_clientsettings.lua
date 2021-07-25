defaultSettings = {
	["useanimation"] = false,
	["toggleable"] = false,
	["showserverinfo"] = false,
	["showgamemodeinfo"] = false,
	["showteams"] = false,
	["usecolors"] = true,
	["drawspeed"] = 1,
	["scale"] = 1,
	["contentfont"] = "default-bold",
	["teamfont"] = "clear",
	["serverinfofont"] = "default",
	["bg_color"] = {
		["r"] = 0,
		["g"] = 0,
		["b"] = 0,
		["a"] = 190
	},
	["selection_color"] = {
		["r"] = 238,
		["g"] = 206,
		["b"] = 89,
		["a"] = 170
	},
	["highlight_color"] = {
		["r"] = 255,
		["g"] = 255,
		["b"] = 255,
		["a"] = 50
	},
	["header_color"] = {
		["r"] = 150,
		["g"] = 150,
		["b"] = 150,
		["a"] = 255
	},
	["team_color"] = {
		["r"] = 100,
		["g"] = 100,
		["b"] = 100,
		["a"] = 100
	},
	["border_color"] = {
		["r"] = 100,
		["g"] = 100,
		["b"] = 100,
		["a"] = 50
	},
	["serverinfo_color"] = {
		["r"] = 150,
		["g"] = 150,
		["b"] = 150,
		["a"] = 255
	},
	["content_color"] = {
		["r"] = 255,
		["g"] = 255,
		["b"] = 255,
		["a"] = 255
	}
}

tempColors = {
	["bg_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["selection_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["highlight_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["header_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["team_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["border_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["serverinfo_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	},
	["content_color"] = {
		["r"] = nil,
		["g"] = nil,
		["b"] = nil,
		["a"] = nil
	}
}
MAX_DRAWSPEED = 4.0
MIN_DRAWSPEED = 0.5
MAX_SCALE = 2.5
MIN_SCALE = 0.5
fontIndexes = {
	["column"] = 1,
	["content"] = 1,
	["team"] = 1,
	["serverinfo"] = 1
}
fontNames = { "default", "default-bold", "clear", "arial", "sans","pricedown", "bankgothic", "diploma", "beckett" }

function validateRange( number )
	if type( number ) == "number" then
		local isValid = number >= 0 and number <= 255
		if isValid then
			return number
		end
	end
	return false
end
