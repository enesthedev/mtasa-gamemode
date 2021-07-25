local timeoutPlayers = {}

function removePlayerTimeout(timeoutPlayer, timeoutTag)
  local timeoutTimer, _, _ = isPlayerInTimeout(timeoutPlayer, timeoutTag)
  if timeoutTimer then
    killTimer(timeoutTimer)
  end

  timeoutPlayers[timeoutTag][timeoutPlayer] = nil
end

function isPlayerInTimeout(timeoutPlayer, timeoutTag)
  return timeoutPlayers[timeoutTag] and timeoutPlayers[timeoutTag][timeoutPlayer] and timeoutPlayers[timeoutTag][timeoutPlayer], timeoutPlayer, timeoutTag
end

function addPlayerTimeout(timeoutPlayer, timeoutTag, timeoutInterval)
  if not timeoutPlayers[timeoutTag] then
    timeoutPlayers[timeoutTag] = {}
  end

  local timeoutElement, _, _ = isPlayerInTimeout(timeoutPlayer, timeoutTag)
  if timeoutElement and isTimer(timeoutElement) then
    local timerDetails = getTimerDetails(timeoutElement)
    if timerDetails then
      killTimer(timeoutElement)
      timeoutPlayers[timeoutTag][timeoutPlayer] = setTimer(removePlayerTimeout, timerDetails + timeoutInterval, 1, timeoutPlayer, timeoutTag)
    end
  else
    timeoutPlayers[timeoutTag][timeoutPlayer] = setTimer(removePlayerTimeout, timeoutInterval, 1, timeoutPlayer, timeoutTag)
  end
end