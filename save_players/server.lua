local defaultValues = {
  level = 1,
  gc = 15,
  score = 100,
  skin = 1,
  money = 50000
}

local dbKeys = {
  '%s.level', '%s.gc', '%s.score', '%s.skin'
}

local cache = exports.account_cache

addEventHandler('onPlayerLogin', root, function(thePreviousAccount, theCurrentAccount)
    if getElementData(source, 'player.logged') then
      return false
    end

    setElementData(source, 'player.logged', true)

    setElementData(source, 'player.level', cache:get(theCurrentAccount, 'db.level', defaultValues.level))
    setElementData(source, 'player.gc',    cache:get(theCurrentAccount, 'db.gc',  defaultValues.gc))
    setElementData(source, 'player.score', cache:get(theCurrentAccount, 'db.score', defaultValues.score))
    setElementData(source, 'player.skin',  cache:get(theCurrentAccount, 'db.skin', defaultValues.skin))

    setElementData(source, 'player.account', theCurrentAccount, false)

    setPlayerBlurLevel(source, 0)
    setPlayerNametagShowing(source, false)

    setPlayerMoney(source, cache:get(theCurrentAccount, 'db.money', defaultValues.money))
  end
)

addEventHandler('onPlayerQuit', root, function()
    local theAccount = getElementData(source, 'player.account')
    if not (getElementData(source, 'player.logged')) or not theAccount then
      return false
    end

    cache:set(theAccount, 'db.money', getPlayerMoney(source))

    for i = 1, table.maxn(dbKeys) do
      local dbKey = dbKeys[i]
      if dbKey then
        cache:set(theAccount, string.format(dbKey, 'db'), getElementData(source, string.format(dbKey, 'player')))
      end
    end
  end
)

addEventHandler('onResourceStop', root, function()
    for _, playerSource in ipairs(getElementsByType'player') do
      local theAccount = getElementData(playerSource, 'player.account')
      if not (getElementData(playerSource, 'player.logged')) or not theAccount then
        return false
      end

      cache:set(theAccount, 'db.money', getPlayerMoney(playerSource))

      for i = 1, table.maxn(dbKeys) do
        local dbKey = dbKeys[i]
        if dbKey then
          cache:set(theAccount, string.format(dbKey, 'db'), getElementData(playerSource, string.format(dbKey, 'player')))
        end
      end
    end
  end
)