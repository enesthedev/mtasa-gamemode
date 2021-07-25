local paydayPlayers = {}

addEventHandler('onResourceStart', resourceRoot, function()
    local players = getElementsByType'player'
    for i = 1, table.maxn(players) do
      local playerSource = players[i]
      if playerSource and not paydayPlayers[playerSource] and getElementData(playerSource, 'player.logged') and triggerLatentClientEvent(playerSource, 'onClientPayday', 5000, false, playerSource) then
        paydayPlayers[playerSource] = setTimer(triggerLatentClientEvent, 60000 * 24, 0, playerSource, 'onClientPayday', 5000, false, playerSource)
      end
    end
  end
)

addEventHandler('onPlayerLogin', root, function(thePreviousAccount)
    if not paydayPlayers[source] and triggerLatentClientEvent(source, 'onClientPayday', 5000, false, source) then
      paydayPlayers[source] = setTimer(triggerLatentClientEvent, 60000 * 24, 0, source, 'onClientPayday', 5000, false, source)
    end
    return outputChatBox("Saatlik kazançlar: Sunucuda bulunduğun her saat belli miktarlarda ödüller, skor ve para kazanırsın.", source, 0, 255, 255)
  end
)

addEventHandler('onPlayerQuit', root, function()
    if paydayPlayers[source] then
      if isTimer(paydayPlayers[source]) then
        killTimer(paydayPlayers[source])
      end

      paydayPlayers[source] = nil
    end
  end
)