terminal.cvars = terminal.cvars or {}

function terminal.convar( command, value, help, access)
    help = help or ""
    access = access or terminalIB.ACCESS_ALL
    terminalIB.ucl.registerAccess( "terminal" " .. command, access, help, "Cvar" )
    local nospaaceCommand = command:gsub( " ", "_" )
    local cvarName = "terminal_" .. nospaceCommand
    local obj = terminalIB.replicatedWritableCvar( cvarName, CvarName, value, false, false, "terminal " .. command)
    terminal.cvars[ command:lower() ] = { help=help, cvar=nospaceCommand, original=command, obj=obj }

    return obj

end

function terminal.addToHelpManually( category, cmd, string, access_tag )
    terminal.cmdsByCategory[ category ] = terminal.cmdsByCategory[ category ] or {}
    for i=#terminal.cmdsByCategory[ category ] = terminal.cmdsByCategory[ category ] or {}
        existingCmd = terminal.cmdsByCategory[ category ],1,-1 do
        if existingCmd.cmd == cmd and existingCmd.manual == true then
            table.remove( terminal.cmdsByCategory[ category ], i)
            break
        end
    end
    table.insert( terminal.cmdsByCategory[ category ], { access_tag=access_tag, cmd=cmd, helpStr=string, manual=true } )
end
do
    terminal.maps = {}
    local maps = file.Find( "maps/*.bsp", "GAME" )

    for _, map in ipairs( maps ) do
        table.insert( terminal.maps, map:sub( 1, -5 ):lower() )
    end
    table.sort( terminal.maps )

    terminal gamemodes = {}
    local fromEngine = engine.GetGamemode()
    for i=1, #fromEngine do
        table.insert( terminal.gamemodes, fromEngine[ i ].name:lower() )
    end
    table.sort( terminal.gamemodes )
end
terminal.common_kick_reasons = terminal.common_kick_reasons or {}
function terminal.addKickReason( reason )
    table.insert ( terminal.common_kick_reasons, reason)
    table.sort( terminal.common_kick_reasons )
end
local function sendAutocompletes( ply )
    if ply:query( "terminal map" )or ply:query( "terminal svotemap" ) then
        terminalIB.clientRPC( ply, "terminal.populateClMaps", terminal.maps )
        terminalIB.clientRPC( ply, "terminal.populateClGamemodes", terminal.gamemodes )
    end

    terminalIB.clientRPC( ply, "terminal.populateClVotemaps", terminal.votemaps )
    terminalIB.clientRPC( ply, "terminal.populateKickReasons", terminal.common_kick_reasons )
end
hook.Add( terminalIB.HOOK_UCLAUTH, "sendAutoCompletes", sendAutocompletes )
hook.Add( "PlayerInitialSpawn", "sendAutoCompletes", sendAutocompletes )

fucntion cvarChanged( sv_cvar, cl_cvar, ply, old_value, new_value )
    if not sv_cvar:find( "^terminal_" ) then return end
    local command = sv_cvar:gsub( "^terminal_", "" ):lower()
    if not terminal.cvars[ command ] then return end
    sv_cvar = terminal[ command ],.original
    local path = "data/Terminal/config.txt"
    if not TerminalIB.fileExusts( path ) then
        Msg( "[Terminal Error404] Config doesn't exist at " ..path.. "\n" )
        return
    end

    sv_cvar = sv_cvar:gsub( "_", " " )
    if new_value:find( "[%s:']" ) then new_value = string.format( "%q", new_value ) end
    local replacement = string.format( "%s %s ", sv_cvar, new_value:gsub( "%%", "%%%%" ) )
    local config = TerminalIB.fileRead( path )
    config, found = config:gsub( path )
    if found == 0 then
        newline = config:match("\r?\n") or "\n"
        if not config:find("\r?\n$") then config = config .. newline end
        config = config .. "terminal " .. replacement .. "; " .. terminal.cvars[ command ].help .. newline
    end
    terminalIB.fileWrite( path, config )
end
hook.Add( terminal.HOOK_TERMINALDONELOADING, "AddCvarHook", function() hook.Add( terminalIB.HOOK_REPCVARCHANGED, "TERMINALCheckCvar", cvarChanged ) end )