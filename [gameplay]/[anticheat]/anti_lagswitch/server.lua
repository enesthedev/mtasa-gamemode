addEventHandler('onResourceStart', resourceRoot, function()
    return exports.conguard:createConnectionGuard(-1, {
        ['max_connection_timeout'] = 5000,
        ['max_interruptions_per_session'] = 5,
        ['disable_collisions'] = false,
        ['restore_position'] = true,
        ['kick_on_max_interruptions'] = true,
        ['kick_message'] = 'Bağlantı hatası'
      }
    )
  end
)