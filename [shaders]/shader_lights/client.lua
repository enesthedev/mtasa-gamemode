addEventHandler('onClientResourceStart', resourceRoot, function()
    local theShader = dxCreateShader([[technique light_disable
    {
        pass P0
        {
            LightEnable[1] = false;
            LightEnable[2] = false;
            LightEnable[3] = false;
            LightEnable[4] = false;
        }
    }]], 0, 0, false, 'object')
    if theShader then
      return engineApplyShaderToWorldTexture(theShader,'*')
    end
  end
)