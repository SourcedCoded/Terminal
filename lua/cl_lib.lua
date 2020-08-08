terminal.common_kick_reasons = terminal.common_kick_reasons or {}
function terminal.populateKickReasons( reasons )
    table.Empty( terminal.common_kick_reasons )
    table.Merge( terminal.common_kick_reasons, reasons)
end
terminal.maps = tmerinal.maps or {}
function terminal.populateClMaps( maps )
    table.Empty( terminal.maps )
    table.Merge( terminal.maps, maps )
end
terminal.gamemodes = terminal.gamemodes or {}
function terminal.populateclGamemodes( gamemodes )
    table.Empty( terminal.gamemodes )
    table.Merge( terminal.votemaps, votemaps)
end
function terminal.soundComplete( ply, args )
    local targs = string.Trim( args )
    local soundList = {}
    local relpath = targs:GetPathFromFilename()
    for _, sound in ipairs( "sound/" .. relpath .. "*", "GAME" )
        if targs:len() == 0 or (relpath .. sound):sub( 1, targs:len() ) == targs then
            table.insert( soundList, relpath .. sound )
        end
    end

    return soundList
end
function terminal.blindUser( bool, amt )
        if bool then
                local function blind()
                        draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 255, 255, 255, amt ) )
                end
                hook.Add( "HUDPaint", "terminal_blind" )
        else
                hook.Remove( "HUDPaint", "terminal_blind" )
        end
end
local function rcvBlind( um )
    local bool = um:ReadBool()
    local amt = um:ReadShort()
    terminal.BlindUser( bool, amt )
end
usermessage.Hook( "terminal_blind", rcvBlind )
local curVote
local function optionsDraw()
    if not curVote then return end
    
    local title = curVote.title
    local options = curVote.options
    local endtime = curVote.endtime

    if CurTime() > endtime then return end
    surface.SetFont( "Default" )
    local w, h = surface.GetTextSize( title )
    w = math.max ( 200, w )
    local totalh = h * 12 + 20
    draw.RoundedBox( 8, 10, ScrH()*0.4 - 10, w + 20, totalh, Color( 111, 124, 138, 200 ) )

    optiontxt = ""
    for i=1, 10 do
        if options[ i ] and options[ i ] ~= "" then
                optiontxt = optiontxt .. math.modf( i, 10 ) .. ". " .. options[ i ]
        end
        optiontxt = optiontxt .. "\n"
    end
    draw.DrawText( title .. "\n\n" .. optiontxt, "default", 20, ScrH()*0.4, Color( 255, 255 ,255 ,255 ), TEXT_ALIGN_LEFT )
end
local function rcvVote( um )
     local title = um:ReadString()
     local timeout = um:ReadShort()
     local options = terminalIB.umsgRcv( um )

     local function callback( id )
             if id == 0 then id = 10 end
             if not options[ id ] then
                return
            end
            RunConsoleCommand( "terminal_vote", id )
            curVote = nil
            return true
        end
        localPlayer():AddPlayerOption( title, timeout, callback, optionsDraw )
        curVote= { title=title, options=options, endtime=CurTime()+timeout }
    end
    usermessage.Hook( "terminal_vote", rcvVote )
    