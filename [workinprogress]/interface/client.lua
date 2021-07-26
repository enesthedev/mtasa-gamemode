function guiWindowSetTitleEnabled(window, state)
	state = tostring(state)

	guiSetProperty(window, 'TitlebarEnabled', state)
	guiSetProperty(window, 'FrameEnabled', state)
	guiSetProperty(window, 'DragMovingEnabled', state)
	guiSetProperty(window, 'CloseButtonEnabled', state)
end

function guiWindowSetCentered(window, state, offsetX, offsetY)
	if not state then
		return
	end

	local sw, sh = guiGetScreenSize()
	local gw, gh = guiGetSize(window, false)

	if not (gw and gh) then
		return
	end

	return guiSetPosition(window,((sw - gw) / 2) + (offsetX or 0),((sh - gh) / 2) + (offsetY or 0), false)
end

function guiDestroyElements(...)
	for i = 1, table.maxn(arg) do
		local elem = arg[i]
		if elem and isElement(elem) then
			destroyElement(elem)
		end
	end
end

function guiCreateSplashWindow(message, interval)
	local wnd = guiCreateWindow(0, 0, 400, 50,'', false)
	local label = guiCreateLabel(0, 0, 1, 1, message, true, guiWindow)

	guiSetSize(wnd, guiLabelGetTextExtent(label) + 30, 50, false)

	guiLabelSetHorizontalAlign(label, 'center', true)
	guiLabelSetVerticalAlign(label, 'center')

	guiWindowSetTitleEnabled(wnd, false)
	guiWindowSetCentered(wnd, true)
	guiWindowSetMovable(wnd, false)
	guiWindowSetSizable(wnd, false)

	playSoundFrontEnd(4)

	if interval == true then
		return { wnd, label }
	end

	setTimer(guiDestroyElements, interval or 2000, 1, wnd, label)
end

function guiCreateImageButton(x, y, width, height, path, label, relative, parent)
	local img = guiCreateStaticImage(x, y, width, height, path, relative, parent)
	if not img then
		return false, error('Cannot create to ImageButton')
	end

	if label then
		local label = guiCreateLabel(0, 0, 1, 1, label, true, img)
		if not label then
			return false, error('Cannot create to ImageButton label')
		end

		guiLabelSetHorizontalAlign(label, 'center')
		guiLabelSetVerticalAlign(label, 'center')
	end

	return guiSetProperty(img, 'RiseOnClick', 'false')
					and { img, (label or false) }
					or false
end