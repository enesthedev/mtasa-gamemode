local createdBlips = {}

function createBlips(playerElements)
  for i = 1, table.maxn(playerElements) do
    local thePlayer = playerElements[i]
    if thePlayer and thePlayer ~= localPlayer and not createdBlips[thePlayer] then
      createdBlips[thePlayer] = createBlipAttachedTo(thePlayer, 0, 1.2, 255, 255, 0, 255, 0, 500.0, localPlayer)
    end
  end
end

addEventHandler('onClientResourceStart', resourceRoot, function(startedResource)
    if startedResource == resource then
      createBlips(getElementsByType('player'))
    end
  end
)

addEventHandler('onClientPlayerJoin', root, function()
    createBlips({ source })
  end
)