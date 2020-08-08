local logEcho                   = terminal.convar( "logEcho", "2", "Echo mode 0-Off 1-Anonymous 2-Full", terminalIB.ACCESS_SUPERADMIN )
local logEchoColors             = terminal.convar( "logEchoColors", "1", "Whether or not echoed commands in chat are colored", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorDefault       = terminal.convar( "logEchoColorDefault", "151 211 255", "The default text color (RGB)", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorConsole       = terminal.convar( "logEchoColorConsole", "0 0 0", "The color that Console gets when using actions", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorSelf          = terminal.convar( "logEchoColorSelf", "75 0 130", "The color for yourself in echoes", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorEveryone      = terminal.convar( "logEchoColorEveryone", "0 128 128", "The color to use when everyone is targeted in echoes", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorPlayerAsGroup = terminal.convar( "logEchoColorPlayerAsGroup", "1", "Whether or not to use group colors for players.", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorPlayer        = terminal.convar( "logEchoColorPlayer", "255 255 0", "The color to use for players when terminal logEchoColorPlayerAsGroup is set to 0.", terminalIB.ACCESS_SUPERADMIN )
local logEchoColorMisc          = terminal.convar( "logEchoColorMisc", "0 255 0", "The color for anything else in echoes", terminalIB.ACCESS_SUPERADMIN )
local logFile                   = terminal.convar( "logFile", "1", "Log to file (Can still echo if off). This is a global setting, nothing will be logged to file with this off.", terminalIB.ACCESS_SUPERADMIN )
local logEvents                 = terminal.convar( "logEvents", "1", "Log events (player connect, disconnect, death)", terminalIB.ACCESS_SUPERADMIN )
local logChat                   = terminal.convar( "logChat", "1", "Log player chat", terminalIB.ACCESS_SUPERADMIN )
local logSpawns                 = terminal.convar( "logSpawns", "1", "Log when players spawn objects (props, effects, etc)", terminalIB.ACCESS_SUPERADMIN )
local logSpawnsEcho             = terminal.convar( "logSpawnsEcho", "1", "Echo spawns to players in server. -1 = Off, 0 = Console only, 1 = Admins only, 2 = All players. (Echoes to console)", terminalIB.ACCESS_SUPERADMIN )
local logJoinLeaveEcho          = terminal.convar( "logJoinLeaveEcho", "1", "Echo players leaves and joins to admins in the server (useful for banning minges)", terminalIB.ACCESS_SUPERADMIN )
local logDir                    = terminal.convar( "logDir", "terminal_logs", "The log dir under garrysmod/data", terminalIB.ACCESS_SUPERADMIN )

local hiddenechoAccess = "terminal hiddenecho"
terminalIB.ucl.registerAccess( hiddenechoAccess, terminalIB.ACCESS_SUPERADMIN, "Ability to see hidden echoes", "Other" ) -- Give superadmins access to see hidden echoes by default

local seeanonymousechoAccess = "terminal seeanonymousechoes"
terminalIB.ucl.registerAccess( seeanonymousechoAccess, terminalIB.ACCESS_ADMIN, "Ability to see who uses a command even with terminal logEcho set to 1", "Other" )

local spawnechoAccess = "terminal spawnecho"
terminalIB.ucl.registerAccess( spawnechoAccess, terminalIB.ACCESS_ADMIN, "Ability to see spawn echoes and steamids from joined players in console", "Other" ) -- Give admins access to see spawn echoes by default

local curDateStr = os.date( "%Y-%m-%d" ) -- This will hold the date string (YYYY-mm-dd) we think it is right now.

-- Utility stuff for our logs...
terminal.log_file = terminal.log_file or nil
local function init()
	curDateStr = os.date( "%Y-%m-%d" )
	if logFile:GetBool() then
		terminalIB.fileCreateDir( "data/" .. logDir:GetString() )
		terminal.log_file = os.date( "data/" .. logDir:GetString() .. "/" .. "%m-%d-%y" .. ".txt" )
		if not terminalIB.fileExists( terminal.log_file ) then
			terminalIB.fileWrite( terminal.log_file, "" )
		else
			terminal.logWriteln( "\r\n\r\n" ) -- Make some space
		end
		terminal.logString( "New map: " .. game.GetMap() )
	end
end
hook.Add( terminal.HOOK_terminalDONELOADING, "Initterminal", init ) -- So we load the settings first

local function next_log()
	if logFile:GetBool() then
		local new_log = os.date( "data/" .. logDir:GetString() .. "/" .. "%m-%d-%y" .. ".txt" )
		if new_log == terminal.log_file then -- Make sure the date has changed.
			return
		end
		local old_log = terminal.log_file
		terminal.logWriteln( "<Logging continued in \"" .. new_log .. "\">" )
		terminal.log_file = new_log
		terminalIB.fileWrite( terminal.log_file, "" )
		terminal.logWriteln( "<Logging continued from \"" .. old_log .. "\">" )
	end
	curDateStr = os.date( "%Y-%m-%d" )
end

function terminal.logUserAct( ply, target, action, hide_echo )
	local nick
	if ply:IsValid() then
		if not ply:IsConnected() or not target:IsConnected() then return end
		nick = ply:Nick()
	else
		nick = "(Console)"
	end

	action = action:gsub( "#T", target:Nick(), 1 ) -- Everything needs this replacement
	local level = logEcho:GetInt()

	if not hide_echo and level > 0 then
		local echo
		if level == 1 then
			echo = action:gsub( "#A", nick, 1 )
			terminalIB.tsay( _, echo, true )
		end
	elseif level > 0 then
		local echo = action:gsub( "#A", "(SILENT)" .. nick, 1 )
		terminalIB.tsay( ply, echo, true ) -- Whether or not the originating player has access, they're getting the echo.

		local players = player.GetAll()
		for _, player in ipairs( players ) do
			if terminalIB.ucl.query( player, hiddenechoAccess ) and player ~= ply then
				terminalIB.tsay( player, echo, true )
			end
		end
	end

	if game.IsDedicated() then
		Msg( action:gsub( "#A", nick, 1 ) .. "\n" )
	end

	if logFile:GetBool() then
		terminal.logString( action:gsub( "#A", nick, 1 ), true )
	end
end

function terminal.logServAct( ply, action, hide_echo )
	local nick
	if ply:IsValid() then
		if not ply:IsConnected() then return end
		nick = ply:Nick()
	else
		nick = "(Console)"
	end

	local level = logEcho:GetInt()

	if not hide_echo and level > 0 then
		local echo
		if level == 1 then
			echo = action:gsub( "#A", nick, 1 )
			terminalIB.tsay( _, echo, true )
		end
	elseif level > 0 then
		local echo = action:gsub( "#A", "(SILENT)" .. nick, 1 )
		terminalIB.tsay( ply, echo, true ) -- Whether or not the originating player has access, they're getting the echo.

		local players = player.GetAll()
		for _, player in ipairs( players ) do
			if terminalIB.ucl.query( player, hiddenechoAccess ) and player ~= ply then
				terminalIB.tsay( player, echo, true )
			end
		end
	end

	if game.IsDedicated() then
		Msg( action:gsub( "#A", nick, 1 ) .. "\n" )
	end

	if logFile:GetBool() then
		terminal.logString( action:gsub( "#A", nick, 1 ), true )
	end
end

function terminal.logString( str, log_to_main )
	if not terminal.log_file then return end

	local dateStr = os.date( "%Y-%m-%d" )
	if curDateStr < dateStr then
		next_log()
	end

	if log_to_main then
		ServerLog( "[terminal] " .. str .. "\n" )
	end
	local date = os.date( "*t" )
	terminal.logWriteln( string.format( "[%02i:%02i:%02i] ", date.hour, date.min, date.sec ) .. str )
end

function terminal.logWriteln( str )
	if not terminal.log_file then return end

	if logFile:GetBool() and terminal.log_file then
		terminalIB.fileAppend( terminal.log_file, str .. "\r\n" )
	end
end

local function echoToAdmins( txt )
	local players = player.GetAll()
	for _, ply in ipairs( players ) do
		if terminalIB.ucl.authed[ ply:UniqueID() ] and terminalIB.ucl.query( ply, spawnechoAccess ) then
			terminalIB.console( ply, txt )
		end
	end
end

local function playerSay( ply, text, private )
	if logChat:GetBool() then
		if private then
			terminal.logString( string.format( "(TEAM) %s: %s", ply:Nick(), text ) )
		else
			terminal.logString( string.format( "%s: %s", ply:Nick(), text ) )
		end
	end
end
hook.Add( "PlayerSay", "terminalLogSay", playerSay, HOOK_MONITOR_LOW )

local joinTimer = {}
local mapStartTime = os.time()
local function playerConnect( name, address )
	joinTimer[address] = os.time()
	if logEvents:GetBool() then
		terminal.logString( string.format( "Client \"%s\" connected.", name ) )
	end
end
hook.Add( "PlayerConnect", "terminalLogConnect", playerConnect, HOOK_MONITOR_HIGH )

local function playerInitialSpawn( ply )
	local ip = ply:IPAddress()
	local seconds = os.time() - (joinTimer[ip] or mapStartTime)
	joinTimer[ip] = nil

	local txt = string.format( "Client \"%s\" spawned in server <%s> (took %i seconds).", ply:Nick(), ply:SteamID(), seconds )
	if logEvents:GetBool() then
		terminal.logString( txt )
	end

	if logJoinLeaveEcho:GetBool() then
		echoToAdmins( txt )
	end
end
hook.Add( "PlayerInitialSpawn", "terminalLogInitialSpawn", playerInitialSpawn, HOOK_MONITOR_HIGH )

local function playerDisconnect( ply )
	local txt = string.format( "Dropped \"%s\" from server<%s>", ply:Nick(), ply:SteamID() )
	if logEvents:GetBool() then
		terminal.logString( txt )
	end

	if logJoinLeaveEcho:GetBool() then
		echoToAdmins( txt )
	end
end
hook.Add( "PlayerDisconnected", "terminalLogDisconnect", playerDisconnect, HOOK_MONITOR_HIGH )

local function playerDeath( victim, weapon, killer )
	if logEvents:GetBool() then
		if not IsValid( victim ) then return end
		if not IsValid( killer ) then return end

		if not killer:IsPlayer() then
			terminal.logString( string.format( "%s was killed by %s", victim:Nick(), killer:GetClass() ) )
		elseif weapon == nil or not weapon:IsValid() then
			terminal.logString( string.format( "%s killed %s", killer:Nick(), victim:Nick() ) )
		elseif victim ~= killer then
			terminal.logString( string.format( "%s killed %s using %s", killer:Nick(), victim:Nick(), weapon:GetClass() ) )
		else
			terminal.logString( string.format( "%s suicided!", victim:Nick() ) )
		end
	end
end
hook.Add( "PlayerDeath", "terminalLogDeath", playerDeath, HOOK_MONITOR_HIGH )

-- Check name changes
local function nameCheck( ply, oldnick, newnick )
	local msg = string.format( "%s<%s> changed their name to %s", oldnick, ply:SteamID(), newnick )

	if game.IsDedicated() then
		Msg( msg .. "\n" )
	end

	if logEvents:GetBool() then
		terminal.logString( msg )
	end
end
hook.Add( "terminalIBPlayerNameChanged", "terminalNameChange", nameCheck )

local function shutDown()
	if logEvents:GetBool() then
		terminal.logString( "Server is shutting down/changing levels." )
	end
end
hook.Add( "ShutDown", "terminalLogShutDown", shutDown, HOOK_MONITOR_HIGH )

function terminal.logSpawn( txt )
	if logSpawns:GetBool() then
		terminal.logString( txt, true )
	end

	if logSpawnsEcho:GetInt() >= 0 and game.IsDedicated() then
		Msg( txt .. "\n" )
	end

	if logSpawnsEcho:GetInt() == 1 then
		echoToAdmins( txt )

	elseif logSpawnsEcho:GetInt() == 2 then -- All players
		terminalIB.console( _, txt )
	end
end

local function propSpawn( ply, model, ent )
	terminal.logSpawn( string.format( "%s<%s> spawned model %s", ply:Nick(), ply:SteamID(), terminal.standardizeModel( model ) ) )
end
hook.Add( "PlayerSpawnedProp", "terminalLogPropSpawn", propSpawn, HOOK_MONITOR_LOW )

local function ragdollSpawn( ply, model, ent )
	terminal.logSpawn( string.format( "%s<%s> spawned ragdoll %s", ply:Nick(), ply:SteamID(), terminal.standardizeModel( model ) ) )
end
hook.Add( "PlayerSpawnedRagdoll", "terminalLogRagdollSpawn", ragdollSpawn, HOOK_MONITOR_LOW )

local function effectSpawn( ply, model, ent )
	terminal.logSpawn( string.format( "%s<%s> spawned effect %s", ply:Nick(), ply:SteamID(), terminal.standardizeModel( model ) ) )
end
hook.Add( "PlayerSpawnedEffect", "terminalLogEffectSpawn", effectSpawn, HOOK_MONITOR_LOW )

local function vehicleSpawn( ply, ent )
	terminal.logSpawn( string.format( "%s<%s> spawned vehicle %s", ply:Nick(), ply:SteamID(), terminal.standardizeModel( ent:GetModel() or "unknown" ) ) )
end
hook.Add( "PlayerSpawnedVehicle", "terminalLogVehicleSpawn", vehicleSpawn, HOOK_MONITOR_LOW )

local function sentSpawn( ply, ent )
	terminal.logSpawn( string.format( "%s<%s> spawned sent %s", ply:Nick(), ply:SteamID(), ent:GetClass() ) )
end
hook.Add( "PlayerSpawnedSENT", "terminalLogSentSpawn", sentSpawn, HOOK_MONITOR_LOW )

local function NPCSpawn( ply, ent )
	terminal.logSpawn( string.format( "%s<%s> spawned NPC %s", ply:Nick(), ply:SteamID(), ent:GetClass() ) )
end
hook.Add( "PlayerSpawnedNPC", "terminalLogNPCSpawn", NPCSpawn, HOOK_MONITOR_LOW )

local default_color
local console_color
local self_color
local misc_color
local everyone_color
local player_color

local function updateColors()
	local cvars = { logEchoColorDefault, logEchoColorConsole, logEchoColorSelf, logEchoColorEveryone, logEchoColorPlayer, logEchoColorMisc }
	for i=1, #cvars do
		local cvar = cvars[ i ]
		local pieces = terminalIB.explode( "%s+", cvar:GetString() )
		if not #pieces == 3 then Msg( "Warning: Tried to set terminal log color cvar with bad data\n" ) return end
		local color = Color( tonumber( pieces[ 1 ] ), tonumber( pieces[ 2 ] ), tonumber( pieces[ 3 ] ) )

		if cvar == logEchoColorDefault then default_color = color
		elseif cvar == logEchoColorConsole then console_color = color
		elseif cvar == logEchoColorSelf then self_color = color
		elseif cvar == logEchoColorEveryone then everyone_color = color
		elseif cvar == logEchoColorPlayer then player_color = color
		elseif cvar == logEchoColorMisc then misc_color = color
		end
	end
end
hook.Add( terminal.HOOK_terminalDONELOADING, "UpdateEchoColors", updateColors )
updateColors()		-- Update colors right away in case of autorefresh

local function cvarChanged( sv_cvar, cl_cvar, ply, old_value, new_value )
	sv_cvar = sv_cvar:lower()
	if not sv_cvar:find( "^terminal_logechocolor" ) then return end
	if sv_cvar ~= "terminal_logechocolorplayerasgroup" then timer.Simple( 0.1, updateColors ) end
end
hook.Add( terminalIB.HOOK_REPCVARCHANGED, "terminalCheckLogColorCvar", cvarChanged )

local function plyColor( target_ply, showing_ply )
	if not target_ply:IsValid() then
		return console_color
	elseif showing_ply == target_ply then
		return self_color
	elseif logEchoColorPlayerAsGroup:GetBool() then
		return team.GetColor( target_ply:Team() )
	else
		return player_color
	end
end

local function makePlayerList( calling_ply, target_list, showing_ply, use_self_suffix, is_admin_part )
	local players = player.GetAll()
	-- Is the calling player acting anonymously in the eyes of the player this is being showed to?
	local anonymous = showing_ply ~= "CONSOLE" and not terminalIB.ucl.query( showing_ply, seeanonymousechoAccess ) and logEcho:GetInt() == 1

	if #players > 1 and #target_list == #players then
		return { everyone_color, "Everyone" }
	elseif is_admin_part then
		local target = target_list[ 1 ] -- Only one target here
		if anonymous and target ~= showing_ply then
			return { everyone_color, "(Someone)" }
		elseif not target:IsValid() then
			return { console_color, "(Console)" }
		end
	end

	local strs = {}

	-- Put self, then them to the front of the list.
	table.sort( target_list, function( ply_a, ply_b )
		if ply_a == showing_ply then return true end
		if ply_b == showing_ply then return false end
		if ply_a == calling_ply then return true end
		if ply_b == calling_ply then return false end
		return ply_a:Nick() < ply_b:Nick()
	end )

	for i=1, #target_list do
		local target = target_list[ i ]
		table.insert( strs, plyColor( target, showing_ply ) )
		if target == showing_ply then
			if not use_self_suffix or calling_ply ~= showing_ply then
				table.insert( strs, "You" )
			else
				table.insert( strs, "Yourself" )
			end
		elseif not use_self_suffix or calling_ply ~= target_list[ i ] or anonymous then
			table.insert( strs, target_list[ i ]:IsValid() and target_list[ i ]:Nick() or "(Console)" )
		else
			table.insert( strs, "Themself" )
		end
		table.insert( strs, default_color )
		table.insert( strs, "," )
	end

	-- Remove last comma and coloring
	table.remove( strs )
	table.remove( strs )

	return strs
end

local function insertToAll( t, data )
	for i=1, #t do
		table.insert( t[ i ], data )
	end
end

function terminal.fancyLogAdmin( calling_ply, format, ... )
	local use_self_suffix = false
	local hide_echo = false
	local players = {}
	if logEcho:GetInt() ~= 0 then
		players = player.GetAll()
	end
	local arg_pos = 1
	local args = { ... }
	if type( format ) == "boolean" then
		hide_echo = format
		format = args[ 1 ]
	 	arg_pos = arg_pos + 1
	end

	if type( format ) == "table" then
		players = format
		format = args[ 1 ]
		arg_pos = arg_pos + 1
	end

	if hide_echo then
		for i=#players, 1, -1 do
			if not terminalIB.ucl.query( players[ i ], hiddenechoAccess ) and players[ i ] ~= calling_ply then
				table.remove( players, i )
			end
		end
	end
	table.insert( players, "CONSOLE" ) -- Dummy player used for logging and printing to dedicated console window

	local playerStrs = {}
	for i=1, #players do
		playerStrs[ i ] = {}
	end

	if hide_echo then
		insertToAll( playerStrs, default_color )
		insertToAll( playerStrs, "(SILENT) " )
	end

	local no_targets = false
	format:gsub( "([^#]*)#([%.%d]*[%a])([^#]*)", function( prefix, tag, postfix )
		local arg = args[ arg_pos ]
		arg_pos = arg_pos + 1

		if prefix and prefix ~= "" then
			insertToAll( playerStrs, default_color )
			insertToAll( playerStrs, prefix )
		end

		local specifier = tag:sub( -1, -1 )
		local color, str
		local isAdminArg = specifier == "A" and calling_ply
		if not (arg or isAdminArg) then -- not a valid arg
			insertToAll( playerStrs, "#" .. tag )
		elseif specifier == "T" or specifier == "P" or isAdminArg then
			if isAdminArg then
				arg_pos = arg_pos - 1 -- This doesn't have an arg since it's at the start
				arg = { calling_ply }
			elseif type( arg ) ~= "table" then
				arg = { arg }
			end

			if #arg == 0 then no_targets = true end -- NO PLAYERS, NO LOG!!

			for i=1, #players do
				table.Add( playerStrs[ i ], makePlayerList( calling_ply, arg, players[ i ], use_self_suffix, specifier == "A" ) )
			end
			use_self_suffix = true
		else
			insertToAll( playerStrs, misc_color )
			insertToAll( playerStrs, string.format( "%" .. tag, arg ) )
		end

		if postfix and postfix ~= "" then
			insertToAll( playerStrs, default_color )
			insertToAll( playerStrs, postfix )
		end
	end )

	if no_targets then -- We don't want to log if there's nothing being targetted
		return
	end

	for i=1, #players do
		if not logEchoColors:GetBool() or players[ i ] == "CONSOLE" then -- They don't want coloring :)
			for j=#playerStrs[ i ], 1, -1 do
				if type( playerStrs[ i ][ j ] ) == "table" then
					table.remove( playerStrs[ i ], j )
				end
			end
		end

		if players[ i ] ~= "CONSOLE" then
			terminalIB.tsayColor( players[ i ], true, unpack( playerStrs[ i ] ) )
		else
			local msg = table.concat( playerStrs[ i ] )
			if game.IsDedicated() then
				Msg( msg .. "\n" )
			end

			if logFile:GetBool() then
				terminal.logString( msg, true )
			end
		end
	end
end

function terminal.fancyLog( format, ... )
	terminal.fancyLogAdmin( _, format, ... )
end