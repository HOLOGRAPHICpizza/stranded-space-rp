AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--Called when an entity is no longer touching this SENT.
--Return: Nothing
function ENT:EndTouch(entEntity)
end

--Called when the SENT is spawned
--Return: Nothing

function ENT:Initialize()
	 self.Entity:SetMoveType( MOVETYPE_NONE )

 	 self.Entity:SetMaterial("models/wireframe")
 	 self.Entity.StrandedProtected = true
 	 self.LastUsed = CurTime()
end

function ENT:AddResource(ply,res,int)
         self.Costs[res] = self.Costs[res] - int
         
         if self.Entity.Costs[res] <= 0 then
            self.Entity.Costs[res] = nil
         end
end

function ENT:Setup(model,resclass)
         self.Entity:SetModel(model)
         self.ResultClass = resclass

 	 self.Entity:PhysicsInit( SOLID_VPHYSICS )
	 self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	 self.Entity:SetSolid( SOLID_VPHYSICS )

 	 self.Entity:SetColor(255,255,255,255)
 	 
 	 local phys = self.Entity:GetPhysicsObject()
 	 if phys != NULL and phys then phys:EnableMotion(false) end
end

function ENT:Finish()
	local ent = ents.Create(self.ResultClass)
	ent:SetPos(self.Entity:GetPos())
	ent:SetAngles(self.Entity:GetAngles())
	ent:SetModel(self.Entity:GetModel())
	ent:Spawn()
	
	ent:Fadein()
	
	self.Entity.Player:SendMessage("Finished!",3,Color(10,200,10,255))
	self.Entity.Player.HasBuildingSite = false
	self.Entity:Fadeout()
end

function ENT:Use(ply)
         if CurTime() - self.LastUsed < 0.5 then return end
         self.LastUsed = CurTime()

         for k,v in pairs(self.Costs) do
             if ply:GetResource(k) >= 0 then
                self:AddResource(ply,k,ply:GetResource(k))
                ply:DecResource(k,ply:GetResource(k))
             end
         end

         if table.Count(self.Costs) > 0 then
            local str = "You need: "
            for k,v in pairs(self.Costs) do
                str = str..k.." ("..v.."x)  "
            end
            
            str = str.." to finish."
            ply:SendMessage(str,5,Color(255,255,255,255))
         else
            self:Finish()
            ply:SendMessage("Finished!",3,Color(10,200,10,255))
         end
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