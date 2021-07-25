local screenWidth, screenHeight = guiGetScreenSize()
local screenScale = math.max(screenHeight / 1080, 0.64)

local show = 15

local font11 = dxCreateFont(':dx_fonts/compass.otf', screenScale * 11, false, 'antialiased')
local font10 = dxCreateFont(':dx_fonts/compass.otf', screenScale * 10, false, 'antialiased')

local offset = screenScale * 30
local slotwidth = 40

local cords = {
  { 0, 'N' }, { 15, 15 }, { 30, 30 }, { 45, 'NE' }, { 60, 60 }, { 75, 75 },
  { 90, 'E' }, { 105, 105 }, { 120, 120 }, { 135, 'SE' }, { 150, 150 }, { 165, 165 },
  { 170, 'S' }, { 195, 195 }, { 210, 210 }, { 225, 'SW' }, { 240, 240 }, { 255, 255 },
  { 270, 'W' }, { 285, 285 }, { 300, 300 }, { 315, 'NW' }, { 330, 330 }, { 345, 345 }
}

local cordn = table.maxn(cords)

local ceil = math.ceil
local floor = math.floor
local abs = math.abs

local camera = getCamera()

local rendering = false

function setCompassState(state)
  if state and not rendering then
    addEventHandler('onClientRender', root,  render, true)
  elseif rendering then
    removeEventHandler('onClientRender', root, render)
  end
end

function render()
  local center = ceil(show / 2) - 1
  local _, _, r = getElementRotation(camera)
  local pos = floor(r / 15)
  local smooth = ((r - (pos * 15)) / 15) * slotwidth
  local left = screenWidth / 2 - ((show + 2) * slotwidth)/2

  for i=1, show do
    local id = i + pos - center
    if(id > cordn)then
      id = id - cordn
    end
    if(id <= 0)then
      id = cordn - abs(id)
    end
    if(cords[id])then
      local alpha = (tonumber(cords[id][2]) or 0 > 0) and 175 or 255
      if(i < center)then
        alpha = alpha * (i/center)
      end
      if(i > center)then
        alpha = alpha * ((show-i)/center)
      end
      dxDrawRectangle(left + slotwidth * i - smooth + (slotwidth / 2 - 1) + 1, offset + 10 + 1, 2, 10, tocolor(0, 0, 0, alpha * 0.5))
      dxDrawRectangle(left + slotwidth * i - smooth + (slotwidth / 2 - 1), offset + 10, 2, 10, tocolor(255, 255, 255, alpha))
      dxDrawText(cords[id][2], left + slotwidth * i - smooth + 1, offset + 20, left + slotwidth * (i+1) - smooth + 2, offset + 40, tocolor(0, 0, 0, alpha * 0.5), 1, font10, "center", "center")
      dxDrawText(cords[id][2], left + slotwidth * i - smooth, offset + 20, left + slotwidth * (i+1) - smooth, offset + 40, tocolor(255, 255, 255, alpha), 1, font10, "center", "center")
    end
  end

  dxDrawText("➤", left + 4, offset + 26 + 2, left + ((show + 3) * slotwidth) + 30, 0, tocolor(0, 0, 0, 160), 1, font11, "center", "top", false, false, false, false, false, 90)
  dxDrawText("➤", left, offset + 26, left + ((show + 3) * slotwidth) + 30, 0, tocolor(255, 255, 255, 255), 1, font11, "center", "top", false, false, false, false, false, 90)

  rendering = true
end

addEventHandler('onClientElementDataChange', localPlayer, function(theKey, _, newValue)
    if theKey == 'player.logged' then
      setCompassState(newValue)
    end
  end
)

addEventHandler('onClientResourceStart', resourceRoot, function()
      setCompassState(getElementData(localPlayer, 'player.logged'))
  end
)