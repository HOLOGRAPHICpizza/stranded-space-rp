if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Hands"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 80
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
end



SWEP.Author		= "jA_cOp"
SWEP.Contact		= "jakob_oevrum@hotmail.com"
SWEP.Purpose		= "Pick up stuff, as well as poor harvesting."
SWEP.Instructions	= "Primary fire: Attack/Harvest\nReload: Pick up / drop items\nSecondary Fire: Move picked up item to inventory"


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
	if CLIENT then return end
	self:SetWeaponHoldType("normal")
	self.HoldEnt = nil
end
/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
         if CLIENT then return end
            //Pickup
            if !self.HoldEnt then
                local ang = self.Owner:GetAimVector()
	        local spos = self.Owner:GetShootPos()
                
                local trace = {}
	        trace.start = spos
	        trace.endpos = spos + (ang * 100)
	        trace.filter = self.Owner
                local tr = util.TraceLine(trace)

                if !tr.HitNonWorld then return end
                if !tr.Entity then return end
                if  tr.Entity:GetClass() != "prop_physics" then return end
                if tr.Entity:GetPhysicsObject():GetMass() > 50 then
                   
                   self.Owner:PrintMessage(4,"Prop too heavy.")
                return end

                self.HoldEnt = tr.Entity
                
                local min,max = self.HoldEnt:WorldSpaceAABB()
                self.Distance = max
                
                self.HoldEnt:SetPos(self.Owner:GetShootPos() + (self.Owner:GetAimVector() * self.Distance * 20))
                self.HoldEnt:SetParent(self.Owner)

                self:SetWeaponHoldType("pistol")

            //Drop
            elseif self.HoldEnt then
                
                self:SetWeaponHoldType("normal")

                self.HoldEnt:SetParent(nil)
                self.HoldEnt:GetPhysicsObject():Wake()
                self.HoldEnt = nil
            end
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
         if CLIENT then return end
         self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
         self.Owner:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))

         local trace = {}
         trace.start = self.Owner:GetShootPos()
         trace.endpos = trace.start + (self.Owner:GetAimVector() * 150)
         trace.filter = self.Owner

         local tr = util.TraceLine(trace)
         
         if !tr.HitNonWorld then return end
         if !tr.Entity then return end

         if tr.Entity:IsTreeModel() then
            local data = {}
            data.Entity = tr.Entity
            data.Chance = 33
            data.MinAmount = 1
            data.MaxAmount = 3

            self.Owner:DoProcess("WoodCutting",3,data)
         elseif tr.Entity:IsRockModel() then
            local data = {}
            data.Entity = tr.Entity

            data.Chance = 33
            data.MinAmount = 1
            data.MaxAmount = 2

            self.Owner:DoProcess("Mining",3,data)
         end
end



/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
         if CLIENT then return end
         if self.HoldEnt then
            self.HoldEnt:SetParent(nil)
            self.HoldEnt = nil
            self.Owner:ConCommand("gms_inventory_pickup\n")
         end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:Holster()
         if self.HoldEnt then
            self.HoldEnt:SetParent(nil)
            self.HoldEnt = nil
         end
         
         timer.Simple(0.1,self.HideWeapon,self,true)
         return true
end

function SWEP:OnDrop()
         self.Weapon:Remove()
end

function SWEP:Deploy()
         timer.Simple(0.1,self.HideWeapon,self,false)
         return true
end

function SWEP:HideWeapon(bool)
         if SERVER and self.Owner then self.Owner:DrawViewModel(bool) end
end
