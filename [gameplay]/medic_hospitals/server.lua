local hospitalPositions = {
  { 1184.6485595703, -1323.3597412109, 13.57390499115 },
  { 1607,	1818, 10.8203125 },
	{ 2040, -1420, 16.9921875 },
	{ -2200, -2308, 30.625 },
	{ 208, -65.3, 1.4357746839523 },
	{ 1245.8, 336.9, 19.40625 },
	{ -317.4, 1056.4, 19.59375 },
	{ -1514.8, 2527.9, 55.6875 }
}

local hospitalBlips = {}

for i = 1, table.maxn(hospitalPositions) do
  local hospitalPosition = hospitalPositions[i]
  if hospitalPosition then
    hospitalBlips[i] = createBlip(hospitalPosition[1], hospitalPosition[2], hospitalPosition[3], 22, 2)
  end
end

addEventHandler('onPlayerWasted', root, function()
    return spawnPlayer(source, unpack(hospitalPositions[math.max(table.maxn(hospitalPositions))]))
  end
)