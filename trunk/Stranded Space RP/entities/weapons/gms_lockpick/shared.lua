if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Lockpick"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end



SWEP.Author		= "jA_cOp, HOLOGRAPHICpizza"
SWEP.Contact		= "HOLOGRAPHICpizza@gmodplanet.com"
SWEP.Purpose		= "Lock picking tool."
SWEP.Instructions	= "Primary fire: Attempt to pick a lock."


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

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
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	
	if self.Owner:Team() != 3 and self.Owner:Team() != 7 then
		self.Owner:SendMessage("Only gangsters can pick locks.", 3, Color(200,0,0,255))
		return
	end
	
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))

	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 150)
	trace.filter = self.Owner

	local tr = util.TraceLine(trace)
	
	if !tr.HitNonWorld then return end
	if !tr.Entity then return end

	if tr.Entity:IsDoor() then
		local data = {}
		data.Entity = tr.Entity

		data.Chance = 2
		-- data.MinAmount = 1
		-- data.MaxAmount = 5

		self.Owner:DoProcess("Lockpicking",2,data)
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end
