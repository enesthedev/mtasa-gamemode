local sx, sy = guiGetScreenSize( )
local s = math.max( sy / 1080, 0.65 )
local o = s * 1.5

local state = false

local ids = { }
local levels = { }
local anons = { }
local formatnames = { }

local font = dxCreateFont( ':dx_fonts/ahronbd.ttf', s * 12, true )

function setRenderElements( playersTable )
  for _, v in ipairs( playersTable ) do
    if getElementType(v) == 'player' then
      ids[v] = getElementData( v, 'player.id' ) or 1
      anons[v] = getElementData( v, 'player.anonymous' ) or false
      levels[v] = getElementData( v, 'player.level' ) or 0
      formatnames[v] = string.gsub( getPlayerName( v ), "#%x%x%x%x%x%x", "" )
    end
  end
  return true
end

function getNametagRenderState( )
  return state
end

function setNametagRenderState( bool )
  if bool and not state then
    state = true
    addEventHandler( 'onClientRender', root, renderer )
  elseif state then
    state = false
    removeEventHandler( 'onClientRender', root, renderer )
  end
end

function reloadRenderElements( )
  local nState = setRenderElements( getElementsByType( 'player', root, true ) )
  if nState then
    setNametagRenderState( true )
  end
end

function renderer( )
  local px, py, pz, tx, ty, tz, dist, playeranon, playername, playerid, random
  px, py, pz = getCameraMatrix( )

  for _, v in ipairs( getElementsByType( 'player', root, true ) ) do
    if v ~= localPlayer then
      tx, ty, tz = getElementPosition( v )
      dist = math.sqrt( ( px - tx ) ^ 2 + ( py - ty ) ^ 2 + ( pz - tz ) ^ 2 )

      if dist < 30.0 then
        if isLineOfSightClear( px, py, pz, tx, ty, tz, true, false, false, true, false, false, false, localPlayer ) then
          local sx, sy, sz = getPedBonePosition( v, 5 )
          local x,y = getScreenFromWorldPosition( sx, sy, sz + 0.3 )

          playername = getPlayerName( v )
          playerid = ids[v]
          playeranon = anons[v]
          playerlevel = levels[v]

          formattedName = formatnames[v]

          if x and not playeranon and playername then
            for oX = (o * -1), o do
              for oY = (o * -1), o do
                dxDrawText( formattedName .. ' (lvl:' .. playerlevel .. ')', x + oX, y + oY, x + oX, y + oY, tocolor(0, 0, 0, 150), 0.5 + ( 15 - dist ) * 0.02, font, "center", "top", false, false, false )
              end
            end
            dxDrawText( playername .. ' (lvl:' .. playerlevel .. ')', x, y, x, y, tocolor(255, 255, 255, 255), 0.5 + ( 15 - dist ) * 0.02, font, "center", "top", false, false, false, false )
          end
        end
      end
    end
  end
end

addEventHandler( 'onClientElementDataChange', root, function( theKey, _, newValue )
    if theKey == 'player.id' then
      ids[source] = newValue
    elseif theKey == 'player.anonymous' then
      anons[source] = newValue
    elseif theKey == 'player.level' then
      levels[source] = newValue
    end
  end
)

addEventHandler( 'onClientPlayerChangeNick', root, function( _, newNick )
    if isElementStreamedIn(source) then
      formatnames[source] = string.gsub( newNick, "#%x%x%x%x%x%x", "" )
    end
  end
)

addEventHandler( 'onClientElementStreamIn', root, function( )
    return setRenderElements( { source } )
  end
)

addEvent( 'onClientDXScoreboardToggle', true )
addEventHandler('onClientDXScoreboardToggle', localPlayer, function( state )
    setNametagRenderState( not state )
  end
)

addEvent( 'onClientMaximapToggle', true )
addEventHandler('onClientMaximapToggle', localPlayer, function( state )
    setNametagRenderState( not state )
  end
)

addEventHandler( 'onClientPlayerSpawn', localPlayer, reloadRenderElements)
addEventHandler( 'onClientResourceStart', resourceRoot, reloadRenderElements)