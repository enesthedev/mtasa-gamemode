local screenWidth, screenHeight = guiGetScreenSize()
local scale = math.max((screenHeight / 1080), 0.74)

local defaultFont = dxCreateFont(":dx_fonts/regular2.ttf", scale * 9.3, false)

local playerLogged = getElementData(localPlayer, 'player.logged') or false

local textWidth = scale * 250
local textHeight = scale * 30

local barHeight = scale * 20

local offsetX = scale * 25
local offsetY = scale * 16

local clientFPS = 70
local clientPing = 30

local nextTick = getTickCount()
local updateInterval = 1000

addEventHandler('onClientElementDataChange', localPlayer, function(theKey, _, newValue)
    if theKey == 'player.logged' then
      playerLogged = newValue
    end
  end
)

addEventHandler('onClientPreRender', root, function()
    if getTickCount() - nextTick > updateInterval then
      clientPing = getPlayerPing(localPlayer)
      clientFPS = exports.player_fps:getClientFPS()

      nextTick = getTickCount()
    end
  end
)

addEventHandler('onClientRender', root, function()
    if not playerLogged or isMainMenuActive() or isDebugViewActive() then
      return false
    end

    dxDrawRectangle(0, screenHeight - barHeight, screenWidth, barHeight, 0xFF000000, true)
    dxDrawText('FPS: ' .. clientFPS .. '  -  Gecikme: ' .. clientPing .. "  -  Yardım için 'F1' tuşuna basın  -  Sahip olduğunuz evler için 'F3' tuşuna basın  -  Para kazanmak için /meslekler komutunu girin  -  Sahip olduğunuz araçlar için 'F4' tuşuna basın", screenWidth - offsetX - textWidth, screenHeight - offsetY, textWidth + offsetX, textHeight, 0xFFFFFFFF, 1, defaultFont, 'center', 'top', false, false, true)
  end
)