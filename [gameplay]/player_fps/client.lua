local clientFPS = 0
local nextTick = 0

function getClientFPS()
    return clientFPS
end

addEventHandler('onClientPreRender', root, function(msSinceLastFrame)
    local now = getTickCount()
    if (now >= nextTick) then
      clientFPS = math.floor((1 / msSinceLastFrame) * 1000 + 0.5)
      nextTick = now + 1000
    end
  end
)