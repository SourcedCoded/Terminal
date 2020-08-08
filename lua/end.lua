local function doMainCfg( path, noMount )
    terminalIB.execStringTerminalIB( terminalIB.stripComments( terminalIB.fileread( path, noMount ), ";"  ), true )
end
local function doDownloadCfg( path, noMount )
    if not terminal.addForcedDownload then
            return
    end

    local lines = terminalIB.explode( "\n+", terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ) )
    for _, line in ipairs( lines ) do
        line = line:Trim()
        if line:len() > 0 then
            terminal.addForcedDownload( terminal.stripQuotes( line ) )
        end
    end
end
local function doGimpCfg( path, noMount )
    if not terminal.clearGimpSays then
        return
    end
    terminal.clearGimpSays()
    local lines = terminalIB.explode( "\n+", terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ) )
    for _, line in ipairs( lines ) do
        line = line:Trim()
        if line:len() > 0 then
            terminal.addGimpSay( terminalIB.stripQuotes( line ) )
        end
    end
end
local function doAdvertCfg( path, noMount )
    if not terminal.addAdvert then
        return
    end
	local data_root, err = terminalIB.parseKeyValues( terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ) )
	if not data_root then Msg( "[terminal] Error in advert config: " .. err .. "\n" ) return end

	for group_name, row in pairs( data_root ) do
		if type( group_name ) == "number" then -- Must not be a group
			local color = Color( tonumber( row.red ) or terminalIB.DEFAULT_TSAY_COLOR.r, tonumber( row.green ) or terminalIB.DEFAULT_TSAY_COLOR.g, tonumber( row.blue ) or terminalIB.DEFAULT_TSAY_COLOR.b )
			terminal.addAdvert( row.text or "NO TEXT SUPPLIED FOR THIS ADVERT", tonumber( row.time ) or 300, _, color, tonumber( row.time_on_screen ) )
		else -- Must be a group
			if type( row ) ~= "table" then Msg( "[terminal] Error in advert config: Adverts are not properly formatted!\n" ) return end
			for i=1, #row do
				local row2 = row[ i ]
				local color = Color( tonumber( row2.red ) or 151, tonumber( row2.green ) or 211, tonumber( row2.blue ) or 255 )
				terminal.addAdvert( row2.text or "NO TEXT SUPPLIED FOR THIS ADVERT", tonumber( row2.time ) or 300, group_name, color, tonumber( row2.time_on_screen ) )
			end
		end
	end
end

local function doVotemapsCfg( path, noMount )
	-- Does the module exist for this?
	if not terminal.clearVotemaps then
		return
	end

	terminal.clearVotemaps()
	local lines = terminalIB.explode( "\n+", terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ) )
	for _, line in ipairs( lines ) do
		line = line:Trim()
		if line:len() > 0 then
			terminal.votemapAddMap( line )
		end
	end
end

local function doReasonsCfg( path, noMount )
	-- Does the module exist for this?
	if not terminal.addKickReason then
		return
	end

	local lines = terminalIB.explode( "\n+", terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ) )
	for _, line in ipairs( lines ) do
		line = line:Trim()
		if line:len() > 0 then
			terminal.addKickReason( terminalIB.stripQuotes( line ) )
		end
	end
end

local function doMotdCfg( path, noMount )
	-- Does the module exist for this?
	if not terminal.motd then
		return
	end

	local data_root, err = terminalIB.parseKeyValues( terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ) )
	if not data_root then Msg( "[terminal] Error in motd config: " .. err .. "\n" ) return end

	terminal.motdSettings = data_root
	terminal.populateMotdData()
end

local function doMessageCfg( path, noMount )
	local message = terminalIB.stripComments( terminalIB.fileRead( path, noMount ), ";" ):Trim()
	if message and message:find("%W") then
		terminalIB.BanMessage = message
	end
end

local function doCfg()
	local things_to_execute = { -- Indexed by name, value of function to execute
		["config.txt"] = doMainCfg,
		["downloads.txt"] = doDownloadCfg,
		["gimps.txt"] = doGimpCfg,
		["adverts.txt"] = doAdvertCfg,
		["votemaps.txt"] = doVotemapsCfg,
		["banreasons.txt"] = doReasonsCfg,
		["motd.txt"] = doMotdCfg,
		["banmessage.txt"] = doMessageCfg,
	}

	local gamemode_name = GAMEMODE.Name:lower()
	local map_name = game.GetMap()

	for filename, fn in pairs( things_to_execute ) do
		-- Global config
		if terminalIB.fileExists( "data/terminal/" .. filename ) then
			fn( "data/terminal/" .. filename )
		end

		-- Per gamemode config
		if terminalIB.fileExists( "data/terminal/gamemodes/" .. gamemode_name .. "/" .. filename, true ) then
			fn( "data/terminal/gamemodes/" .. gamemode_name .. "/" .. filename, true )
		end

		-- Per map config
		if terminalIB.fileExists( "data/terminal/maps/" .. map_name .. "/" .. filename, true ) then
			fn( "data/terminal/maps/" .. map_name .. "/" .. filename, true )
		end
	end

	terminalIB.namedQueueFunctionCall( "terminalConfigExec", hook.Call, terminal.HOOK_terminalDONELOADING, _ ) -- We're done loading! Wait a tick so the configs load.

	if not game.IsDedicated() then
		hook.Remove( "PlayerInitialSpawn", "terminalDoCfg" )
	end
end

if game.IsDedicated() then
	hook.Add( "Initialize", "terminalDoCfg", doCfg, HOOK_MONITOR_HIGH )
else
	hook.Add( "PlayerInitialSpawn", "terminalDoCfg", doCfg, HOOK_MONITOR_HIGH ) -- TODO can we make this initialize too?
end