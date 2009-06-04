function GM:PlayerSay(ply, text)
	self.BaseClass:PlayerSay(ply, text)
	
	if string.lower(text) == 'blarg' then
		return 'WOOT!'
	end
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