local skinIds = {}

addEventHandler('onClientFileDownloadComplete', resourceRoot, function()
    local skins = IMGLoader():LoadFile('skins.img')
    if not skins then
      return false
    end

    engineSetAsynchronousLoading(true, true)

    local skinsCount = skins:GetFilesCount()
    local i = 1;

    while true do
      local modelId = engineRequestModel('ped')

      local txdFile = skins:GetFile(i .. '.txd')
      local dffFile = skins:GetFile(i .. '.dff')

      local txd;
      local dff;

      if txdFile then
        txd = engineLoadTXD(txdFile, true)
      end

      if dffFile then
        dff = engineLoadDFF(dffFile)
      end

      if txd and dff then
        engineImportTXD(txd, modelId)
        engineReplaceModel(dff, modelId)

        skinIds[table.maxn(skinIds) + 1] = modelId
      end

      if i == skinsCount then
        skins:CloseFile()

        txdFile = nil
        dffFile = nil
        txd = nil
        dff = nil

        collectgarbage('collect')

        for _, thePlayer in ipairs(getElementsByType('player', root, true)) do
          local playerSkin  = getElementData(thePlayer, 'player.skin')
          local skinModelId = skinIds[playerSkin]

          if playerSkin and skinModelId then
            setElementModel(thePlayer, skinModelId)
          end
        end

        break
      end

      i = i + 1
    end
  end
)

addEventHandler('onClientResourceStart', resourceRoot, function()
    return downloadFile('skins.img')
  end
)

addEventHandler('onClientElementStreamIn', root, function()
    local playerSkin = getElementData(source, 'player.skin')
    if getElementType(source) == 'player' and playerSkin then
      return setElementModel(source, skinIds[playerSkin] or playerSkin)
    end
  end
)

addEventHandler('onClientElementDataChange', root, function(theKey, _, newValue)
    if getElementType(source) == 'player' and theKey == 'player.skin' and isElementStreamedIn(source) and skinIds[newValue] then
      setElementModel(source, skinIds[newValue] or newValue)
    end
  end
)

addEventHandler('onClientPlayerSpawn', root, function()
    if source == localPlayer then
      for _, thePlayer in ipairs(getElementsByType('player', root, true)) do
        local playerSkin  = getElementData(thePlayer, 'player.skin')
        local skinModelId = skinIds[playerSkin]

        if playerSkin and skinModelId then
          setElementModel(thePlayer, skinModelId)
        end
      end
      return true
    end

    if isElementStreamedIn(source) then
      local playerSkin = getElementData(source, 'player.skin')
      if playerSkin then
        setElementModel(source, skinIds[playerSkin] or playerSkin)
      end
    end
  end
)

addCommandHandler('ss', function(_, value)
    setElementData(localPlayer, 'player.skin', tonumber(value))
  end
)