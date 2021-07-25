local weaponList = {
  'colt 45', 'silenced',
  'deagle', 'shotgun',
  'sawed-off', 'combat shotgun',
  'uzi', 'mp5', 'ak-47',
  'm4', 'tec-9', 'rifle',
  'sniper', 'minigun'
}

local weaponTypes = {
  24, 69, 70,
  71, 72, 73,
  74, 76, 77,
  78, 79
}

addEventHandler('onResourceStart', resourceRoot, function()
    for _, weaponName in ipairs(weaponList) do
      for _, skillLevel in ipairs({ 'poor', 'std', 'pro'}) do
        setWeaponProperty(weaponName, skillLevel, 'flag_move_and_aim',   true)
        setWeaponProperty(weaponName, skillLevel, 'flag_move_and_shoot', true)
        setWeaponProperty(weaponName, skillLevel, 'move_speed',          2)

        if weaponName == 'minigun' then
          setWeaponProperty(weaponName, skillLevel, 'damage', 0)
        end
      end
    end
  end
)

addEventHandler('onPlayerLogin', root, function()
    for i = 1, table.maxn(weaponTypes) do
      local weaponType = weaponTypes[i]
      if weaponType then
        setPedStat(source, weaponType, 1000)
      end
    end
  end
)