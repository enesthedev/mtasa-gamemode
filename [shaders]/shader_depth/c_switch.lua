addEventHandler( "onClientResourceStart", getResourceRootElement( getThisResource()),
	function()
		if isDepthBufferAccessible() then
			enableDoF()
		end
	end
)

addEvent('onClientFPSLow', true)
addEventHandler('onClientFPSLow', localPlayer, function()
		return disableDoF()
	end
)

addEvent('onClientFPSHigh', true)
addEventHandler('onClientFPSHigh', localPlayer, function()
		return enableDoF()
	end
)
