local screenWidth, screenHeight = guiGetScreenSize()
local scale = math.max((screenHeight / 1080), 0.65)

local fadeWindows = {}
local credentials = {}
local hoverElements = {}
local attempts = 1
local states = {}

local spawnAreaSelectMatrix = { -1169.7003173828, 739.37286376953, 116.03268432617, -1264.3681640625, 771.38189697266, 119.69632720947 }

local dumpedFunctions = false
local nextNotification = false

local currentPage = 1
local inputMinLength = 3
local inputMaxLength = 25

local backgroundMusic;

function guiSetScale(guiElement, font, fontSize)
	local guiX, guiY = guiGetPosition(guiElement, false)
	local guiWidth, guiHeight = guiGetSize(guiElement, false)
	local guiFont = guiCreateFont(string.format(':dx_fonts/%s.ttf', font or 'default'), scale * (fontSize or 13))

	guiSetSize(guiElement, guiWidth * scale, guiHeight * scale, false)
	guiSetPosition(guiElement, guiX * scale, guiY * scale, false)
	guiSetFont(guiElement, guiFont)
end

function guiCenterWindow(guiWindow)
	local guiWidth, guiHeight = guiGetSize(guiWindow, false)

	guiSetPosition(guiWindow, screenWidth / 2 - guiWidth / 2, screenHeight / 2 - guiHeight / 2, false)
end


function guiCreateInputDialog(title, fontSize, masked, pattern)
	local wnd = guiCreateStaticImage(0, 0, 430, 200, 'media/transparent.png', false)
	if not wnd then
		return false
	end

	local titl = guiCreateLabel(0, 15, 430, 30, title, false, wnd)
	if not titl then
		return false
	end

	local edt = guiCreateEdit(20, 45, 390, 29, '', false, wnd)
	if not edt then
		return false
	end

	guiEditSetMasked(edt, masked or false)
	guiSetScale(edt, 'default-bold', 10)

	guiLabelSetHorizontalAlign(titl, 'center')
	guiSetScale(titl, 'default-bold', fontSize or 12)

	guiSetProperty(wnd, 'TitlebarEnabled', 'false')
	guiSetProperty(wnd, 'FrameEnabled', 'false')
	guiSetProperty(wnd, 'DragMovingEnabled', 'false')
	guiSetProperty(wnd, 'CloseButtonEnabled', 'false')

	guiSetVisible(wnd, false)
	guiSetScale(wnd)
	guiCenterWindow(wnd)

	guiSetInputMode('no_binds_when_editing')
	guiSetInputEnabled(true)

	return wnd, edt, titl
end

function guiSetAnimState(guiElement, state)
	states[guiElement] = state
	return true
end

function guiGetAnimState(guiElement)
	return states[guiElement]
end

function guiSetHover(guiElement, enterFunction, outFunction)
	hoverElements[guiElement] = { enterFunction, outFunction }
end

function guiRestoreLabel(guiElement)
	guiSetVisible(guiElement, true)
	guiLabelSetColor(guiElement, 255, 255, 255)
end

function guiRestoreEdit(guiElement, placeholderText, masked)
	guiSetText(guiElement, placeholderText or '')
	guiEditSetCaretIndex (guiElement, string.len(guiGetText(guiElement)))
	guiSetEnabled(guiElement, true)
	guiEditSetMasked(guiElement, masked or false)
	guiBlur(guiElement)
	guiFocus(guiElement)

	return true
end

function guiCreateImageButton(guiX, guiY, guiWidth, guiHeight, path, relative, parent, onClick)
	local img = guiCreateStaticImage(guiX, guiY, guiWidth, guiHeight, path, relative, parent)
	guiSetProperty(img, 'RiseOnClick', 'false')

	if img then
		if onClick then
			addEventHandler('onClientGUIClick', img, onClick, false)
		end
		return img
	end
	return false
end

function guiCreateLoginError(guiMessage, guiEdit, invisibleElements, callbackInterval, callbackFunction)
	for i = 1, table.maxn(invisibleElements) do
		guiSetVisible(invisibleElements[i], false)
	end

	guiEditSetCaretIndex(guiEdit, 0)
	guiSetText(guiEdit, guiMessage)
	guiEditSetMasked(guiEdit, false)

	if callbackFunction then
		setTimer(callbackFunction, callbackInterval or 2000, 1)
	end
end

function setPlayerRandomWorldPosition(thePlayer, callback)
	local worldSeed = math.randomseed(os.time())
	local worldX, worldY = math.random(-3000, 3000), math.random(-3000, 3000)
	local worldZLimit = 25

	if not testLineAgainstWater(worldX, worldY, worldZLimit, worldX, worldY, -1) then
		return callServer('spawnPlayerAt', worldX, worldY, callback or false)
	end
	return setPlayerRandomWorldPosition(thePlayer, callback)
end

function guiCreateLoginPane()
	local usernameWnd, usernameEdt = guiCreateInputDialog('Oyun içi adın ne olsun?', 10)
	local passwordWnd, passwordEdt, passwordTitl = guiCreateInputDialog('Şifreni rica edebilir miyim?', 10, true)

	local usernameWndWidth, usernameWndHeight = guiGetSize(usernameWnd, false)
	local usernameEdtWidth, usernameEdtHeight = guiGetSize(usernameEdt, false)

	local usernameInfo = guiCreateLabel(0, 0, 0, 0, '', false, usernameWnd)
	local usernameInfoFont = guiCreateFont(string.format(':dx_fonts/%s.ttf', 'default-bold'), scale * 9)

	addEventHandler('onClientGUIClick', usernameWnd, function()
			if guiGetEnabled(usernameEdt) then
				guiBlur(usernameEdt)
				guiFocus(usernameEdt)
			end
		end
	)

	local usernameEdtInfo = guiCreateImageButton(usernameEdtWidth - scale * 49, scale * 4, scale * 22, scale * 22, 'media/question.png', false, usernameEdt)

	local usernameEdtNext = guiCreateImageButton(usernameEdtWidth - scale * 26, scale * 4, scale * 22, scale * 22, 'media/next.png', false, usernameEdt, function()
			guiBlur(usernameEdt)
			guiSetEnabled(usernameEdt, false)

			local usernameText = guiGetText(usernameEdt)
			local usernameLength = string.len(usernameText)

			if usernameLength <= inputMinLength then
				return guiCreateLoginError('Kullanıcı adınız ' .. inputMinLength .. ' karakterden çok olmalı', usernameEdt, { usernameInfo }, 1500, function()
						guiRestoreEdit(usernameEdt, usernameText)
						guiRestoreLabel(usernameInfo)
					end
				)
			end

			if usernameLength >= inputMaxLength then
				return guiCreateLoginError('Kullanıcı adınız ' .. inputMaxLength .. ' karakterden az olmalı', usernameEdt, { usernameInfo }, 1500, function()
						guiRestoreEdit(usernameEdt, usernameText)
						guiRestoreLabel(usernameInfo)
					end
				)
			end

			table.insert(fadeWindows, { 'out', usernameWnd, 2, function(guiElement)
						guiBlur(usernameWnd)
						guiSetVisible(usernameWnd, false)
						guiSetText(passwordTitl, '"' .. usernameText .. '" için bir şifre girmelisin')
						guiSetVisible(passwordWnd, true)
						guiSetEnabled(passwordEdt, false)
						guiSetAlpha(passwordWnd, 0)

						table.insert(fadeWindows, { 'in', passwordWnd, 1, function(guiElement)
									guiSetEnabled(passwordEdt, true)
									guiBlur(passwordEdt)
									guiFocus(passwordEdt)
								end
							}
						)
					end
				}
			)
		end
	)

	local passwordEdtNext = guiCreateImageButton(usernameEdtWidth - scale * 26, scale * 4, scale * 22, scale * 22, 'media/next.png', false, passwordEdt, function()
			guiBlur(passwordEdt)
			guiSetEnabled(passwordEdt, false)

			local passwordText = guiGetText(passwordEdt)
			local passwordLength = string.len(passwordText)

			if passwordLength <= inputMinLength then
				return guiCreateLoginError('Şifreniz ' .. inputMinLength .. ' karakterden çok olmalı', passwordEdt, { }, 1500, function()
						return guiRestoreEdit(passwordEdt, passwordText, true)
					end
				)
			end

			if passwordLength >= inputMaxLength then
				return guiCreateLoginError('Şifreniz ' .. inputMaxLength .. ' karakterden az olmalı', passwordEdt, { }, 1500, function()
						return guiRestoreEdit(passwordEdt, passwordText, true)
					end
				)
			end

			if attempts >= 3 then
				return guiCreateLoginError('Çok fazla yanlış deneme yaptınız, biraz bekleyin', passwordEdt, { }, 1500, function()
						return guiRestoreEdit(passwordEdt, passwordText, true)
					end
				)
			end

			callServer('loginPlayer', guiGetText(usernameEdt), guiGetText(passwordEdt), function(state)
					if not state then
						attempts = attempts + 1
						setTimer(function()
								attempts = attempts - 1
							end, 10000, 1
						)
						return guiCreateLoginError('Yanlış şifre girdiniz, lütfen tekrar deneyin!', passwordEdt, { }, 1500, function()
								return guiRestoreEdit(passwordEdt, passwordText, true)
							end
						)
					end

					guiSetInputEnabled(false)

					table.insert(fadeWindows, { 'out', passwordWnd, 2, function(guiElement)
								destroyElement(passwordWnd)
								destroyElement(usernameWnd)

								setPlayerRandomWorldPosition(localPlayer, function(state)
										if not state then
											return false
										end

										setCameraTarget(localPlayer, localPlayer)

										setElementData(localPlayer, 'player.chatbox', true, false)

										if backgroundMusic then
											stopSound(backgroundMusic)
										end

										fadeCamera(false)
										fadeCamera(true)
									end
								)
							end
						}
					)
				end
			)
		end
	)

	local passwordEdtBack = guiCreateImageButton(usernameEdtWidth - scale * (24.5 * 2), scale * 4, scale * 22, scale * 22, 'media/previous.png', false, passwordEdt, function()
			guiBlur(passwordEdt)
			guiSetEnabled(passwordEdt, false)

			table.insert(fadeWindows, { 'out', passwordWnd, 2, function(guiElement)
						guiSetVisible(passwordWnd, false)
						guiSetVisible(usernameWnd, true)
						guiSetAlpha(usernameWnd, 0)

						table.insert(fadeWindows, { 'in', usernameWnd, 1, function(guiElement)
									guiSetEnabled(usernameEdt, true)
									guiFocus(usernameEdt)
								end
							}
						)
					end
				}
			)
		end
	)

	local passwordEdtInfo = guiCreateImageButton(usernameEdtWidth - scale * (24.5 * 3), scale * 4, scale * 22, scale * 22, 'media/question.png', false, passwordEdt)


	setElementData(usernameEdtNext, 'tooltip-text', 'Şifre aşamasına geçmek için tıkla')
	setElementData(usernameEdtInfo, 'tooltip-text', 'Kendine göre bir oyun içi ad belirlediysen ilerlemek için sol taraftaki ok tuşunu kullanabilirsin. Yazı yazamıyorsan endişelenmene gerek yok, bu sadece basit bir spam engeli. Ekranda boş bir yere tıkla ve ardından yazı yazma yerine tekrardan tıkla.')

	setElementData(passwordEdtNext, 'tooltip-text', 'Giriş yapmak için tıkla')
	setElementData(passwordEdtBack, 'tooltip-text', 'Oyun içi adı seçmek için geri gel')
	setElementData(passwordEdtInfo, 'tooltip-text', 'Şifreni unuttuysan F3 tuşuna basarak bizlere kullanıcı adın ve şifren ile alakalı rapor oluşturup sana ulaşmamızı sağlayabilirsiniz, ya da Discord adresimize gelip durumu anlatabilirsin.')

	guiEditSetMaxLength(passwordEdt, inputMaxLength)
	guiEditSetMaxLength(usernameEdt, inputMaxLength)

	guiLabelSetHorizontalAlign(usernameInfo, 'center')
	guiLabelSetVerticalAlign(usernameInfo, 'center')

	guiSetFont(usernameInfo, usernameInfoFont)

	guiSetAnimState(usernameInfo, false)

	guiSetAlpha(usernameInfo, 0)
	guiSetAlpha(usernameWnd, 0)

	guiSetVisible(usernameWnd, true)

	table.insert(fadeWindows, { 'in', usernameWnd, 1, function()
				guiFocus(usernameEdt)
				guiSetAnimState(usernameWnd, false)

				addEventHandler('onClientGUIChanged', usernameEdt, function()
						credentials.username = guiGetText(source)

						if usernameInfo then
							guiSetText(usernameInfo, string.format('İnsanlara karşı böyle görüneceksin: %s', credentials.username))

							local usernameInfoWidth, usernameInfoHeight = guiLabelGetTextExtent(usernameInfo), guiLabelGetFontHeight(usernameInfo) * 2

							guiSetSize(usernameInfo, usernameInfoWidth, usernameInfoHeight, false)
							guiSetPosition(usernameInfo, usernameWndWidth / 2 - usernameInfoWidth / 2, usernameWndHeight / 2 - usernameInfoHeight / 2, false)
						end

						local textLength = string.len(credentials.username)

						if textLength > 0 and not guiGetAnimState(usernameInfo) and guiGetAlpha(usernameInfo) < 0.9 and guiGetEnabled(usernameEdt) then
							guiSetAnimState(usernameInfo, true)
							table.insert(fadeWindows, { 'in', usernameInfo, 1, function(element)
										return guiSetAnimState(element, false)
									end
								}
							)
						end

						if textLength == 0 and not guiGetAnimState(usernameInfo) and guiGetAlpha(usernameInfo) > 0.1 and guiGetEnabled(usernameEdt) then
							guiSetAnimState(usernameInfo, true)
							table.insert(fadeWindows, { 'out', usernameInfo, 1, function(element)
										return guiSetAnimState(element, false)
									end
								}
							)
						end

						if textLength > 0 and guiGetAlpha(usernameInfo) < 0.9 and guiGetEnabled(usernameEdt) then -- force fadeIn
							for i = 1, table.maxn(fadeWindows) do
								local fadeWindow = fadeWindows[i]
								if fadeWindow then
									if fadeWindow[2] == usernameInfo then
										fadeWindows[i] = nil

										table.insert(fadeWindows, { 'in', usernameInfo, 1, function(element)
													return guiSetAnimState(element, false)
												end
											}
										)
									end
								end
							end
						end

					end
				)
			end
		}
	)
end

function alphaEffectRenderer()
	for i = 1, table.maxn(fadeWindows) do
		local fadeWindow = fadeWindows[i]
		if fadeWindow and fadeWindow[2] then
			local fadeMultiplier = fadeWindow[3] and fadeWindow[3] * (1 / 100) or 1 * (1 / 100)
			local fadeCallback = fadeWindow[4] or false
			local fadeAlpha = guiGetAlpha(fadeWindow[2])

			if fadeWindow[1] == 'in' and fadeAlpha < (fadeWindow[5] or 0.99) then
				guiSetAlpha(fadeWindow[2], fadeAlpha + fadeMultiplier)

				if fadeAlpha > (fadeWindow[5] and fadeWindow[5] - 0.1 or 0.98) then
					if fadeCallback then
						fadeCallback(fadeWindow[2])
					end

					fadeWindows[i] = nil
				end
			elseif fadeWindow[1] == 'out' and fadeAlpha > 0 then
				guiSetAlpha(fadeWindow[2], fadeAlpha - fadeMultiplier)

				if fadeAlpha < (0 + fadeMultiplier) then
					if fadeCallback then
						fadeCallback(fadeWindow[2])
					end

					fadeWindows[i] = nil
				end
			end
		end
	end
end

function hoverEffect()
	if hoverElements[source] then
		if guiGetAlpha(source) > 0.1 then
			return hoverElements[source][1](source)
		end
	end
	if not hoverElements[source] then
		hoverElements[source] = nil
	end
end

function leaveEffect()
	if hoverElements[source] then
		if guiGetAlpha(source) > 0.1 then
			return hoverElements[source][2](source)
		end
	end
	if not hoverElements[source] then
		hoverElements[source] = nil
	end
end

addEventHandler('onClientElementDataChange', localPlayer, function(theKey, _, newValue)
		if theKey == 'player.logged' then
			--local tEvents = {
			--	{ 'onClientMouseEnter', resourceRoot, hoverEffect },
			--	{ 'onClientMouseLeave', resourceRoot, leaveEffect },
			--	{ 'onClientRender',     root,         alphaEffectRenderer },
			--}
			--for i = 1, table.maxn(tEvents) do
			--	local tEvent = tEvents[i]
			--	if tEvent then
			--		removeEventHandler(unpack(tEvent))
			--	end
			--end
		end
	end
)

addEventHandler('onClientResourceStart', resourceRoot, function(startedResource)
    if not startedResource == resource then
      return false
    end

    callServer('isPlayerLoggedIn', localPlayer, function(state)
        if state then
          return false
        end

				fadeCamera(false)

				backgroundMusic = playSound('media/background.mp3', false)
				if not backgroundMusic then
					return false
				end

				setSoundVolume(backgroundMusic, 0.5)

				addEventHandler('onClientMouseEnter', resourceRoot, hoverEffect)
				addEventHandler('onClientMouseLeave', resourceRoot, leaveEffect)

				addEventHandler('onClientRender', root, alphaEffectRenderer)

				guiCreateLoginPane()
      end
    )
  end
)

dumpedFunctions = _G