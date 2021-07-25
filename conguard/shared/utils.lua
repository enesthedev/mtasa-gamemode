DEBUG = false

function iprintd(...)
	if(DEBUG) then
		return iprint(...)
	end
	return false
end
