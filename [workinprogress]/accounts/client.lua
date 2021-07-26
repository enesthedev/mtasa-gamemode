local sw, sh = guiGetScreenSize()
local s = math.max(sh/1080, 0.8)

local interface = getResourceFromName('interface')

local locations = {
	{ 1804.1455078125, -1932.4345703125, 13.386493682861, 1793.5693359375, -1924.181640625, 17.390524864197 },
	{ 1940.4599609375, -1772.3994140625, 13.390598297119, 1970.6015625, -1742.7529296875, 17.546875 },
	{ 2245.490234375, -1663.033203125, 15.469003677368, 2263.44140625, -1650.8525390625, 19.432439804077 },
	{ 2227.2275390625, -1721.541015625, 13.554790496826, 2223.6796875, -1756.4375, 16.5625 },
	{ 2396.2890625, -1911.6201171875, 16.460195541382, 2360.251953125, -1880.6142578125, 22.553737640381 },
	{ 2495.810546875, -1666.443359375, 13.34375, 2456.9892578125, -1697.0546875, 22.953369140625 },
	{ 2495.810546875, -1666.443359375, 13.34375, 2456.9892578125, -1697.0546875, 22.953369140625 },
	{ 1808.2685546875, -1897.8447265625, 13.578125, 1797.71484375, -1897.3994140625, 20.402294158936 }
}

local trashElements = {}

function guiCreateLoginPanel(title, width, height)
	local windows = {
		mainFrame = guiCreateWindow(0, 0, width, height, title or '', false),
		subFrame = guiCreateWindow(0, 0, width, 20, '', false)
	}

	local inputs = {
		nickname = guiCreateEdit(0, 0.1, 1, 0.35, 'Kullanıcı adı', true, windows.mainFrame),
		password = guiCreateEdit(0, 0.54, 1, 0.35, 'Şifre', true, windows.mainFrame)
	}

	local buttons = {
		continue = call(interface, 'guiCreateImageButton', 0, 0, 150, 40, ':media/')
	}

	call(interface, 'guiWindowSetCentered', windows.mainFrame, true)
	call(interface, 'guiWindowSetCentered', windows.subFrame, true, 0, s * 80)

	for _, wnd in pairs(windows) do
		call(interface, 'guiWindowSetTitleEnabled', wnd, title)

		guiWindowSetMovable(wnd, false)
		guiWindowSetSizable(wnd, false)
	end

	showCursor(true)
end

function guiMapTrashElements(trashElements)
	local args = {}
	local i = 0
	while table.maxn(trashElements) > 0 do
		i = i + 1
		for k = 1, table.maxn(trashElements[i]) do
			table.insert(args, trashElements[i][k])
		end
		trashElements[i] = nil
	end

	return args
end

function guiChangeDialog()
	if table.maxn(trashElements) > 0 then
		call(interface, 'guiDestroyElements', unpack(guiMapTrashElements(trashElements)))
	end

	table.insert(trashElements,
					call(interface, 'guiCreateSplashWindow',
									'Boş olan kısıma KULLANICI ADI ve ŞİFRE girin lütfen, arada boşluk olmasına dikkat edin!\nÖrnek: enesbayrktar denemesifre', true
					)
	)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	if not getElementData(localPlayer, 'player.logged') then
		--- TODO: Müzik çalma eklenecek
		fadeCamera(false)
		fadeCamera(true)

		--- Set Player Camera to random peace. Yes random peace!
		setCameraMatrix(unpack(locations[math.random(1, table.maxn(locations))]))

		if sw >= 801 then
			guiCreateLoginPanel(false, 450, 100)
			return call(interface, 'guiCreateSplashWindow',
							'Oyun sunucumuza hoşgeldin! Giriş yapmak ya da kaydolmak için seni sıkmayacağız.\nBuradaki bilgileri doldurman ve devam et demen senin için yeterli!', 5000
			)
		end

		if table.maxn(trashElements) > 0 then
			call(interface, 'guiDestroyElements', unpack(guiMapTrashElements(trashElements)))
		end

		table.insert(trashElements,
						call(interface, 'guiCreateSplashWindow',
										'Ekran çözünürlüğünüz desteklenmediği için G tuşu ile giriş yapmalısınız\nGözüken ekrana kullanıcı adı ve şifrenizi girin', true
						)
		)

		setElementData(localPlayer, 'player.chatbox', true, false)

		bindKey('g', 'down', 'chatbox', 'Kullanıcı')
		bindKey('g', 'down', guiChangeDialog)
	end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
	for i = 1, table.maxn(trashElements) do
		local trashElem = trashElements[i]
		if trashElem then
			call(interface, 'guiDestroyElements', unpack(trashElem))
		end
	end
end)