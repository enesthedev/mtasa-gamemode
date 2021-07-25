local weaponShooting = false
local weaponTimer = false

addEventHandler('onClientPlayerWeaponFire', localPlayer, function()
    local rotation = getPedCameraRotation(localPlayer)
    if rotation then
      if weaponTimer and isTimer(weaponTimer) then
        killTimer(weaponTimer)
      end

      if not weaponShooting then
        setPedCameraRotation(localPlayer, -(rotation - 0.18))

        weaponTimer = setTimer(setPedCameraRotation, 50, 1, localPlayer, -(rotation + 0.30))
        weaponShooting = true
      else
        setPedCameraRotation(localPlayer, -(rotation + 0.18))

        weaponTimer = setTimer(setPedCameraRotation, 50, 1, localPlayer, -(rotation - 0.30))
        weaponShooting = false
      end
    end
  end
)