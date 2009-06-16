/*---------------------------------------------------------

  Gmod Stranded



---------------------------------------------------------*/

Msg("Loading shared.lua\n")

GMS = {}

GM.Name 	= "Stranded Space RP"
GM.Author 	= "jA_cOp, LS-RD-SB Team, HOLOGRAPHICpizza"
GM.Email 	= "holographicpizza@gmodplanet.com"
GM.Website 	= "http://www.gmodplanet.com/"

-- Unlimited Classes.
team.SetUp(1, "Citizens", Color(0, 200, 0, 255)) -- Green
team.SetUp(2, "Cops", Color(0, 0, 200, 255)) -- Blue
team.SetUp(3, "Gangsters", Color(100, 100, 100, 255)) -- Grey

-- Limited Classes
team.SetUp(4, "Weaponsmiths", Color(255, 140, 0, 255)) -- Orange
team.SetUp(5, "Doctors", Color(200, 0, 200, 255)) -- Magenta

-- Single Players
team.SetUp(6, "Mayor", Color(220, 0, 0, 255)) -- Red
team.SetUp(7, "Mob Boss", Color(60, 60, 60, 255)) -- Dark Grey

//Tables
GMS.classModels = {
	"models/player/group01/male_07.mdl",
	"models/player/police.mdl",
	"models/player/group03/male_07.mdl",
	"models/player/barney.mdl",
	"models/player/kleiner.mdl",
	"models/player/breen.mdl",
	"models/player/monk.mdl"
}

GMS.TreeModels = {
                 "models/props/de_inferno/tree_large.mdl",
                 "models/props/de_inferno/tree_small.mdl",
                 "models/props_foliage/tree_deciduous_03a.mdl",
                 "models/props_foliage/tree_deciduous_01a.mdl",
                 "models/props_foliage/oak_tree01.mdl",
                 "models/props_foliage/tree_cliff_01a.mdl"}
                 
GMS.AdditionalTreeModels = {"models/props_foliage/tree_deciduous_02a.mdl"}
                 
GMS.EdibleModels = {
                   "models/props/cs_italy/orange.mdl",
                   "models/props_junk/watermelon01.mdl",
                   "models/props/cs_italy/bananna_bunch.mdl"
                   }
                   
GMS.RockModels = {
                   "models/props_wasteland/rockgranite02a.mdl",
                   "models/props_wasteland/rockgranite02b.mdl",
                   "models/props_wasteland/rockgranite02c.mdl",
                   "models/props_wasteland/rockgranite03a.mdl",
                   "models/props_wasteland/rockgranite03b.mdl",
                   "models/props_wasteland/rockgranite03c.mdl",
                   "models/props_wasteland/rockcliff01b.mdl",
                   "models/props_wasteland/rockcliff01c.mdl",
                   "models/props_wasteland/rockcliff01e.mdl",
                   "models/props_wasteland/rockcliff01f.mdl",
                   "models/props_wasteland/rockcliff01g.mdl",
                   "models/props_wasteland/rockcliff01J.mdl",
                   "models/props_wasteland/rockcliff01k.mdl",
                   "models/props_wasteland/rockcliff05a.mdl",
                   "models/props_wasteland/rockcliff05b.mdl",
                   "models/props_wasteland/rockcliff05e.mdl",
                   "models/props_wasteland/rockcliff05f.mdl",
                   "models/props_wasteland/rockcliff06d.mdl",
                   "models/props_wasteland/rockcliff06i.mdl"}
                   
GMS.AdditionalRockModels = {"models/props_canal/rock_riverbed01a.mdl",
                            "models/props_canal/rock_riverbed01b.mdl",
                            "models/props_canal/rock_riverbed01c.mdl",
                            "models/props_canal/rock_riverbed01d.mdl",
                            "models/props_canal/rock_riverbed02a.mdl",
                            "models/props_canal/rock_riverbed02b.mdl",
                            "models/props_canal/rock_riverbed02c.mdl",
                            "models/props_wasteland/rockcliff_cluster01b.mdl",
                            "models/props_wasteland/rockcliff_cluster02a.mdl",
                            "models/props_wasteland/rockcliff_cluster02b.mdl",
                            "models/props_wasteland/rockcliff_cluster02c.mdl",
                            "models/props_wasteland/rockcliff_cluster03a.mdl",
                            "models/props_wasteland/rockcliff_cluster03b.mdl",
                            "models/props_wasteland/rockcliff_cluster03c.mdl",
                            "models/props_wasteland/rockcliff05a.mdl"
                            }
                   
GMS.SmallRockModel = "models/props_junk/rock001a.mdl"

GMS.PickupProhibitedClasses = {"GMS_Seed"}
                   
GMS.MaterialResources = {}
GMS.MaterialResources[MAT_CONCRETE] = "Concrete"
GMS.MaterialResources[MAT_METAL] = "Iron"
GMS.MaterialResources[MAT_DIRT] = "Wood"
GMS.MaterialResources[MAT_VENT] = "Iron"
GMS.MaterialResources[MAT_GRATE] = "Iron"
GMS.MaterialResources[MAT_TILE] = "Stone"
GMS.MaterialResources[MAT_SLOSH] = "Wood"
GMS.MaterialResources[MAT_WOOD] = "Wood"
GMS.MaterialResources[MAT_COMPUTER] = "Iron"
GMS.MaterialResources[MAT_GLASS] = "Iron"
GMS.MaterialResources[MAT_FLESH] = "Wood"
GMS.MaterialResources[MAT_BLOODYFLESH] = "Wood"
GMS.MaterialResources[MAT_CLIP] = "Wood"
GMS.MaterialResources[MAT_ANTLION] = "Wood"
GMS.MaterialResources[MAT_ALIENFLESH] = "Wood"
GMS.MaterialResources[MAT_FOLIAGE] = "Wood"
GMS.MaterialResources[MAT_SAND] = "Wood"
GMS.MaterialResources[MAT_PLASTIC] = "Iron"

GMS.Skills = {}
table.insert(GMS.Skills,"Mining")
table.insert(GMS.Skills,"Smithing")
table.insert(GMS.Skills,"Harvesting")
table.insert(GMS.Skills,"Cooking")
table.insert(GMS.Skills,"Lumbering")
table.insert(GMS.Skills,"Carpentry")
table.insert(GMS.Skills,"Survival")

GMS.Resources = {}
table.insert(GMS.Resources,"Ore")
table.insert(GMS.Resources,"Metal")
//table.insert(GMS.Resources,"Cooked_Food")
table.insert(GMS.Resources,"Wood")
table.insert(GMS.Resources,"Planks")
table.insert(GMS.Resources,"Seeds")
table.insert(GMS.Resources,"Sprouts")
table.insert(GMS.Resources,"Fish")
table.insert(GMS.Resources,"Herbs")
table.insert(GMS.Resources,"Raw_Meat")

GMS.ConVarList = {
                  "gms_FreeBuild",
                  "gms_AllTools",
                  "gms_AutoSave",
                  "gms_AutoSaveTime",
                  "gms_physgun",
                  "gms_ReproduceTrees",
                  "gms_MaxReproducedTrees",
                  "gms_AllowSWEPSpawn",
                  "gms_AllowSENTSpawn"
                  }

GMS.SavedClasses = {
	"prop_physics",
	"prop_physics_override",
	"prop_physics_multiplayer",
	"prop_dynamic",
	"prop_effect",
	"gms_buildsite",
	"gms_workbench",
	"gms_stove",
	"gms_spawnpoint"
}

GMS.Commands = {}
GMS.Commands["gms_makefire"] = "Make campfire"
GMS.Commands["gms_sleep"] = "Sleep"
GMS.Commands["gms_wakeup"] = "Wake up"
GMS.Commands["gms_help"] = "Help"
GMS.Commands["gms_savecharacter"] = "Save character"
GMS.Commands["gms_openplantingmenu"] = "Planting"
GMS.Commands["gms_OpenDropResourceWindow"] = "Drop resources"
GMS.Commands["gms_DrinkBottle"] = "Drink Water"
GMS.Commands["gms_BuildingsCombi"] = "Structures"
GMS.Commands["gms_GenericCombi"] = "Combinations"
GMS.Commands["gms_DropWeapon"] = "Drop Weapon"
GMS.Commands["gms_options"] = "Options"

-- Shared Functions and Stuff
PlayerMeta = FindMetaTable("Player")
EntityMeta = FindMetaTable("Entity")

function PlayerMeta:TraceFromEyes(dist)
         local trace = {}
         trace.start = self:GetShootPos()
         trace.endpos = trace.start + (self:GetAimVector() * dist)
         trace.filter = self
         
         return util.TraceLine(trace)
end

function EntityMeta:IsDoor()
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" then
		return true
	end
	return false
end

-- /*function GM.LoadAddons()
         -- if SERVER then Msg("Starting GMS addons.\n") end

         -- for k,v in pairs(file.Find("../gamemodes/GMStranded/gamemode/addons/*.lua")) do
             -- Msg("addons/"..v.."\n")
             -- AddCSLuaFile("addons/"..v)
         -- end
         
         -- local num = 0
         -- for k,v in pairs(file.Find("../gamemodes/GMStranded/gamemode/addons/*.lua")) do
             -- include("addons/"..v)
             -- num = num + 1
         -- end
         
         -- if SERVER then Msg("Loaded "..num.." GMS addons.") end
-- end

-- hook.Add("Initialize","GMS_LoadAddonsOnInit",GM.LoadAddons)*/



                 

                 
