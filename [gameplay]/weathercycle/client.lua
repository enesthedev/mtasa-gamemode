local updateTick = getTickCount()
local updateInterval = 1500

local playerX, playerY, playerZ = getElementPosition(localPlayer)
local lastCity = getZoneName(playerX, playerY, playerZ, true)

local currentWeathersList = {}

local currentCity;

addEvent('onClientRequestWeather', true)
addEventHandler('onClientRequestWeather', localPlayer, function(currentWeathers)
    currentWeathersList = currentWeathers;
    triggerEvent('onClientCityChanged', localPlayer, lastCity)
  end
)

addEvent('onClientCityChanged')
addEventHandler('onClientCityChanged', localPlayer, function(newCity)
    lastCity = newCity
    if currentWeathersList[newCity] then
      setWeatherBlended(currentWeathersList[newCity])
    end
  end
)

addEventHandler('onClientPreRender', root, function()
    if getTickCount() - updateTick >= updateInterval then
      playerX, playerY, playerZ = getElementPosition(localPlayer)
      currentCity = getZoneName(playerX, playerY, playerZ, true)

      if currentCity ~= lastCity then
        triggerEvent('onClientCityChanged', localPlayer, currentCity)
      end

      updateTick = getTickCount()
    end
  end
)

addEventHandler('onClientResourceStart', resourceRoot, function()
    triggerServerEvent('onRequestWeathers', localPlayer)
  end
)