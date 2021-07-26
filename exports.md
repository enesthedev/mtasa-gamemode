# List of export functions on RPG server

### base_env
|SHARED                         |
|-------------------------------|
|get(envKey)                    |
|set(envKey, envValue)          |

### account_cache
|SERVER                            |
|----------------------------------|
|get(theAccount, theKey)           |
|set(theAccount, theKey, theValue) |    

### player_fps
|CLIENT                            |
|----------------------------------|
|getClientFPS()                    |

### interface
|CLIENT                                                    |
|----------------------------------------------------------|
|guiWindowSetCentered(guiWindow, state, offsetX, offsetY)  |
|guiDestroyElements(guiElements...)                        |
|guiCreateSplashWindow(message, interval)                  |
|guiWindowSetTitleEnabled(guiWindow, state)                |

### conguard
|SERVER                                                     |CLIENT                              |
|-----------------------------------------------------------|------------------------------------|
|createConnectionGuard(dimension [, table settings])        |setCustomConnectionImage(imagePath) |
|setConnectionGuardEnabled(dimension, state)                |
|destroyConnectionGuard(dimension)                          |
|setConnectionGuardSetting(dimension, setting, mixed value) |
|getConnectionGuardSetting(dimension, setting)              |