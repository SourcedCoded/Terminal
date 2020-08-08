if not terminal then
	terminal = {}
	include( "terminal/sh_defines.lua" ) include( "terminal/cl_lib.lua" ) include( "terminal/sh_base.lua" )

	local sh_modules = file.Find( "terminal/modules/sh/*.lua", "LUA" )
	local cl_modules = file.Find( "terminal/modules/cl/*.lua", "LUA" )
	for _, file in ipairs( cl_modules ) do
		Msg( "[terminal] Loading CLIENT module: " .. file .. "\n" )
		include( "terminal/modules/cl/" .. file )
	end
	for _, file in ipairs( sh_modules ) do
		Msg( "[terminal] Loading SHARED module: " .. file .. "\n" )
		include( "terminal/modules/sh/" .. file )
	end
end