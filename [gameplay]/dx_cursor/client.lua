local screenWidth, screenHeight = guiGetScreenSize()
local scale = math.max((screenHeight / 1080), 0.65)
local cursorWH = scale * 24
local cursorTexture = dxCreateTexture(':media/cursor.png', 'argb', true, 'clamp')

setCursorAlpha(0)

addEventHandler('onClientRender', root, function()
    if isCursorShowing() or guiGetInputEnabled() then
      local cursorX, cursorY = getCursorPosition()
      dxDrawImage(cursorX * screenWidth, cursorY * screenHeight, cursorWH, cursorWH, cursorTexture, 0, 0, 0, 0xFFFFFFFF, true)
    end
  end
)

bindKey('m', 'down', function()
    if getElementData(localPlayer, 'player.logged') then
      showCursor(not isCursorShowing())
    end
  end
)