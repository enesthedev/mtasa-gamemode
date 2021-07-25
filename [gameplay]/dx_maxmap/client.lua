local screenWidth, screenHeight = guiGetScreenSize()
local screenScale = math.max(screenHeight / 1080, 0.65)

local mapLimits = 6000
local mapSize = screenScale * 1024
local mapCenter = mapSize / 2
local mapTarget = false
local mapTexture = dxCreateTexture('media/radar.dds', 'dxt1')

local boxMultiplier = 0
local boxOffsetX, boxOffsetY = (screenScale * 16) * boxMultiplier, (screenScale * 9) * boxMultiplier
local boxSizeX, boxSizeY = screenWidth - boxOffsetX, screenHeight - boxOffsetY

local sizeCoeff = mapSize / mapLimits
local pixelsPerMeter = screenHeight / mapLimits

local hSize = pixelsPerMeter * mapLimits
local vSize = pixelsPerMeter * mapLimits

local centerX = (screenWidth - hSize) / 2
local centerY = (screenHeight - vSize) / 2

local rt       = { false, screenWidth, screenHeight, true, 'drawMapHandler' }
local FPSLimit = false
local state    = false

local pixels16 = screenScale * 16
local pixels8  = screenScale * 8
local pixels4  = screenScale * 4
local pixels2  = screenScale * 2

local function getMapTexture()
  dxSetRenderTarget(rt[1], true)
  dxSetBlendMode('modulate_add')

  local x = rt[2]
  local y = rt[3]

  pixelsPerMeter = y / mapLimits

  centerX = (x - hSize) / 2
  centerY = (y - vSize) / 2

  dxDrawImage(centerX, centerY, hSize, vSize, mapTexture, 0, 0, 0, 0xBBFFFFFF, false)

  drawRadarAreas()
	drawBlips()
	drawLocalPlayerArrow()

  dxSetBlendMode('blend')
  dxSetRenderTarget()

  return rt[1]
end

local function renderer()
	dxDrawRectangle(0, 0, screenWidth, screenHeight, 0x55000000, false)
	dxDrawImage(boxOffsetX / 2, boxOffsetY / 2, boxSizeX, boxSizeY, getMapTexture())
end

addEventHandler('onClientResourceStart', resourceRoot, function()
		toggleControl('radar', false)

		rt[1] = dxCreateRenderTarget(rt[2], rt[3], rt[4])
		if rt[1] then
      triggerEvent(rt[5], localPlayer)
    end
	end
)

bindKey('F11', 'up', function()
		if getElementData(localPlayer, 'player.logged') then
			state = not state

			triggerEvent('onClientMaximapToggle', localPlayer, state)

			return  _G[(state and 'add' or 'remove') .. 'EventHandler']('onClientRender', root, renderer)
		end
	end
)


function drawRadarAreas()
	local radarareas = getElementsByType('radararea')
	local tick = math.abs(getTickCount() % 1000 - 500)
	local aFactor = tick / 500

	for k,v in ipairs(radarareas) do
		local x, y = getElementPosition(v)
		local sx, sy = getRadarAreaSize(v)
		local r, g, b, a = getRadarAreaColor(v)
		local flashing = isRadarAreaFlashing(v)

		if flashing then
			a = a * aFactor
		end

		local hx1, hy1 = getMapFromWorldPosition(x, y + sy)
		local hx2, hy2 = getMapFromWorldPosition(x + sx, y)
		local width = hx2 - hx1
		local height = hy2 - hy1

		dxDrawRectangle(hx1, hy1, width, height, tocolor(r, g, b ,a), false)
	end
end

function drawBlips()
	for k,v in ipairs(getElementsByType('blip')) do
		local icon = getBlipIcon(v) or 0
		local size = (getBlipSize(v) or pixels2) * pixels4
		local r, g, b, a = getBlipColor(v)

		if icon ~= 0 then
			r, g, b = 255,255,255
			size = pixels16
		end

		local x, y, z = getElementPosition(v)
		x, y = getMapFromWorldPosition(x, y)

		local halfsize = size / 2

		dxDrawImage(x - halfsize, y - halfsize, size, size, 'media/blips/'.. icon ..'.png', 0, 0, 0, tocolor(r, g, b, a), false)
	end
end

function drawLocalPlayerArrow()
	local x, y, z = getElementPosition(localPlayer)
	local r = getPedRotation(localPlayer)

	local mapX, mapY = getMapFromWorldPosition(x, y)

	dxDrawImage(mapX - pixels8, mapY - pixels8, pixels16, pixels16, 'media/blips/2.png',(-r) % 360, 0, 0, 0xFFFFFFFF, false)
end

function getMapFromWorldPosition(worldX,worldY)
	local mapX = centerX + pixelsPerMeter * (worldX - (-3000))
	local mapY = centerY + pixelsPerMeter * (3000 - worldY)
	return mapX, mapY
end

--[[
local VehiclesInStream = {}

function StreamIn()
	if(getElementType(source) == "vehicle") then
		VehiclesInStream[source] = {}
		if(getElementData(source, "owner")) then
			if(getElementData(source, "owner") == getPlayerName(localPlayer)) then
				VehiclesInStream[source]["blip"] = createBlipAttachedTo(source, 0, 1, 170,170,170,170,1)
			end
		end
	end
end
addEvent("onClientElementStreamIn", true)
addEventHandler("onClientElementStreamIn", getRootElement(), StreamIn)




function StreamOut()
	if(getElementType(source) == "vehicle") then
		if(VehiclesInStream[source]) then
			for _, obj in pairs(VehiclesInStream[source]) do
				if(isElement(obj)) then
					destroyElement(obj)
				end
			end
		end
	end
end
addEventHandler("onClientElementStreamOut", getRootElement(), StreamOut)
addEventHandler("onClientVehicleExplode", getRootElement(), StreamOut)



function Start()
	for _,theVehicle in pairs(getElementsByType("vehicle", getRootElement(), true)) do
		triggerEvent("onClientElementStreamIn", theVehicle)
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), Start)


]]--