ChatCommands = {}

function AddChatCommand(cmd, callback)
	table.insert(ChatCommands, { cmd = cmd, callback = callback})
end

function TalkToRange(msg, pos, size)
	local ents = ents.FindInSphere(pos, size)

	for k, v in pairs(ents) do
		if v:IsPlayer() then
			v:ChatPrint(msg)
			--v:PrintMessage(2, msg)
		end
	end
end

function FindPlayer(info)
	local pls = player.GetAll()

	-- Find by Partial Nick
	for k, v in pairs(pls) do
		if string.find(string.lower(v:Name()), string.lower(tostring(info))) ~= nil then
			return v
		end
	end
	return nil
end

function GM:PlayerSay(ply, text, public)
	self.BaseClass:PlayerSay(ply, text, public)
	
	for k, v in pairs(ChatCommands) do
		if v.cmd == string.Explode(" ", string.lower(text))[1] then
			return v.callback(ply, text)
		end
	end
	
	if not public then
		return text
	end
	
	local i, j = string.find(text, '//')
	if i == 1 then
		return string.sub(text, 3, string.len(text))
	end
	
	TalkToRange(ply:Name() .. ": " .. text, ply:GetPos(), 400)
	return ''
end

-- Chat Commands
function Whisper(ply, text)
	TalkToRange('(Whisper)' .. ply:Name() .. ": " .. string.sub(text, 4, string.len(text)), ply:GetPos(), 150)
	return ''
end
AddChatCommand('/w', Whisper)

function Yell(ply, text)
	TalkToRange('(Yell) ' .. ply:Name() .. ": " .. string.sub(text, 4, string.len(text)), ply:GetPos(), 1000)
	return ''
end
AddChatCommand('/y', Yell)

function PersonalMessage(ply, text)
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
	
	local i, j = string.find(text, args[2])
	local msg = 'PM from ' .. ply:Name() .. ': ' .. string.sub(text, j+2, string.len(text))
	
	target:ChatPrint(msg)
	target:PrintMessage(2, msg)
	
	ply:ChatPrint('PM to' .. target:Name() .. ': ' .. string.sub(text, j+2, string.len(text)))
	
	Msg('PM from ' .. ply:Name() .. ' to ' .. target:Name() .. ': ' .. string.sub(text, j+2, string.len(text)) .. '\n')
	
	return ''
end
AddChatCommand('/pm', PersonalMessage)

-- Class Commands
function Citizen(ply, text)
	ply:SetTeam(1)
	ply:Kill()
	ply:SendMessage('You are now a Citizen.',3,Color(255,255,255,255))
	return ''
end
AddChatCommand('/citizen', Citizen)

function Cop(ply, text)
	ply:SetTeam(2)
	ply:Kill()
	ply:SendMessage('You are now a Cop.',3,Color(255,255,255,255))
	return ''
end
AddChatCommand('/cop', Cop)

function Gangster(ply, text)
	ply:SetTeam(3)
	ply:Kill()
	ply:SendMessage('You are now a Gangster.',3,Color(255,255,255,255))
	return ''
end
AddChatCommand('/gangster', Gangster)

function Weaponsmith(ply, text)
	if (team.NumPlayers(4) < 2) then
		ply:SetTeam(4)
		ply:Kill()
		ply:SendMessage('You are now a Weaponsmith.',3,Color(255,255,255,255))
	else
		ply:SendMessage("There are too many players in this class.", 3, Color(200,0,0,255))
	end
	return ''
end
AddChatCommand('/weaponsmith', Weaponsmith)

function Doctor(ply, text)
	if (team.NumPlayers(5) < 2) then
		ply:SetTeam(5)
		ply:Kill()
		ply:SendMessage('You are now a Doctor.',3,Color(255,255,255,255))
	else
		ply:SendMessage("There are too many players in this class.", 3, Color(200,0,0,255))
	end
	return ''
end
AddChatCommand('/doctor', Doctor)

function Mayor(ply, text)
	if (team.NumPlayers(6) < 1) then
		local class = ''
		for k,v in pairs(ply:GetWeapons()) do
			class = v:GetClass()
			if not table.HasValue(GMS.Tools, class) and not table.HasValue(GMS.NoDrop, class) then -- It's a bona-fied WEAPON.
				if table.HasValue(ply.Tools, class) then
					for k,v in ipairs(ply.Tools) do
						if v == class then
							table.remove(ply.Tools, k)
						end
					end
				end
			end
		end
		
		ply:SetTeam(6)
		ply:Kill()
		ply:SendMessage('You are now the Mayor!',3,Color(255,255,255,255))
	else
		ply:SendMessage("There are too many players in this class.", 3, Color(200,0,0,255))
	end
	return ''
end
AddChatCommand('/mayor', Mayor)

function MobBoss(ply, text)
	if (team.NumPlayers(7) < 1) then
		ply:SetTeam(7)
		ply:Kill()
		ply:SendMessage('You are now the Mob Boss!',3,Color(255,255,255,255))
	else
		ply:SendMessage("There are too many players in this class.", 3, Color(200,0,0,255))
	end
	return ''
end
AddChatCommand('/mobboss', MobBoss)

-- Warranting Commands
function Warrant(ply, text)
	if not ply:Team() == 6 and not ply:IsAdmin() then
		ply:SendMessage('You must be the Mayor to use this command.', 3, Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
	
	if not target then
		ply:SendMessage('Player not found.', 3, Color(200,0,0,255))
		return ''
	end
	
	target.Warranted = true
	
	local pls = player.GetAll()
	for k, v in pairs(pls) do
		v:SendMessage(ply:Name() .. ' warranted ' .. target:Name() .. '.',3,Color(255,255,255,255))
	end
	MsgAll(ply:Name() .. ' warranted ' .. target:Name() .. '.\n')
	
	return ''
end
AddChatCommand('/warrant', Warrant)

function UnWarrant(ply, text)
	if not ply:Team() == 6 and not ply:IsAdmin() then
		ply:SendMessage('You must be the Mayor to use this command.', 3, Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
	
	if not target then
		ply:SendMessage('Player not found.', 3, Color(200,0,0,255))
		return ''
	end
	
	target.Warranted = false
	
	local pls = player.GetAll()
	for k, v in pairs(pls) do
		v:SendMessage(ply:Name() .. ' unwarranted ' .. target:Name() .. '.',3,Color(255,255,255,255))
	end
	MsgAll(ply:Name() .. ' unwarranted ' .. target:Name() .. '.\n')
	
	return ''
end
AddChatCommand('/unwarrant', UnWarrant)

function Warrants(ply, text)
	local output = 'Warranted players:'
	
	local pls = player.GetAll()
	for k, v in pairs(pls) do
		if v.Warranted then
			output = output .. '\n' .. v:Name()
		end
	end
	
	ply:ChatPrint(output)
	ply:PrintMessage(2, output)
	return ''
end
AddChatCommand('/warrants', Warrants)

-- Money Commands
function GiveMoney(ply, text)
	local args = string.Explode(' ', text)
	local ammount = tonumber(args[2]) or 0
	local plyMoney = ply:GetMoney()
	
	if ammount < 10 then
		ply:SendMessage("You must give at least $10.",3,Color(200,0,0,255))
		return ''
	end
	
	if plyMoney < ammount then
		ply:SendMessage("You don't have that much money!",3,Color(200,0,0,255))
		return ''
	end
	
	local tr = ply:TraceFromEyes(150)
	local target = tr.Entity
	if not target or not target:IsPlayer() then
		ply:SendMessage("Aim at a player to give money to.",3,Color(200,0,0,255))
		return ''
	end
	
	ply:DecMoney(ammount)
	target:IncMoney(ammount)
	
	ply:SendMessage("You gave $" .. ammount .. ' to ' .. target:Name() .. '.',10,Color(255,255,255,255))
	ply:PrintMessage(2, "You gave $" .. ammount .. ' to ' .. target:Name() .. '.')
	target:SendMessage("You've recived $" .. ammount .. ' from ' .. ply:Name() .. '.',10,Color(255,255,255,255))
	target:PrintMessage(2, "You've recived $" .. ammount .. ' from ' .. ply:Name() .. '.')
	Msg(ply:Name() .. ' gave $' .. ammount .. ' to ' .. target:Name() .. '.\n')
	
	return ''
end
AddChatCommand('/givemoney', GiveMoney)

function DropMoney(ply, text)
	local args = string.Explode(' ', text)
	local ammount = tonumber(args[2]) or 0
	local plyMoney = ply:GetMoney()
	
	if ammount < 10 then
		ply:SendMessage("You must drop at least $10.",3,Color(200,0,0,255))
		return ''
	end
	
	if plyMoney < ammount then
		ply:SendMessage("You don't have that much money!",3,Color(200,0,0,255))
		return ''
	end
	
	local tr = ply:TraceFromEyes(150)
	if tr.HitWorld then
		local ent = ents.Create("GMS_Money")
		ent:SetPos(tr.HitPos)
		ent:Spawn()
		ent:SetAmmount(ammount)
		
		ply:DecMoney(ammount)
	else
		ply:SendMessage("Aim at the ground to spawn.",3,Color(200,0,0,255))
	end
	
	return ''
end
AddChatCommand('/dropmoney', DropMoney)

function PrintMoney(ply, text)
	local args = string.Explode(' ', text)
	local ammount = tonumber(args[2]) or 0
	
	if not ply:IsAdmin() then
		ply:SendMessage("You must be an admin to use this command.",3,Color(200,0,0,255))
		return ''
	end
	
	local tr = ply:TraceFromEyes(150)
	if tr.HitWorld then
		local ent = ents.Create("GMS_Money")
		ent:SetPos(tr.HitPos)
		ent:Spawn()
		ent:SetAmmount(ammount)
	else
		ply:SendMessage("Aim at the ground to spawn.",3,Color(200,0,0,255))
	end
	
	return ''
end
AddChatCommand('/printmoney', PrintMoney)

-- Door Commands
function AddOwner(ply, text)
	ply:ChatPrint(ply:Name() .. ': ' .. text)
	
	local tr = ply:TraceFromEyes(150)
	if tr.Entity:IsValid() and tr.Entity:IsDoor() then
		if player.GetByID( tr.Entity:GetNWInt('Owner1') ) != ply and not ply:IsAdmin() then
			ply:SendMessage("You don't own this door.",3,Color(200,0,0,255))
			return ''
		end
	else
		ply:SendMessage("Aim at a door.",3,Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
	
	if not target or not target:IsPlayer() then
		ply:SendMessage("Player not found.",3,Color(200,0,0,255))
		return ''
	end
	
	tr.Entity:AddOwner(target)
	
	local msg = 'Added ' .. target:Name() .. ' to door.'
	ply:SendMessage(msg,3,Color(255,255,255,255))
	ply:PrintMessage(HUD_PRINTCONSOLE, msg)
	
	return ''
end
AddChatCommand('/addowner', AddOwner)

function RemoveOwner(ply, text)
	ply:ChatPrint(ply:Name() .. ': ' .. text)
	
	local tr = ply:TraceFromEyes(150)
	if tr.Entity:IsValid() and tr.Entity:IsDoor() then
		if player.GetByID( tr.Entity:GetNWInt('Owner1') ) != ply and not ply:IsAdmin() then
			ply:SendMessage("You don't own this door.",3,Color(200,0,0,255))
			return ''
		end
	else
		ply:SendMessage("Aim at a door.",3,Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
	
	if not target or not target:IsPlayer() then
		ply:SendMessage("Player not found.",3,Color(200,0,0,255))
		return ''
	end
	
	tr.Entity:RemoveOwner(target)
	
	local msg = 'Removed ' .. target:Name() .. ' from door.'
	ply:SendMessage(msg,3,Color(255,255,255,255))
	ply:PrintMessage(HUD_PRINTCONSOLE, msg)
	
	return ''
end
AddChatCommand('/removeowner', RemoveOwner)

function Owners(ply, text)
	local tr = ply:TraceFromEyes(150)
	if tr.Entity:IsValid() and tr.Entity:IsDoor() then
		if not tr.Entity:IsOwner(ply) and not ply:IsAdmin() then
			ply:SendMessage("You don't own this door.",3,Color(200,0,0,255))
			return ''
		end
	else
		ply:SendMessage("Aim at a door.",3,Color(200,0,0,255))
		return ''
	end
	
	local output = 'Door Owners:'
	local num = tr.Entity:GetNWInt("OwnerNum") or 0
	local owner = nil
	for n = 1, num do
		owner = player.GetByID(tr.Entity:GetNWInt("Owner" .. n))
		if owner:IsPlayer() then
			output = output .. '\n' .. owner:Name()
		end
	end
	
	ply:ChatPrint(output)
	ply:PrintMessage(2, output)
	return ''
end
AddChatCommand('/owners', Owners)

function SetTitle(ply, text)
	ply:ChatPrint(ply:Name() .. ': ' .. text)
	
	local tr = ply:TraceFromEyes(150)
	if tr.Entity:IsValid() and tr.Entity:IsDoor() then
		if player.GetByID( tr.Entity:GetNWInt('Owner1') ) != ply and not ply:IsAdmin() then
			ply:SendMessage("You don't own this door.",3,Color(200,0,0,255))
			return ''
		end
	else
		ply:SendMessage("Aim at a door.",3,Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	
	local i, j = string.find(text, args[2])
	local title = string.sub(text, i, string.len(text))
	
	if string.len(title) > 50 then
		ply:SendMessage("Titles are limited to 50 characters.",3,Color(200,0,0,255))
		return ''
	end
	
	tr.Entity:SetNWString('title', title)
	ply:SendMessage('Door title set.',3,Color(255,255,255,255))
	
	return ''
end
AddChatCommand('/title', SetTitle)

function SetUnownable(ply, text)	
	local tr = ply:TraceFromEyes(150)
	if tr.Entity:IsValid() and tr.Entity:IsDoor() then
		if not ply:IsAdmin() then
			ply:SendMessage("You must be an admin to use this command.",3,Color(200,0,0,255))
			return ''
		end
	else
		ply:SendMessage("Aim at a door.",3,Color(200,0,0,255))
		return ''
	end
	
	local unownable = tr.Entity:GetNWBool('notOwnable') or false
	if unownable then
		tr.Entity:SetNWBool('notOwnable', false)
		ply:SendMessage('Door is now ownable.',3,Color(255,255,255,255))
	else
		tr.Entity:SetNWBool('notOwnable', true)
		ply:SendMessage('Door is now unownable.',3,Color(255,255,255,255))
		
		local owner = player.GetByID( tr.Entity:GetNWInt('Owner1') )
		if owner:IsPlayer() then
			tr.Entity:RemoveOwner(owner)
		end
	end
	
	return ''
end
AddChatCommand('/unownable', SetUnownable)

-- Hit Commands
function IssueHit(ply, text)	
	if ply:Team() == 7 then
		if GMS.MayorHitActive then
			ply:SendMessage('There is already a hit on the Mayor!', 3, Color(200,0,0,255))
			return ''
		end
		
		GMS.MayorHit()
		local pls = player.GetAll()
		for k, v in pairs(pls) do
			v:SendMessage(ply:Name() .. ' has issued a hit on the Mayor!', 10, Color(255,255,255,255))
		end
	elseif ply:Team() == 6 then
		if GMS.MobBossHitActive then
			ply:SendMessage('There is already a hit on the Mob Boss!', 3, Color(200,0,0,255))
			return ''
		end
		
		GMS.MobBossHit()
		local pls = player.GetAll()
		for k, v in pairs(pls) do
			v:SendMessage(ply:Name() .. ' has issued a hit on the Mob Boss!', 10, Color(255,255,255,255))
		end
	else
		ply:SendMessage('You must be the Mayor or Mob Boss to use this command.', 3, Color(200,0,0,255))
	end
	
	return ''
end
AddChatCommand('/hit', IssueHit)

-- Resource Commands
function MakeResource(ply, text)
	local args = string.Explode(' ', text)
	local resource = args[2]
	local amount = tonumber(args[3]) or 0
	
	if not ply:IsAdmin() then
		ply:SendMessage("You must be an admin to use this command.",3,Color(200,0,0,255))
		return ''
	end
	
	local tr = ply:TraceFromEyes(150)
	if tr.HitWorld then
		local ent = ents.Create("GMS_ResourceDrop")
		ent:SetPos(tr.HitPos)
		ent:Spawn()
		
		ent:SetContents(resource, amount)
	else
		ply:SendMessage("Aim at the ground to spawn.",3,Color(200,0,0,255))
	end
	
	return ''
end
AddChatCommand('/makeresource', MakeResource)
