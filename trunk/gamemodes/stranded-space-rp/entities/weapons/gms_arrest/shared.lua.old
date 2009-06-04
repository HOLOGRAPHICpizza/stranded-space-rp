if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Arrest Baton"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end



SWEP.Author		= "HOLOGRAPHICpizza"
SWEP.Contact		= "HOLOGRAPHICpizza@gmodplanet.com"
SWEP.Purpose		= "Arrest people."
SWEP.Instructions	= "Primary fire: Put the person you hit in jail."


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel			= "models/weapons/w_stunbaton.mdl"

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
         self.Weapon:SetNextPrimaryFire(CurTime() + 1)
         self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
         self.Owner:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))

         local trace = {}
         trace.start = self.Owner:GetShootPos()
         trace.endpos = trace.start + (self.Owner:GetAimVector() * 150)
         trace.filter = self.Owner

         local tr = util.TraceLine(trace)
         
         if !tr.HitNonWorld then return end
         if !tr.Entity then return end

         if tr.Entity:IsPlayer() and tr.Entity.Warranted then
            GMS.Jail(tr.Entity)
         end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end