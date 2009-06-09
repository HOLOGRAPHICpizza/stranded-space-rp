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
	
	ply:ChatPrint(ply:Name() .. ': ' .. text)
	
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
	if not ply:Team() == 6 then
		ply:SendMessage('You must be the Mayor to use this command.', 3, Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
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
	if not ply:Team() == 6 then
		ply:SendMessage('You must be the Mayor to use this command.', 3, Color(200,0,0,255))
		return ''
	end
	
	local args = string.Explode(' ', text)
	local target = FindPlayer(args[2])
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

--Money Commands
function GiveMoney(ply, text)
	local args = string.Explode(' ', text)
	local ammount = tonumber(args[2]) or 0
	local plyMoney = ply:GetNWInt('money')
	
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
	if not target:IsPlayer() then
		ply:SendMessage("Aim at a player to give money to.",3,Color(200,0,0,255))
		return ''
	end
	local targetMoney = target:GetNWInt('money')
	
	plyMoney = plyMoney - ammount
	targetMoney = targetMoney + ammount
	ply:SetNWInt('money', plyMoney)
	target:SetNWInt('money', targetMoney)
	
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
	local plyMoney = ply:GetNWInt('money')
	
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
		
		ply:SetNWInt('money', plyMoney - ammount)
	else
		ply:SendMessage("Aim at the ground to spawn.",3,Color(200,0,0,255))
	end
	
	return ''
end
AddChatCommand('/dropmoney', DropMoney)
