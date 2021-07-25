local textures  = {
  { 'bonyrd_skin2', 'idlegass.dds' }
}

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i = 1, table.maxn(textures) do
      local texture = textures[i]
      local replaceShader = dxCreateShader('fx/replace.fx', 0, 0, false, 'object')
      if replaceShader then
        local mapTexture = dxCreateTexture('textures/' .. texture[2], 'dxt1', true, 'clamp')
        if mapTexture then
          dxSetShaderValue(replaceShader, 'gTexture', mapTexture)
          engineApplyShaderToWorldTexture(replaceShader, texture[1])
        end
      end
    end
  end
)