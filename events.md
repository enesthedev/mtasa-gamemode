# List of events on RPG server

### server_maps
|CLIENT                         |SERVER                       |
|-------------------------------|-----------------------------|
|setLODsClient                  | requestLODsClient           |

### weathercycle
|CLIENT                         |SERVER                       |
|-------------------------------|-----------------------------|
|onClientMaximapToggle          | onRequestWeathers           |
|onClientCityChanged            |
|onClientRequestWeather         |

### dx_maxmap
|CLIENT                         |
|-------------------------------|
|onClientMaximapToggle          |

### water_to_road
|CLIENT                         |
|-------------------------------|
|onClientWaterProtectionChange  |

### ndx_scoreboard
|CLIENT                         |
|-------------------------------|
|onClientDXScoreboardToggle     |

### accounts
|SERVER                         |
|-------------------------------|
|onPlayerResolutionLow          |

### player_greenzones
|CLIENT                         |
|-------------------------------|
|onClientEnterGreenzone         |
|onClientLeaveGreenzone         |

### dynamicfps
|CLIENT                         |
|-------------------------------|
|onClientFPSHigh                |
|onClientFPSLow                 |

### player_payday
|CLIENT                         |
|-------------------------------|
|onClientPayday                 |

### conguard
|SERVER                                     |
|-------------------------------------------|
|onPlayerNetworkTimeout                     |
|onPlayerNetworkInterruptionLimitReached    |
