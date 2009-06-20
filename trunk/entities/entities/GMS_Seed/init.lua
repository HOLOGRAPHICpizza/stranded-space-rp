AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
local GM = GAMEMODE

--Called when an entity is no longer touching this SENT.
--Return: Nothing
function ENT:EndTouch(entEntity)
end

--Called when the SENT is spawned
--Return: Nothing

function ENT:Initialize()
	-- No seeds in space.
	local onplanet, num = SB_OnEnvironment(self.Entity:GetPos(), self.Entity.num, nil, self.Entity.IgnoreClasses)
	if onplanet then
		self.Entity:SetModel("models/weapons/w_bugbait.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		
		self.Entity.Runs = 0
		self.Entity:SetNWInt('runs', self.Entity.Runs)
	else
		self.Entity:Remove()
	end
end

function ENT:Setup(strType,time,ply)
	self.Entity.ResType = strType
	self.Entity.Player = ply
	
	self.Entity:SetNWString('restype', self.Entity.ResType)
	self.Entity:SetNWString('player', self.Entity.Player:Name())
	
	if strType == 'hemp' then
		self.Entity:SetColor(255,0,0,255)
	else
		self.Entity:SetColor(0,255,0,255)
	end
	
	time = time / 10
	
	timer.Create("GMS_SeedTimers_"..self.Entity:EntIndex(),time,10,self.Grow,self)
end

-- function ENT:GetPlayer()
	-- return self.Entity.Player
-- end

-- function ENT:GetResType()
	-- return self.Entity.ResType
-- end

-- function ENT:GetRuns()
	-- return self.Entity.Runs
-- end

function ENT:Grow()
	self.Entity.Runs = self.Entity.Runs + 1
	self.Entity:SetNWInt('runs', self.Entity.Runs)
	
	if self.Entity.Runs < 10 then return end
	
	local strType = self.Entity.ResType
	local ply = self.Entity.Player

	if strType == "tree" then
		GM.MakeTree(self.Entity:GetPos())

	elseif strType == "melon" then
		local num = 1
		
		if ply:HasUnlock("ExpertFarmer") then
		num = num + math.random(1,2)
		end
		
		GM.MakeMelon(self.Entity:GetPos(),num)

	elseif strType == "grain" then
		GM.MakeGrain(self.Entity:GetPos())
	elseif strType == "berry" then
		GM.MakeBush(self.Entity:GetPos())
	elseif strType == "hemp" then
		GM.MakeHemp(self.Entity:GetPos())
	end

	self.Entity:Fadeout()
end

function GM.MakeTree(pos)
		local ent = ents.Create("prop_physics")
		ent:SetPos(pos)
		-- Removed in favor of no seeds in space.
		-- Admins can still make space-trees. :)
		-- local onplanet, num = SB_OnEnvironment(pos, ent.num, nil, ent.IgnoreClasses)
		local onplanet = true
		if onplanet then
			ent:SetAngles(Angle(0,math.random(1,360),0))
			ent:SetModel(GMS.TreeModels[math.random(1,#GMS.TreeModels)])
			ent:Spawn()
			-- ent:Fadein()
			-- ent:RiseFromGround()
			ent:GetPhysicsObject():EnableMotion(false)
			ent.StrandedProtected = true
		else
			-- Msg("No trees in space!\n")
			ent:Remove()
		end
end

function GM.MakeMelon(pos,num)
         local plant = ents.Create("prop_physics")
         plant:SetPos(pos)
         plant:SetAngles(Angle(0,math.random(1,360),0))
         plant:SetModel("models/props_foliage/shrub_01a.mdl")
         plant:Spawn()

         plant:Fadein()
         plant:RiseFromGround(1,50)
         plant.Children = 0
         plant.StrandedProtected = true
            
         for i = 1,num do
             local ent = ents.Create("prop_physics")
             ent:SetPos(pos + Vector(math.random(-10,10),math.random(-10,10),math.random(15,40)))
             ent:SetAngles(Angle(0,math.random(1,360),0))
             ent:SetModel("models/props_junk/watermelon01.mdl")
             ent:Spawn()
                
             local phys = ent:GetPhysicsObject()
             if phys then phys:EnableMotion(false) end
             ent:Fadein()
             ent.PlantParent = plant
             plant.Children = plant.Children + 1
                
             ent:SetHealth(1000)//It's a bitch when your food breaks...BREAKS!
         end
end

function GM.MakeGrain(pos)
	local ent = ents.Create("prop_physics_override")
	ent:SetPos(pos + Vector(math.random(-10,10),math.random(-10,10),0))
	ent:SetAngles(Angle(0,math.random(1,360),0))
	ent:SetModel("models/props_foliage/cattails.mdl")
	ent:Spawn()

	ent:Fadein()
	ent.StrandedProtected = true
	ent:RiseFromGround(1,50)
end

function GM.MakeHemp(pos)
	local ent = ents.Create("prop_physics_override")
	ent:SetPos(pos + Vector(math.random(-10,10),math.random(-10,10),0))
	ent:SetAngles(Angle(0,math.random(1,360),0))
	ent:SetModel("models/props_foliage/bramble001a.mdl")
	ent:Spawn()
	
	ent:Fadein()
	ent.StrandedProtected = true
	ent:RiseFromGround(1,50)
end

function GM.MakeBush(pos)
         local ent = ents.Create("prop_physics")
         ent:SetPos(pos + Vector(math.random(-10,10),math.random(-10,10),20))
         ent:SetAngles(Angle(0,math.random(1,360),0))
         ent:SetModel(GMS.BerryBushModels[math.random(1,#GMS.BerryBushModels)])
         ent:Spawn()

         ent:Fadein()
         ent.StrandedProtected = true
         ent:RiseFromGround(1,50)
end


function ENT:AcceptInput(input, ply)
end

--Called when the entity key values are setup (either through calls to ent:SetKeyValue, or when the map is loaded).
--Return: Nothing
function ENT:KeyValue(k,v)
end

--Called when a save-game is loaded.
--Return: Nothing
function ENT:OnRestore()
end

--Called when something hurts the entity.
--Return: Nothing
function ENT:OnTakeDamage(dmiDamage)
end

--Controls/simulates the physics on the entity.
--Return: (SimulateConst) sim, (Vector) linear_force and (Vector) angular_force
function ENT:PhysicsSimulate(pobPhysics,numDeltaTime)
end

--Called when an entity starts touching this SENT.
--Return: Nothing
function ENT:StartTouch(entEntity)
end

--Called when the SENT thinks.
--Return: Nothing
function ENT:Think()
end

--Called when an entity touches this SENT.
--Return: Nothing
function ENT:Touch(entEntity)
end

--Called when: ?
--Return: TRANSMIT_ALWAYS, TRANSMIT_NEVER or TRANSMIT_PVS
function ENT:UpdateTransmitState(entEntity)
end