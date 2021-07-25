local protectedPlayers = {}
local protectInterval = 3000
local protectAlpha = 155

addEventHandler('onClientPlayerSpawn', root, function()
    if not protectedPlayers[source] then
      protectedPlayers[source] = { getTickCount(), source }
    end
  end
)

addEventHandler('onClientPlayerDamage', root, function()
    if protectedPlayers[source] then
      cancelEvent()
    end
  end
)

addEventHandler('onClientPreRender', root, function()
    for thePlayer, protectionData in pairs(protectedPlayers) do
      if getTickCount() - protectionData[1] > protectInterval then
        protectedPlayers[thePlayer] = nil
      end
    end
  end
)