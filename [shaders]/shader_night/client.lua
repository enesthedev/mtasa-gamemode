setFogDistance(0)
resetSkyGradient()

local intens = 1500
local lock_color = false
local tick = getTickCount()
local bx, by, bz, ax, ay, az =  168, 135, 84, 136, 91, 61

function clr(a, t)
	return (a - (a * (t - 20) / 3))
end

function uclr(a, t)
	return (a * (t - 2) / 3)
end

function timeInterval()
	if getMinuteDuration() >= 100 then
		return getMinuteDuration()
	else
		return 100
	end
end

addEventHandler('onClientPreRender', root, function()
    if getTickCount() - tick > 100 then
      tick = getTickCount()

      local h, m = getTime()
      local th = h + (m / 60)
    	local tm = m + (h * 60)

      if (th >= 20  and th <= 23) then
        if (th <= 23) then
          setSkyGradient(clr(bx, th), clr(by, th), clr(bz, th), clr(ax, th), clr(ay, th), clr(az, th))
        end

        if ((th >= 21) and (th <= 23)) then
    			setFogDistance(-intens + (intens / 120 * (1380 - tm)))
        end
      elseif (((th > 23) and (th <= 24)) or ((th >= 0) and (th < 2))) then
        setFogDistance(-intens)
        setSkyGradient(0, 0, 0, 0, 0, 0)
      elseif ((th >= 2) and (th <= 5)) then
        setSkyGradient(uclr(bx / 10, h), uclr(by / 10, th), uclr(bz / 10, th), uclr(ax / 10, th), uclr(ay / 10, th), uclr(az / 10, th))
    		setFogDistance(-intens + (intens / 180 * (tm - 120)))
      end

      setFogDistance(0)
      setMoonSize(0)
      resetSkyGradient()
    end
  end
)

addEventHandler('onClientResourceStart', resourceRoot, function()
    local shader = dxCreateShader('fx/clear.fx')
    if not shader then
      return false
    end

    dxSetShaderValue(shader, 'color', { 0.0, 0.0, 0.0, 0.0 } );

    engineApplyShaderToWorldTexture(shader, 'coronastar')
    engineApplyShaderToWorldTexture(shader, 'shad_exp')
    engineApplyShaderToWorldTexture(shader, 'handman')

    setTrafficLightState('disabled')
  end
)