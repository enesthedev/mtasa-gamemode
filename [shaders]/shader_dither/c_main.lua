-- sky_dither v0.0.6
-- knoblauch700@o2.pl

skyDither = {
	modelID = engineRequestModel('object', 4729), -- model id used (needs to be a non alpha quad with UVs fitting surface)
	resAspectBug = true, -- enable resolution aspect bug for stars, moon and clouds
	effectsSwitchTime = 500, effectValuesUpdate = 300,
	outGradient = nil, outMoonStars = nil, outClouds = nil,
	moonStarsOn = false, cloudsOn = false,
	moonTex = nil, starTex = nil, object = nil,
	switchTimer = nil
}

local scx, scy = guiGetScreenSize()

function skyDither.startShaderResource()
	if sbdEffectEnabled then return end

	local camX, camY, camZ = getCameraMatrix()
	skyDither.object = createObject( skyDither.modelID, camX, camY, camZ, 0, 0, 0, true )
	setElementAlpha( skyDither.object, 1 )
	setObjectScale( skyDither.object, 10 )

	skyDither.outGradient = dxCreateShader( "fx/RTOutput_gradient.fx", 10, 0, false, "object" )
	skyDither.outMoonStars = dxCreateShader( "fx/RTOutput_moonStars.fx", 10, 0, true, "object" )
	skyDither.outClouds = dxCreateShader( "fx/RTOutput_clouds.fx", 10, 0, true, "object" )
	skyDither.moonTex = dxCreateTexture("tex/coronamoon.png", "argb")
	skyDither.starTex = dxCreateTexture("tex/coronastar.png", "dxt3")
	skyDither.cloudTex = dxCreateTexture("tex/cloud1.png", "dxt1")

	if not skyDither.outGradient or not skyDither.outMoonStars or not skyDither.outClouds
			or not skyDither.moonTex or not skyDither.starTex  or not skyDither.cloudTex then
		return
	end
	dxSetShaderValue( skyDither.outGradient, "fViewportSize", scx, scy )
	dxSetShaderValue( skyDither.outMoonStars, "fViewportSize", scx, scy )
	dxSetShaderValue( skyDither.outClouds, "fViewportSize", scx, scy )
	dxSetShaderValue( skyDither.outMoonStars, "bResAspectBug", skyDither.resAspectBug )
	dxSetShaderValue( skyDither.outClouds, "bResAspectBug", skyDither.resAspectBug )

	dxSetShaderValue( skyDither.outMoonStars, "sTexMoon", skyDither.moonTex )
	dxSetShaderValue( skyDither.outMoonStars, "sTexStar", skyDither.starTex )
	dxSetShaderValue( skyDither.outClouds, "sTexCloud", skyDither.cloudTex )


	engineApplyShaderToWorldTexture( skyDither.outGradient, "*", skyDither.object )
	engineApplyShaderToWorldTexture( skyDither.outMoonStars, "*", skyDither.object )
	engineApplyShaderToWorldTexture( skyDither.outClouds, "*", skyDither.object )
	moonStarsOn = true
	cloudsOn = true
	sbdEffectEnabled = true
	skyDither.switchTimer = setTimer(skyDither.manageShaderEffects, skyDither.effectsSwitchTime, 0)
end

function skyDither.stopShaderResource()
	if not sbdEffectEnabled then return end
	killTimer(skyDither.switchTimer)
	skyDither.switchTimer = nil
	engineRemoveShaderFromWorldTexture( skyDither.outGradient, "*" )
	engineRemoveShaderFromWorldTexture( skyDither.outMoonStars, "*" )
	engineRemoveShaderFromWorldTexture( skyDither.outClouds, "*" )
	sbdEffectEnabled = false
	destroyElement( skyDither.outGradient )
	destroyElement( skyDither.outMoonStars )
	destroyElement( skyDither.outClouds )
	skyDither.object = nil
	skyDither.outGradient = nil
	skyDither.outMoonStars = nil
	skyDither.outClouds = nil
end

local skyTopX, skyTopY, skyTopZ, skyBotX, skyBotY, skyBotZ
local sCol, mCol, mNr, h, m = 0, 0, 0, 0, 0
local lastTickCount = 0

local excludeWeather = {4, 7, 8, 9, 12, 15, 16, 19}
local weather = nil

local cloudyWeatherId, isCloudyWeather = 0, false
local cloudyWeathers = {1, 3, 5, 10, 14, 18}

addEventHandler("onClientPreRender", getRootElement(), function()
	if not sbdEffectEnabled then return end
	setElementMatrix( skyDither.object, getElementMatrix( getCamera() ))
	skyTopX, skyTopY, skyTopZ, skyBotX, skyBotY, skyBotZ = getSkyGradient()
	dxSetShaderValue( skyDither.outGradient, "fSkyTop", skyTopX / 255, skyTopY / 255, skyTopZ / 255 )
	dxSetShaderValue( skyDither.outGradient, "fSkyBot", skyBotX / 255, skyBotY / 255, skyBotZ / 255 )
	if getTickCount() - lastTickCount < skyDither.effectValuesUpdate then return end
	-- stars and moon stuff
	weather = getWeather()
	isWeather = true
	if weather > 19 then
		isWeather = false
	else
		for i, v in ipairs(excludeWeather) do
			if weather == v then
				isWeather = false
			end
		end
	end
	h, m = getTime ()
	mNr = (h * 60 + m)
	if (mNr >= 1320 or mNr <= 440) and isWeather then
		if (mNr > 220 and mNr < 440) then mCol = (440 - mNr) / 255
			else if (mNr <= 220) then mCol = mNr / 255 else mCol = 0 end
		end
		if (mNr > 1320 and mNr < 1380) then sCol = (((mNr - 1320) / 60) * 160) / 255 end
		if (mNr >= 1380 or mNr < 300) then sCol = 160 / 255 end
		if (mNr >= 300 and mNr <= 360) then sCol = (((360 - mNr) / 60) * 160) / 255 end
		if (mNr > 360 and mNr < 1320) then sCol = 0 end
	else
		sCol, mCol = 0, 0
	end
	dxSetShaderValue( skyDither.outMoonStars, "sMoonColor", mCol, mCol, mCol * 0.85)
	dxSetShaderValue( skyDither.outMoonStars, "sStarColor", sCol, sCol, sCol )
	dxSetShaderValue( skyDither.outMoonStars, "sMoonSize", getMoonSize())

	-- cloud stuff
	if weather ~= cloudyWeatherId then
		for i, v in ipairs(cloudyWeathers) do
			isCloudyWeather = (v == weather) or isCloudyWeather
		end
		cloudyWeatherId = weather
	end

	dxSetShaderValue( skyDither.outClouds, "sCloudColor", unpack(skyDither.getCloudsDiffuseColor()))

	lastTickCount = getTickCount()
end, true, "high" )

cloudColorTable = {}
cloudColorTable[1] = { { 0, 0, 0, 0, 0 }, { 3, 0, 0, 0, 0 }, { 5, 0, 0, 0, 0 }, { 6, 0, 98, 32, 23 }, { 7, 0, 118, 38, 38 }, { 9, 0, 87, 36, 32 },
		{ 12, 0, 44, 33, 22 }, { 19, 0, 116, 38, 38 }, { 20, 0, 0, 0, 0 }, { 21, 0, 34, 12, 4 }, { 22, 0, 67, 25, 8 }, { 23, 0, 33, 12, 3 }, { 23, 59, 0, 0, 0 } }
cloudColorTable[3] = { { 0, 0, 28, 17, 0 }, { 3, 0, 31, 11, 4 }, { 5, 0, 34, 7, 8 }, { 6, 0, 98, 32, 23 }, { 7, 0, 118, 38, 38 }, { 9, 0, 87, 36, 32 },
		{ 12, 0, 43, 33, 22 }, { 19, 0, 117, 38, 38 }, { 20, 0, 115, 37, 37 }, { 21, 0, 92, 31, 23 }, { 22, 0, 68, 25, 8 }, { 23, 0, 48, 21, 3 }, { 23, 59, 28, 18, 0 } }
cloudColorTable[5] = { { 0, 0, 29, 19, 0 }, { 3, 0, 53, 23, 5 }, { 5, 0, 69, 26, 9 }, { 6, 0, 99, 33, 24 }, { 7, 0, 119, 39, 39 }, { 9, 0, 119, 63, 63 },
		{ 12, 0, 119, 98, 98 }, { 20, 0, 119, 38, 38 }, { 21, 0, 93, 32, 23 }, { 22, 0, 68, 25, 8 }, { 23, 0, 48, 22, 3 }, { 23, 59, 29, 19, 0 } }
cloudColorTable[10] = { { 0, 0, 29, 19, 0 }, { 3, 0, 53, 23, 5 }, { 5, 0, 68, 26, 9 }, { 6, 0, 99, 33, 24 }, { 7, 0, 119, 39, 39 }, { 9, 0, 119, 63, 63 },
		{ 12, 0, 119, 98, 98 }, { 19, 0, 119, 39, 39 }, { 20, 0, 119, 39, 39 }, { 21, 0, 93, 32, 23 }, { 22, 0, 69, 26, 9 }, { 23, 0, 48, 22, 3 }, { 23, 59, 29, 19, 0 } }
cloudColorTable[14] = {	{ 0, 0, 28, 19, 0 }, { 3, 0, 24, 25, 11 }, { 5, 0, 23, 29, 19 }, { 6, 0, 98, 32, 23 }, { 7, 0, 119, 39, 39 }, { 9, 0, 119, 63, 63 },
		{ 12, 0, 119, 98, 98 }, { 19, 0, 119, 39, 39 },{ 20, 0, 119, 39, 39 },{ 21, 0, 93, 32, 23 },{ 22, 0, 68, 25, 8 },{ 23, 0, 48, 22, 3 },{ 23, 59, 28, 19, 0 } }
cloudColorTable[18] = {	{ 0, 0, 29, 19, 0 }, { 3, 0, 53, 23, 5 }, { 5, 0, 69, 26, 9 }, { 6, 0, 99, 33, 24 }, { 7, 0, 119, 39, 39 }, { 9, 0, 119, 63, 63 },
		{ 12, 0, 119, 98, 98 },{ 19, 0, 119, 38, 38 },{ 20, 0, 119, 38, 38 },{ 21, 0, 93, 32, 23 },{ 22, 0, 68, 25, 8 },{ 23, 0, 48, 22, 3 },{ 23, 59, 29, 19, 0 } }

local lastCloudColor = {0,0,0,0}
function skyDither.getCloudsDiffuseColor()
	if not isCloudyWeather or not getCloudsEnabled() then
		lastCloudColor = {0,0,0,0}
		return lastCloudColor
	end
	if not cloudColorTable[cloudyWeatherId] then
		lastCloudColor = {0,0,0,0}
		return lastCloudColor
	end
	-- Get game time
	local h, m = getTime()
	local fhoursNow = h + m / 60

	-- Find which two lines in the diffuseColorTable to blend between
	for idx,v in ipairs( cloudColorTable[cloudyWeatherId] ) do
		local fhoursTo = v[1] + v[2] / 60
		if fhoursNow <= fhoursTo then

			-- Work out blend from line
			local vFrom = cloudColorTable[cloudyWeatherId][ math.max( idx-1, 1 ) ]
			local fhoursFrom = vFrom[1] + vFrom[2] / 60

			-- Calc blend factor
			local f = math.unlerp( fhoursFrom, fhoursNow, fhoursTo )

			-- Calc final color
			local x = math.lerp( vFrom[3], f, v[3] )
			local y = math.lerp( vFrom[4], f, v[4] )
			local z = math.lerp( vFrom[5], f, v[5] )

			lastCloudColor = {x / 255, y / 255, z / 255, 1}

			return lastCloudColor
		end
	end
	return lastCloudColor
end

function skyDither.manageShaderEffects()
	if not sbdEffectEnabled then return end
	if not moonStarsOn then
		if (mCol or sCol) > 0 then
			engineApplyShaderToWorldTexture( skyDither.outMoonStars, "*", skyDither.object )
			moonStarsOn = true
			--outputDebugString('moonStarsOn '..tostring(moonStarsOn))
		end
	else
		if not ((mCol + sCol) > 0) then
			engineRemoveShaderFromWorldTexture( skyDither.outMoonStars, "*", skyDither.object )
			moonStarsOn = false
			--outputDebugString('moonStarsOn '..tostring(moonStarsOn))
		end
	end
	if not cloudsOn then
		if (lastCloudColor[1] + lastCloudColor[2] + lastCloudColor[3]) > 0 then
			engineApplyShaderToWorldTexture( skyDither.outClouds, "*", skyDither.object )
			cloudsOn = true
			--outputDebugString('cloudsOn '..tostring(cloudsOn))
		end
	else
		if not ((lastCloudColor[1] + lastCloudColor[2] + lastCloudColor[3]) > 0) then
			engineRemoveShaderFromWorldTexture( skyDither.outClouds, "*", skyDither.object )
			cloudsOn = false
			--outputDebugString('cloudsOn '..tostring(cloudsOn))
		end
	end
end

----------------------------------------------------------------
-- Math helper functions
----------------------------------------------------------------
function math.lerp(from,alpha,to)
	return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end
