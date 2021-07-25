local specificClocks = {
  '22:50'
}

addEventHandler('onResourceStart', resourceRoot, function()
    local serverTime = os.date('*t')
    if not serverTime then
      return
    end

    setTime(serverTime.hour, serverTime.min)
    setMinuteDuration(10000)
  end
)

--- TODO: /changewater komutu eklenecek
--- TODO: /listwaters komutu eklenecek
--- TODO: permission sistem ile entegrasyonu yapılacak (acl.xml üzerinden)