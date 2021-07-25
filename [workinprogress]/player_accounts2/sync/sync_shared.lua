--[[
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	[-------------------------------------------------]
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	
	Name: MTA-Communication-Enchantment
	Version: 1.0.1
	Author: IIYAMA
	Licence: https://gitlab.com/IIYAMA12/mta-communication-enchantment/blob/master/LICENSE
	
	File type: shared (client + server)
	
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
	[-------------------------------------------------]
	[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]
]]



--[[
	
	Configuration START
	
]]


local functionWhitelistState = false

local secureCallStatus = false



--[[
	
	Configuration END
	
]]





--[[
	-- Optimized variables
]]
local tableRemove = table.remove
local unpack = unpack
local setTimer = setTimer 
local removeEventHandler = removeEventHandler
local addEventHandler = addEventHandler
local killTimer = killTimer
	
	
--[[
	-- Blacklist
	[*] This list is used to block calls to specific functions, with the communication functions.
]]	

do
	local functionBlacklist = {
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
		collection = {},
		state = functionWhitelistState
	}
	
	function addToBlacklist(thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return functionBlacklist:add(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(addToBlacklist)
	
	function isInBlacklist (thisFunction, functionName)
		if thisFunction and type(thisFunction) == "function" then
			local state = functionBlacklist:check(thisFunction)
			if state then
				outputDebugString ("A blacklisted function call has been BLOCKED." .. (functionName and " Function name: " .. tostring(functionName) or "") , 1 )             
			end
			return state
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(isInBlacklist)
	
end




--[[
	-- Whitelist
]]

do
	local functionWhitelist = {
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
		collection = {},
		state = functionWhitelistState
	}

	--[[
		-- Whitelist functions
	]]
	function addToWhitelist(thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return functionWhitelist:add(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(addToWhitelist)

	function removeFromWhitelist (thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return functionWhitelist:add(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end
	addToBlacklist(removeFromWhitelist)

	function isInWhitelist (thisFunction)
		if thisFunction and type(thisFunction) == "function" then
			return functionWhitelist:check(thisFunction)
		end
		outputIncorrectSyntax("No function defined at argument 1.", 2)
		return false
	end 
	addToBlacklist(isInWhitelist)

	function isWhitelistEnabled ()
		return functionWhitelist.state
	end
	addToBlacklist(isWhitelistEnabled)

end


--[[
	-- This is a shared file, which needs to know if itself is a serverside file or a clientside file.
]]
local serverSide = triggerClientEvent and true or false


--[[
	-- errors can stop your code, but also this code. Sometimes we do not want to stop this code, because it is important.
]]
function secureCall (theFunction, ...)
	if secureCallStatus then -- enabled ?
		local result = {pcall(theFunction, ...)}
		if result[1] then
			tableRemove(result, 1)
			return unpack (result)
		else
			outputDebugString(result[2], 2)
			return
		end
	else
		return theFunction(...)
	end
end


--[[ 
	This function is for arguments that are used in the callbacks, but which are not send to the clients. 
	[*] This will allow you to maintain original data while doing your callbacks: Functions, tables, meta-tables, timers etc.
]]
nonCommunicationArguments = {
	add = function (self, targetCount, callbackFunction,  ...) 
		
		local index = self:newIndex()
		
		self.collection[index] = {index = index, creationTime = getTickCount(), targetCount = targetCount, callbackFunction = callbackFunction,  ...}
		return index
	end,
	get = function (self, index)
		return self.collection[index]
	end,
	newIndex = function (self)
		local index = self.index + 1
		self.index = index
		return index
	end,
	callback = function (self, index, clientCallbackArguments)
		local collection = self.collection
		if collection[index] then
			local arguments = collection[index]
			
			if type(arguments.callbackFunction) == "function" then
				if #clientCallbackArguments > 0 then
					for i=1, #clientCallbackArguments do
						arguments[#arguments + 1] = clientCallbackArguments[i]
					end
				end

				arguments.callbackFunction(unpack(arguments))
			end
			
			if serverSide then
				arguments.targetCount = arguments.targetCount - 1

				if arguments.targetCount == 0 then
					self:remove(index)
				end
			else
				self:remove(index)
			end
		end
		return false
	end,
	remove = function (self, index)
		
		local collection = self.collection
		if collection[index] then
			collection[index] = nil
			return true
		end
		return false
	end,
	collection = {},
	index = 0
}

--[[
	-- Search for the first function inside of a table and return it's index
]]
function findFunctionIndexInTable (thisTable)
	if thisTable and type(thisTable) == "table" then
		for i=1, #thisTable do
			if type(thisTable[i]) == "function" then
				return i
			end
		end
	end
	return false
end


setTimer(function ()
	
	--[[
		-- Clean up lost messages data (we do not want a memory leak)
	]]
	local collection = nonCommunicationArguments.collection
	local timeNow = getTickCount()
	for index, value in pairs(collection) do
		if timeNow - value.creationTime > 10 * 60 * 1000 then -- 10 min delay, before the data is considered invalid and deleted.
			collection[index] = nil
		end
	end
	
	--[[
		-- Clean up old/dead callbacks.
	]]
	cleanUpDeadCallbacks()
	
end, 30 * 60 * 1000, 0) -- 30 min timer


--[[
	-- Debug tools.
]]
do
	local debugGetinfo = debug.getinfo
	
	local stringFormat = string.format
	
	
	function getCalledFrom ()
		local info = debugGetinfo(3, "Sl")
		if info and info.what ~= "C" then
			local lineNumber = info.currentline
			if type(lineNumber) == "number" then
				return "Called From: " .. tostring(stringFormat("[%s]:%d", info.short_src, info.currentline))
			end
		end
		return ""
	end
	
	function outputIncorrectSyntax (content)
		local info = debugGetinfo(3, "Sl")
		if info and info.what ~= "C" then
			local lineNumber = info.currentline
			if type(lineNumber) == "number" then
				content = tostring(content or "")
				return outputDebugString (">->->->[SYNTAX ERROR]: " .. content .. "---> called from:" .. tostring(stringFormat("[%s]:%d", info.short_src, info.currentline)), 0, 255, 80, 0)   
			end
		end
	end
end


--[[
	-- callback functionalities
]]
do
	local callbackIdentifier = "callback_"
	
	local callback
	callback = {
		create = function (self)
			local collection = self.collection
			
			local callbackContainer 
			callbackContainer = {
				type = callbackIdentifier,
				enabled = true,
				trigger = function  (...)
					-- In case the function is re-used, add a block/stop
					if not callbackContainer.enabled then
						return false
					end
					callbackContainer.enabled = nil
					
					
					if callbackContainer.target then
						
						secureCall(callbackContainer.target, ...)
						self:destroy(callbackContainer)
					else -- if there is no target yet, wait for x ms, just in case. You never know when you forget to use an async method.
						
						
						callNextFrame(function (...)
							if callbackContainer.target then
								secureCall(callbackContainer.target, ...)
							end
							self:destroy(callbackContainer)
						end, ...)
						
					end
				end,
				target = nil,
				creationTime = getTickCount()
			}

			collection[callbackContainer.trigger] = callbackContainer
			return callbackContainer.trigger, callbackContainer
		end,
		destroy = function (self, callbackContainer)
			self.collection[callbackContainer.trigger] = nil
			
			-- Making sure that the object is not holding any content after it is destroyed. Making things un-accessible in Lua is the only way to clean them.
			for key,_ in pairs (callbackContainer) do
				if key ~= "type" then
					callbackContainer[key] = nil
				end
			end
		
			return true
		end,
		setTarget = function (self, callbackContainer, target)
			callbackContainer.target = target
			return true
		end,
		collection = {}
	}
	
	--------------
	-- exposure --
	
	function createCallback ()
		return callback:create()
	end
	
	function setCallbackTarget (callbackContainer, target)
		if not callbackContainer or type(callbackContainer) ~= "table" or callbackContainer.type ~= callbackIdentifier then
			outputIncorrectSyntax("No callbackContainer defined at argument 1.")
			return false
		end
		if not target or type(target) ~= "function" then
			outputIncorrectSyntax("No function defined at argument 2.")
			return false
		end
		return callback:setTarget(callbackContainer, target)
	end
	
	function destroyCallback (callbackContainer)
		if not callbackContainer or type(callbackContainer) ~= "table" or callbackContainer.type ~= callbackIdentifier then
			outputIncorrectSyntax("No callbackContainer defined at argument 1.")
			return false
		end
		return callback:destroy(callbackContainer)
	end
	
	function cleanUpDeadCallbacks ()
		local collection = callback.collection
		local timeNow = getTickCount()
		local lifeTime = 30 * 60 * 1000
		for key, callbackContainer in pairs(collection) do
			if timeNow > callbackContainer.creationTime + lifeTime then
				callback:destroy(callbackContainer)
			end
		end
	end
end


--[[
	-- callNextFrame function
]]
do
	
	local nextFrameCalls = {}
	
	local serverSideTimer
	

	local processing = false
	
	local function process ()
		
		--[[ 
			Do an empty check at the beginning of the function, this will make sure to make an extra run in case of heavy work load. 
			If the timer is killed or the addEventHandler is removed, then this has to be re-attached again every frame. This is not very healthy...
		]]
		
		if #nextFrameCalls == 0 then
			if serverSide then
				if serverSideTimer then
					
					if isTimer(serverSideTimer) then
						killTimer(serverSideTimer)
					end
					serverSideTimer = nil
					
				end
			else
				removeEventHandler("onClientRender", root, process)
			end
			
			processing = false
			return
		end
		
		
		-- In case of calling the function callNextFrame within the process, the loop type `repeat until` is required.
		repeat
			local item = nextFrameCalls[1]
			item.callback(unpack(item.content))
			tableRemove(nextFrameCalls, 1)
		until #nextFrameCalls == 0

	end
	
	
	
	function callNextFrame (callback, ...)
		if type(callback) == "function" then
			local newIndex = #nextFrameCalls + 1
			nextFrameCalls[newIndex] = {callback = callback, content = {...}}
			if not processing then
				if serverSide then
					serverSideTimer = setTimer(process, 50, 0)
				else
					addEventHandler("onClientRender", root, process)
				end
				processing = true
			end
			return true
		end
		return false
	end
end