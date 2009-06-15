//Locals
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
/*---------------------------------------------------------
  Process system
---------------------------------------------------------*/
GMS.Processes = {}

//Registry
function GMS.RegisterProcess(name,tbl)
         GMS.Processes[name] = tbl
end

//Handle think hooks
GM.ProcessThinkHookTable = {}
function GM.ProcessThink()
         local GM = GAMEMODE
         for k,v in pairs(GM.ProcessThinkHookTable) do
             local think;
             if v.Think then think = v:Think() end
             
             local basethink = v:BaseThink()
             
             if think or basethink then
                if v.Owner and v.Owner != NULL and v.Owner:IsValid() then 
                   v.Owner:Freeze(false)
                   v.Owner:StopProcessBar()
                   v.Owner.InProcess = false
                   v.Owner:SendMessage("Cancelled.",3,Color(200,0,0,255))
                end

                v.IsStopped = true
                timer.Destroy("GMS_ProcessTimer_"..v.TimerID)
                GM.RemoveProcessThink(v)
             end
         end
end

hook.Add("Think","gms_ProcessThinkHooks",GM.ProcessThink)

function GM.AddProcessThink(tbl)
         table.insert(GAMEMODE.ProcessThinkHookTable,tbl)
end

function GM.RemoveProcessThink(tbl)
         for k,v in pairs(GAMEMODE.ProcessThinkHookTable) do
             if v == tbl then
                table.remove(GAMEMODE.ProcessThinkHookTable,k)
             end
         end
end

//Actual processing
function PlayerMeta:DoProcess(name,time,data)
         if self.InProcess then
            self:SendMessage("You can't do this much at once.",3,Color(200,0,0,255))
         return end
         
         //Need seperate instance
         self.ProcessTable = table.Merge(table.Copy(GMS.Processes[name]),table.Copy(GMS.Processes.BaseProcess))
         self.ProcessTable.Owner = self
         self.ProcessTable.Time = time
         self.ProcessTable.TimerID = self:UniqueID()
         if data then self.ProcessTable.Data = data end

         self.InProcess = true

         if self.ProcessTable.OnStart then self.ProcessTable:OnStart() end
         
         //Start think
         GAMEMODE.AddProcessThink(self.ProcessTable)

         timer.Create("GMS_ProcessTimer_"..self:UniqueID(),time, 1, GAMEMODE.StopProcess, self)
end

function PlayerMeta:MakeProcessBar(name,time)
         umsg.Start("gms_MakeProcessBar",self)
         umsg.String(name)
         umsg.Short(time)
         umsg.End()
end

function PlayerMeta:StopProcessBar()
         umsg.Start("gms_StopProcessBar",self)
         umsg.End()
end

function GM.StopProcess(pl)
         //Run stop
         local bool = pl.ProcessTable:BaseStop()
         if pl.ProcessTable.OnStop then pl.ProcessTable:OnStop() end
         //Stop think
         if pl.ProcessTable.Think then GAMEMODE.RemoveProcessThink(pl.ProcessTable) end
         
         pl.InProcess = false
         pl.ProcessTable = nil
end
/*---------------------------------------------------------
  Base process
---------------------------------------------------------*/
local PROCESS = {}

-- Not sure what this does, reordered checks to attemt to fix NULL entity error on player disconnect.
function PROCESS:BaseThink()
	if !self.Owner:IsValid() or !self.Owner:IsConnected() then
		return true
	end
	
	if !self.Owner:Alive() or !self.Owner or self.Owner == NULL then
		return true
	end
end

function PROCESS:BaseStop()
         if !self.Owner:Alive() or !self.Owner or self.Owner == NULL then return false end
         if !self.Owner:IsValid() then return false end
         
         self.Owner:StopProcessBar()
         return true
end

GMS.Processes.BaseProcess = PROCESS
/*---------------------------------------------------------
  Fruit eating process
---------------------------------------------------------*/
local PROCESS = {}

PROCESS.SideGain = {}
PROCESS.SideGain["melon"] = "Melon_Seeds"
PROCESS.SideGain["orange"] = "Orange_Peel"
PROCESS.SideGain["banana"] = "Banana_Peel"

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Eating Fruit",self.Time)
         self.Owner:Freeze(true)

         if self.Data.Entity:GetModel() == "models/props_junk/watermelon01.mdl" then
            self.SideGain = "Melon_Seeds"
         elseif self.Data.Entity:GetModel() == "models/props/cs_italy/orange.mdl" then
            self.SideGain = "Orange_Peel"
         elseif self.Data.Entity:GetModel() == "models/props/cs_italy/bananna_bunch.mdl" then
            self.SideGain = "Banana_Peel"
         end

         local ent = self.Data.Entity
         local plant = ent.PlantParent

         if plant then
            plant.Children = plant.Children - 1
            if plant.Children <= 0 then
               plant:Fadeout()
            end
         end

         self.Data.Entity:Fadeout(2)
end

function PROCESS:OnStop()
         if self.SideGain then
            local num = math.random(1,2)
            self.Owner:IncResource(self.SideGain,num)
            self.Owner:SendMessage(string.gsub(self.SideGain,"_"," ").." ("..num.."x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
         end

         self.Owner:SetFood(self.Owner.Hunger + 250)
         self.Owner:SendMessage("You feel a little less hungry now.",3,Color(255,255,255,255))
         self.Owner:Freeze(false)
end

GMS.RegisterProcess("EatFruit",PROCESS)

/*---------------------------------------------------------
  Foraging process
---------------------------------------------------------*/
local PROCESS = {}
PROCESS.Results = {}
PROCESS.Results[1] = "Melon Seeds"
PROCESS.Results[2] = "Grain Seeds"
PROCESS.Results[3] = "Herbs"
PROCESS.Results[4] = "Berries"

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Foraging",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num > 50 - self.Owner:GetSkill("Harvesting") then
            local res = self.Results[math.random(1,#self.Results)]

            local amount = math.random(1,3)
            self.Owner:IncResource(string.gsub(res," ","_"),amount)
            self.Owner:IncXP("Harvesting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Harvesting")),1 , 1000))
            self.Owner:SendMessage(res.." ("..amount.."x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
         else
           self.Owner:SendMessage("Found nothing of interest", 3, Color(255,255,255,255))
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Foraging",PROCESS)

/*---------------------------------------------------------
  Looting process
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Data.Entity:Fadeout(2)

         self.Owner:MakeProcessBar("Looting",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         for k,v in pairs(self.Data.Resources) do
             self.Owner:SendMessage(k.." ("..v.."x)", 3, Color(10,200,10,255))
             self.Owner:IncResource(k,v)
         end
         
         self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Loot",PROCESS)

/*---------------------------------------------------------
  Digging
---------------------------------------------------------*/
local PROCESS = {}
//Yes, horribly random, I know
PROCESS.Rarities = {}
PROCESS.Rarities[1] = "Iron"
PROCESS.Rarities[2] = "Sand"
PROCESS.Rarities[3] = "Rope"
PROCESS.Rarities[4] = "Fish"
PROCESS.Rarities[5] = "Stone"

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Digging",self.Time)
         self.Owner:Freeze(true)
         self.StartTime = CurTime()
         
         self:PlaySound()
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
         
         self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
         self.Owner:EmitSound(Sound("player/footsteps/gravel"..math.random(1,4)..".wav"))
         
         timer.Simple(1.4,self.PlaySound,self)
end

function PROCESS:OnStop()
         local num = math.random(1,100)
         
         if num < 10 then
            local res = self.Rarities[math.random(1,#self.Rarities)]
            self.Owner:IncResource(res,1)
            self.Owner:SendMessage(res.." (1x)",3,Color(10,200,10,255))
            self.Owner:SendMessage("You found something weird!",3,Color(255,255,255,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
         elseif num > 10 and num < 40 then
            self.Owner:SendMessage("Found nothing of interest",3,Color(255,255,255,255))
         else
            local tr = self.Owner:TraceFromEyes(200)
            
            local ent = ents.Create("prop_physics_multiplayer")
            ent:SetPos(tr.HitPos + Vector(0,0,10))
            ent:SetModel(GMS.SmallRockModel)
            ent:Spawn()
            
            ent:Fadein(2)
            ent.Uses = 10
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Dig",PROCESS)

/*---------------------------------------------------------
  Filter ground process
---------------------------------------------------------*/
local PROCESS = {}
PROCESS.Results = {}
PROCESS.Results[1] = "Sand"

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Filtering Ground",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num > 50 - self.Owner:GetSkill("Harvesting") then
            local res = self.Results[math.random(1,#self.Results)]

            local amount = math.random(1,3)
            self.Owner:IncResource(string.gsub(res," ","_"),amount)
            self.Owner:IncXP("Harvesting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Harvesting")),1 , 1000))
            self.Owner:SendMessage(res.." ("..amount.."x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
         else
           self.Owner:SendMessage("Found nothing of interest", 3, Color(10,200,10,255))
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("FilterGround",PROCESS)

/*---------------------------------------------------------
  Grain harvesting
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Harvesting Grain",self.Time)
         self.Owner:Freeze(true)
         
         local ent = self.Data.Entity

         if ent and ent != NULL then
            if !ent.Uses then ent.Uses = math.random(1,3) end
         end
end

function PROCESS:OnStop()
         local num = math.random(1,100)
         local add = 0
         if self.Owner:GetActiveWeapon():GetClass() == "gms_sickle" then add = add + 30 end

         if num > 50 - self.Owner:GetSkill("Harvesting") - add then
            local amount = math.random(1,2)
            self.Owner:IncResource("Grain_Seeds",amount)
            self.Owner:IncXP("Harvesting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Harvesting")),1 , 1000))
            self.Owner:SendMessage("Grain Seeds ("..amount.."x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
            
            local ent = self.Data.Entity
         
            if ent and ent != NULL then
               if ent.Uses then
                  ent.Uses = ent.Uses - 1
                  if ent.Uses <= 0 then
                     ent:Fadeout()
                  end
               end
            end

         else
           self.Owner:SendMessage("Failed.", 3, Color(200,0,0,255))
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("HarvestGrain",PROCESS)
/*---------------------------------------------------------
 Berry harvesting
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Harvesting Bush",self.Time)
         self.Owner:Freeze(true)
         
         local ent = self.Data.Entity
         
         if ent and ent != NULL then
            if !ent.Uses then ent.Uses = math.random(1,3) end
         end
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         local add = 0
         if self.Owner:GetActiveWeapon():GetClass() == "gms_sickle" then add = add + 30 end

         if num > 50 - self.Owner:GetSkill("Harvesting") - add then
            local amount = math.random(1,2)
            self.Owner:IncResource("Berries",amount)
            self.Owner:IncXP("Harvesting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Harvesting")),1 , 1000))
            self.Owner:SendMessage("Berries ("..amount.."x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
            
            local ent = self.Data.Entity
         
            if ent and ent != NULL then
               if ent.Uses then
                  ent.Uses = ent.Uses - 1
                  if ent.Uses <= 0 then
                     ent:Fadeout()
                  end
               end
            end

         else
           self.Owner:SendMessage("Failed.", 3, Color(10,200,10,255))
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("HarvestBush",PROCESS)
/*---------------------------------------------------------
  Make Campfire process
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Making Campfire",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         local num = math.random(1,3)

         if num == 1 then
            self.Owner:SendMessage("Failed.", 3, Color(200,0,0,255))
         else
            self.Data.Entity:MakeCampfire()
            self.Owner:SendMessage("Made campfire.",5,Color(10,200,100,255))
            self.Owner:DecResource("Wood",5)
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Campfire",PROCESS)

/*---------------------------------------------------------
  Wood cutting
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Chopping Wood",self.Time)
         self.Owner:Freeze(true)
         
         self.StartTime = CurTime()
         
         self:PlaySound()
         if !self.Data.Entity.Uses then self.Data.Entity.Uses = 100 end
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
         
         self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
         self.Owner:EmitSound(Sound("physics/wood/wood_solid_impact_bullet"..tostring(math.random(1,5))..".wav"))
         
         timer.Simple(1.5,self.PlaySound,self)
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num < self.Data.Chance + self.Owner:GetSkill("Lumbering") then
            local num2 = math.random(self.Data.MinAmount,self.Data.MaxAmount)
            self.Owner:IncResource("Wood",num2)
            self.Owner:IncXP("Lumbering",math.Clamp(math.Round(50 / self.Owner:GetSkill("Lumbering")),1 , 1000))
            self.Owner:SendMessage("Wood ("..num2.."x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))

            if self.Data.Entity then self.Data.Entity.Uses = self.Data.Entity.Uses - num2 end
         else
            self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
         if self.Data.Entity != NULL then
            if self.Data.Entity.Uses <= 0 then
               self.Data.Entity:Fadeout()
            end
         end
end

GMS.RegisterProcess("WoodCutting",PROCESS)

/*---------------------------------------------------------
  Lockpicking
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Picking Lock",self.Time)
         self.Owner:Freeze(true)
         
         self.StartTime = CurTime()
         
         self:PlaySound()
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
         
         self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
         self.Owner:EmitSound(Sound("physics/metal/metal_sheet_impact_bullet1.wav"))
         
         timer.Simple(1.5,self.PlaySound,self)
end

function PROCESS:OnStop()
	local num = math.random(1,100)

	if num < self.Data.Chance + self.Owner:GetSkill("Lockpicking") then
		self.Data.Entity:Fire("unlock", "", 0)
		self.Owner:IncXP("Lockpicking",math.Clamp(math.Round(50 / self.Owner:GetSkill("Lockpicking")),1 , 1000))
		self.Owner:SendMessage("Door Unlocked", 3, Color(10,200,10,255))
		self.Owner:EmitSound(Sound("doors/door_latch3.wav"))
	else
		self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
	end
	
	self.Owner:Freeze(false)
end

GMS.RegisterProcess("Lockpicking",PROCESS)

/*---------------------------------------------------------
  Mining
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Mining",self.Time)
         self.Owner:Freeze(true)
         self.StartTime = CurTime()
         
         self:PlaySound()
         if !self.Data.Entity.Uses then self.Data.Entity.Uses = 250 end
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
         
         self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
         self.Owner:EmitSound(Sound("physics/glass/glass_bottle_impact_hard"..tostring(math.random(1,3))..".wav"))
         
         timer.Simple(1.5,self.PlaySound,self)
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num < self.Data.Chance + self.Owner:GetSkill("Mining") then
            local num2 = math.random(1,2)
            local num3 = math.random(self.Data.MinAmount,self.Data.MaxAmount)

            if num2 == 1 then
               self.Owner:IncResource("Iron",num3)
               self.Owner:SendMessage("Iron ("..num3.."x)", 3, Color(10,200,10,255))
            else
               self.Owner:IncResource("Stone",num3)
               self.Owner:SendMessage("Stone ("..num3.."x)", 3, Color(10,200,10,255))
            end

            self.Owner:IncXP("Mining", math.Clamp(math.Round(50 / self.Owner:GetSkill("Mining")),1 , 1000))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
            if self.Data.Entity then self.Data.Entity.Uses = self.Data.Entity.Uses - num3 end
         else
            self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
         if self.Data.Entity != NULL then
            if self.Data.Entity.Uses <= 0 then
               self.Data.Entity:Fadeout()
            end
         end
end

GMS.RegisterProcess("Mining",PROCESS)
/*---------------------------------------------------------
  Sprout collect
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         if self.Owner:HasUnlock("SproutCollect") then
            self.Owner:MakeProcessBar("Loosening sprout",self.Time)
            self.Owner:Freeze(true)
         else
            self.IsStopped = true
         end
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         local add = 0
         if self.Owner:GetActiveWeapon():GetClass() == "gms_sickle" then add = add + 30 end

         if num > 50 - self.Owner:GetSkill("Harvesting") - add then
            self.Owner:IncResource("Sprouts",1)
            self.Owner:IncXP("Harvesting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Harvesting")),1 , 1000))
            self.Owner:SendMessage("Sprout (1x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))

         else
            self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("SproutCollect",PROCESS)

/*---------------------------------------------------------
  Plant Melon
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Planting Watermelon",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()

         self.Owner:DecResource("Melon_Seeds",1)
         self.Owner:IncXP("Planting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Planting")),1 , 1000))
         self.Owner:SendMessage("Successfully planted.", 3, Color(10,200,10,255))
         
         local ent = ents.Create("GMS_Seed")
         ent:SetPos(self.Data.Pos)
         local tbl = ent:GetTable()
         tbl:Setup("melon",160 - math.Clamp(self.Owner:GetSkill("Planting"),0,60) + math.random(-20,20),self.Owner)
         ent:Spawn()

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("PlantMelon",PROCESS)

/*---------------------------------------------------------
  Plant Grain
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Planting Grain",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()

         self.Owner:DecResource("Grain_Seeds",1)
         self.Owner:IncXP("Planting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Planting")),1 , 1000))
         self.Owner:SendMessage("Successfully planted.", 3, Color(10,200,10,255))
         
         local ent = ents.Create("GMS_Seed")
         ent:SetPos(self.Data.Pos)
         local tbl = ent:GetTable()
         tbl:Setup("grain",160 - math.Clamp(self.Owner:GetSkill("Planting"),0,60) + math.random(-20,20),self.Owner)
         ent:Spawn()

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("PlantGrain",PROCESS)

/*---------------------------------------------------------
  Plant Bush
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Planting Berry Bush",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()

         self.Owner:DecResource("Berries",1)
         self.Owner:IncXP("Planting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Planting")),1 , 1000))
         self.Owner:SendMessage("Successfully planted.", 3, Color(10,200,10,255))
         
         local ent = ents.Create("GMS_Seed")
         ent:SetPos(self.Data.Pos)
         local tbl = ent:GetTable()
         tbl:Setup("berry",160 - math.Clamp(self.Owner:GetSkill("Planting"),0,60) + math.random(-20,20),self.Owner)
         ent:Spawn()

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("PlantBush",PROCESS)
/*---------------------------------------------------------
  Plant Tree
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Planting Tree",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()

         self.Owner:DecResource("Sprouts",1)
         self.Owner:IncXP("Planting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Planting")),1 , 1000))
         self.Owner:SendMessage("Successfully planted.", 3, Color(10,200,10,255))
         
         local ent = ents.Create("GMS_Seed")
         ent:SetPos(self.Data.Pos)
         local tbl = ent:GetTable()
         tbl:Setup("tree",240 - math.Clamp(self.Owner:GetSkill("Planting"),0,60) + math.random(-20,20),self.Owner)
         ent:Spawn()

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("PlantTree",PROCESS)

/*---------------------------------------------------------
  Assembling
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Assembling",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         self.Owner:SendMessage("Assembly successful.", 3, Color(10,200,10,255))
         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Assembling",PROCESS)

/*---------------------------------------------------------
  Fishing
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Fishing",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num < self.Data.Chance + self.Owner:GetSkill("Fishing") then
            self.Owner:IncResource("Fish",1)
            self.Owner:IncXP("Fishing",math.Clamp(math.Round(50 / self.Owner:GetSkill("Fishing")),1 , 1000))
            self.Owner:SendMessage("Fish (1x)", 3, Color(10,200,10,255))
            self.Owner:EmitSound(Sound("ambient/water/water_splash"..math.random(1,3)..".wav"))
         else
            self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Fishing",PROCESS)

/*---------------------------------------------------------
  Bottle Water
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Bottling Water",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         self.Owner:IncResource("Water_Bottles",1)
         self.Owner:SendMessage("Water Bottle (1x)", 3, Color(10,200,10,255))
         self.Owner:EmitSound(Sound("ambient/water/water_splash"..math.random(1,3)..".wav"))

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("BottleWater",PROCESS)

/*---------------------------------------------------------
  Drink bottle
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Drinking Bottle",self.Time)
         self.Owner:Freeze(true)
         self.StartTime = CurTime()
         
         self:PlaySound()
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
         
         self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
         self.Owner:EmitSound(Sound("ambient/water/water_spray"..tostring(math.random(1,3))..".wav"))
         
         timer.Simple(0.5,self.PlaySound,self)
end

function PROCESS:Think()
         if self.Owner.Thirst < 1000 then
            self.Owner:SetThirst(self.Owner.Thirst + 1)
         end
end

function PROCESS:OnStop()
         self.Owner:DecResource("Water_Bottles",1)
         self.Owner:SendMessage("You're a little less thirsty now.", 3, Color(10,200,10,255))

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("DrinkBottle",PROCESS)

/*---------------------------------------------------------
  Cooking
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Cooking "..self.Data.Name,self.Time)
         self.Owner:Freeze(true)
         self.Sound = CreateSound(self.Owner,Sound("npc/headcrab/headcrab_burning_loop2.wav"))
         self.Sound:Play()
end

function PROCESS:OnStop()
         local num = math.random(1,100)
         
         if num >= 50 + self.Owner:GetSkill("Cooking") then
            self.Owner:SendMessage("Successfully cooked.", 3, Color(10,200,10,255))
            self.Owner:IncXP("Cooking",math.Clamp(math.Round(50 / self.Owner:GetSkill("Cooking")),1 , 1000))

            local food = ents.Create("GMS_Food")
            food:SetPos(self.Owner:TraceFromEyes(70).HitPos + Vector(0,0,5))
            food.Value = self.Data.FoodValue
            food:Spawn()

            food:SetFoodInfo(self.Data.Name)
            
            for k,v in pairs(self.Data.Cost) do
                self.Owner:DecResource(k,v)
            end
         else
            self.Owner:SendMessage("Failed.", 3, Color(200,0,0,255))
            
            local num = math.random(1,2)
            
            if num == 1 then
               for k,v in pairs(self.Data.Cost) do
                   self.Owner:DecResource(k,v)
               end
               
               self.Owner:SendMessage("The ingredients was wasted!",3,Color(200,0,0,255))
            end
         end

         self.Sound:Stop()
         self.Owner:Freeze(false)
end

GMS.RegisterProcess("Cook",PROCESS)
/*---------------------------------------------------------
  Make Weapon
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Crafting "..self.Data.Name,self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         self.Owner:SendMessage("Made a "..self.Data.Name..".", 3, Color(10,200,10,255))
         self.Owner:IncXP("Weapon_Crafting",math.Clamp(math.Round(50 / self.Owner:GetSkill("Weapon_Crafting")),1 , 1000))

         local weap = ents.Create(self.Data.Class)
         weap:SetPos(self.Owner:TraceFromEyes(100).HitPos + Vector(0,0,15))
         weap:Spawn()
         
         for k,v in pairs(self.Data.Cost) do
             self.Owner:DecResource(k,v)
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("MakeWeapon",PROCESS)
/*---------------------------------------------------------
  MakeGeneric
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Making "..self.Data.Name,self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         for k,v in pairs(self.Data.Cost) do
             self.Owner:DecResource(k,v)
         end

         for k,v in pairs(self.Data.Res) do
             self.Owner:SendMessage("Made "..string.gsub(k,"_"," ").." ("..v.."x)", 3, Color(10,200,10,255))
             self.Owner:IncResource(k,v)
         end

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("MakeGeneric",PROCESS)
/*---------------------------------------------------------
  Make Building
---------------------------------------------------------*/
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:MakeProcessBar("Setting up "..self.Data.Name.." site",self.Time)
         self.Owner:Freeze(true)
end

function PROCESS:OnStop()
         self.Owner:SendMessage("Made a "..self.Data.Name.." site.", 3, Color(10,200,10,255))
         
         if self.Owner:GetBuildingSite() then self.Owner:GetBuildingSite():Remove() end
         local pos = self.Owner:TraceFromEyes(100).HitPos
         local site = self.Owner:CreateBuildingSite(pos, self.Owner:GetAngles(),self.Data.BuildSiteModel,self.Data.Class)
         local tbl = site:GetTable()

         tbl.Costs = self.Data.Cost

         self.Owner:Freeze(false)
end

GMS.RegisterProcess("MakeBuilding",PROCESS)