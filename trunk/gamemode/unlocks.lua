/*---------------------------------------------------------
  System
---------------------------------------------------------*/
GMS.FeatureUnlocks = {}
function GMS.RegisterUnlock(name,tbl)
         GMS.FeatureUnlocks[name] = tbl
end
/*---------------------------------------------------------
  Unlocks
---------------------------------------------------------*/
//Sprint
local UNLOCK = {}

UNLOCK.Name = "Sprinting I"
UNLOCK.Description = [[You can now hold down shift to sprint.]]
UNLOCK.Req = {}
UNLOCK.Req["Survival"] = 3

GMS.RegisterUnlock("Sprint_Mki",UNLOCK)

local UNLOCK = {}

UNLOCK.Name = "Sprinting II"
UNLOCK.Description = [[Your movement speed has got permanent increase. Also, your sprint is now walk.]]
UNLOCK.Req = {}
UNLOCK.Req["Survival"] = 10
function UNLOCK.OnUnlock(ply)
         GAMEMODE:SetPlayerSpeed(ply, 400, 100)
end

GMS.RegisterUnlock("Sprint_Mkii",UNLOCK)

//Health increase
local UNLOCK = {}

UNLOCK.Name = "Adept Survivalist"
UNLOCK.Description = [[Your max health has been increased by 50%.]]
UNLOCK.Req = {}
UNLOCK.Req["Survival"] = 15
function UNLOCK.OnUnlock(ply)
         ply:Heal(50)
end

GMS.RegisterUnlock("Adept_Survivalist",UNLOCK)

//Sprouts
local UNLOCK = {}

UNLOCK.Name = "Sprout Collecting"
UNLOCK.Description = [[You can now press use on a tree to attempt to loosen a sprout.
                       Sprouts can be planted if you have the skill, and they will grow into trees.]]
UNLOCK.Req = {}
UNLOCK.Req["Lumbering"] = 5
UNLOCK.Req["Harvesting"] = 5

GMS.RegisterUnlock("Sprout_Collect",UNLOCK)

//Sprout Planting
local UNLOCK = {}

UNLOCK.Name = "Sprout Planting"
UNLOCK.Description = [[You can now plant sprouts, which will grow into trees.]]
UNLOCK.Req = {}
UNLOCK.Req["Planting"] = 5

GMS.RegisterUnlock("Sprout_Planting",UNLOCK)

//Expert farmer
local UNLOCK = {}

UNLOCK.Name = "Expert Farmer"
UNLOCK.Description = [[Your melon vines can now carry up to three 3 melons instead of one.]]
UNLOCK.Req = {}
UNLOCK.Req["Planting"] = 20

GMS.RegisterUnlock("Expert_Farmer",UNLOCK)

//Grain planting
local UNLOCK = {}

UNLOCK.Name = "Grain Planting"
UNLOCK.Description = [[You can now plant grain.]]
UNLOCK.Req = {}
UNLOCK.Req["Planting"] = 3

GMS.RegisterUnlock("Grain_Planting",UNLOCK)

