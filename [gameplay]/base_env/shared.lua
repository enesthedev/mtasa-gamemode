local env = {
  server = {
    name = 'Multi Theft Auto: Türkiye',
    tag = 'MTT',
    gamemode = 'San Andreas'
  }
}

function get(envKey)
  return env[envKey]
end

function set(envKey, envValue)
  env[envKey] = envValue
end