local downgradeState = false

local currentSecondFPS = {}
local lastFiveSecondsFPS = {}

local lastSecondTicks = getTickCount()

function getAverageFPSOfFPSArray(table)
  local totalFPS = 0
  for _, fps in pairs(table) do
    totalFPS = totalFPS + fps
  end
  return totalFPS / #table
end

function isPlayerDowngraded()
  return downgradeState
end

function setPlayerDowngraded(state)
  downgradeState = state
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    local frameResource = getResourceFromName('player_fps')
    if getResourceState(frameResource) == 'running' then
      addEventHandler('onClientHUDRender', root, function()
          table.insert(currentSecondFPS, exports.player_fps:getClientFPS())

          if getTickCount() - lastSecondTicks >= 1000 then
            local averageFPSPerSecond = getAverageFPSOfFPSArray(currentSecondFPS)

            currentSecondFPS = {}
            lastSecondTicks = getTickCount()

            table.insert(lastFiveSecondsFPS, averageFPSPerSecond)

            if table.maxn(lastFiveSecondsFPS) == 6 then
              table.remove(lastFiveSecondsFPS, 1)
            end

            if averageFPSPerSecond < 40 and not isPlayerDowngraded() then
              triggerEvent('onClientFPSLow', localPlayer)
              setPlayerDowngraded(true)
            elseif averageFPSPerSecond > 71 and isPlayerDowngraded() then
              triggerEvent('onClientFPSHigh', localPlayer)
              setPlayerDowngraded(false)
            end
          end
        end
      )
    end
  end
)