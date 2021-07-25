local disabledControls = {
	'fire', 'action',
	'aim_weapon', 'vehicle_fire',
	'vehicle_secondary_fire'
}

local playerDName = 'player.greenzone'
local vehicleDName = 'vehicle.greenzone'

local createdZones = {}
local avaliableZones = {
	-- { x = 0, y = 0, z = 0, width = 0, depth = 0, height = 0 }
	{ x = 2467.42,           y = -1686.06,         z = 12,         width = 37, depth = 36, height = 15 },
	{ x = 1987.69,           y = 1503.08,          z = 8,          width = 40, depth = 70, height = 25 },
	{ x = -727.38,           y = 930.76,           z = 11,         width = 60, depth = 60, height = 25 },
	{ x = -2420,             y = -626.2,           z = 125,        width = 60, depth = 60, height = 30 },
	{ x = 1655.0051269531,   y = 1733.1754150391,  z = 10,         width = 60, depth = 60, height = 30 },
	{ x = 2102.7048339844,   y = 2257.498046875,   z = 10,         width = 60, depth = 60, height = 30 },
	{ x = 2244.7224121094,   y = -1663.8387451172, z = 10,         width = 60, depth = 60, height = 30 },
	{ x = -2375.5783691406,  y = 909.90075683594,  z = 10,         width = 60, depth = 60, height = 30 },
	{ x = 1900.9112548828,   y = -1805.7283935547, z = 0,          width = 100, depth = 60, height = 30 },
	--{ x = -1455.3184814453,  y = -341.10089111328, z = 0,          width = 60, depth = 60, height = 30 },
	--{ x = 1685.7241210938,   y = -2332.4052734375, z = 0,          width = 60, depth = 60, height = 30 },
	--{ x = 1675.2132568359,   y = 1447.7581787109, z = 0,           width = 60, depth = 60, height = 30 }
}

addEventHandler('onResourceStart', resourceRoot, function()
		if avaliableZones and table.maxn(avaliableZones) > 0 then
			for i = 1, table.maxn(avaliableZones) do
				local avaliableZone = avaliableZones[i]
				if avaliableZone then
					local cuboid = createColCuboid(avaliableZone.x, avaliableZone.y, avaliableZone.z, avaliableZone.width, avaliableZone.depth, avaliableZone.height)
					local radarArea = createRadarArea(avaliableZone.x, avaliableZone.y, avaliableZone.width, avaliableZone.depth, 0, 255, 0, 150)

					if cuboid and radarArea then
						setElementParent(cuboid, radarArea)
						createdZones[cuboid] = true

						local colPlayers = getElementsWithinColShape(cuboid, 'player')
						local colVehicles = getElementsWithinColShape(cuboid, 'vehicle')

						local colPIndex = table.maxn(colPlayers)
						local colVIndex = table.maxn(colVehicles)

						if colPIndex > 0 then
							for i = 1, colPIndex do
								local thePlayer = colPlayers[i]
								if thePlayer then
									setElementData(thePlayer, playerDName, true)
								end
							end
						end

						if colVIndex > 0 then
							for i = 1, colVIndex do
								local theVehicle = colVehicles[i]
								if theVehicle then
									setElementData(theVehicle, vehicleDName, true)
								end
							end
						end

						addEventHandler('onElementDestroy', cuboid, function()
								if createdZones[source] then
									createdZones[source] = nil
								end
							end
						)

						addEventHandler('onColShapeHit', cuboid, function(hitElement)
								if hitElement and isElement(hitElement) and getElementType(hitElement) == 'player' then
									if getElementData(hitElement, 'colshape.fix.out') then
										return setElementData(hitElement, "colshape.fix.out", false, false)
									end

									triggerClientEvent(hitElement, 'onClientEnterGreenzone', hitElement)

									if getElementData(hitElement, playerDName) then
										return setElementData(hitElement, 'colshape.fix.in', true, false)
									end

									outputChatBox('Bildirim: #319d16Güvenli bölgeye giriş yaptın.', hitElement, 0, 220, 0, true)
									setElementData(hitElement, playerDName, true)

									for i = 1, table.maxn(disabledControls) do
										local controlName = disabledControls[i]
										if controlName then
											toggleControl(hitElement, controlName, false)
										end
									end
								end
							end
						)

						addEventHandler('onColShapeHit', cuboid, function(hitElement)
								if hitElement and isElement(hitElement) and getElementType(hitElement) == 'vehicle' then
									setElementData(hitElement, vehicleDName, true)
								end
							end
						)

						addEventHandler('onColShapeLeave', cuboid, function(leaveElement)
								if leaveElement and isElement(leaveElement) and getElementType(leaveElement) == 'player' then
									if getElementData(leaveElement, 'colshape.fix.in') then
										return setElementData(leaveElement, 'colshape.fix.in', false, false)
									end

									if getElementData(leaveElement, playerDName) then
										outputChatBox('Bildirim: #319d16Güvenli bölgeden çıktın.', leaveElement, 0, 220, 0, true)
										setElementData(leaveElement, 'player.greenzone', false)

										for i = 1, table.maxn(disabledControls) do
											local controlName = disabledControls[i]
											if controlName then
												toggleControl(leaveElement, controlName, true)
											end
										end

										triggerClientEvent(leaveElement, 'onClientLeaveGreenzone', leaveElement)
									else
										setElementData(leaveElement, "colshape.fix.out", true)
									end
								end
							end
						)

						addEventHandler('onColShapeLeave', cuboid, function(leaveElement)
								if leaveElement and isElement(leaveElement) and getElementType(leaveElement) == 'vehicle' then
									setTimer(setElementData, 350, 1, leaveElement, vehicleDName, false)
								end
							end
						)
					end
				end
			end
		end
	end
)

addEventHandler('onResourceStop', resourceRoot, function()
		local players = getElementsByType('player')
		for i = 1, table.maxn(players) do
			local thePlayer = players[i]
			if thePlayer and isElement(thePlayer) then
				removeElementData(thePlayer, playerDName)
			end
		end

		local vehicles = getElementsByType('vehicle')
		for i = 1, table.maxn(vehicles) do
			local theVehicle = vehicles[i]
			if theVehicle and isElement(theVehicle) then
				removeElementData(theVehicle, vehicleDName)
			end
		end
	end
)