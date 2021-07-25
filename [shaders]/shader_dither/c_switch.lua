--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "switchSkyDither", root, true )
--
--	To switch off:
--			triggerEvent( "switchSkyDither", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
-- Auto switch on at start
--------------------------------
local isFXSupported = true
addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		return triggerEvent( "switchSkyDither", resourceRoot, true )
	end
)


--------------------------------
-- Switch effect on or off
--------------------------------
function switchSkyDither( sbOn )
	if not isFXSupported then return end
	if sbOn then
		skyDither.startShaderResource()
	else
		skyDither.stopShaderResource()
	end
end

addEvent( "switchSkyDither", true )
addEventHandler( "switchSkyDither", resourceRoot, switchSkyDither )

--------------------------------
-- onClientResourceStop
-- Stop the resource
--------------------------------
addEventHandler( "onClientResourceStop", resourceRoot, skyDither.stopShaderResource )
