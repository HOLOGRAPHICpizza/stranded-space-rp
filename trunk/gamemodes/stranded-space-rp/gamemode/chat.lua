ChatCommands = {}

function AddChatCommand(cmd, callback)
	table.insert(ChatCommands, { cmd = cmd, callback = callback})
end

function TalkToRange(msg, pos, size)
	local ents = ents.FindInSphere(pos, size)

	for k, v in pairs(ents) do
		if v:IsPlayer() then
			v:ChatPrint(msg)
			v:PrintMessage(2, msg)
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
	
	TalkToRange(ply:Name() .. ": " .. text, ply:GetPos(), 300)
	return ''
end

-- Chat Commands
function Whisper(ply, text)
	TalkToRange('(Whisper)' .. ply:Name() .. ": " .. string.sub(text, 4, string.len(text)), ply:GetPos(), 100)
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
	ply:PrintMessage(2, ply:Name() .. ': ' .. text)
	return ''
end
AddChatCommand('/pm', PersonalMessage)