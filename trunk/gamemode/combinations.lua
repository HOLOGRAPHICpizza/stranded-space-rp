/*---------------------------------------------------------
  Combinations system
---------------------------------------------------------*/
GMS.Combinations = {}
function GMS.RegisterCombi(name,tbl,group)
         if !GMS.Combinations[group] then GMS.Combinations[group] = {} end
         GMS.Combinations[group][name] = tbl
end
/*---------------------------------------------------------

  Buildings / big stuff

---------------------------------------------------------*/
/*---------------------------------------------------------
  Workbench
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Workbench"
COMBI.Description = [[This table has various fine specialized equipment used in crafting items.
You need:
30 Iron
20 Wood
]]

COMBI.Req = {}
COMBI.Req["Wood"] = 20
COMBI.Req["Iron"] = 30

COMBI.Result = "GMS_Workbench"
COMBI.BuildSiteModel = "models/props_wasteland/controlroom_desk001b.mdl"

GMS.RegisterCombi("Workbench",COMBI,"Buildings")

/*---------------------------------------------------------
  Stove
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Stove"
COMBI.Description = [[Using a stove, you can cook without having to light a fire.
You need:
35 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 35

COMBI.Result = "GMS_Stove"
COMBI.BuildSiteModel = "models/props_c17/furniturestove001a.mdl"

GMS.RegisterCombi("Stove",COMBI,"Buildings")

/*---------------------------------------------------------
  Weaponbench
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Weaponbench"
COMBI.Description = [[This table has various fine specialized equipment used in crafting weapons.
You need:
30 Iron
20 Wood
]]

COMBI.Req = {}
COMBI.Req["Wood"] = 20
COMBI.Req["Iron"] = 30

COMBI.Result = "GMS_Weaponbench"
COMBI.BuildSiteModel = "models/props_wasteland/controlroom_desk001a.mdl"

GMS.RegisterCombi("Weaponbench",COMBI,"Buildings")

/*---------------------------------------------------------

  Generic

---------------------------------------------------------*/
/*---------------------------------------------------------
  Flour
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Flour"
COMBI.Description = [[Flour can be used for making dough.
You need:
1 Stone (Stays)
2 Grain Seeds
]]

COMBI.Req = {}
COMBI.Req["Stone"] = 1
COMBI.Req["Grain_Seeds"] = 2

COMBI.Results = {}
COMBI.Results["Flour"] = 1
COMBI.Results["Stone"] = 1

GMS.RegisterCombi("Flour",COMBI,"Generic")
/*---------------------------------------------------------
  Spice
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Spices"
COMBI.Description = [[Spice can be used for various meals.
You need:
1 Stone (Stays)
2 Herbs
]]

COMBI.Req = {}
COMBI.Req["Stone"] = 1
COMBI.Req["Herbs"] = 2

COMBI.Results = {}
COMBI.Results["Spices"] = 1
COMBI.Results["Stone"] = 1

GMS.RegisterCombi("Spices",COMBI,"Generic")
/*---------------------------------------------------------
  Dough
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Dough"
COMBI.Description = [[Dough is used for baking.
You need:
1 Bottle of water
2 Flour
]]

COMBI.Req = {}
COMBI.Req["Water_Bottles"] = 1
COMBI.Req["Flour"] = 2

COMBI.Results = {}
COMBI.Results["Dough"] = 1

GMS.RegisterCombi("Dough",COMBI,"Generic")
/*---------------------------------------------------------
  Rope
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Rope"
COMBI.Description = [[Rope has various uses.
You need:
10 Herbs
1 Bottle of water
]]

COMBI.Req = {}
COMBI.Req["Herbs"] = 10
COMBI.Req["Water_Bottles"] = 1

COMBI.Results = {}
COMBI.Results["Rope"] = 1

GMS.RegisterCombi("Rope",COMBI,"Generic")
/*---------------------------------------------------------
  Concrete
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Concrete"
COMBI.Description = [[Concrete can be used for spawning concrete props.
You need:
5 Sand
2 Bottle of water
]]

COMBI.Req = {}
COMBI.Req["Sand"] = 5
COMBI.Req["Water_Bottles"] = 2

COMBI.Results = {}
COMBI.Results["Concrete"] = 1

GMS.RegisterCombi("Concrete",COMBI,"Generic")

-- Paper
local COMBI = {}

COMBI.Name = "Paper"
COMBI.Description = [[Paper can be used for various trippy purposes.
You need:
2 Wood
1 Bottle of Water
1 Stone (Stays)
]]

COMBI.Req = {}
COMBI.Req["Stone"] = 1
COMBI.Req["Water_Bottles"] = 1
COMBI.Req["Wood"] = 2

COMBI.Results = {}
COMBI.Results["Paper"] = 1
COMBI.Results["Stone"] = 1

GMS.RegisterCombi("Paper",COMBI,"Generic")

-- Joint
local COMBI = {}

COMBI.Name = "Joint"
COMBI.Description = [[Sells for more than hemp alone.
You need:
1 Hemp
1 Paper
]]

COMBI.Req = {}
COMBI.Req["Hemp"] = 1
COMBI.Req["Paper"] = 1

COMBI.Results = {}
COMBI.Results["Joint"] = 1

GMS.RegisterCombi("Joint",COMBI,"Generic")

/*---------------------------------------------------------

  Coooking

---------------------------------------------------------*/
/*---------------------------------------------------------
  Casserole
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Casserole"
COMBI.Description = [[Put a little spiced fish over the fire to make this delicious casserole.
You need:
1 Fish
3 Herbs

Food initial quality: 40%
]]

COMBI.Req = {}
COMBI.Req["Fish"] = 1
COMBI.Req["Herbs"] = 3
COMBI.FoodValue = 400
COMBI.Texture = "gui/GMS/gms_fish"

GMS.RegisterCombi("Casserole",COMBI,"Cooking")

/*---------------------------------------------------------
  Fried meat
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Fried Meat"
COMBI.Description = [[Simple fried meat.
You need:
1 Raw meat

Food initial quality: 25%]]

COMBI.Req = {}
COMBI.Req["Meat"] = 1

COMBI.FoodValue = 250
COMBI.Texture = "gui/GMS/gms_fish"

GMS.RegisterCombi("FriedMeat",COMBI,"Cooking")
/*---------------------------------------------------------
  Fish soup
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Fish Soup"
COMBI.Description = [[Fish soup, pretty good!
You need:
1 Fish
2 Spices
2 Cooking skill

Food initial quality: 40%]]

COMBI.Req = {}
COMBI.Req["Fish"] = 1
COMBI.Req["Spices"] = 2
COMBI.Req["Water_Bottles"] = 2

COMBI.SkillReq = {}
COMBI.SkillReq["Cooking"] = 2

COMBI.FoodValue = 400
COMBI.Texture = "gui/GMS/gms_fish"

GMS.RegisterCombi("FishSoup",COMBI,"Cooking")

/*---------------------------------------------------------
  Meatballs
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Meatballs"
COMBI.Description = [[Processed meat.
You need:
1 Meat
1 Spices
1 Bottle of water
2 Cooking skill

Food initial quality: 40%]]

COMBI.Req = {}
COMBI.Req["Meat"] = 1
COMBI.Req["Spices"] = 1
COMBI.Req["Water_Bottles"] = 1

COMBI.SkillReq = {}
COMBI.SkillReq["Cooking"] = 2

COMBI.FoodValue = 400

GMS.RegisterCombi("Meatballs",COMBI,"Cooking")
/*---------------------------------------------------------
  Fried fish
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Fried Fish"
COMBI.Description = [[Simple fried fish.
You need:
1 Fish

Food initial quality: 20%]]

COMBI.Req = {}
COMBI.Req["Fish"] = 1
COMBI.FoodValue = 200
COMBI.Texture = "gui/GMS/gms_fish"

GMS.RegisterCombi("FriedFish",COMBI,"Cooking")
/*---------------------------------------------------------
  Berry Pie
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Berry Pie"
COMBI.Description = [[Yummy, berry pie reminds me of home!
You need:
2 Dough
2 Water bottles
5 Berries
5 Cooking skill

Food initial quality: 70%]]

COMBI.Req = {}
COMBI.Req["Dough"] = 2
COMBI.Req["Water_Bottles"] = 2
COMBI.Req["Berries"] = 5

COMBI.SkillReq = {}
COMBI.SkillReq["Cooking"] = 5

COMBI.FoodValue = 700
COMBI.Texture = "gui/GMS/gms_pie"

GMS.RegisterCombi("BerryPie",COMBI,"Cooking")
/*---------------------------------------------------------
  Rock cake
---------------------------------------------------------*/
local COMBI = {}
 
COMBI.Name = "Rock Cake"
COMBI.Description = [[Crunchy!
You need:
2 Iron
1 Herbs
 
Food initial quality: 5%
]]
 
COMBI.Req = {}
COMBI.Req["Iron"] = 2
COMBI.Req["Herbs"] = 1
COMBI.FoodValue = 50
COMBI.Texture = "gui/GMS/gms_rock"
 
GMS.RegisterCombi("Rock_Cake", COMBI, "Cooking")

/*---------------------------------------------------------
  Salad
---------------------------------------------------------*/
local COMBI = {}
 
COMBI.Name = "Salad"
COMBI.Description = [[Everything for survival, I guess.
You need:
2 Herbs

Food initial quality: 10%
]]
 
COMBI.Req = {}
COMBI.Req["Herbs"] = 2
COMBI.FoodValue = 100
COMBI.Texture = "gui/GMS/gms_herb"
 
GMS.RegisterCombi("Salad", COMBI, "Cooking")

/*---------------------------------------------------------
  Meal
---------------------------------------------------------*/
local COMBI = {}
 
COMBI.Name = "Meal"
COMBI.Description = [[The ultimate meal. Delicious!
You need:
5 Herbs
1 Fish
1 Raw Meat
3 Spices
20 Cooking skill

Food initial quality: 100%
]]
 
COMBI.Req = {}
COMBI.Req["Herbs"] = 5
COMBI.Req["Fish"] = 1
COMBI.Req["Meat"] = 2
COMBI.Req["Spices"] = 3

COMBI.SkillReq = {}
COMBI.SkillReq["Cooking"] = 20

COMBI.FoodValue = 1000
COMBI.Texture = "gui/GMS/gms_sandwich02"
 
GMS.RegisterCombi("Meal", COMBI, "Cooking")

/*---------------------------------------------------------
  Bread
---------------------------------------------------------*/
local COMBI = {}
 
COMBI.Name = "Bread"
COMBI.Description = [[Good old bread.
You need:
2 Dough
1 Bottle of water


Food initial quality: 80%
]]
 
COMBI.Req = {}
COMBI.Req["Dough"] = 2
COMBI.Req["Water_Bottles"] = 1


COMBI.SkillReq = {}
COMBI.SkillReq["Cooking"] = 5

COMBI.FoodValue = 800
COMBI.Texture = "gui/GMS/gms_sandwich02"

GMS.RegisterCombi("Bread", COMBI, "Cooking")
/*---------------------------------------------------------
  Hamburger
---------------------------------------------------------*/
local COMBI = {}
 
COMBI.Name = "Hamburger"
COMBI.Description = [[A hamburger! Yummy!
You need:
2 Dough
1 Bottle of water
2 Raw Meat


Food initial quality: 85%
]]
 
COMBI.Req = {}
COMBI.Req["Dough"] = 2
COMBI.Req["Water_Bottles"] = 1
COMBI.Req["Meat"] = 2


COMBI.SkillReq = {}
COMBI.SkillReq["Cooking"] = 3

COMBI.FoodValue = 850
COMBI.Texture = "gui/GMS/gms_burger02"
 
GMS.RegisterCombi("Burger", COMBI, "Cooking")

/*---------------------------------------------------------

  Tool crafting

---------------------------------------------------------*/
/*---------------------------------------------------------
  Hatchet
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Hatchet"
COMBI.Description = [[This small axe is ideal for chopping down trees.
You need:
5 Iron
10 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 5
COMBI.Req["Wood"] = 10

/*COMBI.SkillReq = {}
COMBI.SkillReq["Smithing"] = 1*/

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_hatchet"

GMS.RegisterCombi("Hatchet",COMBI,"Weapons")

/*---------------------------------------------------------
  Pickaxe
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Pickaxe"
COMBI.Description = [[The pickaxe is useful for effectively mining rocks.
You need:
10 Iron
5 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 10
COMBI.Req["Wood"] = 5
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_pickaxe"

GMS.RegisterCombi("Pickaxe",COMBI,"Weapons")

/*---------------------------------------------------------
  Fishing rod
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Fishing Rod"
COMBI.Description = [[This rod of wood can be used to fish from a lake.
You need:
1 Iron
20 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 1
COMBI.Req["Wood"] = 20
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_fishingrod"

GMS.RegisterCombi("FishingRod",COMBI,"Weapons")

/*---------------------------------------------------------
  Frying pan
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Frying Pan"
COMBI.Description = [[This kitchen tool is used for more effective cooking.
You need:
20 Iron
5 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 20
COMBI.Req["Wood"] = 5
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_fryingpan"

GMS.RegisterCombi("Fryingpan",COMBI,"Weapons")

/*---------------------------------------------------------
  Sickle
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Sickle"
COMBI.Description = [[This tool effectivizes harvesting.
You need:
5 Iron
15 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 5
COMBI.Req["Wood"] = 15
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_sickle"

GMS.RegisterCombi("Sickle",COMBI,"Weapons")

/*---------------------------------------------------------
  Strainer
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Strainer"
COMBI.Description = [[This tool can filter the earth for resources.
You need:
5 Iron
5 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 5
COMBI.Req["Wood"] = 5
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_strainer"

GMS.RegisterCombi("Strainer",COMBI,"Weapons")
/*---------------------------------------------------------
  Shovel
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Shovel"
COMBI.Description = [[This tool can dig up rocks, and decreases forage times.
You need:
15 Iron
15 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 15
COMBI.Req["Wood"] = 15
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_shovel"

GMS.RegisterCombi("Shovel",COMBI,"Weapons")

-- Lockpick
local COMBI = {}

COMBI.Name = "Lockpick"
COMBI.Description = [[This tool can pick locks.
You need:
75 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 75
COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "gms_lockpick"

GMS.RegisterCombi("Lockpick",COMBI,"Weapons")

-- WEAPONS (The kind that hurt people.)
/*---------------------------------------------------------
  Crowbar
---------------------------------------------------------*/
local COMBI = {}

COMBI.Name = "Crowbar"
COMBI.Description = [[Gordon Freeman's signature face smasher.
You need:
50 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 50

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_crowbar"

GMS.RegisterCombi("Crowbar",COMBI,"Guns")

-- Glock
local COMBI = {}

COMBI.Name = "Glock"
COMBI.Description = [[Comonly used for shooting people in the face.
You need:
65 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 65

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_glock"

GMS.RegisterCombi("Glock",COMBI,"Guns")

-- FiveSeven
local COMBI = {}

COMBI.Name = "FiveSeven"
COMBI.Description = [[A fairly accurate pistol.
You need:
70 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 70

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_fiveseven"

GMS.RegisterCombi("FiveSeven",COMBI,"Guns")

-- Deagle
local COMBI = {}

COMBI.Name = "Deagle"
COMBI.Description = [[A very powerful and accurate pistol.
You need:
90 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 90

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_deagle"

GMS.RegisterCombi("Deagle",COMBI,"Guns")

-- Mac10
local COMBI = {}

COMBI.Name = "Mac10"
COMBI.Description = [[A favorite for drive-bys everywhere.
You need:
110
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 110

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_mac10"

GMS.RegisterCombi("Mac10",COMBI,"Guns")

-- MP5
local COMBI = {}

COMBI.Name = "MP5"
COMBI.Description = [[A pretty good SMG.
You need:
125 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 125

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_mp5"

GMS.RegisterCombi("MP5",COMBI,"Guns")

-- M16
local COMBI = {}

COMBI.Name = "M16"
COMBI.Description = [[A pretty good rifle.
You need:
145 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 145

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_m4"

GMS.RegisterCombi("M16",COMBI,"Guns")

-- AK-47
local COMBI = {}

COMBI.Name = "AK-47"
COMBI.Description = [[AK-47, the very best there is.
When you absolutely, positively, have to kill every single motherfucker in the room; accept no substitute.
You need:
100 Iron
50 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 100
COMBI.Req["Wood"] = 50

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_ak47"

GMS.RegisterCombi("AK-47",COMBI,"Guns")

-- Shotgun
local COMBI = {}

COMBI.Name = "Shotgun"
COMBI.Description = [[Good for blowing zombies in half.
You need:
145 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 145

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_pumpshotgun"

GMS.RegisterCombi("Shotgun",COMBI,"Guns")

-- Shotgun
local COMBI = {}

COMBI.Name = "Shotgun"
COMBI.Description = [[Good for blowing zombies in half.
You need:
145 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 145

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_pumpshotgun"

GMS.RegisterCombi("Shotgun",COMBI,"Guns")

-- Para
local COMBI = {}

COMBI.Name = "Para"
COMBI.Description = [[Good for pretending to be Rambo.
You need:
150 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 150

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_para"

GMS.RegisterCombi("Para",COMBI,"Guns")

-- Crossbow
local COMBI = {}

COMBI.Name = "Crossbow"
COMBI.Description = [[For when you need to impale people with superheated rebar from great distances.
100 Iron
75 Wood
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 100
COMBI.Req["Wood"] = 75

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_crossbow"

GMS.RegisterCombi("Crossbow",COMBI,"Guns")

-- AR2
local COMBI = {}

COMBI.Name = "AR2"
COMBI.Description = [[A redonkulous gun from the future.
You need:
200 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 200

COMBI.Texture = "weapons/swep"
COMBI.SwepClass = "weapon_ar2"

GMS.RegisterCombi("AR2",COMBI,"Guns")

-- Drugs

-- Stim-Pack
local COMBI = {}

COMBI.Name = "Stim-Pack"
COMBI.Description = [[Heals you.
You need:
20 Herbs
1 Iron
]]

COMBI.Req = {}
COMBI.Req["Iron"] = 1
COMBI.Req["Herbs"] = 20

COMBI.Results = {}
COMBI.Results["Stim-Pack"] = 1

GMS.RegisterCombi("Stim-Pack",COMBI,"Drugs")

-- Caffeine
local COMBI = {}

COMBI.Name = "Caffeine"
COMBI.Description = [[Makes you not sleepy!
You need:
20 Berries
1 Water Bottle
1 Stone (Stays)
]]

COMBI.Req = {}
COMBI.Req["Berries"] = 20
COMBI.Req["Water_Bottles"] = 1
COMBI.Req["Stone"] = 1

COMBI.Results = {}
COMBI.Results["Caffeine"] = 1
COMBI.Results["Stone"] = 1

GMS.RegisterCombi("Caffeine",COMBI,"Drugs")

-- Powerthirst
local COMBI = {}

COMBI.Name = "Powerthirst"
COMBI.Description = [[You'll be running ALL THE TIME!!!
You need:
1 Caffeine
3 Water Bottles
10 Spices
]]

COMBI.Req = {}
COMBI.Req["Caffeine"] = 1
COMBI.Req["Water_Bottles"] = 3
COMBI.Req["Spices"] = 10

COMBI.Results = {}
COMBI.Results["Powerthirst"] = 1

GMS.RegisterCombi("Powerthirst",COMBI,"Drugs")

-- Gman Stuff

-- Turd
-- local COMBI = {}

-- COMBI.Name = "Turd"
-- COMBI.Description = [[A big expansive turd.
-- You need:
-- $5000
-- ]]

-- --COMBI.Price = 5000

-- COMBI.Req = {}

-- COMBI.Results = {}
-- COMBI.Results["Turd"] = 1

-- GMS.RegisterCombi("Turd",COMBI,"Gman")

-- -- Pizza
-- COMBI.Name = "Pizza"
-- COMBI.Description = [[Gimme ur turd!
-- You will recive:
-- $5000
-- ]]

-- --COMBI.Value = 5000

-- COMBI.Req = {}
-- COMBI.Req["Turd"] = 1

-- COMBI.Results = {}

-- GMS.RegisterCombi("Pizza",COMBI,"Gman")
