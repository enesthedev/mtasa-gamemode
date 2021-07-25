local accountsCache = {}

function get(theAccount, theKey, defaultValue)
  local accountDump = accountsCache[theAccount]

  if not accountDump then
    accountsCache[theAccount] = {}
    accountDump = accountsCache[theAccount]
  end

  accountDump[theKey] = accountDump[theKey] or getAccountData(theAccount, theKey)
  accountsCache[theAccount] = accountDump

  return accountDump[theKey] or defaultValue
end

function set(theAccount, theKey, theValue)
  local accountDump = accountsCache[theAccount] or {}

  accountDump[theKey] = theValue
  accountsCache[theAccount] = accountDump

  setAccountData(theAccount, theKey, theValue)
end