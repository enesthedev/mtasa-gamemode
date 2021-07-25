local disabledControls = {
	'fire', 'action',
	'aim_weapon', 'vehicle_fire',
	'vehicle_secondary_fire'
}

addEvent('onClientEnterGreenzone', true)
addEventHandler('onClientEnterGreenzone', localPlayer, function()
		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local nearbyVehicles = getElementsWithinRange(playerX, playerY, playerZ, 300, 'vehicle')

		if nearbyVehicles then
			for i = 1, table.maxn(nearbyVehicles) do
				local theVehicle = nearbyVehicles[i]
				if theVehicle then
					setElementCollidableWith(localPlayer, theVehicle, false)
				end
			end
		end
	end
)

addEvent('onClientLeaveGreenzone', true)
addEventHandler('onClientLeaveGreenzone', localPlayer, function()
		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local nearbyVehicles = getElementsWithinRange(playerX, playerY, playerZ, 300, 'vehicle')

		if nearbyVehicles then
			for i = 1, table.maxn(nearbyVehicles) do
				local theVehicle = nearbyVehicles[i]
				if theVehicle then
					setElementCollidableWith(localPlayer, theVehicle, true)
				end
			end
		end
	end
)

addEventHandler('onClientPlayerDamage', localPlayer, function()
		if getElementData(source, 'player.greenzone') then
			cancelEvent()
		end
	end
)

addEventHandler('onClientPlayerStealthKill', localPlayer, function(target)
		if getElementData(target, 'player.greenzone') then
			cancelEvent()
		end
	end
)

addEventHandler('onClientElementStreamIn', root, function()
		if not getElementData(localPlayer, 'player.greenzone') then
			return
		end
		if getElementType(source) == 'vehicle' then
			setElementCollidableWith(localPlayer, source, false)
		end
	end
)

addEventHandler('onClientElementStreamOut', resourceRoot, function()
		if not getElementData(source, 'vehicle.greenzone') then
			return
		end
		if getElementType(source) == 'vehicle' and isElementCollidableWith(localPlayer, source) == false then
			setElementCollidableWith(localPlayer, source, true)
		end
	end
)

addEventHandler('onClientPlayerWeaponFire', localPlayer, function()
		if getElementData(localPlayer, 'player.greenzone') then
			for i = 1, table.maxn(disabledControls) do
				local controlName = disabledControls[i]
				if controlName then
					toggleControl(controlName, false)
				end
			end
		end
	end
)