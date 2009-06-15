/*---------------------------------------------------------

  Gmod Stranded



---------------------------------------------------------*/

Msg("Loading init.lua\n")

/*---------------------------------------------------------
  Pre-Defines
---------------------------------------------------------*/
-- DeriveGamemode( "sandbox" )
include( 'shared.lua' )
include( 'init_sb.lua' )
include( 'chat.lua' )

// Send clientside files
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "unlocks.lua" )
AddCSLuaFile( "combinations.lua" )

//Processes
include( 'processes.lua' )
//Unlocks
include( 'unlocks.lua' )
//Combis
include( 'combinations.lua' )

//Convars
CreateConVar("gms_FreeBuild","0")
CreateConVar("gms_AllTools","0",FCVAR_ARCHIVED)
CreateConVar("gms_AutoSaveTime","2",FCVAR_ARCHIVED)
CreateConVar("gms_physgun","1")
CreateConVar("gms_ReproduceTrees","0")
CreateConVar("gms_MaxReproducedTrees","50",FCVAR_ARCHIVED)
CreateConVar("gms_AllowSWEPSpawn","0")
CreateConVar("gms_AllowSENTSpawn","0")
CreateConVar("gms_JailRadius","512")
CreateConVar("gms_JailTime","120")

//Vars
GM.NextSaved = 0
GM.NextLoaded = 0

/*---------------------------------------------------------
  Custom Resources
---------------------------------------------------------*/
resource.AddFile("gamemodes/GMStranded/help.htm")

for k,v in pairs(file.Find("../materials/gui/GMS/*")) do
    resource.AddFile("materials/gui/GMS/"..v)
end
/*---------------------------------------------------------

  Utility functions

---------------------------------------------------------*/
/*---------------------------------------------------------
  Custom player messages
---------------------------------------------------------*/
function PlayerMeta:SendMessage(text,duration,color)
         local duration = duration or 3
         local color = color or Color(255,255,255,255)

         umsg.Start("gms_sendmessage",self)
         umsg.String(text)
         umsg.Short(duration)
         umsg.String(color.r..","..color.g..","..color.b..","..color.a)
         umsg.End()
end

function PlayerMeta:SendAchievement(text)
         umsg.Start("gms_sendachievement",self)
         umsg.String(text)
         umsg.End()

         local sound = CreateSound( self, Sound("music/hl1_song11.mp3") )
         sound:Play()
         GAMEMODE.StopSoundDelayed(sound,5.5)
end

function GM.StopSoundDelayed(sound,time)
         timer.Simple(time,GAMEMODE.StopSoundDelayed2,sound)
end

function GM.StopSoundDelayed2(sound)
         sound:Stop()
end

/*---------------------------------------------------------
  Menu toggles
---------------------------------------------------------*/
function GM:ShowHelp( ply )
 	 umsg.Start("gms_ToggleSkillsMenu",ply)
 	 umsg.End()
end

function GM:ShowTeam( ply )
 	 umsg.Start("gms_ToggleResourcesMenu",ply)
 	 umsg.End()
end

function GM:ShowSpare1( ply )
 	 umsg.Start("gms_ToggleCommandsMenu",ply)
 	 umsg.End()
end

function GM:ShowSpare2( ply )
	local tr = ply:TraceFromEyes(150)
	if tr.Entity:IsValid() and tr.Entity:IsDoor() then
		local owner = player.GetByID( tr.Entity:GetNWInt('Owner1') )
		if owner:IsPlayer() then -- Someone owns the door.
			if owner == ply then -- The player owns it, wants to sell.
				tr.Entity:RemoveOwner(ply)
				
				local plyMoney = ply:GetNWInt('money')
				ply:SetNWInt('money', plyMoney + 50)
			else -- Someone else owns the door.
				ply:SendMessage("Door already owned!",3,Color(200,0,0,255))
			end
		else -- No one owns it.
			if tr.Entity:GetNWBool('notOwnable') then -- Door not ownable.
				ply:SendMessage("Door is unownable!",3,Color(200,0,0,255))
			else -- Buy the door.
				tr.Entity:AddOwner(ply)
				
				local plyMoney = ply:GetNWInt('money')
				ply:SetNWInt('money', plyMoney - 100)
			end
		end
	end
end

function PlayerMeta:OpenCombiMenu(str)
         umsg.Start("gms_OpenCombiMenu",self)
         umsg.String(str)
         umsg.End()
end

function PlayerMeta:CloseCombiMenu()
         umsg.Start("gms_CloseCombiMenu",self)
         umsg.End()
end

/*---------------------------------------------------------
  Skill functions
---------------------------------------------------------*/
function PlayerMeta:SetSkill(skill,int)
         if !self.Skills[skill] then self.Skills[skill] = 0 end

         self.Skills[skill] = int
         
         umsg.Start("gms_SetSkill",self)
         umsg.String(skill)
         umsg.Short(self:GetSkill(skill))
         umsg.End()
end

function PlayerMeta:GetSkill(skill)
         return self.Skills[skill] or 0
end

function PlayerMeta:IncSkill(skill,int)
         if !self.Skills[skill] then self:SetSkill(skill,0) end
         if !self.Experience[skill] then self:SetXP(skill,0) end

         if skill != "Survival" then
            self:IncXP("Survival",20)
            self:SendMessage(skill.." +1",3,Color(10,200,10,255))
         else
            self.MaxResources = self.MaxResources + 5

            self:SendAchievement("Level Up!")
         end
         
         self.Skills[skill] = self.Skills[skill] + int
         
         umsg.Start("gms_SetSkill",self)
         umsg.String(skill)
         umsg.Short(self:GetSkill(skill))
         umsg.End()
         
         self:CheckForUnlocks()
end

function PlayerMeta:DecSkill(skill,int)
         self.Skills[skill] = self.Skills[skill] - int
         
         umsg.Start("gms_SetSkill",self)
         umsg.String(skill)
         umsg.Short(self:GetSkill(skill))
         umsg.End()
end

/*---------------------------------------------------------
  XP functions
---------------------------------------------------------*/
function PlayerMeta:SetXP(skill,int)
         if !self.Skills[skill] then self:SetSkill(skill,0) end
         if !self.Experience[skill] then self.Experience[skill] = 0 end

         self.Experience[skill] = int
         
         umsg.Start("gms_SetXP",self)
         umsg.String(skill)
         umsg.Short(self:GetXP(skill))
         umsg.End()
end

function PlayerMeta:GetXP(skill)
         return self.Experience[skill] or 0
end

function PlayerMeta:IncXP(skill,int)
         if !self.Skills[skill] then self.Skills[skill] = 0 end
         if !self.Experience[skill] then self.Experience[skill] = 0 end

         if self.Experience[skill] + int >= 100 then
            self.Experience[skill] = 0
            self:IncSkill(skill,1)
         else
            self.Experience[skill] = self.Experience[skill] + int
         end

         umsg.Start("gms_SetXP",self)
         umsg.String(skill)
         umsg.Short(self:GetXP(skill))
         umsg.End()
end

function PlayerMeta:DecXP(skill,int)
         self.Experience[skill] = self.Experience[skill] - int

         umsg.Start("gms_SetXP",self)
         umsg.String(skill)
         umsg.Short(self:GetXP(skill))
         umsg.End()
end

/*---------------------------------------------------------
  Resource functions
---------------------------------------------------------*/
function PlayerMeta:SetResource(resource,int)
         if !self.Resources[resource] then self.Resources[resource] = 0 end

         self.Resources[resource] = int
         
         umsg.Start("gms_SetResource",self)
         umsg.String(resource)
         umsg.Short(int)
         umsg.End()
end

function PlayerMeta:GetResource(resource)
         return self.Resources[resource] or 0
end

function PlayerMeta:IncResource(resource,int)
         if !self.Resources[resource] then self.Resources[resource] = 0 end
         local all = self:GetAllResources()
         local max = self.MaxResources

         if all + int > max then
            self.Resources[resource] = self.Resources[resource] + (max - all)
            self:DropResource(resource,(all + int) - max)
            self:SendMessage("You can't carry anymore!",3,Color(200,0,0,255))
         else
            self.Resources[resource] = self.Resources[resource] + int
         end

         umsg.Start("gms_SetResource",self)
         umsg.String(resource)
         umsg.Short(self:GetResource(resource))
         umsg.End()
end

function PlayerMeta:GetAllResources()
         local num = 0

         for k,v in pairs(self.Resources) do
             num = num + v
         end

         return num
end

function PlayerMeta:CreateBuildingSite(pos,angle,model,class)
         local rep = ents.Create("GMS_Buildsite")
         local tbl = rep:GetTable()
         rep:SetPos(pos)
         rep:SetAngles(angle)
         tbl:Setup(model,class)
         rep:Spawn()
         rep.Player = self

         self.HasBuildingSite = rep
         return rep
end

function PlayerMeta:GetBuildingSite()
         return self.HasBuildingSite
end

function PlayerMeta:DecResource(resource,int)
         if !self.Resources[resource] then self.Resources[resource] = 0 end
         self.Resources[resource] = self.Resources[resource] - int
         
         umsg.Start("gms_SetResource",self)
         umsg.String(resource)
         umsg.Short(self:GetResource(resource))
         umsg.End()
end

function PlayerMeta:DropResource(resource,int)
         local nearby = {}

         for k,v in pairs(ents.FindByClass("GMS_ResourceDrop")) do
             if v:GetPos():Distance(self:GetPos()) < 150 and v.Type == resource then
                table.insert(nearby,v)
             end
         end

         if #nearby > 0 then
            local ent = nearby[1]
            ent.Amount = ent.Amount + int
            ent:SetResourceDropInfoInstant(ent.Type,ent.Amount)
         else
            local ent = ents.Create("GMS_ResourceDrop")
            ent:SetPos(self:TraceFromEyes(60).HitPos + Vector(0,0,15))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()

            ent:GetPhysicsObject():Wake()

            ent.Type = resource
            ent.Amount = int

            ent:SetResourceDropInfo(ent.Type,ent.Amount)
         end
end

function EntityMeta:SetResourceDropInfo(strType,int)
         timer.Simple(0.5,self.SetResourceDropInfoInstant,self,strType,int)
end

function EntityMeta:SetResourceDropInfoInstant(strType,int)
         for k,v in pairs(player.GetAll()) do
             local strType = strType or "Error"
             umsg.Start("gms_SetResourceDropInfo",v)
             umsg.String(self:EntIndex())
             umsg.String(string.gsub(strType,"_"," "))
             umsg.Short(self.Amount)
             umsg.End()
         end
end

/*---------------------------------------------------------
  Food functions
---------------------------------------------------------*/
function EntityMeta:SetFoodInfo(strType)
         timer.Simple(0.5,self.SetFoodInfoInstant,self,strType)
end

function EntityMeta:SetFoodInfoInstant(strType)
         for k,v in pairs(player.GetAll()) do
             local strType = strType or "Error"
             umsg.Start("gms_SetFoodDropInfo",v)
             umsg.String(self:EntIndex())
             umsg.String(string.gsub(strType,"_"," "))
             umsg.End()
         end
end

function PlayerMeta:SetFood(int)
         if self.Hunger + int > 1000 then
            int = 1000
         end

         self.Hunger = int
         self:UpdateNeeds()
end

function PlayerMeta:GetFood()
         return self.Hunger
end

/*---------------------------------------------------------
  Water functions
---------------------------------------------------------*/
function PlayerMeta:SetThirst(int)
         if self.Thirst + int > 1000 then
            int = 1000
         end

         self.Thirst = int
         self:UpdateNeeds()
end

function PlayerMeta:GetThirst()
         return self.Thirst
end

/*---------------------------------------------------------
  Sleep functions
---------------------------------------------------------*/
function PlayerMeta:SetSleepiness(int)
         if self.Sleepiness + int > 1000 then
            int = 1000
         end

         self.Sleepiness = int
         self:UpdateNeeds()
end

function PlayerMeta:GetSleepiness()
         return self.Sleepiness
end

/*---------------------------------------------------------
  Custom health functions
---------------------------------------------------------*/
function PlayerMeta:Heal(int)
         local max = 100
         
         if self:HasUnlock("Adept_Survivalist") then max = 150 end

         if self:Health() + int > max then
            self:SetHealth(max)
         else
            self:SetHealth(self:Health() + int)
         end
end

/*---------------------------------------------------------
  Unlock functions
---------------------------------------------------------*/
function PlayerMeta:AddUnlock(text)

         self.FeatureUnlocks[text] = 1

         umsg.Start("gms_AddUnlock",self)
         umsg.String(text)
         umsg.End()
         
         if GMS.FeatureUnlocks[text].OnUnlock then GMS.FeatureUnlocks[text].OnUnlock(self) end
end

function PlayerMeta:HasUnlock(text)
         if self.FeatureUnlocks[text] then return true end
         return false
end

function PlayerMeta:CheckForUnlocks()
         for k,unlock in pairs(GMS.FeatureUnlocks) do
             if !self:HasUnlock(k) then
                local NrReqs = 0

                for skill,value in pairs(unlock.Req) do
                    if self:GetSkill(skill) >= value then
                       NrReqs = NrReqs + 1
                    end
                end
             
                if NrReqs == table.Count(unlock.Req) then
                   self:AddUnlock(k)
                end
             end
         end
end

/*---------------------------------------------------------
  Model check functions
---------------------------------------------------------*/
function EntityMeta:IsTreeModel()
         local trees = table.Merge(GMS.TreeModels,GMS.AdditionalTreeModels)
         for k,v in pairs(trees) do
             if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
                return true
             end
         end
         
         return false
end

GMS.BerryBushModels = {"models/props/CS_militia/fern01.mdl","models/props/CS_militia/fern01lg.mdl"}

function EntityMeta:IsBerryBushModel()
         for k,v in pairs(GMS.BerryBushModels) do
             if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
                return true
             end
         end
         
         return false
end

function EntityMeta:IsGrainModel()
         local mdl = "models/props_foliage/cattails.mdl"
         if mdl == self:GetModel() or string.gsub(string.lower(mdl),"/","\\") == self:GetModel() then
            return true
         end

         return false
end

function EntityMeta:IsFoodModel()
         for k,v in pairs(GMS.EdibleModels) do
             if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
                return true
             end
         end
         
         return false
end

function EntityMeta:IsRockModel()
         local rocks = table.Merge(GMS.RockModels,GMS.AdditionalRockModels)
         for k,v in pairs(rocks) do
             if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
                return true
             end
         end

         return false
end

function EntityMeta:IsProp()
         local cls = self:GetClass()

         if (cls == "prop_physics" or cls == "prop_physics_multiplayer" or cls == "prop_dynamic") then
            return true
         end
         
         return false
end


/*---------------------------------------------------------
  Other utilities
---------------------------------------------------------*/
function string.Capitalize(str)
         local str = string.Explode("_",str)
         for k,v in pairs(str) do
             str[k] = string.upper(string.sub(v,1,1))..string.sub(v,2)
         end

         str = string.Implode("_",str)
         return str
end

function EntityMeta:DropToGround()
         local trace = {}
         trace.start = self:GetPos()
         trace.endpos = trace.start + Vector(0,0,-100000)
         trace.mask = MASK_SOLID_BRUSHONLY
         trace.filter = self

         local tr = util.TraceLine(trace)

         self:SetPos(tr.HitPos)
end

function GMS.ClassIsNearby(pos,class,range)
	local nearby = false

	for k,v in pairs(ents.FindInSphere(pos,range)) do
		if v:GetClass() == class then
			nearby = true
		end
	end
	
	return nearby
end

function GMS.IsInWater(pos)
         local trace = {}
         trace.start = pos
         trace.endpos = pos + Vector(0,0,1)
         trace.mask = MASK_WATER

         local tr = util.TraceLine(trace)
         
         return tr.Hit
end

function GMS.Jail(ply)
	if not ply.Warranted then return end
	
	ply.Jailed = true
	for k,ent in pairs(ents.GetAll()) do
		if ((ent:GetClass() == 'gms_spawnpoint') and (ent:GetSpawnName() == 'jail')) then
			ent:SpawnPlayer(ply)
		end
	end
	local jailtime = GetConVar('gms_JailTime'):GetInt()
	timer.Simple(jailtime, GMS.UnJail, ply)
end

function GMS.UnJail(ply)
	--Msg('UNJAIL TIME!!!')
	ply.Jailed = false
	local pos = ply:GetPos()
	local range = GetConVar('gms_JailRadius'):GetInt()
	for k,v in pairs(ents.FindInSphere(pos,range)) do
		if ((v:GetClass() == 'gms_spawnpoint') and (v:GetSpawnName() == 'jail')) then
			-- Is in range of jail still, send to spawn.
			for k,ent in pairs(ents.GetAll()) do
				if ((ent:GetClass() == 'gms_spawnpoint') and (ent:GetSpawnName() == ply:Team())) then
					ent:SpawnPlayer(ply)
				end
			end
		end
	end
end

function EntityMeta:AddOwner(ply)
	local num = self:GetNWInt("OwnerNum") or 0
	num = num + 1
	
	self:SetNWInt("OwnerNum", num)
	self:SetNWInt("Owner" .. num, ply:EntIndex())
end

function EntityMeta:RemoveOwner(ply)
	local num = self:GetNWInt("OwnerNum") or 0

	for n = 1, num do
		if ply:EntIndex() == self:GetNWInt("Owner" .. n) then
			self:SetNWInt("Owner" .. n, -1)
			break
		end
	end
	
	if self:GetNWInt("Owner1") == -1 then
		for i = 1, num do
			self:SetNWInt("Owner" .. i, -1)
		end
		self:SetNWInt('OwnerNum', 0)
	end
end

function EntityMeta:IsOwner(ply)
	local num = self:GetNWInt("OwnerNum") or 0
	
	for n = 1, num do
		if ply:EntIndex() == self:GetNWInt("Owner" .. n) then
			return true
		end
		return false
	end
end

/*---------------------------------------------------------

  Automatic tree reproduction

---------------------------------------------------------*/
function GM.ReproduceTrees()
		-- Msg("ReproduceTrees\n")
		
         local GM = GAMEMODE
         if GetConVarNumber("gms_ReproduceTrees") == 1 then
            local trees = {}
            for k,v in pairs(ents.GetAll()) do
                if v:IsTreeModel() then
                   table.insert(trees,v)
                end
            end

            if #trees < GetConVarNumber("gms_MaxReproducedTrees") then
               for k,ent in pairs(trees) do
                   local num = math.random(1,3)

                   if num == 1 then
                      local nearby = {}
                      for k,v in pairs(ents.FindInSphere(ent:GetPos(),50)) do
                          if v:GetClass() == "GMS_Seed" or v:IsProp() then
                             table.insert(nearby,v)
                          end
                      end
                      
                      if #nearby < 3 then
                         local pos = ent:GetPos() + Vector(math.random(-500,500),math.random(-500,500),0)
                         local retries = 50

                         while (pos:Distance(ent:GetPos()) < 200 or GMS.ClassIsNearby(pos,"prop_physics",100)) and retries > 0 do
                               pos = ent:GetPos() + Vector(math.random(-300,300),math.random(-300,300),0)
                               retries = retries - 1
                         end

                         local pos = pos + Vector(0,0,500)

                         local seed = ents.Create("GMS_Seed")
                         seed:SetPos(pos)
                         seed:DropToGround()
                         seed:Setup("tree",180)
                         seed:Spawn()
                      end
                   end
                end
            end
            if #trees == 0 then
               local info = {}
               for i = 1,20 do
                   info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
                   info.Retries = 50

                   //Find pos in world
                   while util.IsInWorld(info.pos) == false and info.Retries > 0 do
                         info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
                         info.Retries = info.Retries - 1
                   end
             
                   //Find ground
                   local trace = {}
                   trace.start = info.pos
                   trace.endpos = trace.start + Vector(0,0,-100000)
                   trace.mask = MASK_SOLID_BRUSHONLY

                   local groundtrace = util.TraceLine(trace)

                   //Assure space
                   local nearby = ents.FindInSphere(groundtrace.HitPos,200)
                   info.HasSpace = true
             
                   for k,v in pairs(nearby) do
                       if v:IsProp() then
                          info.HasSpace = false
                       end
                   end

                   //Find sky
                   local trace = {}
                   trace.start = groundtrace.HitPos
                   trace.endpos = trace.start + Vector(0,0,100000)

                   local skytrace = util.TraceLine(trace)
             
                   //Find water?
                   local trace = {}
                   trace.start = groundtrace.HitPos
                   trace.endpos = trace.start + Vector(0,0,1)
                   trace.mask = MASK_WATER

                   local watertrace = util.TraceLine(trace)

                   //All a go, make entity
                   if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
                      local seed = ents.Create("GMS_Seed")
                      seed:SetPos(groundtrace.HitPos)
                      seed:DropToGround()
                      seed:Setup("tree",180 + math.random(-20,20))
                      seed:Spawn()
                   end
                end
             end
         end

         timer.Simple(math.random(1,3) * 60,GM.ReproduceTrees)
end

timer.Simple(60,GM.ReproduceTrees)

/*---------------------------------------------------------

  Admin terraforming

---------------------------------------------------------*/
function GM.CreateRandomTree(ply)
         if !ply:IsAdmin() then 
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         local tr = ply:TraceFromEyes(10000)
         
         GAMEMODE.MakeTree(tr.HitPos)
end

concommand.Add("gms_admin_maketree",GM.CreateRandomTree)

function GM.CreateRandomRock(ply)
	if !ply:IsAdmin() then 
		ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
	return end
	
	local tr = ply:TraceFromEyes(10000)
	
	local ent = ents.Create("prop_physics_multiplayer")
	ent:SetPos(tr.HitPos)
	ent:SetModel(GMS.RockModels[math.random(1,#GMS.RockModels)])
	ent:SetAngles(Angle(0,math.random(1,360),0))
	ent:Spawn()
	
	ent:GetPhysicsObject():EnableMotion(false)
end

concommand.Add("gms_admin_makerock",GM.CreateRandomRock)

function GM.CreateRandomFood(ply)
         if !ply:IsAdmin() then 
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         local tr = ply:TraceFromEyes(10000)
         
         local ent = ents.Create("prop_physics_multiplayer")
         ent:SetPos(tr.HitPos + Vector(0,0,10))
         ent:SetModel(GMS.EdibleModels[math.random(1,#GMS.EdibleModels)])
         ent:SetAngles(Angle(0,math.random(1,360),0))
         ent:Spawn()
end

concommand.Add("gms_admin_makefood",GM.CreateRandomFood)

function GM.MakeAntlionBarrow(ply,cmd,args)
         if !ply:IsAdmin() then
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         if !args[1] then
            ply:SendMessage("Specify max antlions!",3,Color(200,0,0,255))
         return end

         local tr = ply:TraceFromEyes(10000)

         local ent = ents.Create("GMS_AntlionBarrow")
         ent:SetPos(tr.HitPos)
         ent:Spawn()
         
         ent:SetKeyValue("MaxAntlions",args[1])
         Msg("Sending keyvalue: "..args[1].."\n")
end

concommand.Add("gms_admin_MakeAntlionBarrow",GM.MakeAntlionBarrow)

function GM.CreateRandomBush(ply)
         local GM = GAMEMODE
         if !ply:IsAdmin() then 
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         local tr = ply:TraceFromEyes(10000)
         local typ = math.random(1,3)
         local pos = tr.HitPos

         if typ == 1 then
            GM.MakeMelon(pos,math.random(1,2))
         elseif typ == 2 then
            GM.MakeBush(pos)
         elseif typ == 3 then
            GM.MakeGrain(pos)
         end
end

concommand.Add("gms_admin_makebush",GM.CreateRandomBush)

function GM.PopulateArea(ply,cmd,args)
         local GM = GAMEMODE
         if !ply:IsAdmin() then
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         if !args[1] or !args[2] or !args[3] then
            ply:SendMessage("You need to specify <type> <amount> <radius>",3,Color(200,0,0,255))
         return end
         
         for k,v in pairs(player.GetAll()) do
             v:SendMessage("Populating area...",3,Color(255,255,255,255))
         end
         
         //Population time
         local Amount = tonumber(args[2])
         local info = {}
         info.Amount = Amount

         if Amount > 200 then 
            ply:SendMessage("Auto-capped at 200 props.",3,Color(200,0,0,255))
            info.Amount = 200
         end

         local Type = args[1]
         local Amount = info.Amount
         local Radius = tonumber(args[3])

         //Find playertrace
         local plytrace = ply:TraceFromEyes(10000)

         for i = 1,Amount do

             info.pos = plytrace.HitPos + Vector(math.random(-Radius,Radius),math.random(-Radius,Radius),1000)
             info.Retries = 50

             //Find pos in world
             while util.IsInWorld(info.pos) == false and info.Retries > 0 do
                   info.pos = plytrace.HitPos + Vector(math.random(-Radius,Radius),math.random(-Radius,Radius),1000)
                   info.Retries = info.Retries - 1
             end
             
             //Find ground
             local trace = {}
             trace.start = info.pos
             trace.endpos = trace.start + Vector(0,0,-100000)
             trace.mask = MASK_SOLID_BRUSHONLY

             local groundtrace = util.TraceLine(trace)

             //Assure space
             local nearby = ents.FindInSphere(groundtrace.HitPos,200)
             info.HasSpace = true
             
             for k,v in pairs(nearby) do
                 if v:IsProp() then
                    info.HasSpace = false
                 end
             end
             
             //Find sky
             local trace = {}
             trace.start = groundtrace.HitPos
             trace.endpos = trace.start + Vector(0,0,100000)

             local skytrace = util.TraceLine(trace)
             
             //Find water?
             local trace = {}
             trace.start = groundtrace.HitPos
             trace.endpos = trace.start + Vector(0,0,1)
             trace.mask = MASK_WATER

             local watertrace = util.TraceLine(trace)

             //All a go, make entity
             if Type == "forest" then
                if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
                   GM.MakeTree(groundtrace.HitPos)
                end
             elseif Type == "rocks" then
                 if !watertrace.Hit then
                    local ent = ents.Create("prop_physics_multiplayer")
                    ent:SetPos(groundtrace.HitPos)
                    ent:SetModel(GMS.RockModels[math.random(1,#GMS.RockModels)])
                    ent:SetAngles(Angle(0,math.random(1,360),0))
                    ent:Spawn()
             
                    ent:GetPhysicsObject():EnableMotion(false)
                 end
             elseif Type == "plant" and info.HasSpace then
                 local typ = math.random(1,3)
                 local pos = groundtrace.HitPos

                 if typ == 1 then
                    GM.MakeMelon(pos,math.random(1,2))
                 elseif typ == 2 then
                    GM.MakeBush(pos)
                 elseif typ == 3 then
                    GM.MakeGrain(pos)
                 end
              end
          end
          
          //Finished
          for k,v in pairs(player.GetAll()) do
             v:SendMessage("Done!",3,Color(255,255,255,255))
          end
          

end

concommand.Add("gms_admin_PopulateArea",GM.PopulateArea)

function GM.TreeRockCleanup(ply)
         if !ply:IsAdmin() then
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         for k,v in pairs(ents.GetAll()) do
             if v:IsRockModel() or v:IsTreeModel() then
                
                for k,tbl in pairs(GAMEMODE.RisingProps) do
                    if tbl.Entity == v then
                       table.remove(GAMEMODE.RisingProps,k)
                    end
                end
                
                for k,tbl in pairs(GAMEMODE.SinkingProps) do
                    if tbl.Entity == v then
                       table.remove(GAMEMODE.SinkingProps,k)
                    end
                end
                
                for k,ent in pairs(GAMEMODE.FadingInProps) do
                    if ent == v then
                       table.remove(GAMEMODE.FadingInProps,k)
                    end
                end

                v:Fadeout()
             end
         end
         
         for k,v in pairs(player.GetAll()) do v:SendMessage("Cleared map.",3,Color(255,255,255,255)) end
end

concommand.Add("gms_admin_clearmap",GM.TreeRockCleanup)

function GM.SetClassSpawn(ply,cmd,args)
	if !ply:IsAdmin() then 
		ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
	return end
	
	local tr = ply:TraceFromEyes(150)
	
	if tr.HitWorld then
		local ent = ents.Create("GMS_Spawnpoint")
		ent:SetPos(tr.HitPos)
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion(false)
		ent:SetSpawnName(args[1])
		-- Msg('Spawnpoint created for class ' .. ent:GetSpawnName() .. ".\n")
	else
		ply:SendMessage("Aim at the ground to spawn.",3,Color(200,0,0,255))
	end
end
concommand.Add("gms_admin_setspawn",GM.SetClassSpawn)
/*---------------------------------------------------------

  Prop fadeout

---------------------------------------------------------*/
GMS.FadingOutProps = {}
GMS.FadingInProps = {}

function EntityMeta:Fadeout(speed)
         local speed = speed or 1

         for k,v in pairs(player.GetAll()) do
             umsg.Start("gms_CreateFadingProp",v)
             umsg.String(self:GetModel())
             umsg.Vector(self:GetPos())
             umsg.Vector(self:GetAngles():Forward())
             umsg.Short(math.Round(speed))
             umsg.End()
         end
         
         self:Remove()
end

//Fadein is serverside
function EntityMeta:Fadein()
         self.AlphaFade = 0
         self:SetColor(255,255,255,0)
         table.insert(GMS.FadingInProps,self)
end


function GM.FadeFadingProps()
         for k,ent in pairs(GMS.FadingInProps) do
             if !ent or ent == NULL then
                table.remove(GMS.FadingInProps,k)
             elseif !ent:IsValid() then
                table.remove(GMS.FadingInProps,k)
             elseif ent.AlphaFade >= 255 then
                table.remove(GMS.FadingInProps,k)
             else
                ent.AlphaFade = ent.AlphaFade + 1
                ent:SetColor(255,255,255,ent.AlphaFade)
             end
         end
end

hook.Add("Think","gms_FadePropsThink",GM.FadeFadingProps)
/*---------------------------------------------------------

  Prop rising/lowering

---------------------------------------------------------*/
GM.RisingProps = {}
GM.SinkingProps = {}

function EntityMeta:RiseFromGround(speed,altmax)
         local speed = speed or 1
         local max;

         if !altmax then
             min,max = self:WorldSpaceAABB()
             max = max.z
         else
             max = altmax
         end

         local tbl = {}
         tbl.Origin = self:GetPos().z
         tbl.Speed = speed
         tbl.Entity = self

         self:SetPos(self:GetPos() + Vector(0,0,-max + 10))
         table.insert(GAMEMODE.RisingProps,tbl)
end

function EntityMeta:SinkIntoGround(speed)
         local speed = speed or 1

         local tbl = {}
         tbl.Origin = self:GetPos().z
         tbl.Speed = speed
         tbl.Entity = self
         tbl.Height = max
         
         table.insert(GAMEMODE.SinkingProps,tbl)
end

function GM.RiseAndSinkProps()
         local GM = GAMEMODE

         for k,tbl in pairs(GM.RisingProps) do
             if tbl.Entity:GetPos().z >= tbl.Origin then
                table.remove(GM.RisingProps,k)
             else
                tbl.Entity:SetPos(tbl.Entity:GetPos() + Vector(0,0,1*tbl.Speed))
             end
         end

         for k,tbl in pairs(GM.SinkingProps) do
             if tbl.Entity:GetPos().z <= tbl.Origin - tbl.Height then
                table.remove(GM.SinkingProps,k)
                tbl.Entity:Remove()
             else
                tbl.Entity:SetPos(tbl.Entity:GetPos() + Vector(0,0,-1*tbl.Speed))
             end
         end
end

hook.Add("Think","gms_RiseAndSinkPropsHook",GM.RiseAndSinkProps)
/*---------------------------------------------------------

  Spawn/death

---------------------------------------------------------*/

firstPlayerMapLoad = false

function GM:PlayerInitialSpawn(ply)
	//Create HUD
	umsg.Start("gms_CreateInitialHUD",ply)
	umsg.End()

	ply:SetTeam(1)
	ply:ConCommand("gms_help\n")

	//Serverside player variables
	ply.Skills = {}
	ply.Resources = {}
	ply.Experience = {}
	ply.FeatureUnlocks = {}
	ply.Warranted = false
	ply.Jailed = false
	
	//Admin info, needed clientside
	if ply:IsAdmin() then
		for k,v in pairs(file.Find("GMStranded/Gamesaves/*.txt")) do
			local name = string.sub(v,1,string.len(v) - 4)

			if string.Right(name,5) != "_info" then
			umsg.Start("gms_AddLoadGameToList",ply)
			umsg.String(name)
			umsg.End()
			end
		end
	end

	//Character loading
	if file.Exists("GMStranded/Saves/"..ply:UniqueID()..".txt") then
		local tbl = util.KeyValuesToTable(file.Read("GMStranded/Saves/"..ply:UniqueID()..".txt"))

		if tbl["skills"] then
		for k,v in pairs(tbl["skills"]) do
			ply:SetSkill(string.Capitalize(k),v)
		end
		end

		if tbl["experience"] then
		for k,v in pairs(tbl["experience"]) do
			ply:SetXP(string.Capitalize(k),v)
		end
		end
		
		if tbl["unlocks"] then 
		for k,v in pairs(tbl["unlocks"]) do
			ply.FeatureUnlocks[string.Capitalize(k)] = v
		end
		end
		
		for k,v in pairs(GMS.FeatureUnlocks) do
			if ply:HasUnlock(k) then
			if v.OnUnlock then v.OnUnlock(ply) end
			end
		end

		if !ply.Skills["Survival"] then ply.Skills["Survival"] = 0 end
		
		ply.MaxResources = (ply.Skills["Survival"] * 5) + 25
		
		ply:SetNWInt('money', tbl.money)

		ply:SendMessage("Loaded character successfully.",3,Color(255,255,255,255))
		ply:SendMessage("Last visited on "..tbl.date..", enjoy your stay.",10,Color(255,255,255,255))
	else
		ply:SetSkill("Survival",0)
		ply:SetXP("Survival",0)
		ply.MaxResources = 25
		ply:SetNWInt('money', 750)
	end
	
	if !firstPlayerMapLoad then
		-- Msg('Initial Spawn Load Command sent.\n')
		-- ply:timer.Simple(4, self.ConCommand, "gms_autoload\n")
		ply:ConCommand("gms_autoload\n")
	end
end

function GM:PlayerSpawn(ply)
	--Msg(ply.Jailed)
	if ply.Jailed then
		--Msg('U IS IN JAIL!!!')
		for k,ent in pairs(ents.GetAll()) do
			if ((ent:GetClass() == 'gms_spawnpoint') and (ent:GetSpawnName() == 'jail')) then
				ent:SpawnPlayer(ply)
			end
		end
	else
		for k,ent in pairs(ents.GetAll()) do
			if ((ent:GetClass() == 'gms_spawnpoint') and (ent:GetSpawnName() == ply:Team())) then
				ent:SpawnPlayer(ply)
			end
		end
	end
	
	if ply:HasUnlock("Sprint_Mkii") then
		ply:SetWalkSpeed(400)
		ply:SetRunSpeed(150)
	else
		ply:SetWalkSpeed(250)
		ply:SetRunSpeed(250)
	end

	self:PlayerSetModel( ply )
	self:PlayerLoadout(ply)

	ply.Sleepiness = 1000
	ply.Hunger = 1000
	ply.Thirst = 1000
	if ply:HasUnlock("Adept_Survivalist") then ply:SetHealth(150) end

	ply:UpdateNeeds()
	
	--SbPlayerSpawn(ply)
end

function GM:PlayerSetModel( ply )
	ply:SetModel( GMS.classModels[ply:Team()] )
end

function GM:PlayerLoadout(ply)
	//Tools
	ply:Give("gms_hands")
	ply:Give('gms_keys')
	
	if GetConVarNumber("gms_AllTools") == 1 then
		ply:Give("gms_pickaxe")
		ply:Give("gms_hatchet")
		ply:Give("gms_fishingrod")
		ply:Give("gms_fryingpan")
		ply:Give("gms_shovel")
		ply:Give("gms_strainer")
		ply:Give("gms_sickle")
	end

	//Gmod
	if GetConVarNumber("gms_physgun") == 1 or ply:IsAdmin() then ply:Give("weapon_physgun") end
	ply:Give("weapon_physcannon")
	ply:Give("gmod_tool")
	
	ply:SelectWeapon("gms_hands")
	
	-- Class Specific
	if (ply:Team() == 2) or ply:IsAdmin() then --Cop
		ply:Give('gms_stunstick')
		ply:Give('gms_arrest')
		ply:Give('gms_ram')
	end
	
end

function GM:PlayerDeath(ply)
         self.PlayerWake(ply)
         
         for k,v in pairs(ply.Resources) do
             ply:SetResource(k,0)
         end
end

/*---------------------------------------------------------

  Character saving

---------------------------------------------------------*/
function GM.AutoSaveAllCharacters()
	local GM = GAMEMODE
	
	local ClassPayday = {
		50,
		50,
		50,
		60,
		60,
		100,
		80
	}
	
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			local payday = ClassPayday[v:Team()]
			local money = v:GetNWInt('money')
			v:SetNWInt('money', money + payday)
			v:SendMessage("Payday! You've earned $" .. payday .. '.',10,Color(255,255,255,255))
		end
		
		v:SendMessage("Autosaving..",3,Color(255,255,255,255))
		GM.SaveCharacter(v)
	end
	
	timer.Simple(math.Clamp(GetConVarNumber("gms_AutoSaveTime"),1,60) * 60,GM.AutoSaveAllCharacters)
end
timer.Simple(1,GM.AutoSaveAllCharacters)

function GM:PlayerDisconnected(ply)
         self.SaveCharacter(ply)
         Msg("Saved character of disconnecting player "..ply:Nick()..".\n")
end

function GM:ShutDown()
         for k,v in pairs(player.GetAll()) do
             self.SaveCharacter(v)
         end
end

function GM.SaveCharacter(ply,cmd,args)
	if !file.IsDir("GMStranded") then file.CreateDir("GMStranded") end
	if !file.IsDir("GMStranded/Saves") then file.CreateDir("GMStranded/Saves") end

	local tbl = {}
	tbl["skills"] = {}
	tbl["experience"] = {}
	tbl["unlocks"] = {}
	tbl["date"] = os.date("%A %m/%d/%y")
	tbl["name"] = ply:Nick()
	tbl['money'] = ply:GetNWInt('money')

	for k,v in pairs(ply.Skills) do
		tbl["skills"][k] = v
	end
	
	for k,v in pairs(ply.Experience) do
		tbl["experience"][k] = v
	end
	
	for k,v in pairs(ply.FeatureUnlocks) do
		tbl["unlocks"][k] = v
	end

	file.Write("GMStranded/Saves/"..ply:UniqueID()..".txt",util.TableToKeyValues(tbl))
	ply:SendMessage("Saved character!",3,Color(255,255,255,255))
end

concommand.Add("gms_savecharacter",GM.SaveCharacter)

function GM.SaveAllCharacters(ply)
         if !ply:IsAdmin() then 
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end
         
         for k,v in pairs(player.GetAll()) do
             GAMEMODE.SaveCharacter(v)
         end
         
         ply:SendMessage("Saved characters on all current players.",3,Color(255,255,255,255))
end

concommand.Add("gms_admin_saveallcharacters",GM.SaveAllCharacters)

/*---------------------------------------------------------

  Planting

---------------------------------------------------------*/
//Melon planting
function GM.PlantMelon(ply,cmd,args)

         local tr = ply:TraceFromEyes(150)
         
         if tr.HitWorld then
            if (tr.MatType == MAT_DIRT or tr.MatType == MAT_GRASS or tr.MatType == MAT_SAND) and !GMS.IsInWater(tr.HitPos) then
               if ply:GetResource("Melon_Seeds") >= 1 then
                  if !GMS.ClassIsNearby(tr.HitPos,"GMS_Seed",25) and !GMS.ClassIsNearby(tr.HitPos,"prop_physics",25) then
                     local data = {}
                     data.Pos = tr.HitPos

                     ply:DoProcess("PlantMelon",3,data)
                  else
                     ply:SendMessage("You need more distance between seeds/props.",3,Color(200,0,0,255))
                  end
               else
                  ply:SendMessage("You need a watermelon seed.",3,Color(200,0,0,255))
               end
            else
               ply:SendMessage("You cannot plant on this terrain.",3,Color(200,0,0,255))
            end
         else
            ply:SendMessage("Aim at the ground to plant.",3,Color(200,0,0,255))
         end
end

concommand.Add("gms_plantmelon",GM.PlantMelon)

//Grain planting
function GM.PlantGrain(ply,cmd,args)

         local tr = ply:TraceFromEyes(150)
         
         if tr.HitWorld then
            local nearby = false
            
            for k,v in pairs(ents.FindInSphere(tr.HitPos,25)) do
                if v:IsGrainModel() or v:IsProp() or v:GetClass() == "GMS_Seed" then
                   nearby = true
                end
            end

            if (tr.MatType == MAT_DIRT or tr.MatType == MAT_GRASS or tr.MatType == MAT_SAND) and !GMS.IsInWater(tr.HitPos) then
               if ply:GetResource("Grain_Seeds") >= 1 then
                  if !nearby then
                     local data = {}
                     data.Pos = tr.HitPos

                     ply:DoProcess("PlantGrain",3,data)
                  else
                     ply:SendMessage("You need more distance between seeds/props.",3,Color(200,0,0,255))
                  end
               else
                  ply:SendMessage("You need a grain seed.",3,Color(200,0,0,255))
               end
            else
               ply:SendMessage("You cannot plant on this terrain.",3,Color(200,0,0,255))
            end
         else
            ply:SendMessage("Aim at the ground to plant.",3,Color(200,0,0,255))
         end
end

concommand.Add("gms_plantgrain",GM.PlantGrain)

//Berry planting
function GM.PlantBush(ply,cmd,args)

         local tr = ply:TraceFromEyes(150)
         
         if tr.HitWorld then
            local nearby = false
            
            for k,v in pairs(ents.FindInSphere(tr.HitPos,25)) do
                if v:IsGrainModel() or v:IsProp() or v:GetClass() == "GMS_Seed" then
                   nearby = true
                end
            end

            if (tr.MatType == MAT_DIRT or tr.MatType == MAT_GRASS or tr.MatType == MAT_SAND) and !GMS.IsInWater(tr.HitPos) then
               if ply:GetResource("Berries") >= 1 then
                  if !nearby then
                     local data = {}
                     data.Pos = tr.HitPos

                     ply:DoProcess("PlantBush",3,data)
                  else
                     ply:SendMessage("You need more distance between seeds/props.",3,Color(200,0,0,255))
                  end
               else
                  ply:SendMessage("You need a berry.",3,Color(200,0,0,255))
               end
            else
               ply:SendMessage("You cannot plant on this terrain.",3,Color(200,0,0,255))
            end
         else
            ply:SendMessage("Aim at the ground to plant.",3,Color(200,0,0,255))
         end
end

concommand.Add("gms_plantbush",GM.PlantBush)

//Tree planting
function GM.PlantTree(ply,cmd,args)
         if !ply:HasUnlock("Sprout_Planting") then
            ply:SendMessage("You need more planting skill.",3,Color(200,0,0,255))
         return end

         local tr = ply:TraceFromEyes(150)
         
         if tr.HitWorld then 
            if (tr.MatType == MAT_DIRT or tr.MatType == MAT_GRASS or tr.MatType == MAT_SAND) and !GMS.IsInWater(tr.HitPos) then
               if ply:GetResource("Sprouts") >= 1 then
                  local data = {}
                  data.Pos = tr.HitPos

                  ply:DoProcess("PlantTree",5,data)
               else
                  ply:SendMessage("You need a sprout.",3,Color(200,0,0,255))
               end
            else
               ply:SendMessage("You cannot plant on this terrain.",3,Color(200,0,0,255))
            end
         else
            ply:SendMessage("Aim at the ground to plant.",3,Color(200,0,0,255))
         end
end

concommand.Add("gms_planttree",GM.PlantTree)
/*---------------------------------------------------------

  Drink command

---------------------------------------------------------*/
function GM.DrinkFromBottle(ply,cmd,args)
         if ply:GetResource("Water_Bottles") < 1 then
            ply:SendMessage("You need a water bottle.",3,Color(200,0,0,255))
         return end

         ply:DoProcess("DrinkBottle",1.5)
end

concommand.Add("gms_DrinkBottle",GM.DrinkFromBottle)
/*---------------------------------------------------------

  Drop weapon command

---------------------------------------------------------*/
function GM.DropWeapon(ply,cmd,args)
         if !ply:Alive() then return end
         if ply:GetActiveWeapon():GetClass() == "gms_hands" then
            ply:SendMessage("You cannot drop your hands!",3,Color(200,0,0,255))
         else
            ply:DropWeapon(ply:GetActiveWeapon())
         end
end

concommand.Add("gms_DropWeapon",GM.DropWeapon)
/*---------------------------------------------------------

  Drop resource command

---------------------------------------------------------*/
function GM.DropResource(ply,cmd,args)
         if (!args[1] or !args[2]) then
            ply:SendMessage("You need to input all values!",3,Color(200,0,0,255))
         return end

         if tonumber(args[2]) <= 0 then
            ply:SendMessage("Nay, you won't get away with negative numbers either.",3,Color(200,0,0,255))
         return end

         if !ply.Resources[args[1]] then
            ply:SendMessage("You don't have this kind of resource.",3,Color(200,0,0,255))
         return end

         local int = tonumber(args[2])
         local Type = args[1]
         
         local res = ply:GetResource(Type)
         
         if int > res then
            int = res
         end
         
         ply:DropResource(Type,int)
         ply:DecResource(Type,int)
         ply:SendMessage("Dropped "..Type.." ("..int.."x)",3,Color(10,200,10,255))
end

concommand.Add("gms_DropResources",GM.DropResource)
/*---------------------------------------------------------

  Buildings menu

---------------------------------------------------------*/
function GM.OpenBuildingsCombi(ply)
         ply:OpenCombiMenu("Buildings")
end

concommand.Add("gms_BuildingsCombi",GM.OpenBuildingsCombi)
/*---------------------------------------------------------

  Generic combi menu

---------------------------------------------------------*/
function GM.OpenGenericCombi(ply)
         ply:OpenCombiMenu("Generic")
end

concommand.Add("gms_GenericCombi",GM.OpenGenericCombi)
/*---------------------------------------------------------

  Make combination

---------------------------------------------------------*/
function GM.MakeCombination(ply,cmd,args)
	if !args[1] or !args[2] then
		ply:SendMessage("Please specify a valid combination.",3,Color(255,255,255,255))
		ply:CloseCombiMenu()
	return end
	
	local group = args[1]
	local combi = args[2]

	if !GMS.Combinations[group] then return end
	if !GMS.Combinations[group][combi] then return end

	local tbl = GMS.Combinations[group][combi]

	//Check for nearby forge/fire etc:
	if group == "Cooking" then
		local nearby = false
		
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),100)) do
			if (v:IsProp() and v:IsOnFire()) or v:GetModel() == "models/props_c17/furniturestove001a.mdl" then nearby = true end
		end
		
		if !nearby then
			ply:SendMessage("You need to be close to a fire!",3,Color(200,0,0,255))
			ply:CloseCombiMenu()
		return end

	elseif group == "Weapons" then
		local nearby = false
		
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),100)) do
			if v:GetClass() == "GMS_Workbench" then nearby = true end
		end
		
		if !nearby then
			ply:SendMessage("You need to be close to a workbench!",3,Color(200,0,0,255))
			ply:CloseCombiMenu()
		return end
	end

	//Check for skills
	local numreq = 0

	if tbl.SkillReq then
		for k,v in pairs(tbl.SkillReq) do
			if ply:GetSkill(k) >= v then
				numreq = numreq + 1
			end
		end
		
		if numreq < table.Count(tbl.SkillReq) then
			ply:SendMessage("Not enough skill.",3,Color(200,0,0,255))
			ply:CloseCombiMenu()
		return end
	end
	


	//Check for resources
	local numreq = 0
	
	for k,v in pairs(tbl.Req) do
		if ply:GetResource(k) >= v then
			numreq = numreq + 1
		end
	end
	
	if numreq < table.Count(tbl.Req) and group != "Buildings" then
		ply:SendMessage("Not enough resources.",3,Color(200,0,0,255))
		ply:CloseCombiMenu()
	return end

	ply:CloseCombiMenu()
	//all well, make stuff:
	if group == "Cooking" then
		local data = {}
		data.Name = tbl.Name
		data.FoodValue = tbl.FoodValue
		data.Cost = tbl.Req

		local time = 5
		
		if ply:GetActiveWeapon():GetClass() == "gms_fryingpan" then
			time = 2
		end

		ply:DoProcess("Cook",time,data)

	elseif group == "Generic" then
		local data = {}
		data.Name = tbl.Name
		data.Res = tbl.Results
		data.Cost = tbl.Req
		local time = 5

		ply:DoProcess("MakeGeneric",time,data)

	elseif group == "Weapons" then
		local data = {}
		data.Name = tbl.Name
		data.Class = tbl.SwepClass
		data.Cost = tbl.Req
		local time = 10

		ply:DoProcess("MakeWeapon",time,data)

	elseif group == "Buildings" then
		local data = {}
		data.Name = tbl.Name
		data.Class = tbl.Result
		data.Cost = tbl.Req
		data.BuildSiteModel = tbl.BuildSiteModel
		local time = 20
		
		ply:DoProcess("MakeBuilding",time,data)
	end
end

concommand.Add("gms_MakeCombination",GM.MakeCombination)
/*---------------------------------------------------------

  STOOLs and Physgun

---------------------------------------------------------*/
function GM:PhysgunPickup(ply, ent)
         if ply:IsAdmin() then return true end
         
         if ent.StrandedProtected or ent:IsRockModel() or ent:IsTreeModel() or ent:IsPlayer() or table.HasValue(GMS.PickupProhibitedClasses,ent:GetClass()) then
            return false
         else
            return true
         end
end

function GM:GravGunPunt( ply, ent )
         return ply:IsAdmin()
end

GM.ProhibitedStools = {"duplicator"}

function GM:CanTool(ply,tr,mode)
         local ent = tr.Entity

         if mode == "remover" then
            if !ply:IsAdmin() then
               if (ent:IsFoodModel() or ent:IsTreeModel() or ent:IsRockModel() or table.HasValue(GMS.PickupProhibitedClasses,ent:GetClass())) then
                   ply:SendMessage("This is prohibited!",3,Color(200,0,0,255))
                   return false
               end
            end
         end
         
         if table.HasValue(self.ProhibitedStools,mode) then
            ply:SendMessage("This sTOOL is prohibited.",3,Color(200,0,0,255))
         return false
         end
         
         return true
end
/*---------------------------------------------------------

  Server Chat

---------------------------------------------------------*/
function GM.IncomingServerChatMessage(ply,cmd,args)
         local msg = table.concat(args," ")
         
         for k,v in pairs(player.GetAll()) do
             umsg.Start("gms_AddServerChatMessage",v)
             umsg.String(ply:Nick())
             umsg.String(msg)
             umsg.End()
         end
end

concommand.Add("gms_say",GM.IncomingServerChatMessage)
/*---------------------------------------------------------

  Prop spawning

---------------------------------------------------------*/
function GM:PlayerSpawnedProp( ply, mdl, ent )
         if GetConVarNumber("gms_FreeBuild") == 1 then return end
         if ply.InProcess then 
            ent:Remove()
         return end

         if ply.CanSpawnProp == false then
            ent:Remove()
            ply:SendMessage("No spamming!",3,Color(200,0,0,255))
         return end
         
         ply.CanSpawnProp = false
         timer.Simple(0.2,self.PlayerSpawnedPropDelay, self, ply, mdl, ent)
end

function GM:PlayerSpawnedPropDelay( ply, mdl, ent )
         ply.CanSpawnProp = true
         if ply.InProcess then return end

         //Admin only models
         if (ent:IsRockModel() or ent:IsTreeModel() or ent:IsFoodModel()) and !ply:IsAdmin() then
            ent:Remove()
            ply:SendMessage("You cannot spawn this prop unless you're admin.",5,Color(255,255,255,255))
         return end

         //Trace
         ent.EntOwner = ply
         local min,max = ent:WorldSpaceAABB()
         local mass = ent:GetPhysicsObject():GetMass()

         local trace = {}
         trace.start = ent:GetPos() + Vector(0,0,100)
         trace.endpos = ent:GetPos()

         local tr = util.TraceLine(trace)
         
         //Faulty trace
         if tr.Entity != ent then
            ent:Remove()
            ply:SendMessage("You need more space to spawn.",3,Color(255,255,255,255))
         return end

         local res = GMS.MaterialResources[tr.MatType]
         local cost = math.Clamp(math.Round(mass / 4),1,500)
         
         if cost > ply:GetResource(res) then
            if ply:GetBuildingSite() and ply:GetBuildingSite():IsValid() then ply:GetBuildingSite():Remove() end
            
            local site = ply:CreateBuildingSite(ent:GetPos(),ent:GetAngles(),ent:GetModel(),ent:GetClass())
            local tbl = site:GetTable()

            local costtable = {}
            costtable[res] = cost

            tbl.Costs = costtable

            tbl:AddResource(ply,res,ply:GetResource(res))
            ply:DecResource(res,ply:GetResource(res))
            ply:DoProcess("Assembling",2)
            ply:SendMessage("Not enough resources, creating buildsite.",3,Color(255,255,255,255))
            ent:Remove()
            return
         end

         //Resource cost
         if ply:GetResource(res) < cost then
            ent:Remove()
            ply:SendMessage("You need "..res.." ("..cost.."x) to spawn this prop.",3,Color(200,0,0,255))
         else
            ply:DecResource(res,cost)
            ply:SendMessage("Used "..res.." ("..cost.."x) to spawn this prop.",3,Color(255,255,255,255))
            ply:DoProcess("Assembling",5)
         end
end

function GM:PlayerSpawnedEffect(ply,mdl,ent)
         if GetConVarNumber("gms_FreeBuild") == 1 then return end
         ent:Remove()
end

function GM:PlayerSpawnedNPC(ply,ent)
         if GetConVarNumber("gms_FreeBuild") == 1 then return end
         ent:Remove()
end

function GM:PlayerSpawnedVehicle(ply,ent)
         if GetConVarNumber("gms_FreeBuild") == 1 then return end
         ent:Remove()
end

function GM:PlayerSpawnedSENT( ply, prop )
         if GetConVarNumber("gms_AllowSENTSpawn") == 1 then return end
         prop:Remove()
end
/*---------------------------------------------------------
  SWEP Spawning
---------------------------------------------------------*/
//Override
function CCSpawnSWEP( player, command, arguments )
        if GetConVarNumber("gms_AllowSWEPSpawn") == 0 then
           player:SendMessage("SWEP spawning is disabled.",3,Color(200,0,0,255))
        return end

 	if ( arguments[1] == nil ) then return end 
   
 	// Make sure this is a SWEP 
 	local swep = weapons.GetStored( arguments[1] ) 
 	if (swep == nil) then return end 
 	 
 	// You're not allowed to spawn this! 
 	if ( !swep.Spawnable && !player:IsAdmin() ) then 
 		return 
 	end 
 	 
 	MsgAll( "Giving "..player:Nick().." a "..swep.Classname.."\n" ) 
 	player:Give( swep.Classname ) 
 	 
 end 
   
 concommand.Add( "gm_giveswep", CCSpawnSWEP )
/*---------------------------------------------------------

  Needs

---------------------------------------------------------*/
function PlayerMeta:UpdateNeeds()
         umsg.Start("gms_setneeds",self)
         umsg.Short(self.Sleepiness)
         umsg.Short(self.Hunger)
         umsg.Short(self.Thirst)
         umsg.End()
end

function GM.SubtractNeeds()
         for k,ply in pairs(player.GetAll()) do
             if ply:Alive() then
                //Sleeping
                if ply.Sleeping then
                   if ply.Sleepiness < 1000 and ply.Sleepiness <= 950 then
                      ply.Sleepiness = ply.Sleepiness + 50
                   elseif ply.Sleepiness < 1000 and ply.Sleepiness > 950 then
                      ply.Sleepiness = 1000
                      GAMEMODE.PlayerWake(ply)
                   end
                   
                   if ply.Thirst - 20 < 0 then
                      ply.Thirst = 0
                   else
                      ply.Thirst = ply.Thirst - 20
                   end

                   if ply.Hunger - 20 < 0 then
                      ply.Hunger = 0
                   else
                      ply.Hunger = ply.Hunger - 20
                   end

                   if ply.NeedShelter then ply:SetHealth(ply:Health() - 10) end
                end

                //Kay you're worn out
                if ply.Sleepiness > 0 then ply.Sleepiness = ply.Sleepiness - 1 end
                if ply.Thirst > 0 then ply.Thirst = ply.Thirst - 3 end
                if ply.Hunger > 0 then ply.Hunger = ply.Hunger - 1 end
             
                ply:UpdateNeeds()

                //Are you dying?
                if ply.Sleepiness <= 0 or ply.Thirst <= 0 or ply.Hunger <= 0 then
                   if ply:Health() > 4 then
                      ply:SetHealth(ply:Health() - 2)
                   else
                      ply:Kill()
                      for k,v in pairs(player.GetAll()) do ply:SendMessage(ply:Nick().." died of famine.", 3, Color(170,0,0,255)) end
                   end
                end
             end
         end
         
         timer.Simple(1,GAMEMODE.SubtractNeeds)
end

timer.Simple(1,GM.SubtractNeeds)

/*---------------------------------------------------------
  Sleep
---------------------------------------------------------*/
function GM.PlayerSleep(ply,cmd,args)
         if ply.Sleeping or !ply:Alive() then return end
         if ply.Sleepiness > 700 then
            ply:SendMessage("You're not tired enough.",3,Color(255,255,255,255))
         return end

         ply.Sleeping = true
         umsg.Start("gms_startsleep",ply)
         umsg.End()

         ply:Freeze(true)
         
         //Check for shelter
         local trace = {}
         trace.start = ply:GetShootPos()
         trace.endpos = trace.start + (ply:GetUp() * 300)
         trace.filter = ply

         local tr = util.TraceLine(trace)
         
         if !tr.HitWorld and !tr.HitNonWorld then
            ply.NeedShelter = true
         end
end

concommand.Add("gms_sleep",GM.PlayerSleep)

function GM.PlayerWake(ply,cmd,args)
         if !ply.Sleeping then return end
         ply.Sleeping = false
         umsg.Start("gms_stopsleep",ply)
         umsg.End()
         
         ply:Freeze(false)
         
         //Check for shelter
         local trace = {}
         trace.start = ply:GetShootPos()
         trace.endpos = trace.start + (ply:GetUp() * 300)
         trace.filter = ply

         local tr = util.TraceLine(trace)

         if ply.NeedShelter then
            ply:SendMessage("You should find some shelter!",5,Color(200,0,0,255))
         else
            ply:SendMessage("Ah, nothing like a good nights sleep!",5,Color(255,255,255,255))
         end
end

concommand.Add("gms_wakeup",GM.PlayerWake)
/*---------------------------------------------------------
  NPC death hook
---------------------------------------------------------*/
GMS.LootableNPCs = {"npc_antlion",
                    "npc_antlionguard"
                    }

function EntityMeta:IsLootableNPC()
         if table.HasValue(GMS.LootableNPCs,self:GetClass()) then
            return true
         end
         
         return false
end

function GM:OnNPCKilled( npc, killer, weapon )
         if npc:IsLootableNPC() then
            local loot = ents.Create("GMS_Loot")
            local tbl = loot:GetTable()
            
            local num = math.random(1,3)
            
            local res = {}
            res["Meat"] = num
            
            tbl.Resources = res
            
            loot:SetPos(npc:GetPos())
            loot:Spawn()
         end
end
/*---------------------------------------------------------
  Make Campfire command
---------------------------------------------------------*/
GM.CampFireProps = {}

function GM.CampFireTimer()
         local GM = GAMEMODE

         for k,ent in pairs(GM.CampFireProps) do
             if !ent or ent == NULL then
                table.remove(GM.CampFireProps,k)
             else
                 if CurTime() - ent.CampFireLifeTime >= 180 then
                    ent:Fadeout()
                    table.remove(GM.CampFireProps,k)
                 else
                     ent:SetHealth(ent.CampFireMaxHP)
                 end
             end
         end
         
         timer.Simple(1,GM.CampFireTimer)
end

timer.Simple(1,GM.CampFireTimer)

function GM.MakeCampfire(ply,cmd,args)
         local tr = ply:TraceFromEyes(150)
         
         if !tr.HitNonWorld or !tr.Entity then
            ply:SendMessage("Aim at the prop(s) to use for campfire.",3,Color(255,255,255,255))
         return end
         
         local ent = tr.Entity
         local cls = tr.Entity:GetClass()
         
         if ent:IsOnFire() or cls != "prop_physics" and cls != "prop_physics_multiplayer" and cls != "prop_dynamic" then
            ply:SendMessage("Aim at the prop(s) to use for campfire.",3,Color(255,255,255,255))
         return end

         local mat = tr.MatType
         
         if ply:GetResource("Wood") < 5 then
            ply:SendMessage("You need at least 5 wood to make a fire.",5,Color(255,255,255,255))
         return end

         if mat != MAT_WOOD then
            ply:SendMessage("Prop has to be wood, or if partially wood, aim at the wooden part.",5,Color(255,255,255,255))
         return end
         
         local data = {}
         data.Entity = ent

         ply:DoProcess("Campfire",5,data)
end



concommand.Add("gms_makefire",GM.MakeCampfire)

function EntityMeta:MakeCampfire()
         self:Ignite(180,0)

         self.CampFireMaxHP = self:Health()
         self.CampFireLifeTime = CurTime()

         table.insert(GAMEMODE.CampFireProps,self)

         local mdl = self:GetModel()

         for k,v in pairs(ents.FindInSphere(self:GetPos(),100)) do
             local cls = v:GetClass()
             if v != ent and v:IsProp() then
                if v:GetModel() == mdl then
                   v:Ignite(180,0)
                   
                   v.CampFireMaxHP = v:Health()
                   v.CampFireLifeTime = CurTime()
         
                   table.insert(GAMEMODE.CampFireProps,v)
                end
             end
         end
end
/*---------------------------------------------------------
  Use Hook
---------------------------------------------------------*/
function GM.UseKeyHook(ply,key)
         local GM = GAMEMODE
         if key != IN_USE then return end

         local tr = ply:TraceFromEyes(150)

         if tr.HitNonWorld then
            if tr.Entity and !GMS.IsInWater(tr.HitPos) then
               local ent = tr.Entity
               local mdl = tr.Entity:GetModel()
               local cls = tr.Entity:GetClass()

               if ent:IsFoodModel() or cls == "GMS_Food" then
                  if cls == "GMS_Food" then
                      ply:SendMessage("Restored "..tostring((ent.Value / 1000) * 100).."% food.",3,Color(10,200,10,255))
                      ply:SetFood(ply.Hunger + ent.Value)
                      ent:Fadeout(2)
                  else
                      local data = {}
                      data.Entity = ent
                      ply:DoProcess("EatFruit",2,data)
                  end
               
               elseif ent:IsTreeModel() then
                  ply:DoProcess("SproutCollect",5)
               
               elseif cls == "GMS_ResourceDrop" then
                  ply:PickupResourceEntity(ent)
               elseif ent:IsOnFire() then
                  ply:OpenCombiMenu("Cooking")
               end
            end
         elseif tr.HitWorld then
            for k,v in pairs(ents.FindInSphere(tr.HitPos,100)) do
                if v:IsGrainModel() then
                   local data = {}
                   data.Entity = v
                   
                   ply:DoProcess("HarvestGrain",3,data)
                   return
                elseif v:IsBerryBushModel() then
                   local data = {}
                   data.Entity = v
                   
                   ply:DoProcess("HarvestBush",3,data)
                   return
                end
            end
            
            if (tr.MatType == MAT_DIRT or tr.MatType == MAT_GRASS or tr.MatType == MAT_SAND) and !GMS.IsInWater(tr.HitPos) then
               local time = 5
               if ply:GetActiveWeapon():GetClass() == "gms_shovel" then time = 2 end

               ply:DoProcess("Foraging",time)
            end
         elseif !tr.Hit or GMS.IsInWater(tr.HitPos) then
            local trace = {}
            trace.start = ply:GetShootPos()
            trace.endpos = trace.start + (ply:GetAimVector() * 200)
            trace.mask = MASK_WATER

            local tr2 = util.TraceLine(trace)
            
            if tr2.Hit then
               if ply:WaterLevel() > 0 then
                  if ply.Thirst < 1000 and ply.Thirst > 950 then
                     ply.Thirst = 1000
                     ply:UpdateNeeds()
                     ply:EmitSound(Sound("ambient/water/water_spray"..math.random(1,3)..".wav"))
                  elseif ply.Thirst < 950 then
                     ply.Thirst = ply.Thirst + 50
                     ply:EmitSound(Sound("ambient/water/water_spray"..math.random(1,3)..".wav"))
                     ply:UpdateNeeds()
                  end
               else
                  ply:DoProcess("BottleWater",3)
               end
            end
         end
end

function PlayerMeta:PickupResourceEntity(ent)
          
          local int = ent.Amount
          local room = self.MaxResources - self:GetAllResources()

          if room <= 0 then
             self:SendMessage("You can't carry anymore!",3,Color(200,0,0,255))
          return end

          if room < int then
             int = room
          end

          ent.Amount = ent.Amount - int

          if ent.Amount <= 0 then
             ent:Fadeout()
          else
             ent:SetResourceDropInfo(ent.Type,ent.Amount)
          end

          self:IncResource(ent.Type,int)
          self:SendMessage("Picked up "..ent.Type.." ("..int.."x)",4,Color(10,200,10,255))
end

hook.Add("KeyPress","GMS_UseKeyHook",GM.UseKeyHook)

/*---------------------------------------------------------
  Sprint Hook
---------------------------------------------------------*/
function GM.SprintKeyHook(ply,key)
         local GM = GAMEMODE
         if key != IN_SPEED then return end

         if ply:HasUnlock("Sprint_Mki") and !ply:HasUnlock("Sprint_Mkii") then
            GM:SetPlayerSpeed(ply, 250,400)
         end
end

hook.Add("KeyPress","GMS_SprintKeyHook",GM.SprintKeyHook)

function GM.SprintKeyReleaseHook(ply,key)
         local GM = GAMEMODE
         if key != IN_SPEED then return end

         if ply:HasUnlock("Sprint_Mki") and !ply:HasUnlock("Sprint_Mkii") then
            GM:SetPlayerSpeed(ply, 250,250)
         end
end

hook.Add("KeyReleased","GMS_SprintKeyReleaseHook",GM.SprintKeyReleaseHook)
/*---------------------------------------------------------
  Saving/loading functions
---------------------------------------------------------*/
//Loading bar
function PlayerMeta:MakeLoadingBar(msg)
         umsg.Start("gms_MakeLoadingBar",self)
         umsg.String(msg)
         umsg.End()
end

function PlayerMeta:StopLoadingBar()
         umsg.Start("gms_StopLoadingBar",self)
         umsg.End()
end


//Find pre-existing entities
function GM:FindMapSpecificEntities()
         self.MapSpecificEntities = ents.GetAll()
end

timer.Simple(3,GM.FindMapSpecificEntities,GM)

//Commands
function GM.SaveMapCommand(ply,cmd,args)
         if !ply:IsAdmin() then
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end

         if !args[1] or string.Trim(args[1]) == "" then return end
         GAMEMODE:PreSaveMap(string.Trim(args[1]))
end

concommand.Add("gms_admin_savemap",GM.SaveMapCommand)

function GM.LoadMapCommand(ply,cmd,args)
         if !ply:IsAdmin() then
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end

         if !args[1] or string.Trim(args[1]) == "" then return end
         GAMEMODE:PreLoadMap(string.Trim(args[1]))
end

concommand.Add("gms_admin_loadmap",GM.LoadMapCommand)

function GM.DeleteMapCommand(ply,cmd,args)
         if !ply:IsAdmin() then
            ply:SendMessage("You need admin rights for this!",3,Color(200,0,0,255))
         return end

         if !args[1] or string.Trim(args[1]) == "" then return end
         GAMEMODE:DeleteSavegame(string.Trim(args[1]))
end

concommand.Add("gms_admin_deletemap",GM.DeleteMapCommand)

//Delete map

function GM:DeleteSavegame(name)
         if !file.Exists("GMStranded/Gamesaves/"..name..".txt") then return end
         
         file.Delete("GMStranded/Gamesaves/"..name..".txt")
         if file.Exists("GMStranded/Gamesaves/"..name.."_info.txt") then file.Delete("GMStranded/Gamesaves/"..name.."_info.txt") end

         for k,ply in pairs(player.GetAll()) do
             if ply:IsAdmin() then
                umsg.Start("gms_RemoveLoadGameFromList",ply)
                umsg.String(name)
                umsg.End()
             end
         end
end

//Save map
function GM:PreSaveMap(name)
         if CurTime() < 3 then return end
         if CurTime() < self.NextSaved then return end

         for k,ply in pairs(player.GetAll()) do
             ply:MakeLoadingBar("Saving game as \""..name.."\"")
         end

         self.NextSaved = CurTime() + 0.6
         timer.Simple(0.5,self.SaveMap,self,name)
end

function GM:SaveMap(name)

	local savegame = {}
	savegame["name"] = name
	savegame["entries"] = {}

	savegame_info = {}
	savegame_info["map"] = game.GetMap()
	savegame_info["date"] = os.date("%A %m/%d/%y")

	local num = 0

	for k,ent in pairs(ents.GetAll()) do
		--Msg(ent)
		if ent and ent != NULL and ent:IsValid() and !table.HasValue(self.MapSpecificEntities, ent) then
			--Msg(ent)
			--Msg("\n" .. ent:GetClass() .. "\n")
			if table.HasValue(GMS.SavedClasses,ent:GetClass()) then
				--Msg(ent)
				
				local entry = {}
				
				entry["class"] = ent:GetClass()
				entry["model"] = ent:GetModel()

				local pos = ent:GetPos()
				local ang = ent:GetAngles()
				local colr,colg,colb,cola = ent:GetColor()

				entry["color"] = colr.." "..colg.." "..colb.." "..cola
				entry["pos"] =   pos.x.." "..pos.y.." "..pos.z
				entry["angles"] = ang.p.." "..ang.y.." "..ang.r
				entry["material"] = ent:GetMaterial() or "0"
				entry["keyvalues"] = ent:GetKeyValues()
				if ent:GetClass() == 'gms_spawnpoint' then
					entry["spawnname"] = ent:GetSpawnName()
				end
				entry["table"] = ent:GetTable()

				local phys = ent:GetPhysicsObject()
				
				if phys and phys != NULL and phys:IsValid() then
					entry["freezed"] = phys:IsMoveable()
					entry["sleeping"] = phys:IsAsleep()
				end

				num = num + 1
				savegame["entries"][#savegame["entries"] + 1] = entry
			end
		end
	end

	file.Write("GMStranded/Gamesaves/"..name..".txt",util.TableToKeyValues(savegame))
	file.Write("GMStranded/Gamesaves/"..name.."_info.txt",util.TableToKeyValues(savegame_info))

	for k,ply in pairs(player.GetAll()) do
		ply:SendMessage("Saved game \""..name.."\".",3,Color(255,255,255,255))
		ply:StopLoadingBar()
		
		if ply:IsAdmin() then
			umsg.Start("gms_AddLoadGameToList",ply)
			umsg.String(name)
			umsg.End()
		end
	end
end

function GM.AutoLoadMapCommand(ply,cmd,args)
	if !firstPlayerMapLoad then
		local map = game.GetMap()
		GAMEMODE:PreLoadMap(map)
		firstPlayerMapLoad = true
		-- Kill them so that they can spawn on their class' spawnpoint after it is loaded.
		ply:Kill()
	end
end
concommand.Add("gms_autoload",GM.AutoLoadMapCommand)

//Load map
function GM:PreLoadMap(name)
	-- Msg('This is PreLoadMap at ' .. CurTime() .. '.\n')
	-- if CurTime() < 3 then return end
	if CurTime() < self.NextLoaded then return end
	if !file.Exists("GMStranded/Gamesaves/"..name..".txt") then return end

	for k,ply in pairs(player.GetAll()) do
		ply:MakeLoadingBar("Savegame \""..name.."\"")
	end

	self.NextLoaded = CurTime() + 0.6
	timer.Simple(0.5,self.LoadMap,self,name)
end

function GM:LoadMap(name)
	-- Msg('GMS Loading: ' .. name .. "\n")
	local savegame = util.KeyValuesToTable(file.Read("GMStranded/Gamesaves/"..name..".txt"))
	local num = table.Count(savegame["entries"])

	if num == 0 then
		Msg("This savegame is empty!\n")
	return end

	self:LoadMapEntity(savegame,num,1)
end

//Don't load it all at once
function GM:LoadMapEntity(savegame,max,k)
	local entry = savegame["entries"][tostring(k)]

	local ent = ents.Create(entry["class"])
	ent:SetModel(entry["model"])

	local pos = string.Explode(" ",entry["pos"])
	local ang = string.Explode(" ",entry["angles"])
	local col = string.Explode(" ",entry["color"])

	ent:SetColor(tonumber(col[1]),tonumber(col[2]),tonumber(col[3]),tonumber(col[4]))
	ent:SetPos(Vector(tonumber(pos[1]),tonumber(pos[2]),tonumber(pos[3])))
	ent:SetAngles(Angle(tonumber(ang[1]),tonumber(ang[2]),tonumber(ang[3])))

	if entry["material"] != "0" then ent:SetMaterial(entry["material"]) end

	for k,v in pairs(entry["keyvalues"]) do
		ent:SetKeyValue(k,v)
	end

	for k,v in pairs(entry["table"]) do
		ent[k] = v
	end

	ent:Spawn()
	
	local phys = ent:GetPhysicsObject()
	if phys and phys != NULL and phys:IsValid() then
		phys:EnableMotion(entry["freezed"])
		if entry["sleeping"] then phys:Sleep() else phys:Wake() end
	end
	
	if ent:GetClass() == 'gms_spawnpoint' then
		ent:SetSpawnName(entry["spawnname"])
	end
	
	if k >= max then
		for k,ply in pairs(player.GetAll()) do
			ply:SendMessage("Loaded game \""..savegame["name"].."\" ("..max.." entries)",3,Color(255,255,255,255))
			ply:StopLoadingBar()
		end
	else
		timer.Simple(0.05,self.LoadMapEntity,self,savegame,max,k + 1)
	end
end
