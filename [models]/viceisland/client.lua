local models = {
  { 'starfishpart1', 1389, 1 }, { 'starfishpart2', 1379, 1 },
  { 'starfishpart3', 1387, 1 }, { 'mansionpart1', 1392, 2 },
  { 'mansionpart2', 1386, 2 }
}

local textures = {
  'starfish.txd', 'mansion.txd'
}

local removeIDS = {
  1389, 1379, 1387, 1392, 1386
}

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i = 1, table.maxn(models) do
      local model = models[i]
      if model then
        local modelTXD = textures[model[3]]
        local modelID =  model[2]
        local modelPART = model[1]
        local modelDFF = 'parts/' .. modelPART .. '.dff'
        local modelCOL = 'parts/' .. modelPART .. '.col'

        engineImportTXD(engineLoadTXD(modelTXD),    modelID)
        engineReplaceModel(engineLoadDFF(modelDFF), modelID)
        engineReplaceCOL(engineLoadCOL(modelCOL),   modelID)
      end
    end

    for i = 1, table.maxn(removeIDS) do
      local removeID = removeIDS[i]
      if removeID then
        removeWorldModel(removeID, 10000, 0, 0, 0)
        engineSetModelLODDistance(removeID, 500000)
      end
    end
  end
)