include("shared.lua")

if not GMS then local GMS = {} end
local texLogo = surface.GetTextureID( "gui/gmod_logo" )
ENT.ResourceIcons = {}
ENT.ResourceIcons["Loading"] = surface.GetTextureID( "gui/gmod_logo" )
ENT.ResourceIcons["Wood"] = surface.GetTextureID( "gui/GMS/gms_wood" )
ENT.ResourceIcons["Melon_Seeds"] = surface.GetTextureID( "gui/GMS/gms_seed" )
ENT.ResourceIcons["Grain_Seeds"] = surface.GetTextureID( "gui/GMS/gms_seed" )
ENT.ResourceIcons["Stone"] = surface.GetTextureID( "gui/GMS/gms_rock" )
ENT.ResourceIcons["Iron"] = surface.GetTextureID( "gui/GMS/gms_iron" )
ENT.ResourceIcons["Fish"] = surface.GetTextureID( "gui/GMS/gms_fish" )
ENT.ResourceIcons["Herbs"] = surface.GetTextureID( "gui/GMS/gms_herb" )
ENT.ResourceIcons["Water_Bottles"] = surface.GetTextureID( "gui/GMS/gms_waterbottle" )

--Called when it's time to draw the entity.
--Return: Nothing
function ENT:Draw()
         self.Entity:DrawModel()
         local res = self.Entity.Res or "Loading"
         local int = self.Entity.Amount or 0
         local tex = self.ResourceIcons[string.gsub(res," ","_")] or texLogo

         cam.Start3D2D( self.Entity:GetPos() + Vector(0,0,40), self.AddAngle, 0.03 )
            surface.SetDrawColor(255,255,255,255)
            surface.SetTexture(tex)
            surface.DrawTexturedRect(-500,-500,1000,1000)
         cam.End3D2D()

         cam.Start3D2D( self.Entity:GetPos() + Vector(0,0,40),self.AddAngle + Angle(0,180,0), 0.03 )
            surface.SetDrawColor(255,255,255,255)
            surface.SetTexture(tex)
            surface.DrawTexturedRect(-500,-500,1000,1000)
         cam.End3D2D()

         cam.Start3D2D( self.Entity:GetPos() + Vector(0,0,60),self.AddAngle, 0.4 )
            draw.SimpleText(res..": "..int,"ScoreboardText",0,0,Color(255,255,255,255),1,1)
         cam.End3D2D()

         cam.Start3D2D( self.Entity:GetPos() + Vector(0,0,60), self.AddAngle + Angle(0,180,0), 0.4 )
            draw.SimpleText(res..": "..int,"ScoreboardText",0,0,Color(255,255,255,255),1,1)
         cam.End3D2D()
end

function GMS.SetEntityDropInfo(um)
         local index = um:ReadString()
         local type = um:ReadString()
         local int = um:ReadShort()
         
         local ent = ents.GetByIndex(index)
         
         if ent == NULL or !ent then

            local tbl = {}
            tbl.Type = type
            tbl.Amount = int
            tbl.Index = index

            table.insert(GMS.PendingRDrops,tbl)
          else
            ent.Res = type
            ent.Amount = int
          end
end

usermessage.Hook("gms_SetResourceDropInfo",GMS.SetEntityDropInfo)

GMS.PendingRDrops = {}

function GMS.CheckForRDrop()
         for k,tbl in pairs(GMS.PendingRDrops) do
             local ent = ents.GetByIndex(tbl.Index)

             if ent != NULL then
                ent.Res = tbl.Type
                ent.Amount = tbl.Amount

                table.remove(GMS.PendingRDrops,k)
             end
         end
end

hook.Add("Think","gms_CheckForPendingRDrops",GMS.CheckForRDrop)

--Called when the SENT is spawned
--Return: Nothing
function ENT:Initialize()
         self.AddAngle = Angle(0,0,90)
end

--Return true if this entity is translucent.
--Return: Boolean
function ENT:IsTranslucent()
end

--Called when a save-game is loaded.
--Return: Nothing
function ENT:OnRestore()
end

--Called when the SENT thinks.
--Return: Nothing
function ENT:Think()
         self.AddAngle = self.AddAngle + Angle(0,1.5,0)
end