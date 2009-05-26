-- Stranded Space RP ULX Modules

Msg("Loading modules.lua\n")

ulx.setCategory( "SSRP" )

-- Join Class
function ulx.cc_class(ply, command, argv, args)
	if #argv < 1 then
		ply:SendMessage(ulx.LOW_ARGS, 3, Color(200,0,0,255))
		return
	end
	
	-- TeamID, Player Limit, Join Message, Model
	local classList = {
		["citizen"] =		{1, 0, "You are now a Citizen."},
		["cop"] =			{2, 0, "You are now a Cop."},
		["gangter"] =		{3, 0, "You are now a Gangster."},
		["weaponmith"] =	{4, 2, "You are now a Weaponsmith."},
		["doctor"] =		{5, 2, "You are now a Doctor."},
		["mayor"] =			{6, 1, "You are now the Mayor!"},
		["mobbo"] =			{7, 1, "You are now the Mob Boss!"}
	}
	
	-- To eleminate variations, string is made lower case and the letter s and spaces are stripped.
	local class = argv[1]:lower()
	class = class:gsub("s", "")
	class = class:gsub(" ", "")
	
	local classid = classList[class][1]
	local classlimit = classList[class][2]
	local classmessage = classList[class][3]
	
	if ((classlimit == 0) or (team.NumPlayers(classid) < classlimit)) then
		ply:SetTeam(classid)
		ply:Kill()
		ply:SendMessage(classmessage,3,Color(255,255,255,255))
	else
		ply:SendMessage("There are too many players in this class.", 3, Color(200,0,0,255))
	end
end
ulx.concommand( "class", ulx.cc_class, "<class> - Changes you to the specified class.", ULib.ACCESS_ADMIN, "!class", _, ulx.ID_HELP )

-- Warrant
function ulx.cc_warrant(ply, command, argv, args)
	if #argv < 1 then
		ply:SendMessage(ulx.LOW_ARGS, 3, Color(200,0,0,255))
		return
	end
	
	if (ply:Team() == 6) then
		local targets, err = ULib.getUsers( argv[ 1 ], _, true, ply ) -- Enable keywords
		if not targets then
			ply:SendMessage(err, 3, Color(200,0,0,255))
			return
		end
		
		for _, v in ipairs( targets ) do
			ulx.logUserAct( ply, v, "#A warranted #T." )
			v.Warranted = true
		end
	else
		ply:SendMessage('You must be the Mayor to use this command.', 3, Color(200,0,0,255))
	end
end
ulx.concommand( "warrant", ulx.cc_warrant, "<user(s)> - Warrants the specified players.", ULib.ACCESS_ADMIN, "!warrant", _, ulx.ID_HELP )

-- Unwarrant
function ulx.cc_unwarrant(ply, command, argv, args)
	if #argv < 1 then
		ply:SendMessage(ulx.LOW_ARGS, 3, Color(200,0,0,255))
		return
	end
	
	if (ply:Team() == 6) then
		local targets, err = ULib.getUsers( argv[ 1 ], _, true, ply ) -- Enable keywords
		if not targets then
			ply:SendMessage(err, 3, Color(200,0,0,255))
			return
		end
		
		for _, v in ipairs( targets ) do
			ulx.logUserAct( ply, v, "#A unwarranted #T." )
			v.Warranted = false
		end
	else
		ply:SendMessage('You must be the Mayor to use this command.', 3, Color(200,0,0,255))
	end
end
ulx.concommand( "unwarrant", ulx.cc_unwarrant, "<user(s)> - Unwarrants the specified players.", ULib.ACCESS_ADMIN, "!unwarrant", _, ulx.ID_HELP )

-- List Warrants
function ulx.cc_warrants(ply, command, argv, args)
	for k, v in pairs(player.GetAll()) do
		if v.Warranted then
			ULib.tsay(ply, v:Nick(), true)
		end
	end
end
ulx.concommand( "warrants", ulx.cc_warrants, " - Lists all current warrants.", ULib.ACCESS_ADMIN, "!warrants", _, ulx.ID_HELP )

-- Jail Player
function ulx.cc_rpjail(ply, command, argv, args)
	if #argv < 1 then
		ply:SendMessage(ulx.LOW_ARGS, 3, Color(200,0,0,255))
		return
	end
	
	local targets, err = ULib.getUsers( argv[ 1 ], _, true, ply ) -- Enable keywords
	if not targets then
		ply:SendMessage(err, 3, Color(200,0,0,255))
		return
	end
	
	for _, v in ipairs( targets ) do
		ulx.logUserAct( ply, v, "#A rpjailed #T." )
		v:Jail()
	end
end
ulx.concommand( "rpjail", ulx.cc_rpjail, "<user(s)> - Warrants the specified players.", ULib.ACCESS_ADMIN, "!rpjail", _, ulx.ID_HELP )
