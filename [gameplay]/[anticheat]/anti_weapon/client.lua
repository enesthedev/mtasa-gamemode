local defaultFpsLimit

local previousTask = false
local isAdded = false

function render()
	local weapon = getPedWeaponSlot(localPlayer)

	if not (weapon >= 2 and weapon <= 6)
		then return
	end

	local newTask = getPedTask(localPlayer, 'secondary', 0)

	if (previousTask ~= 'TASK_SIMPLE_USE_GUN' or false) and (previousTask ~= newTask) then
		setFPSLimit(70)
	elseif (previousTask == 'TASK_SIMPLE_USE_GUN') and (previousTask ~= newTask) then
		setFPSLimit(defaultFpsLimit)
	end

	previousTask = newTask
end

addEventHandler('onClientResourceStart', resourceRoot, function()
		defaultFpsLimit = getFPSLimit()
	end
)

addEventHandler('onClientPlayerWeaponSwitch', localPlayer, function(prevSlot, curSlot)
		if not isAdded and (curSlot >= 2 and curSlot <= 6) then
			addEventHandler('onClientRender', getRootElement(), render)
			isAdded = true
		elseif isAdded and (curSlot <= 1 or curSlot >= 7) then
			removeEventHandler('onClientRender', getRootElement(), render)
			isAdded = false
		end
	end
)

addEventHandler('onClientPedsProcessed', root, function()
		toggleControl('fire', not (getPedMoveState(localPlayer) == 'sprint'))
	end
)