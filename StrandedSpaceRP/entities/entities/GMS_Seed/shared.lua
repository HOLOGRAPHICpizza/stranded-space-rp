ENT.Type = "Anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Seed" --The name of the SENT.
ENT.Author = "jA_cOp" --Your name.
ENT.Contact = "jakob_oevrum@hotmail.com" --EMail address.
ENT.Purpose = "" --The purpose of this SENT.
ENT.Instructions = "" --Instructions

ENT.Spawnable = false --Can the clients spawn this SENT?
ENT.AdminSpawnable = false --Can the admins spawn this SENT?

--Called when the SENT is removed
--Return: Nothing
function ENT:OnRemove()
         if SERVER then timer.Destroy("GMS_SeedTimers_"..self.Entity:EntIndex()) end
end

--Controls what a scripted entity does during a collison.
--Return: Nothing
--Notes: tblData contains: HitEntity (Entity), HitPos (Vector), OurOldVelocity (Vector), HitObject (PhysObj), DeltaTime (number), TheirOldVelocity (Vector), Speed (number?) and HitNormal (Vector).
function ENT:PhysicsCollide(tblData)
end

--Called when physics are updated?
--Return: Nothing
function ENT:PhysicsUpdate(pobPhysics)
end