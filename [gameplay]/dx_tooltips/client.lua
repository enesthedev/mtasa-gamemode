local sw, sh = guiGetScreenSize()
local sc = math.max((sh / 1080), 0.65)
local tooltips = {}
local color = { 255, 255, 255 }
local background = { 255, 255, 255 }
local font = { face = dxCreateFont(string.format(':dx_fonts/%s.ttf', 'ahronbd'), sc * 8, true, 'cleartype'), size = 1 * sc, maxwidth = 300 * sc }

function tooltipShow()
  if getElementData(source, "tooltip-text") and getElementType(source):find("gui-", 1, true) then
    local x,y = guiGetPosition(source, false)
    local parent = getElementParent(source)
    while getElementType(parent) ~= "guiroot" do
      if getElementData(source, "tooltip-text") == getElementData(parent, "tooltip-text") then return false end
      local px, py = guiGetPosition(parent, false)
      x, y = x + px, y + py
      if getElementType(parent) == "gui-tab" then y = y + 24 end
      parent = getElementParent(parent)
    end
    local w,h = guiGetSize(source, false)
    x = x + w/2
    tooltips[source] = {}
    local fonts = getElementData(source, "tooltip-font")
    if fonts then
      tooltips[source].font = gettok(fonts, 1, " ") or font.face
      tooltips[source].fontsize = tonumber(gettok(fonts, 2, " ")) or font.size
    else
      tooltips[source].font = font.face
      tooltips[source].fontsize = font.size
    end
    tooltips[source].text = getElementData(source, "tooltip-text")
    tooltips[source].w = math.ceil(dxGetTextWidth(tooltips[source].text, tooltips[source].fontsize, tooltips[source].font))
    tooltips[source].h = math.ceil(dxGetFontHeight(tooltips[source].fontsize, tooltips[source].font))
    if tooltips[source].w > font.maxwidth then
      tooltips[source].h = tooltips[source].h*math.ceil(tooltips[source].w/font.maxwidth)
      tooltips[source].w = font.maxwidth
    end
    tooltips[source].arrow = x
    tooltips[source].x = math.floor(math.min(math.max(x - tooltips[source].w/2, 16), sw - tooltips[source].w-16))
    tooltips[source].y = math.floor(y - tooltips[source].h - 12)
    if tooltips[source].y < 16 * sc then
      tooltips[source].y = math.floor(y + h + 12 * sc)
      tooltips[source].bottom = true
    end
    tooltips[source].ticks = 1
    tooltips[source].step = 1
    -- color
    tooltips[source].br, tooltips[source].bg, tooltips[source].bb = unpack(background)
    local tcolor = getElementData(source, "tooltip-color")
    local bcolor = getElementData(source, "tooltip-background")
    if tcolor then
      tooltips[source].r, tooltips[source].g, tooltips[source].b = getColorFromString(tcolor)
    else
      tooltips[source].r, tooltips[source].g, tooltips[source].b = unpack(color)
    end
    if bcolor then
      tooltips[source].br, tooltips[source].bg, tooltips[source].bb = getColorFromString(bcolor)
    else
      tooltips[source].br, tooltips[source].bg, tooltips[source].bb = unpack(background)
    end
  end
end
addEventHandler("onClientMouseEnter", root, tooltipShow)

function tooltipHide(element)
  local e = isElement(element) and element or source
  if tooltips[e] then
    tooltips[e].ticks = 10
    tooltips[e].step = -1
  end
end
addEventHandler("onClientMouseLeave", root, tooltipHide)
addEventHandler("onClientGUIClick", root, tooltipHide)

local function dxDrawBorderedText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, outline)
	for oX = (outline * -1), outline do
			for oY = (outline * -1), outline do
					dxDrawText(text, left + oX, top + oY, right + oX, bottom + oY, tocolor(0, 0, 0, bitExtract(color, 24, 8) * 100 / 255), scale, font, alignX, alignY, clip, wordBreak, postGUI)
			end
	end
	dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, false)
end

function tooltipRender()
  if isMainMenuActive() or isMTAWindowActive() or isConsoleActive() or isChatBoxInputActive() then
    return false
  end
  for element, tooltip in pairs(tooltips) do
    if tooltip.ticks < 0 or not isElement(element) then
      tooltips[element] = nil
    else
      dxDrawBorderedText(tooltip.text, tooltip.x, tooltip.y, tooltip.x+tooltip.w, tooltip.y+tooltip.h, tocolor(tooltip.r,tooltip.g,tooltip.b, math.min(tooltip.ticks*25, 255)), tooltip.fontsize, tooltip.font, "left", "top", false, true, true, false, sc * 2)
      if tooltip.ticks < 255 then tooltip.ticks = tooltip.ticks + tooltip.step end
      if not guiGetVisible(element) then
        tooltips[element] = nil
      end
    end
  end
end
addEventHandler("onClientRender", root, tooltipRender)