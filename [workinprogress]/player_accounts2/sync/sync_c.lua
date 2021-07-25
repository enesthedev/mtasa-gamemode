--[[
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	[-------------------------------------------------]
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	
	Name: MTA-Communication-Enchantment
	Version: 1.0.1
	Author: IIYAMA
	Licence: https://gitlab.com/IIYAMA12/mta-communication-enchantment/blob/master/LICENSE
	
	File type: client
	
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	[-------------------------------------------------]
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
]]

function readyForCommunication ()
	
	-- I am ready!
	triggerServerEvent("onClientReadyForCommunication", resourceRoot, localPlayer)
	
	-- clean-up
	removeEventHandler("onClientResourceStart", resourceRoot, readyForCommunication)
	readyForCommunication = nil
end
addEventHandler("onClientResourceStart", resourceRoot, readyForCommunication)



addEvent("onClientCommunication", true)
addEventHandler("onClientCommunication", resourceRoot, 
	function (callbackFunctionName, serverCallbackArgumentsIndex, ...) 
	local callbackResult
	
	-- check and call the function
	local callbackFunction = _G[callbackFunctionName]
	if type(callbackFunction) == "function" and not isInBlacklist(callbackFunction, callbackFunctionName) and (not isWhitelistEnabled() or isInWhitelist(callbackFunction)) then
		callbackResult = {secureCall(callbackFunction, ...)}
	end
	

	-- Do we need to call back?
	if serverCallbackArgumentsIndex and type(serverCallbackArgumentsIndex) == "number" then
		
		-- Make it possible to use async here.
		if callbackResult and type(callbackResult[1]) == "table" and callbackResult[1].type == "callback_" then
			setCallbackTarget(callbackResult[1], function  (...)
				triggerServerEvent("onServerCommunicationCallback", resourceRoot, serverCallbackArgumentsIndex, {...})
			end)
		else
			
			triggerServerEvent("onServerCommunicationCallback", resourceRoot, serverCallbackArgumentsIndex, callbackResult)
		end
	end
end, false)

addEvent("onClientCommunicationCallback", true)
addEventHandler("onClientCommunicationCallback", resourceRoot, 
function (callbackArgumentsIndex, callbackResult)
	if not callbackResult then
		callbackResult = {}
	end
	nonCommunicationArguments:callback(callbackArgumentsIndex, callbackResult)
end)


function callServer(serverCallbackFunctionName, ...)
	if serverCallbackFunctionName and type(serverCallbackFunctionName) == "string" then
		-- all arguments
		local arguments = {...}
		
		-- A list of arguments that are going to be used to send to the server. This will be filled in as soon as the existence of an serverCallback function has been checked.
		local communicationArguments = {}
		
		-- Check if there is an callback function inside of the arguments. This function will return the index of the callback function from the table: arguments.
		local clientCallbackFunctionIndex = findFunctionIndexInTable(arguments)
		
		-- This variable will be filled in when a callback function is used. It contains the index of the clientside arguments located in a table: nonCommunicationArguments.collection
		local clientCallbackArgumentsIndex = nil
		
		-- Is there a clientside-Callback function found?
		if clientCallbackFunctionIndex then
			local clientCallbackFunction = arguments[clientCallbackFunctionIndex]
			
			-- separate the communication arguments
			for i= 1, clientCallbackFunctionIndex - 1 do
				communicationArguments[#communicationArguments + 1] = arguments[i]		
			end
			
			
			-- Save the clientside-callback function and arguments
			clientCallbackArgumentsIndex = nonCommunicationArguments:add(nil, clientCallbackFunction, select(clientCallbackFunctionIndex + 1, ...))
		else
			-- no server callback function has been found. All arguments will be send to the server.
			communicationArguments = arguments
		end
		
		return triggerServerEvent("onServerCommunication", resourceRoot, serverCallbackFunctionName, clientCallbackArgumentsIndex, unpack(communicationArguments))
	end
	outputIncorrectSyntax("No callback function defined (string)")
	return false
end
addToBlacklist(callServer)

do
	local callRemoteClient_ = function  (await, target, clientCallbackFunctionName, ...)
		if not target or type(target) == "string" then
			outputIncorrectSyntax("No target defined (player)")
			return false
		elseif not isElement(target) or getElementType(target) ~= "player"  then
			outputIncorrectSyntax("No target is not a player.")
			return false		
		end
		
		if not clientCallbackFunctionName or type(clientCallbackFunctionName) ~= "string" then
			outputIncorrectSyntax("No callback function defined (string)")
			return false
		end
		
		
		local clientCallbackFunctionAdded = findFunctionIndexInTable({...}) ~=  false

		callServer("callRemoteClient", target, await, clientCallbackFunctionAdded, clientCallbackFunctionName,  ...)
	end
	
	function callRemoteClient (...)
		callRemoteClient_(false, ...)
	end
	addToBlacklist(callRemoteClient)
	
	function callRemoteClientAwait (...)
		callRemoteClient_(true, ...)
	end
	addToBlacklist(callRemoteClientAwait)
end

do
	local remoteClientAccessPoints = {
		add = function (self, thisFunction)
			self.collection[thisFunction] = true
			return true
		end,
		remove = function (self, thisFunction)
			self.collection[thisFunction] = nil
			return true
		end,
		check = function (self, thisFunction)
			return self.collection[thisFunction]
		end,
		collection = {}
	}
	
	function addRemoteClientAccessPoint (thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return remoteClientAccessPoints:add(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(addRemoteClientAccessPoint)
	
	
	function removeRemoteClientAccessPoint (thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return remoteClientAccessPoints:add(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(removeRemoteClientAccessPoint)
	
	function isInRemoteClientAccessPoint (thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return remoteClientAccessPoints:check(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(isInRemoteClientAccessPoint)
	
	function onRemoteClientCall (callbackFunctionName, ...)
		
		local callbackFunction = _G[callbackFunctionName]
		if type(callbackFunction) ~= "function" or not isInRemoteClientAccessPoint(callbackFunction) then
			return
		end
		
		return secureCall(callbackFunction, ...)
	end
	addToWhitelist(onRemoteClientCall)
end