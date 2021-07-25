local updateMinute = 5
local updateInterval = 60000 * updateMinute

local subscribedPlayers = {}
local currentWeathers = {}

local cityWeathers = {
  ['Los Santos'] = { 0, 0, 1, 2, 3, 4 },
  ['San Fierro'] = { 5, 6, 7, 8, 9 },
  ['Las Venturas'] = { 3, 10, 11, 12, 17, 14 },
  ['Red County'] = { 13, 14, 15, 16, 14 },
  ['Whetstone'] = { 13, 14, 15, 16, 14 },
  ['Tierra Robada'] = { 0, 1, 2, 5, 6, 7, 10, 11, 12, 17, 14 },
  ['Bone County'] = { 0, 11, 17, 18, 19 },
  ['Flint County'] = { 5, 6, 7, 8, 9, 10, 11, 12, 17, 14, 16 },
  ['Unknown'] = { 0, 2, 12, 14, 17, 1, 20 }
}

function getRandomWeather(city)
  if cityWeathers[city] then
    return cityWeathers[city][math.random(1, table.maxn(cityWeathers[city]))]
  end
end

function setCityNewWeather(city, weather)
  currentWeathers[city] = weather
end

function updateCityWeathers()
  for cityName, _ in pairs(cityWeathers) do
    setCityNewWeather(cityName, getRandomWeather(cityName))
  end

  local players = getElementsByType('player')
  for i = 1, table.maxn(players) do
    local thePlayer = players[i]
    if thePlayer and subscribedPlayers[thePlayer] then
      triggerLatentClientEvent(thePlayer, 'onClientRequestWeather', 5000, false, thePlayer, currentWeathers)
    end
  end
end

addEventHandler('onResourceStart', resourceRoot, function()
    setWeather(0)
    updateCityWeathers()
  end
)

addEvent('onRequestWeathers', true)
addEventHandler('onRequestWeathers', root, function()
    subscribedPlayers[client] = true
    triggerClientEvent(client, 'onClientRequestWeather', client, currentWeathers)
  end
)

addEventHandler('onPlayerQuit', root, function()
    if subscribedPlayers[source] then
      subscribedPlayers[source] = nil
    end
  end
)

setTimer(updateCityWeathers, updateInterval, 0)