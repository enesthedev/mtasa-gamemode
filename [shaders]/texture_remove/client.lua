local replaceShader = dxCreateShader('fx/replace.fx')

addEventHandler('onClientResourceStart', resourceRoot, function(startedResource)
    if startedResource ~= resource or not replaceShader then
      return false
    end

    for _, textureName in ipairs({ 'shad_ped', 'bullethitsmoke', 'cloudmasked', 'vgntelewires1', 'txgrass0_1', 'shad_car', 'fist', 'font1' }) do
      engineApplyShaderToWorldTexture(replaceShader, textureName)
    end
  end
)