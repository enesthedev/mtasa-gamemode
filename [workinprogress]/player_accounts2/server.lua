function isPlayerLoggedIn()
  if not client then
    return false
  end

  local theAccount = getPlayerAccount(client)
  if not theAccount then
    return false
  end

  return not isGuestAccount(theAccount)
end

function loginPlayer(theUsername, thePassword)
  if not client then
    return false
  end

  local playerAccount = getPlayerAccount(client)
  if isGuestAccount(playerAccount) then

    local theAccount = getAccount(theUsername)
    if theAccount then
      return logIn(client, theAccount, thePassword)
    else

      theAccount = addAccount(theUsername, thePassword)
      if theAccount then
        return logIn(client, theAccount, thePassword)
      end
    end
  end
  return 1
end

function spawnPlayerAt(playerX, playerY)
  if not client then
    return false
  end

  return spawnPlayer(client, playerX, playerY, exports.positions:getGroundPosition(playerX, playerY) + 0.5)
end