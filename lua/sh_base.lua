terminalIB.registerPlugin{
	Name          = "Terminal OS",
	Version       = string.format( "%.2f", terminal.version ),
	IsRelease     = terminal.release,
	Author        = "Team Ulysses",
	URL           = "http://ulyssesmod.net",
	WorkshopID    = 557962280,
	BuildNumLocal         = tonumber(terminalIB.fileRead( "terminal.build" )),
	--BuildNumRemoteReceivedCallback = nil
}

function terminal.getVersion() -- This function will be removed in the future
	return terminalIB.pluginVersionStr( "terminal" )
end

local terminalCommand = inheritsFrom( terminalIB.cmds.TranslateCommand )

function terminalCommand:logString( str )
	Msg( "Warning: <terminal command>:logString() was called, this function is being phased out!\n" )
end

function terminalCommand:oppositeLogString( str )
	Msg( "Warning: <terminal command>:oppositeLogString() was called, this function is being phased out!\n" )
end

function terminalCommand:help( str )
	self.helpStr = str
end

function terminalCommand:getUsage( ply )
	local str = self:superClass().getUsage( self, ply )

	if self.helpStr or self.say_cmd or self.opposite then
		str = str:Trim() .. " - "
		if self.helpStr then
			str = str .. self.helpStr
		end
		if self.helpStr and self.say_cmd then
			str = str .. " "
		end
		if self.say_cmd then
			str = str .. "(say: " .. self.say_cmd[1] .. ")"
		end
		if self.opposite and (self.helpStr or self.say_cmd) then
			str = str .. " "
		end
		if self.opposite then
			str = str .. "(opposite: " .. self.opposite .. ")"
		end
	end

	return str
end

terminal.cmdsByCategory = terminal.cmdsByCategory or {}
function terminal.command( category, command, fn, say_cmd, hide_say, nospace, unsafe )
	if type( say_cmd ) == "string" then say_cmd = { say_cmd } end
	local obj = terminalCommand( command, fn, say_cmd, hide_say, nospace, unsafe )
	obj:addParam{ type=terminalIB.cmds.CallingPlayerArg }
	terminal.cmdsByCategory[ category ] = terminal.cmdsByCategory[ category ] or {}
	for cat, cmds in pairs( terminal.cmdsByCategory ) do
		for i=1, #cmds do
			if cmds[i].cmd == command then
				table.remove( terminal.cmdsByCategory[ cat ], i )
				break
			end
		end
	end
	table.insert( terminal.cmdsByCategory[ category ], obj )
	obj.category = category
	obj.say_cmd = say_cmd
	obj.hide_say = hide_say
	return obj
end

local function cc_terminal( ply, command, argv )
	local argn = #argv

	if argn == 0 then
		terminalIB.console( ply, "No command entered. If you need help, please type \"terminal help\" in your console." )
	else
		-- TODO, need to make this cvar hack actual commands for sanity and autocomplete
		-- First, check if this is a cvar and they just want the value of the cvar
		local cvar = terminal.cvars[ argv[ 1 ]:lower() ]
		if cvar and not argv[ 2 ] then
			terminalIB.console( ply, "\"terminal " .. argv[ 1 ] .. "\" = \"" .. GetConVarString( "terminal_" .. cvar.cvar ) .. "\"" )
			if cvar.help and cvar.help ~= "" then
				terminalIB.console( ply, cvar.help .. "\n  CVAR generated by terminal" )
			else
				terminalIB.console( ply, "  CVAR generated by terminal" )
			end
			return
		elseif cvar then -- Second, check if this is a cvar and they specified a value
			local args = table.concat( argv, " ", 2, argn )
			if ply:IsValid() then
				-- Workaround: gmod seems to choke on '%' when sending commands to players.
				-- But it's only the '%', or we'd use terminalIB.makePatternSafe instead of this.
				ply:ConCommand( "terminal_" .. cvar.cvar .. " \"" .. args:gsub( "(%%)", "%%%1" ) .. "\"" )
			else
				cvar.obj:SetString( argv[ 2 ] )
			end
			return
		end
		terminalIB.console( ply, "Invalid command entered. If you need help, please type \"terminal help\" in your console." )
	end
end
terminalIB.cmds.addCommand( "terminal", cc_terminal )

function terminal.help( ply )
	terminalIB.console( ply, "terminal Help:" )
	terminalIB.console( ply, "If a command can take multiple targets, it will usually let you use the keywords '*' for target" )
	terminalIB.console( ply, "all, '^' to target yourself, '@' for target your picker, '$<userid>' to target by ID (steamid," )
	terminalIB.console( ply, "uniqueid, userid, ip), '#<group>' to target users in a specific group, and '%<group>' to target" )
	terminalIB.console( ply, "users with access to the group (inheritance counts). IE, terminal slap #user slaps all players who are" )
	terminalIB.console( ply, "in the default guest access group. Any of these keywords can be preceded by '!' to negate it." )
	terminalIB.console( ply, "EG, terminal slap !^ slaps everyone but you." )
	terminalIB.console( ply, "You can also separate multiple targets by commas. IE, terminal slap bob,jeff,henry.")
	terminalIB.console( ply, "All commands must be preceded by \"terminal \", ie \"terminal slap\"" )
	terminalIB.console( ply, "\nCommand Help:\n" )

	for category, cmds in pairs( terminal.cmdsByCategory ) do
		local lines = {}
		for _, cmd in ipairs( cmds ) do
			local tag = cmd.cmd
			if cmd.manual then tag = cmd.access_tag end
			if terminalIB.ucl.query( ply, tag ) then
				local usage
				if not cmd.manual then
					usage = cmd:getUsage( ply )
				else
					usage = cmd.helpStr
				end
				table.insert( lines, string.format( "\to %s %s", cmd.cmd, usage:Trim() ) )
			end
		end

		if #lines > 0 then
			table.sort( lines )
			terminalIB.console( ply, "\nCategory: " .. category )
			for _, line in ipairs( lines ) do
				terminalIB.console( ply, line )
			end
			terminalIB.console( ply, "" ) -- New line
		end
	end


	terminalIB.console( ply, "\n-End of help\nterminal version: " .. terminalIB.pluginVersionStr( "terminal" ) .. "\n" )
end
local help = terminal.command( "Utility", "terminal help", terminal.help )
help:help( "Shows this help." )
help:defaultAccess( terminalIB.ACCESS_ALL )

function terminal.dumpTable( t, indent, done )
	done = done or {}
	indent = indent or 0
	local str = ""

	for k, v in pairs( t ) do
		str = str .. string.rep( "\t", indent )

		if type( v ) == "table" and not done[ v ] then
			done[ v ] = true
			str = str .. tostring( k ) .. ":" .. "\n"
			str = str .. terminal.dumpTable( v, indent + 1, done )

		else
			str = str .. tostring( k ) .. "\t=\t" .. tostring( v ) .. "\n"
		end
	end

	return str
end

function terminal.uteamEnabled()
	return terminalIB.isSandbox() and GAMEMODE.Name ~= "DarkRP"
end