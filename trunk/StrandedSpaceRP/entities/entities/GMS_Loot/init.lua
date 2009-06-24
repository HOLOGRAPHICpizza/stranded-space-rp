AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
         self.Entity:SetModel("models/weapons/w_bugbait.mdl")

         self.Entity:PhysicsInit( SOLID_VPHYSICS )
	 self.Entity:SetMoveType( MOVETYPE_NONE )
	 self.Entity:SetSolid( SOLID_VPHYSICS )

 	 self.Entity:SetColor(255,0,0,255)
end

function ENT:Use(ply)
         local data = {}
         data.Entity = self.Entity
         data.Resources = self.Resources
         
         ply:DoProcess("Loot",5,data)
end

function ENT:Think()
         local effectdata = EffectData()
         effectdata:SetOrigin(self.Entity:GetPos())
         util.Effect("GMS_LootEffect",effectdata)
end