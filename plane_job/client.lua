local screenWidth, screenHeight = guiGetScreenSize()
local screenScale = math.max(screenHeight / 1080, 0.65)

local markerPositions = {
  Vector3(-1422.8194580078, -288.87780761719, 12.9),
  Vector3(1685.7241210938, -2332.4052734375, 12.54),
  Vector3(1675.2132568359, 1447.7581787109, 9.788067817688)
}

local xOffset = 10
local yOffset = 25

local panelYOffset = screenScale * 50

local panelW, panelH = screenScale * 800, screenScale * 250
local panelX, panelY = (screenWidth - panelW) / 2, (screenHeight - panelH) / 2

local inputState = false

local introText = [[Uçak mesleğine hoşgeldin ]] .. getPlayerName(localPlayer) ..  [[ bu meslekte dört adet havalimanı arasından birisini seçip, yine senin seçimin olan uçakla beraber sefer düzenliyorsun. Dikkat etmen gereken sağ alt tarafta yazan süre bitmeden uçağı istenilen havalimanına başarıyla indirebilmen. Unutma diğer kişiler sana uçak sürerken saldırabilir.

Mesleğin gereksinimleri:
  - 5000$ depozito.
  - Seviye 3 ve üstü olan uçaklar için ehliyet.

Meslek kuralları:
  - Uçaklar ile troll yapmak yasaktır.
  - Meslek aracından inerseniz otomatik olarak mesleğiniz iptal olur.
]]

function bind(theKey)
  return function()
    _G[theKey]()
  end
end

function jobPanel()
  print('deneme')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i = 1, table.maxn(markerPositions) do
      local markerPosition = markerPositions[i]
      if markerPosition then
        local dummyMarker = createMarker(markerPosition.x, markerPosition.y, markerPosition.z, 'cylinder', 3.0, 148, 205, 255, 100)
        local dummyBlip = createBlipAttachedTo(dummyMarker, 5)

        setElementParent(dummyMarker, dummyBlip)

        addEventHandler('onClientMarkerHit', dummyMarker, function(hitPlayer, matchingDimension)
            if matchingDimension and hitPlayer == localPlayer then

              local panel = GuiWindow(panelX, panelY, panelW, panelH, getElementData(root, 'server.name') .. ' - Pilotluk Mesleği', false)

              panel:setSizable(false)
              panel:setMovable(false)

              panel:setProperty('CaptionColour', 'FF94cdff')

              local tabpanel = GuiTabPanel(0, yOffset, panelW, panelH, false, panel)
              local tabs = {
                { 'Tanıtım', false }, { 'Meslek Paneli', bind('jobPanel') },
                { 'Seviyeler', bind('jobLevels') }, { 'Skor Tablosu', bind('jobScores'), false }
              }

              for i = 1, table.maxn(tabs) do
                tabs[i].guiElement = GuiTab(tabs[i][1], tabpanel)
                if tabs[i][3] == false then
                  tabs[i].guiElement:setEnabled(false)
                end
              end

              addEventHandler('onClientGUITabSwitched', tabpanel, function(selectedTab)
                  for i = 1, table.maxn(tabs) do
                    local tab = tabs[i]
                    if tab and tab.guiElement and tab.guiElement == selectedTab and tab[2] then
                      return tab[2]()
                    end
                  end
                end
              )

              local introElements = {
                text = guiCreateMemo(screenScale * 15, screenScale * 15, screenScale * 750, screenScale * 140, introText, false, tabs[1].guiElement),
                checkbox = GuiCheckBox(screenScale * 15, screenScale * 155, screenScale * 256, screenScale * 32, 'Meslek şartlarını okudum ve kabul ediyorum', false, false, tabs[1].guiElement)
              }

              if introElements.text then
                introElements.text:setReadOnly(true)
              end

              inputState = GuiElement.setInputEnabled(true)
            end
          end, false
        )
      end
    end
  end
)

addEventHandler('onClientResourceStop', resourceRoot, function()
    if inputState then
      GuiElement.setInputEnabled(false)
    end
  end
)

print(engineGetModelIDFromName('andre'))