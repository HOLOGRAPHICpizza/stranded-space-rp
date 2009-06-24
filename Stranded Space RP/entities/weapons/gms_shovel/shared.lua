if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Shovel"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end



SWEP.Author		= "jA_cOp"
SWEP.Contact		= "jakob_oevrum@hotmail.com"
SWEP.Purpose		= "Dig."
SWEP.Instructions	= "Use primary to dig."


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
end
/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
         if CLIENT then return end
         self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
         local tr = self.Owner:TraceFromEyes(150)
         
         if tr.HitWorld then
            if (tr.MatType == MAT_DIRT or tr.MatType == MAT_GRASS or tr.MatType == MAT_SAND) then
               self.Owner:DoProcess("Dig",5)
            else
               self.Owner:SendMessage("Can't dig on this terrain!",3,Color(200,0,0,255))
               self.Owner:EmitSound(Sound("physics/concrete/concrete_impact_hard"..math.random(1,3)..".wav"))
            end
         end
end

function SWEP:Deploy()
         timer.Simple(0.1,self.HideWeapon,self,false)
         return true
end

function SWEP:HideWeapon(bool)
         if SERVER and self.Owner then self.Owner:DrawViewModel(bool) end
end

function SWEP:Holster()
         timer.Simple(0.1,self.HideWeapon,self,true)
         return true
end