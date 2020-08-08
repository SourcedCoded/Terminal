if not terminal then
	terminal = {}

	include( "data.lua" )

	local sv_modules = file.Find( "terminal/modules/*.lua", "LUA" )
	local sh_modules = file.Find( "terminal/modules/sh/*.lua", "LUA" )
	local cl_modules = file.Find( "terminal/modules/cl/*.lua", "LUA" )

	Msg( "///////////////////////////////\n" )
	Msg( "//       Terminal Admin Mod       //\n" )
	Msg( "///////////////////////////////\n" )
	Msg( "// Loading...                //\n" )

	Msg( "//  sh_defines.lua           //\n" )
	include( "sh_defines.lua" )
	Msg( "//  lib.lua                  //\n" )
	include( "lib.lua" )
	Msg( "//  base.lua                 //\n" )
	include( "base.lua" )
	Msg( "//  sh_base.lua              //\n" )
	include( "sh_base.lua" )
	Msg( "//  log.lua                  //\n" )
	include( "log.lua" )
	for _, file in ipairs( sv_modules ) do
		Msg( "//  MODULE: " .. file .. string.rep( " ", 17 - file:len() ) .. "//\n" )
		include( "modules/" .. file )
	end
	for _, file in ipairs( sh_modules ) do
		Msg( "//  MODULE: " .. file .. string.rep( " ", 17 - file:len() ) .. "//\n" )
		include( "modules/sh/" .. file )
	end
	Msg( "//  end.lua                  //\n" )
	include( "end.lua" )
	Msg( "// Load Complete!            //\n" )
	Msg( "///////////////////////////////\n" )

	AddCSLuaFile( "terminal/cl_init.lua" )
	AddCSLuaFile( "terminal/sh_defines.lua" )
	AddCSLuaFile( "terminal/sh_base.lua" )
	AddCSLuaFile( "terminal/cl_lib.lua" )
	for _, file in ipairs( cl_modules ) do
		AddCSLuaFile( "terminal/modules/cl/" .. file )
	end

	for _, file in ipairs( sh_modules ) do
		AddCSLuaFile( "terminal/modules/sh/" .. file )
	end
end