local translates = {
  month = {
    [1] = 'Oca',
    [2] = 'Şub',
    [3] = 'Mar',
    [4] = 'Nis',
    [5] = 'May',
    [6] = 'Haz',
    [7] = 'Tem',
    [8] = 'Ağu',
    [9] = 'Eyl',
    [10] = 'Eki',
    [11] = 'Kas',
    [12] = 'Ara'
  }
}

local isChatboxVisible = getElementData(localPlayer, 'player.chatbox') or false

addEventHandler('onClientResourceStart', resourceRoot, function(startedResource)
    if not startedResource == resource then
      return false
    end
  end
)

addEventHandler('onClientPreRender', root, function()
    return showChat(isChatboxVisible)
  end
)

addEventHandler('onClientElementDataChange', localPlayer, function(theKey, _, newValue)
    if theKey == 'player.chatbox' then
      isChatboxVisible = newValue
    end
  end
)

addEventHandler('onClientChatMessage', root, function(message)
  if not getElementData(localPlayer, 'player.logged') then
    return cancelEvent()
  end

  local messageLength = string.len(message)
  local checkSub = string.sub(message, 0, 1)

  if checkSub ~= '(' then

    local messageSplitter = string.find(message, ':')
    if not messageSplitter then
      return
    end

    local chatMessage = string.sub(message, messageSplitter + 1, messageLength)
    local username = string.sub(message, 0, string.find(message, ':'))

    if not username or username == 'login:' or username == 'register:' then
      return cancelEvent()
    end

    outputChatBox(os.date('(%d ' .. translates.month[tonumber(os.date('%m'))] .. ' %H:%M)') .. ' #ffffff' .. username .. '#EBDDB2' .. chatMessage, 200, 200, 200, true)
    cancelEvent()
  end
end)