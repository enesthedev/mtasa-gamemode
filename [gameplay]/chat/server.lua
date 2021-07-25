addEventHandler('onPlayerChat', root, function(message, messageType)
    if not getElementData(source, 'player.logged') then
      return cancelEvent()
    end

    while (message ~= string.gsub(message, '#%x%x%x%x%x%x', '')) do
      message = string.gsub(message, '#%x%x%x%x%x%x', '')
    end

    outputChatBox(getPlayerName(source) .. ( messageType == 1 and ': (aksiyon mesajı) ' or ': ' ) .. message, root, 255, 255, 255, true)
    cancelEvent()
  end
)