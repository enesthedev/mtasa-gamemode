local screenWidth, screenHeight = guiGetScreenSize()
local scale = math.max((screenHeight / 1080), 0.65)

local defaultFont = 'bankgothic'
local defaultTextScale = scale * 0.8

local offsetY = scale * 50
local textWidth = scale * 200
local textHeight = scale * 20

local hudComponents = { "weapon", "ammo", "health", "clock", "money", "breath", "armour", "wanted", "radar" }

local hudStyle = 1;

function string.moneyFormating( money, separator )
	local formatted = tostring( money )
	local formatType = '%1' .. ( separator or ' ' ).. '%2'
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", formatType)
		if (k==0) then
			break
		end
	end
	return formatted
end

function string.removeHex(s)
  if type (s) == "string" then
      while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
          s = s:gsub ("#%x%x%x%x%x%x", "")
      end
  end
  return s or false
end

function dxDrawBorderedText(text, left, top, right, bottom, color, fscale, font, alignX, alignY, clip, wordBreak, postGUI, outline)
	for oX = (outline * -1), outline do
			for oY = (outline * -1), outline do
					dxDrawText(string.removeHex(text), left + oX, top + oY, right + oX, bottom + oY, 0xFF000000, fscale, font, alignX, alignY, clip, wordBreak, postGUI)
			end
	end
	dxDrawText(text, left, top, right, bottom, color, fscale, font, alignX, alignY, clip, wordBreak, postGUI, true)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    if not hudComponents then
      return false
    end

    for i = 1, table.maxn(hudComponents) do
      setPlayerHudComponentVisible(hudComponents[i], false)
    end
  end
)