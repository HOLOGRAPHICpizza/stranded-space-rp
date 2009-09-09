/*---------------------------------------------------------

  Gmod Stranded



---------------------------------------------------------*/

--Msg("Loading cl_init.lua\n")

-- DeriveGamemode( "sandbox" )
include( 'shared.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_init_sb.lua' )

//Custom panels
include( 'cl_panels.lua' )
//Unlocks
include( 'unlocks.lua' )
//Combis
include( 'combinations.lua' )

//Clientside player variables

//Convars...stupid color panel :D

DefaultColorTheme = Color(100,100,50,240)
DefaultBorderTheme = Color(70,70,20,180)
DefaultButtonTheme = Color(30,144,255,255)
DefaultHoveredTheme = Color(200,200,30,255)
		
StrandedColorTheme = Color(100,100,50,240)
StrandedBorderTheme = Color(70,70,20,180)

Skills = {}
Resources = {}
Experience = {}
FeatureUnlocks = {}
MaxResources = 25

local PlayerMeta = FindMetaTable("Player")
/*---------------------------------------------------------
  General / utility
---------------------------------------------------------*/
//Hide other sandbox stuff
function GM:HUDShouldDraw(name)
         if name != "CHudHealth" and name != "CHudBattery" then
            return true
         end
end

//Create the HUD
function GM.CreateHUD()
         Hunger = 1000
         Sleepiness = 1000
         Thirst = 1000
         GAMEMODE.NeedHud = vgui.Create("gms_NeedHud")
         GAMEMODE.SkillsHud = vgui.Create("gms_SkillsHud")
         GAMEMODE.ResourcesHud = vgui.Create("gms_ResourcesHud")
         GAMEMODE.CommandsHud = vgui.Create("gms_CommandHud")
         GAMEMODE.ProcessBar = vgui.Create("gms_ProcessBar")
         GAMEMODE.ProcessBar:SetVisible(false)
         GAMEMODE.LoadingBar = vgui.Create("gms_LoadingBar")
         GAMEMODE.LoadingBar:SetVisible(false)
end

usermessage.Hook("gms_CreateInitialHUD",GM.CreateHUD)

//Make a progress bar
function GM.MakeProgressBar(um)
         GAMEMODE.ProcessBar:DoProcessBar(um:ReadString(),um:ReadShort())
end

usermessage.Hook("gms_MakeProcessBar",GM.MakeProgressBar)

//Stop progress bar
function GM.StopProgressBar(um)
         GAMEMODE.ProcessBar:Stop()
end

usermessage.Hook("gms_StopProcessBar",GM.StopProgressBar)

//Start a loading bar
function GM.MakeLoadingBar(um)
         GAMEMODE.LoadingBar:Show(um:ReadString())
end

usermessage.Hook("gms_MakeLoadingBar",GM.MakeLoadingBar)

//Stop loading bar
function GM.StopLoadingBar(um)
         GAMEMODE.LoadingBar:Hide()
end

usermessage.Hook("gms_StopLoadingBar",GM.StopLoadingBar)

//Get skill
function GetSkill(skill)
         return Skills[skill] or 0
end

//Set skill
function GM.SetSkill(um)
         Skills[um:ReadString()] = um:ReadShort()
         
         MaxResources = 25 + (GetSkill("Survival") * 5)

         GAMEMODE.SkillsHud:RefreshSkills()
end

usermessage.Hook("gms_SetSkill",GM.SetSkill)

//Get XP
function GetXP(skill)
         return Experience[skill] or 0
end

//Set XP
function GM.SetXP(um)
         Experience[um:ReadString()] = um:ReadShort()
end

usermessage.Hook("gms_SetXP",GM.SetXP)

//Get resource
function GetResource(resource)
         return Resources[resource] or 0
end

//Set Resource
function GM.SetResource(um)
         local res = um:ReadString()
         local amount = um:ReadShort()

         Resources[res] = amount
         GAMEMODE.ResourcesHud:RefreshResources()
end

usermessage.Hook("gms_SetResource",GM.SetResource)

//Set max resources
function GM.SetMaxResources(um)
         MaxResources = um:ReadShort()
         GAMEMODE.ResourcesHud:RefreshResources()
end

usermessage.Hook("gms_SetMaxResources",GM.SetMaxResources)

//Toggle skills menu
function GM.ToggleSkillsMenu(um)
         GAMEMODE.SkillsHud:ToggleExtend()
end

usermessage.Hook("gms_ToggleSkillsMenu",GM.ToggleSkillsMenu)

//Toggle Resources menu
function GM.ToggleResourcesMenu(um)
         GAMEMODE.ResourcesHud:ToggleExtend()
end

usermessage.Hook("gms_ToggleResourcesMenu",GM.ToggleResourcesMenu)

//Toggle commands menu
function GM.ToggleCommandsMenu(um)
         GAMEMODE.CommandsHud:ToggleExtend()
end

usermessage.Hook("gms_ToggleCommandsMenu",GM.ToggleCommandsMenu)

//Open combi menu
function GM.OpenCombiMenu(um)
         local GM = GAMEMODE
         if !GM.CombiMenu then GM.CombiMenu = vgui.Create("GMS_CombinationWindow") end
         GM.CombiMenu:SetTable(um:ReadString())
         GM.CombiMenu:SetVisible(true)
end

usermessage.Hook("gms_OpenCombiMenu",GM.OpenCombiMenu)

//Close combi menu
function GM.CloseCombiMenu(um)
         local GM = GAMEMODE
         if !GM.CombiMenu then GM.CombiMenu = vgui.Create("GMS_CombinationWindow") end
         GM.CombiMenu:SetVisible(false)
end

usermessage.Hook("gms_CloseCombiMenu",GM.CloseCombiMenu)

//Other stuff
function string.Capitalize(str)
         local str = string.Explode("_",str)
         for k,v in pairs(str) do
             str[k] = string.upper(string.sub(v,1,1))..string.sub(v,2)
         end

         str = string.Implode("_",str)
         return str
end

function TraceFromEyes(dist)
         local trace = {}
         trace.start = self:GetShootPos()
         trace.endpos = trace.start + (self:GetAimVector() * dist)
         trace.filter = self
         
         return util.TraceLine(trace)
end
/*---------------------------------------------------------
  Stranded-Like info messages
---------------------------------------------------------*/
GM.InfoMessages = {}
GM.InfoMessageLine = 0

function GM.SendMessage(um)
         local text = um:ReadString()
         local dur = um:ReadShort()
         local col = um:ReadString()
         local str = string.Explode(",",col)
         local col = Color(tonumber(str[1]),tonumber(str[2]),tonumber(str[3]),tonumber(str[4]))

         for k,v in pairs(GAMEMODE.InfoMessages) do
             v.drawline = v.drawline + 1
         end

         local message = {}
         message.Text = text
         message.Col = col
         message.Tab = 5
         message.drawline = 1

         GAMEMODE.InfoMessages[#GAMEMODE.InfoMessages + 1] = message
         GAMEMODE.InfoMessageLine = GAMEMODE.InfoMessageLine + 1
         

         
         timer.Simple(dur,GAMEMODE.DropMessage,message)
end

usermessage.Hook("gms_sendmessage",GM.SendMessage)


function GM.DrawMessages()
         for k,msg in pairs(GAMEMODE.InfoMessages) do
             local txt = msg.Text
             local line = ScrH() / 2 + (msg.drawline * 20)
             local tab = msg.Tab
             local col = msg.Col
             draw.SimpleTextOutlined(txt,"ScoreboardText",tab,line,col,0,0,0.5,Color(100,100,100,150))
             
             if msg.Fading then
                msg.Tab = msg.Tab - (msg.InitTab - msg.Tab - 0.05)
                
                if msg.Tab > ScrW() + 10 then
                   GAMEMODE.RemoveMessage(msg)
                end
             end
         end
end

hook.Add("HUDPaint","gms_drawmessages",GM.DrawMessages)

function GM.DropMessage(msg)
         msg.InitTab = msg.Tab
         msg.Fading = true
end

function GM.RemoveMessage(msg)
         for k,v in pairs(GAMEMODE.InfoMessages) do
             if v == msg then
                GAMEMODE.InfoMessages[k] = nil
                GAMEMODE.InfoMessageLine = GAMEMODE.InfoMessageLine - 1
                table.remove(GAMEMODE.InfoMessages,k)
             end
         end
end
/*---------------------------------------------------------
  Prop fading
---------------------------------------------------------*/
GM.FadingProps = {}
function GM.AddFadingProp(um)
         local mdl = um:ReadString()
         local pos = um:ReadVector()
         local dir = um:ReadVector()
         local speed = um:ReadShort()
         
         if !mdl or !pos or !dir or !speed then return end
         
         local ent = ents.Create("prop_physics")
         ent:SetModel(mdl)
         ent:SetPos(pos)
         ent:SetAngles(dir:Angle())
         ent:Spawn()

         ent.Alpha = 255
         ent.Speed = speed

         table.insert(GAMEMODE.FadingProps,ent)
end

usermessage.Hook("gms_CreateFadingProp",GM.AddFadingProp)

function GM.FadeFadingProps()
         local GM = GAMEMODE
         
         for k,v in pairs(GM.FadingProps) do
             if v.Alpha <= 0 then
                v.Entity:Remove()
                table.remove(GM.FadingProps,k)
             else
                v.Alpha = v.Alpha - (1 * v.Speed)
                v.Entity:SetColor(255,255,255,v.Alpha)
             end
         end
end

hook.Add("Think","gms_FadeFadingPropsHook",GM.FadeFadingProps)

/*---------------------------------------------------------
  Achievement Messages
---------------------------------------------------------*/
GM.AchievementMessages = {}

function GM.SendAchievement(um)
         local text = um:ReadString()
         
         local tbl = {}
         tbl.Text = text
         tbl.Alpha = 255

         table.insert(GAMEMODE.AchievementMessages,tbl)
end

usermessage.Hook("gms_sendachievement",GM.SendAchievement)


function GM.DrawAchievementMessages()
         for k,msg in pairs(GAMEMODE.AchievementMessages) do
             msg.Alpha = msg.Alpha - 1
             draw.SimpleTextOutlined(msg.Text,"ScoreboardHead",ScrW() / 2,ScrH() / 2,Color(255,255,255,msg.Alpha),1,1,0.5,Color(100,100,100,msg.Alpha))
             
             if msg.Alpha <= 0 then
                table.remove(GAMEMODE.AchievementMessages,k)
             end
         end
end

hook.Add("HUDPaint","gms_drawachievementmessages",GM.DrawAchievementMessages)
/*---------------------------------------------------------
  Needs
---------------------------------------------------------*/
function GM.SetNeeds(um)
         Sleepiness = um:ReadShort()
         Hunger = um:ReadShort()
         Thirst = um:ReadShort()
end
usermessage.Hook("gms_setneeds",GM.SetNeeds)
/*---------------------------------------------------------
  Help Menu
---------------------------------------------------------*/
function GM.OpenHelpMenu()
         local GM = GAMEMODE

         if GM.HelpMenu then 
         GM.HelpMenu:SetVisible(!GM.HelpMenu:IsVisible()) 
         GM.HelpMenu.HTML:SetHTML(file.Read("../gamemodes/GMStranded/help.html"))
         return end
         
         GM.HelpMenu = vgui.Create("GMS_Frame")

         GM.HelpMenu:SetPos(50,50)
         GM.HelpMenu:SetSize(ScrW() - 100, ScrH() - 100)

         GM.HelpMenu:SetTitle("Welcome to Stranded Space RP")

         GM.HelpMenu.HTML = vgui.Create("HTML",GM.HelpMenu)
         GM.HelpMenu.HTML:SetSize(GM.HelpMenu:GetWide() - 50, GM.HelpMenu:GetTall() - 50)
         GM.HelpMenu.HTML:SetPos(25,25)
         GM.HelpMenu.HTML:SetHTML(file.Read("../gamemodes/StrandedSpaceRP/help.html"))

         GM.HelpMenu:SetKeyboardInputEnabled(true)
         GM.HelpMenu:SetMouseInputEnabled(true)

         GM.HelpMenu:SetVisible(true)
end

concommand.Add("gms_help",GM.OpenHelpMenu)

/*---------------------------------------------------------
  Sleep
---------------------------------------------------------*/
function GM.SleepOverlay()
         if !SleepFadeIn and !SleepFadeOut then return end

         if SleepFadeIn and SleepFade < 250 then
            SleepFade = SleepFade + 5
         elseif SleepFadeIn and SleepFade >= 255 then
            SleepFadeIn = false
         end
         
         if SleepFadeOut and SleepFade > 0 then
            SleepFade = SleepFade - 5
         elseif SleepFadeOut and SleepFade <= 0 then
            SleepFadeOut = false
         end
         
         surface.SetDrawColor(0,0,0,SleepFade)
         surface.DrawRect(0,0,ScrW(),ScrH())
         
         draw.SimpleText("Use the command \"gms_wakeup\" to wake up.","ScoreboardSub",ScrW() / 2, ScrH() / 2, Color(255,255,255,SleepFade),1,1)
end

hook.Add("HUDPaint","gms_sleepoverlay",GM.SleepOverlay)

function GM.StartSleep(um)
         SleepFadeIn = true
         SleepFade = 0
end

usermessage.Hook("gms_startsleep",GM.StartSleep)

function GM.StopSleep(um)
         SleepFadeOut = true
         SleepFade = 255
end

usermessage.Hook("gms_stopsleep",GM.StopSleep)

/*---------------------------------------------------------
  Unlock system
---------------------------------------------------------*/
function GM.AddUnlock(um)
         local text = um:ReadString()
         local GM = GAMEMODE

         if !GM.UnlockWindow then GM.UnlockWindow = vgui.Create("GMS_UnlockWindow") end
         
         GM.UnlockWindow:SetUnlock(text)
         GM.UnlockWindow:SetVisible(true)
end

usermessage.Hook("gms_AddUnlock",GM.AddUnlock)

/*---------------------------------------------------------
  Drop resource menu
---------------------------------------------------------*/
function GM.OpenDropResourceWindow()
         local GM = GAMEMODE

         if !GM.ResourceWindow then GM.ResourceWindow = vgui.Create("GMS_ResourceDropWindow") end

         GM.ResourceWindow:RefreshList()
         GM.ResourceWindow:SetVisible(!GM.ResourceWindow:IsVisible())
end

concommand.Add("gms_OpenDropResourceWindow",GM.OpenDropResourceWindow)

-- Gman Menu
function GM.OpenGmanWindow()
	local GM = GAMEMODE
	
	local tr = LocalPlayer():TraceFromEyes(150)
	if not tr.Entity:IsValid() and not tr.Entity:GetClass() == 'gms_gman' then
		LocalPlayer():SendMessage("Aim at the Gman.", 3, Color(200,0,0,255))
		return
	end
	
	-- Msg(GM.GmanWindow)
	if !GM.GmanWindow then GM.GmanWindow = vgui.Create("GMS_GmanWindow") end
	-- Msg(GM.GmanWindow)
	
	GM.GmanWindow:SetVisible(!GM.GmanWindow:IsVisible())
end
concommand.Add("gms_OpenGmanWindow",GM.OpenGmanWindow)

/*---------------------------------------------------------
  Planting menu
---------------------------------------------------------*/
function GM.OpenPlantingMenu()
         local GM = GAMEMODE

         if !GM.PlantingMenu then GM.PlantingMenu = vgui.Create("GMS_PlantingMenu") end

         GM.PlantingMenu:SetVisible(!GM.PlantingMenu:IsVisible())
end

concommand.Add("gms_OpenPlantingMenu",GM.OpenPlantingMenu)

/*---------------------------------------------------------
  Admin menu
---------------------------------------------------------*/
function GM.OpenAdminMenu()
         if !LocalPlayer():IsAdmin() then return end
         local GM = GAMEMODE

         if !GM.AdminMenu then GM.AdminMenu = vgui.Create("GMS_AdminMenu") end

         GM.AdminMenu:SetVisible(!GM.AdminMenu:IsVisible())
end

concommand.Add("gms_admin",GM.OpenAdminMenu)

function GM.AddLoadGame(um)
         local GM = GAMEMODE
         if !GM.AdminMenu then GM.AdminMenu = vgui.Create("GMS_AdminMenu") end
         
         local str = um:ReadString()
         GM.AdminMenu.LoadGameEntry:AddItem(str,str)
end

usermessage.Hook("gms_AddLoadGameToList",GM.AddLoadGame)

function GM.RemoveLoadGame(um)
         local GM = GAMEMODE
         if !GM.AdminMenu then GM.AdminMenu = vgui.Create("GMS_AdminMenu") end
         
         local str = um:ReadString()
         GM.AdminMenu.LoadGameEntry:RemoveItem(str)
end

usermessage.Hook("gms_RemoveLoadGameFromList",GM.RemoveLoadGame)

/*---------------------------------------------------------
  Options menu
---------------------------------------------------------*/
function GM.OpenOptionsMenu()
         local GM = GAMEMODE

         if !GM.OptionsMenu then GM.OptionsMenu = vgui.Create("GMS_OptionsMenu") end

         GM.OptionsMenu:SetVisible(!GM.OptionsMenu:IsVisible())
end

concommand.Add("gms_options",GM.OpenOptionsMenu)
/*---------------------------------------------------------
  Server Chat Menu
---------------------------------------------------------*/
function GM.OpenChatMenu()
         local GM = GAMEMODE

         if !GM.ChatMenu then GM.ChatMenu = vgui.Create("GMS_ChatMenu") end

         GM.ChatMenu:SetVisible(!GM.ChatMenu:IsVisible())
end

concommand.Add("gms_ServerChat",GM.OpenChatMenu)

function GM.IncomingServerChatMessage(um)
         local GM = GAMEMODE
         local nick = um:ReadString()
         local msg = um:ReadString()
         
         if !GM.ChatMenu then GM.ChatMenu = vgui.Create("GMS_ChatMenu") end

         GM.ChatMenu:AddChat(nick,msg)
end

usermessage.Hook("gms_AddServerChatMessage",GM.IncomingServerChatMessage)

-- Money HUD
function DrawMoney()
	draw.SimpleTextOutlined('Money: $' .. LocalPlayer():GetNWInt('money'), "ScoreboardText", ScrW() - 10, ScrH() - 20, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
end
hook.Add("HUDPaint", "DrawMoney", DrawMoney)

-- Trace HUD
function TraceHUD()
	local tr = LocalPlayer():TraceFromEyes(150)
	if tr.Entity:IsValid() then
		if tr.Entity:IsDoor() then -- Door HUD
			local msg = ''
			if tr.Entity:GetNWBool('notOwnable') then
				msg = 'Unownable'
			else
				local owner = player.GetByID( tr.Entity:GetNWInt('Owner1') )
				if owner:IsPlayer() then
					msg = owner:Name()
				else
					msg = 'Press F4 to rent.'
				end
			end
			draw.SimpleTextOutlined(msg, "ScoreboardText", ScrW() / 2, ScrH() / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
			
			local title = tr.Entity:GetNWString('title') or ''
			draw.SimpleTextOutlined(title, "ScoreboardText", ScrW() / 2, (ScrH() / 2) - 20, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
		elseif tr.Entity:GetClass() == 'gms_seed' then -- Seed HUD
			local player = tr.Entity:GetNWString('player') or ''
			draw.SimpleTextOutlined(player, "ScoreboardText", ScrW() / 2, ScrH() / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
			
			local ResType = tr.Entity:GetNWString('restype') or ''
			draw.SimpleTextOutlined(string.Capitalize(ResType), "ScoreboardText", ScrW() / 2, (ScrH() / 2) + 20, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
			
			local runs = tr.Entity:GetNWInt('runs') or 0
			draw.SimpleTextOutlined(tostring(runs * 10) .. '%', "ScoreboardText", ScrW() / 2, (ScrH() / 2) + 40, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
		end
		
		--draw.SimpleTextOutlined(tr.Entity:GetClass(), "ScoreboardText", ScrW() - 10, ScrH() - 40, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,255))
	end
end
hook.Add("HUDPaint", "TraceHUD", TraceHUD)
