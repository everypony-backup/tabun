###*
# Методы таймера например, запуск функции через интервал
###

timers = {}

module.exports = 
  run: (fMethod, sUniqKey, aParams, iTime) ->
    iTime = iTime or 1500
    aParams = aParams or []
    sUniqKey = sUniqKey or Math.random()

    if timers[sUniqKey]
      clearTimeout timers[sUniqKey]
      timers[sUniqKey] = null

    timeout = setTimeout(
      =>
        clearTimeout timers[sUniqKey]
        timers[sUniqKey] = null
        fMethod.apply this, aParams
      iTime
    )
    timers[sUniqKey] = timeout
