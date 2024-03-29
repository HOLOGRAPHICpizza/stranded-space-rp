if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Battering Ram"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

// Variables that are used on both client and server

SWEP.Author = "Rickster"
SWEP.Instructions = "Left click to break open doors."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.AnimPrefix = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false     -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType("rpg")
	end
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if (CLIENT) then return end

	local trace = self.Owner:GetEyeTrace()

	if (not ValidEntity(trace.Entity) or (not trace.Entity:IsDoor())) then
		return
	end

	if (trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 45) then
		return
	end
	
	if (trace.Entity:IsDoor()) then
		local num = trace.Entity:GetNWInt("OwnerNum") or 0
		local owner = -1
		local owned = false
		for n = 1, num do
			owner = player.GetByID( trace.Entity:GetNWInt("Owner" .. n) )
			if owner:IsPlayer() then
				owned = true
				if owner.Warranted or self.Owner == owner or self.Owner:IsAdmin() then
					openDoor(trace.Entity)
					break
				else
					self.Owner:SendMessage("Owner not warranted!",3,Color(200,0,0,255))
				end
			end
		end
		
		if not owned then
			openDoor(trace.Entity)
		end
	end
	
	self.Owner:EmitSound(self.Sound)
	self.Owner:ViewPunch(Angle(-10, math.random(-5, 5), 0))
	self.Weapon:SetNextPrimaryFire(CurTime() + 2.5)
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function openDoor(door)
	door:Fire("unlock", "", .5)
	door:Fire("open", "", .6)
end
