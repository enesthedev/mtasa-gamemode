local players = {}

setmetatable(players, {
    __newindex = function(t, k, v)
      setElementData(v, 'player.id', k)
      rawset(t, k, v)
    end
  }
)

addEventHandler('onResourceStart', resourceRoot, function(startedResource)
    if not startedResource == resource then
      return false
    end
    for theIndex, thePlayer in ipairs(getElementsByType'player') do
      players[theIndex] = thePlayer
    end
  end
)

addEventHandler('onPlayerQuit', root, function()
    local playerID = getElementData(source, 'player.id')
    if not playerID or not players[playerID] then
      return false
    end

    players[playerID] = nil
  end
)

addEventHandler('onPlayerJoin', root, function()
    local iID = 0
    for i in ipairs(players) do
      iID = i
    end

    iID = iID + 1
    players[iID] = source
  end
)