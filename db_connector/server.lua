local dbConnections = {}
local alterResources = {}

local function xmlLoadMeta(metapath, readonly)
  assert(metapath, '@ Failed to load meta-path')
  assert(type(readonly) == 'boolean', '@ Failed to load read-only')

  local xmlNode = xmlLoadFile(metapath, readonly)
  if not xmlNode then
    xmlUnloadFile(xmlNode)
    return false
  end

  local xmlChild = xmlFindChild(xmlNode, 'db_connection', 0)
  if not xmlChild then
    xmlUnloadFile(xmlNode)
    return false
  end

  local xmlAttribute = xmlNodeGetAttribute(xmlChild, 'database')
  if not xmlAttribute then
    xmlUnloadFile(xmlNode)
    return false
  end

  xmlUnloadFile(xmlNode)
  xmlNode = nil

  collectgarbage()

  return xmlAttribute
end

local function dbGetConnection(index)
  if not dbConnections[index] and alterResources[index] then
    local dbResponse = {}
    for i = 1, table.maxn(alterResources[index]) do
      local dbIndex = alterResources[index][i]
      local dbConnection = dbConnections[dbIndex]

      if dbConnection then
        table.insert(dbResponse, dbConnection)
      end
    end
    return dbResponse
  end
  return dbConnections[index]
end

function get(...)
  local varargLength = table.maxn(arg)
  if varargLength > 1 then
    local dumpConnections = {}
    for i = 1, varargLength do
      dumpConnections[i] = dbGetConnection(arg[i])
    end
    return dumpConnections
  end
  return dbGetConnection(arg[1])
end

addEventHandler('onResourcePreStart', root, function(resource)
    local resourceName = getResourceName(resource)
    if not resourceName then
      return false
    end

    local xmlAttribute = xmlLoadMeta(string.format(':%s/meta.xml', resourceName), true)
    if not xmlAttribute then
      return false
    end

    xmlAttribute = split(xmlAttribute, ", ")
    alterResources[resource] = {}

    for i = 1, table.maxn(xmlAttribute) do
      local dbName = xmlAttribute[i]
      local dbConnection = dbConnections[dbName]

      if not dbConnection then
        dbConnections[dbName] = dbConnect('sqlite', string.format(':/%s.db', dbName))
        table.insert(alterResources[resource], dbName)
      end
    end
    return true
  end
)

addEventHandler('onResourceStop', root, function(resource)
    if alterResources[resource] then
      for i = 1, table.maxn(alterResources[resource]) do
        local dbName = alterResources[resource][i]
        destroyElement(dbConnections[dbName])
        dbConnections[dbName] = nil
      end

      alterResources[resource] = nil
      collectgarbage()
    end
  end
)