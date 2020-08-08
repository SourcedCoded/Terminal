local files = {}

files["adverts.txt"] =
[[; Here's where you put advertisements
;
; Whether an advertisement is a center advertisement (csay) or text box advertisement (tsay) is determined by
; whether or not the "time_on_screen" key is present. If it is present, it's a csay.
;
; The 'time' argument inside a center advertisement and the number following a chat advertisement are the
; time it takes between each showing of this advertisement in seconds. Set it to 300 and the advertisement
; will show every five minutes.
;
; If you want to make it so that one advertisement is shown and then will always be followed by another,
; put them in a table. For example, if you add the following to the bottom of the file, A will always show
; first followed by B.
; "my_group"
; {
;     {
;         "text" "Advertisement A"
;         "time" "200"
;     }
;     {
;         "text" "Advertisement B"
;         "time" "300"
;     }
; }
]]

files["banmessage.txt"] = [[
; Possible variables here are as follows:
; {{BANNED_BY}} - The person (and steamid) who initiated the ban
; {{BAN_START}} - The date/time of the ban, in the server's time zone
; {{REASON}} - The ban reason
; {{TIME_LEFT}} - The time left in the ban
; {{STEAMID}} - The banned player's Steam ID (excluding non-number characters)
; {{STEAMID64}} - The banned player's 64-bit Steam ID
; The two steam ID vairables are useful for constructing URLs for appealing bans
-------===== [ BANNED ] =====-------
---= Reason =---
{{REASON}}
---= Time Left =---
{{TIME_LEFT}}
]]


files["banreasons.txt"] =
[[; This file is used to store default reasons for kicking and banning users.
; These reasons show up in console autocomplete and in XGUI dropdowns.
Spammer
Crashed server
Minge
Griefer
Foul language
Disobeying the rules
]]

files["config.txt"] =
[[;Any of the settings in here can be added to the per-map or per-gamemode configs.
;To add per-map and per-gamemode configs, create data/terminal/maps/<mapname>/config.txt
;and data/terminal/gamemodes/<gamemodename>/config.txt files. This can also be done for
;All other configuration files (adverts.txt, downloads.txt, gimps.txt, votemaps.txt)
;All configurations add to each other except gimps and votemaps, which takes the most
;specific config only.
;Any line starting with a ';' is a comment!
terminal showMotd 2 ; MOTD mode
; MOTD modes:
; 0 - OFF No MOTD shown
; 1 - FILE Show the players the contents of the file from the 'motdfile' cvar
; 2 - GENERATOR Uses the MOTD generator to create a MOTD for the player (use XGUI for this)
; 3 - URL Show the player the URL specified by the 'motdurl' cvar
; In a URL, you can use %curmap% and %steamid% in the URL to have it automagically parsed for you (eg, server.com/?map=%curmap%&id=%steamid%).
terminal motdfile terminal_motd.txt ; The MOTD to show, if using a file. Put this file in the root of the garry's mod directory.
terminal motdurl ulyssesmod.net ; The MOTD to show, if using a URL.
terminal chattime 0 ; Players can only chat every x seconds (anti-spam). 0 to disable
terminal meChatEnabled 1 ; Allow players to use '/me' in chat. 0 = Disabled, 1 = Sandbox only (Default), 2 = Enabled
; This is what the players will see when they join, set it to "" to disable.
; You can use %host% and %curmap% in your text and have it automagically parsed for you
terminal welcomemessage "Welcome to %host%! We're playing %curmap%."

terminal logfile 1
tmerinal logEvent 1
terminal logChat 1 
terminal logSpawns 1 
terminal logJoinLeaveEcho 1
terminal logDir "terminal_logs" 
terminal logEcho 1

terminal logEchoColors 1 
terminal logEchoColorDefault "151 211 255"
terminal logEchoCOlorConsole "0 0 0"
terminal logEchoColorSelf "75 0 130"
terminal logEchoColorEveryone "0 128 238"

terminal rslotsMode 0
terminal rslots 4
terminal rslotsVisible 0

terminal votemapEnabled 1
terminal votemapMintime 10
terminal votemapWaittime 5
terminal votemapSuccessratio 0.4
terminal votemapVetotime 30
terminal votemapMapmode 1

terminal voteEcho 0

terminal svotemapSuccessratio 0.4
terminal svotemapMinvotes 0

terminal votebanSuccessratio 0.4
terminal votebanMinvotes 3

files["downloads.txt"] =
[[; You can add forced downloads here. Add as many as you want, one file or
; folder per line. You can also add these to your map- or game-specific files.
; You can add a folder to add all files inside that folder recursively.
; Any line starting with ';' is a comment and WILL NOT be processed!!!
; Examples:
;sound/cheeseman.mp3 <-- Adds the file 'cheeseman.mp3' under the sound folder
;sound/my_music <-- Adds all files within the my_music folder, inside the sound folder
]]

files["gimps.txt"] =
[[; Add gimp says in this file, one per line.
; Any line starting with a ';' is a comment
I'm a llama.
How do you fly?
baaaaaaaaaah.
Llama power!
Llamas are the coolest!
What's that gun to move stuff?
I'm a soulless approximation of a cheese danish!
Hold up guys, I'm watching The Powerpuff Girls.
Not yet, I'm being attacked by an... OH CRAP!
]]

files["sbox_limits.txt"] =
[[;The number by each cvar indicates the maximum value for the slider in XGUI.
|Sandbox
sbox_maxballoons 100
sbox_maxbuttons 200
sbox_maxdynamite 75
sbox_maxeffects 200
sbox_maxemitters 100
sbox_maxhoverballs 200
sbox_maxlamps 50
sbox_maxlights 50
sbox_maxnpcs 50
sbox_maxprops 1000
sbox_maxragdolls 50
sbox_maxsents 1024
sbox_maxspawners 50
sbox_maxthrusters 200
sbox_maxturrets 50
sbox_maxvehicles 50
sbox_maxwheels 200
|Other
sbox_maxdoors 100
sbox_maxhoverboards 10
sbox_maxkeypads 100
sbox_maxwire_keypads 100
sbox_maxpylons 100
|Wire
sbox_maxwire_addressbuss 100
sbox_maxwire_adv_emarkers 50
sbox_maxwire_adv_inputs 100
sbox_maxwire_buttons 100
sbox_maxwire_cameracontrollers 100
sbox_maxwire_cd_disks 100
sbox_maxwire_cd_locks 100
sbox_maxwire_cd_rays 100
sbox_maxwire_clutchs 10
sbox_maxwire_colorers 100
sbox_maxwire_consolescreens 100
sbox_maxwire_cpus 10
sbox_maxwire_damage_detectors 50
sbox_maxwire_data_satellitedishs 100
sbox_maxwire_data_stores 100
sbox_maxwire_data_transferers 100
sbox_maxwire_dataplugs 100
sbox_maxwire_dataports 100
sbox_maxwire_datarates 100
sbox_maxwire_datasockets 100
sbox_maxwire_deployers 5
sbox_maxwire_detonators 100
sbox_maxwire_dhdds 100
sbox_maxwire_digitalscreens 100
sbox_maxwire_dual_inputs 100
sbox_maxwire_dynamic_buttons 100
sbox_maxwire_egps 10
sbox_maxwire_emarkers 30
sbox_maxwire_exit_points 10
sbox_maxwire_explosives 50
sbox_maxwire_expressions 100
sbox_maxwire_extbuss 100
sbox_maxwire_eyepods 15
sbox_maxwire_forcers 100
sbox_maxwire_freezers 50
sbox_maxwire_fx_emitters 100
sbox_maxwire_gate_angles 30
sbox_maxwire_gate_arithmetics 30
sbox_maxwire_gate_arrays 30
sbox_maxwire_gate_bitwises 30
sbox_maxwire_gate_comparisons 30
sbox_maxwire_gate_entitys 30
sbox_maxwire_gate_logics 30
sbox_maxwire_gate_memorys 30
sbox_maxwire_gate_rangers 30
sbox_maxwire_gate_selections 30
sbox_maxwire_gate_strings 30
sbox_maxwire_gate_times 30
sbox_maxwire_gate_trigs 30
sbox_maxwire_gate_vectors 30
sbox_maxwire_gates 30
sbox_maxwire_gimbals 10
sbox_maxwire_gpss 50
sbox_maxwire_gpus 10
sbox_maxwire_grabbers 100
sbox_maxwire_graphics_tablets 100
sbox_maxwire_gyroscopes 50
sbox_maxwire_hdds 100
sbox_maxwire_holoemitters 50
sbox_maxwire_hologrids 100
sbox_maxwire_hoverballs 30
sbox_maxwire_hoverdrivecontrolers 5
sbox_maxwire_hudindicators 100
sbox_maxwire_hydraulics 16
sbox_maxwire_igniters 100
sbox_maxwire_indicators 100
sbox_maxwire_inputs 100
sbox_maxwire_keyboards 100
sbox_maxwire_keypads 50
sbox_maxwire_lamps 50
sbox_maxwire_las_receivers 100
sbox_maxwire_latchs 15
sbox_maxwire_levers 50
sbox_maxwire_lights 10
sbox_maxwire_locators 30
sbox_maxwire_motors 50
sbox_maxwire_nailers 100
sbox_maxwire_numpads 100
sbox_maxwire_oscilloscopes 100
sbox_maxwire_outputs 50
sbox_maxwire_pixels 100
sbox_maxwire_plugs 100
sbox_maxwire_pods 100
sbox_maxwire_radios 100
sbox_maxwire_rangers 50
sbox_maxwire_relays 100
sbox_maxwire_screens 100
sbox_maxwire_sensors 100
sbox_maxwire_simple_explosives 100
sbox_maxwire_sockets 100
sbox_maxwire_soundemitters 50
sbox_maxwire_spawners 50
sbox_maxwire_speedometers 50
sbox_maxwire_spus 10
sbox_maxwire_target_finders 100
sbox_maxwire_textreceivers 50
sbox_maxwire_textscreens 100
sbox_maxwire_thrusters 50
sbox_maxwire_trails 100
sbox_maxwire_turrets 100
sbox_maxwire_twoway_radios 100
sbox_maxwire_users 100
sbox_maxwire_values 100
sbox_maxwire_vectorthrusters 50
sbox_maxwire_vehicles 100
sbox_maxwire_watersensors 100
sbox_maxwire_waypoints 30
sbox_maxwire_weights 100
sbox_maxwire_wheels 30
]]
files["votemaps.txt"] =
[[; List of maps that are either included in the votemap command or excluded from it
; Make sure to set votemapMapmode in config.txt to what you want.
background01
background02
background03
background04
background05
background06
background07
credits
intro
test_hardware
test_speakers
]]

files["motd.txt"] =
[[; These settings describe the default configuration and text to be shown on the MOTD. This only applies if terminal showMotd is set to 1.
; All style configuration is set, and the values must be valid CSS.
; Under info, you may have as many sections as you like. Valid types include "text", "ordered_list", "list".
; Special type "mods" will automatically list workshop and regular addons in an unordered list.
; Special type "admins" will automatically list all users within the groups specified in contents.
; For an example of all of these items, please see the default file generated in terminal\lua\data.lua
"info"
{
	"description" "Welcome to our server. Enjoy your stay!"
	{
		"title" "About This Server"
		"type" "text"
		"contents"
		{
			"This server is running terminal."
			"To edit this default MOTD, open XGUI->Settings->Server->terminal MOTD, or edit data\terminal\motd.txt."
		}
	}
	{
		"title" "Rules"
		"type" "ordered_list"
		"contents"
		{
			"DON'T MESS WITH OTHER PLAYERS' STUFF. If they want help, they'll ask!"
			"Don't spam."
			"Have fun."
		}
	}
	{
		"title" "Reporting Rulebreakers"
		"type" "list"
		"contents"
		{
			"Contact an available admin on this server and let them know."
			"Use @ before typing a chat message to send it to admins."
			"If no admin is available, note the players name and the current time, then let an admin know as soon as they are available."
		}
	}
	{
		"title" "Installed Addons"
		"type" "mods"
	}
	{
		"title" "Our Admins"
		"type" "admins"
		"contents"
		{
			"superadmin"
			"admin"
		}
	}
}
"style"
{
	"borders"
	{
		"border_color" "#000000"
		"border_thickness" "2px"
	}
	"colors"
	{
		"background_color" "#dddddd"
		"header_color" "#82a0c8"
		"header_text_color" "#ffffff"
		"section_text_color" "#000000"
		"text_color" "#000000"
	}
	"fonts"
	{
		"server_name"
		{
			"family" "Impact"
			"size" "32px"
			"weight" "normal"
		}
		"subtitle"
		{
			"family" "Impact"
			"size" "20px"
			"weight" "normal"
		}
		"section_title"
		{
			"family" "Impact"
			"size" "26px"
			"weight" "normal"
		}
		"regular"
		{
			"family" "Tahoma"
			"size" "12px"
			"weight" "normal"
		}
	}
}
]]

ULib.fileCreateDir( "data/terminal" )
for filename, content in pairs( files ) do
	local filepath = "data/terminal/" .. filename
	if not ULib.fileExists( filepath, true ) then
		ULib.fileWrite( filepath, content )
	end
end
files = nil