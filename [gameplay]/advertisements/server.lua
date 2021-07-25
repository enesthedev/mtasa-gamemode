addCommandHandler('reklam', function(thePlayer, _, ...)
    if getElementData(thePlayer, 'player.logged') then
      if not exports.timeouts:isPlayerInTimeout(thePlayer, 'ads') and (getPlayerMoney(thePlayer) - 50000) > 50000 then
        outputChatBox('#ee293a[REKLAM] ' .. getPlayerName(thePlayer) .. ': #94cdff' .. table.concat({...}, ' '), root, 255, 255, 255, true)
        outputChatBox('Uyarı: /reklam komutunu her 1 dakikada 1 kez kullanabilirsin, 1 den fazla kez kullanımın için cezalandırılırsın!', thePlayer)

        takePlayerMoney(thePlayer, 50000)

        exports.timeouts:addPlayerTimeout(thePlayer, 'ads', 6 * 10000)
      end
    end
  end
)