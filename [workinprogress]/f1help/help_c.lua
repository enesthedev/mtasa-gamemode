local x,y = guiGetScreenSize()
local s = math.max(y/1080, 0.8)
local window = guiCreateWindow((x-(800 * s))/2, (y-(600 * s))/2, 800 * s, 600 * s, exports.base_env:get('server.name') .. " - Oyun içi yardım paneli", false )
local textBox = guiCreateMemo( 266 * s, 30 * s, 624 * s, 560 * s, "", false, window )
local gList = guiCreateGridList( 10 * s, 30 * s, 250 * s, 560 * s, false, window )
--exports.GTWgui:setDefaultFont(textBox, 10)
--exports.GTWgui:setDefaultFont(gList, 10)
guiGridListSetSelectionMode(gList,2)
guiMemoSetReadOnly(textBox, true)
guiGridListAddColumn(gList,"Makaleler",0.9)
guiSetVisible(window,false)
--exports.GTWgui:showGUICursor(false)
local Text = { }

local F1wndShowing = false
bindKey('f1','down',
function()
	if F1wndShowing == true then
	    guiSetVisible(window, false)
        --exports.GTWgui:showGUICursor(false)
        guiSetInputEnabled( false )
        F1wndShowing = false
    else
        for i = 1, 2 do
					Text[i] = string.format(Text[i], string.gsub( getPlayerName( localPlayer ), "#%x%x%x%x%x%x", "" ))
				end
        guiSetVisible(window, true)
        --exports.GTWgui:showGUICursor(true)
        guiSetInputEnabled( true )
        F1wndShowing = true
    end
end)

-- Disable sorting
guiGridListSetSortingEnabled( gList, false )

for i,val in ipairs(list) do
    local rowID = guiGridListAddRow(gList)
    if val[2] == 0 then
    	guiGridListSetItemText(gList, rowID, 1, val[1], true, true)
    	guiGridListSetItemColor( gList, rowID, 1, 100, 100, 100 )
    else
    	guiGridListSetItemText(gList, rowID, 1, val[1], false, true)
    	Text[rowID] = list[rowID+1][3]
    end
end

for i = 1, 2 do
	Text[i] = string.format(Text[i], string.gsub( getPlayerName( localPlayer ), "#%x%x%x%x%x%x", "" ))
end

guiSetText(textBox,Text[1])

addEventHandler('onClientGUIClick',root,
function()
	local row,col = guiGridListGetSelectedItem ( gList )
	if Text[row] then
    	guiSetText(textBox,Text[row])
    end
end)
