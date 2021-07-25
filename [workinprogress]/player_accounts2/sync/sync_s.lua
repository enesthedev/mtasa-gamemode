--[[
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	[-------------------------------------------------]
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	
	Name: MTA-Communication-Enchantment
	Version: 1.0.1
	Author: IIYAMA
	Licence: https://gitlab.com/IIYAMA12/mta-communication-enchantment/blob/master/LICENSE
	
	File type: server
	
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	[-------------------------------------------------]
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
]]

local loadedPlayers = {
	object = {},
	array = {}
}

local c_functionsFireWall = true

-- Buffer these functions:
local tableRemove = table.remove


-- Keep track of loaded players.
addEvent("onClientReadyForCommunication", true)
addEventHandler("onClientReadyForCommunication", resourceRoot, function (player)
	if client == player and not loadedPlayers.object[client] then
		loadedPlayers.object[client] = true
		loadedPlayers.array[#loadedPlayers.array + 1] = client
		callClientAwaitBuffer:resumeMessagesForPlayer(client)
	end
end, false)




-- Clean-up when a player leaves.
addEventHandler("onPlayerQuit", root, 
function () 
	if loadedPlayers.object[source] then
		loadedPlayers.object[source] = nil
		
		local loadedPlayersFormatArray = loadedPlayers.array
		
		for i=1, #loadedPlayersFormatArray do
			if loadedPlayersFormatArray[i] == source then
				tableRemove(loadedPlayersFormatArray, i)
				break
			end
		end
	else
		callClientAwaitBuffer:removeAllMessagesForPlayer(source)
	end
end)





function callClient (target, clientCallbackFunctionName, ...)
	
	if not target or type(target) == "string" then
		outputIncorrectSyntax("No target defined (player/root/table)")
		return false
	end
	
	if clientCallbackFunctionName and type(clientCallbackFunctionName) == "string" then

		-- prepare the target and target count (the amount of players that need to receive the message)
		local targetCount = 0
		if target == root then
			target = loadedPlayers.array
			targetCount = #target
		elseif type(target) == "table" then
			
			-- remove all not loaded players
			for i=#target, 1, -1  do
				if not loadedPlayers.object[target[i]] then
					tableRemove(target, i)
				end
			end
			
			targetCount = #target
		elseif isElement(target) and getElementType(target) == "player" and loadedPlayers.object[target] then
			targetCount = 1		
		end
		
		if targetCount == 0 then
			target = nil
			return false
		end

		
		-- all arguments
		local arguments = {...}
		
		-- A list of arguments that are going to be used to send to the client. This will be filled in as soon as the existence of an serverCallback function has been checked.
		local communicationArguments = {}
		
		
		-- Check if there is an callback function inside of the arguments. This function will return the index of the callback function from the table: arguments.
		local serverCallbackFunctionIndex = findFunctionIndexInTable(arguments)
		
		-- This variable will be filled in when a callback function is used. It contains the index of the serverside arguments located in a table: nonCommunicationArguments.collection
		local serverCallbackArgumentsIndex = nil
		
		-- Is there a serverSide-Callback function found?
		if serverCallbackFunctionIndex then
			local serverCallbackFunction = arguments[serverCallbackFunctionIndex]
			
			
			-- separate the communication arguments
			for i= 1, serverCallbackFunctionIndex - 1 do
				communicationArguments[#communicationArguments + 1] = arguments[i]
			end
			
			
			-- Save the serverside-callback function and arguments
			serverCallbackArgumentsIndex = nonCommunicationArguments:add(targetCount, serverCallbackFunction, select(serverCallbackFunctionIndex + 1, ...))
		else
			-- no server callback function has been found. All arguments will be send to the client.
			communicationArguments = arguments
		end
		
		
		return triggerClientEvent(target, "onClientCommunication", resourceRoot, clientCallbackFunctionName, serverCallbackArgumentsIndex, unpack(communicationArguments))
	end
	outputIncorrectSyntax("No callback function defined (string)")
	return false
end
addToBlacklist(callClient)

callClientAwaitBuffer = {
	addMessage = function (self, targetAwait, ...)
		
		local collection = self.collection
		local collectionReference = self.collectionReference
		
		local index = self:newMessageIndex()
		
		local targetAwaitCheckList = {}
		for i=1, #targetAwait do
			
			local player = targetAwait[i]
			targetAwaitCheckList[player] = true
			
			-- Reference each player to the message
			local reference = collectionReference[player]
			if not reference then
				reference = {}
				collectionReference[player] = reference
			end
			reference[#reference + 1] = index
		end
		
		collection[index] = {checkList = targetAwaitCheckList, arguments = {...}}
		return index
	end,
	
	getMessageByIndex = function (self, index)
		return self.collection[index]
	end,
	
	getMessagesReferencesByPlayer = function (self, player)
		local reference = self.collectionReference[player]
		if reference then
			return reference
		end
		return false
	end,
	
	removeAllMessagesForPlayer = function (self, player)
		local reference = self:getMessagesReferencesByPlayer(player)
		if reference then
			for i=1, #reference do
				local index = reference[i]
			
				-- Check if the message doesn't have any other receiver
				local message = self:getMessageByIndex(index)
				if message then
					local checkList = message.checkList
					checkList[player] = nil
					
					if not next(checkList) then
						self:removeMessage(index)
					end
				end
			end
			
			-- remove the reference table
			self.collectionReference[player] = nil
		end
	end,
	
	messageHasBeenDeliveredOrCancelledForPlayer = function (self, index, player)
		local reference = self:getMessagesReferencesByPlayer(player)
		if reference then
			for i=1, #reference do
				if reference[i] == index then
					
					-- Check if the message doesn't have any other receiver
					local message = self:getMessageByIndex(index)
					if message then
						local checkList = message.checkList
						checkList[player] = nil
						
						if not next(checkList) then
							self:removeMessage(index, false)
						end
					end
					
					tableRemove(reference, i)
					
					-- remove the reference table if there are no references
					if #reference == 0 then
						self.collectionReference[player] = nil
					end
					
					return true
				end
			end
		end
		return false
	end,
	
	removeMessage = function (self, index, deletePlayerReference)
		local collection = self.collection
		if collection[index] ~= nil then
			collection[index] = nil
			
			if deletePlayerReference then
				self:deletePlayerReferenceByMessageIndex(index)
			end
			
			return true
		end
		return false
	end,
	
	deletePlayerReferenceByMessageIndex = function (self, index)
		local collectionReference = self.collectionReference
		for player, reference in pairs(collectionReference) do
			if reference then
				for i=1, #reference do
					if reference[i] == index then
						tableRemove(reference, i)
						if #reference == 0 then
							collectionReference[player] = nil 
						end
						break
					end
				end
			end
		end
	end,
	
	clearBufferIfMessageIsEmpty = function (self, index, player)
		local message = self:getMessageByIndex(index)
		if message then
			local checkList = message.checkList
			if checkList then
				checkList[player] = nil
				if not next(checkList) then
					self:removeMessage(index, false)
					return true
				end
			end
		end
		return false
	end,
	
	newMessageIndex = function (self)
		local index = self.index + 1
		self.index = index
		return index
	end,
	
	resumeMessagesForPlayer = function (self, player)
		local reference = self:getMessagesReferencesByPlayer(player)
		if reference then
			for i=1, #reference do
				local index = reference[i]
				local message = self:getMessageByIndex(index)
				callClient(player, unpack(message.arguments))
			end
			self:removeAllMessagesForPlayer(player)
		end
	end,
	
	collection = {},
	collectionReference = {},
	index = 0
}


function callClientAwait (target, clientCallbackFunctionName, ...)
	if clientCallbackFunctionName and type(clientCallbackFunctionName) == "string" then
		
		
		-- Split the loaded players from the unloaded players
		local targetDirect = {} -- Loaded players
		local targetAwait = {} -- Unloaded players
		
		if target == root then
			target = getElementsByType("player")
			
			for i=#target, 1, -1  do
				local player = target[i]
				if not loadedPlayers.object[player] then
					targetAwait[#targetAwait + 1] = player
				end
			end
			
			targetDirect = loadedPlayers.array
		elseif type(target) == "table" then
			
			for i=#target, 1, -1  do
				local player = target[i]
				if isElement(player) and getElementType(player) == "player" then
					if loadedPlayers.object[player] then
						targetDirect[#targetDirect + 1] = player
					else
						targetAwait[#targetAwait + 1] = player
					end
				end
			end
			
		elseif isElement(target) and getElementType(target) == "player" then
			local player = target
			if loadedPlayers.object[player] then
				targetDirect[#targetDirect + 1] = player
			else 
				targetAwait[#targetAwait + 1] = player
			end
		end
		
		
		
		if #targetDirect ~= 0 then
			callClient(targetDirect, clientCallbackFunctionName, ...)
		end
		
		if #targetAwait ~= 0 then
			return true, callClientAwaitBuffer:addMessage(targetAwait, clientCallbackFunctionName, ...)
		end
		
		return true, false
	end
	outputIncorrectSyntax("No callback function defined (string)", 2)
	return false, false
end
addToBlacklist(callClientAwait)

function communicateAwaitStop (index)
	index = tonumber(index)
	if index and type(index) == "number" then
		return callClientAwaitBuffer:removeMessage(index, true)
	end
	outputIncorrectSyntax("No index defined (number)", 2)
	return false
end
addToBlacklist(communicateAwaitStop)


addEvent("onServerCommunication", true)
addEventHandler("onServerCommunication", resourceRoot, 
function (callbackFunctionName, clientCallbackArgumentsIndex, ...)
	
	
	local callbackFunction = _G[callbackFunctionName]
	
	local isFunctionCallAllowed = true
	
	-- Firewall to prevent the client to be able to call C/MTA functions.
	if c_functionsFireWall then
		if debug.getinfo(callbackFunction).what ~= "Lua" then
			outputDebugString("Player: " .. tostring(getPlayerName(client)) .. ", tried to call a not lua function. [BLOCKING REQUEST]", 0, 0, 0, 255)
			isFunctionCallAllowed = false
		end
	end
	
	local callbackResult
	
	if isFunctionCallAllowed and type(callbackFunction) == "function" and not isInBlacklist(callbackFunction, callbackFunctionName) and (not isWhitelistEnabled() or isInWhitelist(callbackFunction)) then
		callbackResult = {secureCall(callbackFunction, ...)}
	end
	
	
	if clientCallbackArgumentsIndex and type(clientCallbackArgumentsIndex) == "number" then
		-- Make it possible to use async here.
		
		local target = client
		if isElement(target) then -- Is the player still ingame (keep supporting older versions)
			if callbackResult and type(callbackResult[1]) == "table" and callbackResult[1].type == "callback_" then
				
				setCallbackTarget(callbackResult[1], function  (...)
					if isElement(target) then
						triggerClientEvent(target, "onClientCommunicationCallback", resourceRoot, clientCallbackArgumentsIndex, {...})
					end
				end)
			else
				triggerClientEvent(target, "onClientCommunicationCallback", resourceRoot, clientCallbackArgumentsIndex, callbackResult)
			end
		end
	end
end, false)

addEvent("onServerCommunicationCallback", true)
addEventHandler("onServerCommunicationCallback", resourceRoot, 
function (callbackArgumentsIndex, callbackResult)
	if not callbackResult then
		callbackResult = {}
	end
	nonCommunicationArguments:callback(callbackArgumentsIndex, callbackResult)
end, false)



function callRemoteClient (target, await, clientCallbackFunctionAdded, ...)
	if isElement(target) and getElementType(target) == "player" then
		local communicationFunction = (await and callClientAwait or callClient)
		if clientCallbackFunctionAdded then
			
			local arguments = {...}
			
			local callbackFunction, callbackContainer = createCallback()
			
			
			arguments[#arguments + 1] = callbackFunction
			
			communicationFunction(target, "onRemoteClientCall", unpack(arguments))
			
			
			return callbackContainer
		else
			return communicationFunction(target, "onRemoteClientCall", ...)
		end
	end
end
addToWhitelist(callRemoteClient)
