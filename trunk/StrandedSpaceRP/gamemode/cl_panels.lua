/*---------------------------------------------------------
  Gamemode Frame simple
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetName("GMS_TempFrameName")
         self:LoadControlsFromString([["GMS_TempFrameName"{"GMS_TempFrameName"{"sizable" "0"}}]])
         
         self.Title = ""
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(col.r,col.g,col.b,col.a)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())
         
         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,bordcol.a)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         draw.SimpleText(self.Title,"ScoreboardText",25,5,Color(255,255,255,255))
         return true
end

function PANEL:SetTitle(txt)
         self.Title = txt
end

vgui.Register("GMS_Frame",PANEL,"Frame")

/*---------------------------------------------------------
  Unlock window
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetTitle("You unlocked a new ability!")
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)
         self.Name = "Name"
         
         self:SetSize(ScrW() / 2, ScrH() / 2)
         self:SetPos(ScrW() / 2 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))

         self.DescWindow = vgui.Create("RichText",self)
         self.DescWindow:SetPos(20,self:GetTall() / 6 + 70)
         self.DescWindow:SetSize(self:GetWide() - 40, self:GetTall() - (self:GetTall() / 6 + 70) - 20)
         self.DescWindow:SetText("Description.")
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(col.r,col.g,col.b,col.a)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())
         
         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,bordcol.a)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         draw.SimpleText(self.Title,"ScoreboardText",25,5,Color(255,255,255,255))
         draw.SimpleTextOutlined(self.Name,"ScoreboardHead",self:GetWide() / 2,self:GetTall() / 6,Color(10,200,10,255),1,1,0.5,Color(100,100,100,160))
         return true
end

function PANEL:SetUnlock(text)
         local unlock = GMS.FeatureUnlocks[text]
         
         self.Name = unlock.Name
         self.DescWindow:SetText(unlock.Description)
end

vgui.Register("GMS_UnlockWindow",PANEL,"GMS_Frame")
/*---------------------------------------------------------
  GMS dropdown
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self.Children = {}
         self.Extended = false
         self.Active = nil
end

function PANEL:SetInitSize(w,h)
         self.InitW = w
         self.InitH = h
         
         self:SetSize(w,h)
end

function PANEL:AddItem(text,value)
         local item = vgui.Create("GMS_DropDown_Item",self)
         item:SetPos(0,self.InitH)
         item:SetSize(self:GetWide(),self.InitH)
         item:SetInfo(text,value)
         
         if !self.Extended then item:SetVisible(false) end
         table.insert(self.Children,item)
end

function PANEL:RemoveItem(text)
         self.Active = nil

         for k,item in pairs(self.Children) do
             if item.Text == text then
                item:Remove()
                item = nil
                table.remove(self.Children,k)
             end
         end
         
         if self.Extended then
            self:Retract()
         else
            self:Extend()
            self:Retract()
         end
end

function PANEL:Clear()
         for k,v in pairs(self.Children) do
             v:Remove()
         end

         self.Children = {}
         self.Active = nil
         self:Retract()
end

function PANEL:SetActive(item)
         if self.Active then
            self.Active.Active = false
         end
         
         if item then item.Active = true end
         self.Active = item
end

function PANEL:Extend()
         self.Extended = true
         local line = self.InitH

         for k,item in pairs(self.Children) do
             item:SetPos(0,line)
             item:SetVisible(true)
             
             line = line + self.InitH
         end
         
         self:SetSize(self.InitW,self.InitH + (#self.Children * self.InitH))
         self:SetZPos(310)
end

function PANEL:Retract()
         self.Extended = false
         
         for k,item in pairs(self.Children) do
             item:SetPos(0,0)
             item:SetVisible(false)
         end
         
         self:SetZPos(300)
         self:SetSize(self.InitW,self.InitH)
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(50,50,25,255)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())
         
         surface.SetDrawColor(70,70,20,180)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         if self.Active then
            draw.SimpleText(self.Active.Text,"Default",5,5,Color(255,255,255,255))
         else
            draw.SimpleText("< select >","Default",5,5,Color(255,255,255,255))
         end

         return true
end

function PANEL:GetValue()
         if self.Active then
            return self.Active.Value or nil
         end
         
         return false
end

function PANEL:GetText()
         if self.Active then
            return self.Active.Text or ""
         end
         
         return ""
end

function PANEL:OnMousePressed(mc)
         if mc != 107 then return end
         if !self.Extended then self:Extend() end
end

vgui.Register("GMS_DropDown",PANEL,"Panel")

/*---------------------------------------------------------
  GMS dropdown item
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self.Text = ""
         self.Value = nil
         self.Color = Color(50,50,25,255)
end

function PANEL:SetInfo(text,value)
         self.Text = text
         self.Value = value
end

function PANEL:Paint()
         surface.SetDrawColor(self.Color.r,self.Color.g,self.Color.b,255)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         draw.SimpleText(self.Text,"Default",5,5,Color(255,255,255,255))
         return true
end

function PANEL:OnMousePressed(mc)
         if mc != 107 then return end
         self:GetParent():SetActive(self)
         self:GetParent():Retract()
end

function PANEL:OnCursorEntered()
         self.Color = Color(200,200,0,255)
end

function PANEL:OnCursorExited()
         self.Color = Color(50,50,25,255)
end


vgui.Register("GMS_DropDown_Item",PANEL,"Panel")
/*---------------------------------------------------------
  Resource Drop window
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetTitle("Drop Resources")
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)
         
         self:SetSize(ScrW() / 2, ScrH() / 2)
         self:SetPos(ScrW() / 2 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))

         self.ResourceEntry = vgui.Create("GMS_DropDown",self)
         self.ResourceEntry:SetInitSize(self:GetWide() / 4, 20)
         self.ResourceEntry:SetPos(self:GetWide() / 20, self:GetTall() / 2 - 10)

         local lbl = vgui.Create("Label",self)
         lbl:SetPos(self:GetWide() / 20, self:GetTall() / 2 - 35)
         lbl:SetSize(self:GetWide() / 4,20)
         lbl:SetText("Specify resource")
         //lbl:SetFont("ScoreboardText")

         self.AmountEntry = vgui.Create("TextEntry",self)
         self.AmountEntry:SetSize(self:GetWide() / 6, 20)
         self.AmountEntry:SetPos(self:GetWide() / 20 + self.ResourceEntry:GetWide() + self:GetWide() / 20, self:GetTall() / 2 - 10)
         
         local lbl = vgui.Create("Label",self)
         lbl:SetPos(self:GetWide() / 20 + self.ResourceEntry:GetWide() + self:GetWide() / 20, self:GetTall() / 2 - 35)
         lbl:SetSize(self:GetWide() / 6,20)
         lbl:SetText("Specify amount")
         //lbl:SetFont("ScoreboardText")

         local button = vgui.Create("gms_CommandButton",self)
         button:SetSize(self:GetWide() / 3,self:GetTall() / 6)
         button:SetPos(self:GetWide() / 2 - (button:GetWide() / 2), self:GetTall() / 1.5)
         button:SetText("Drop")

         function button.DoClick(button)
               LocalPlayer():ConCommand("gms_DropResources "..string.Trim(self.ResourceEntry:GetText()).." "..string.Trim(self.AmountEntry:GetValue()).."\n")
               button:GetParent():SetVisible(false)
               self.AmountEntry:SetText("")
               self.ResourceEntry:SetActive(nil)
         end
end

function PANEL:RefreshList()
         self.ResourceEntry:Clear()

         for k,v in pairs(Resources) do
             if v > 0 then
                self.ResourceEntry:AddItem(k,k)
             end
         end
end

vgui.Register("GMS_ResourceDropWindow",PANEL,"GMS_Frame")
/*---------------------------------------------------------
  Planting menu
---------------------------------------------------------*/
local PANEL = {}

PANEL.Plantables = {}
PANEL.Plantables["gms_plantmelon"] = "Plant Melon"
PANEL.Plantables["gms_planttree"] = "Plant Tree"
PANEL.Plantables["gms_plantgrain"] = "Plant Grain"
PANEL.Plantables["gms_planthemp"] = "Plant Hemp"
PANEL.Plantables["gms_plantbush"] = "Plant Berry Bush"

function PANEL:Init()
         self:SetTitle("Planting")
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)
         
         local size = ScrH() / 30
         local space = 10

         self:SetSize(ScrW() / 6, (table.Count(self.Plantables) * (size + space)) + 30)
         self:SetPos(ScrW() / 1.3 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))

         local line = 25

         for cmd,txt in pairs(self.Plantables) do
             local button = vgui.Create("gms_CommandButton",self)
             button:SetSize(self:GetWide() - ((self:GetWide() / 8) * 2),ScrH() / 30)
             button:SetPos(self:GetWide() / 8, line)
             button:SetConCommand(cmd.."\n")
             button:SetText(txt)
             
             line = line + button:GetTall() + 10
         end
end

vgui.Register("GMS_PlantingMenu",PANEL,"GMS_Frame")

-- Gman Window
local PANEL = {}

PANEL.Plantables = {}
PANEL.Plantables["gms_selldrugs"] = "Sell Drugs"
PANEL.Plantables["gms_OpenGmanCombi"] = "Buy Drug Stuff"

function PANEL:Init()
         self:SetTitle("Gman")
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)
         
         local size = ScrH() / 30
         local space = 10

         self:SetSize(ScrW() / 6, (table.Count(self.Plantables) * (size + space)) + 30)
         self:SetPos(ScrW() / 1.3 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))

         local line = 25

         for cmd,txt in pairs(self.Plantables) do
             local button = vgui.Create("gms_CommandButton",self)
             button:SetSize(self:GetWide() - ((self:GetWide() / 8) * 2),ScrH() / 30)
             button:SetPos(self:GetWide() / 8, line)
             button:SetConCommand(cmd.."\n")
             button:SetText(txt)
             
             line = line + button:GetTall() + 10
         end
end
vgui.Register("GMS_GmanWindow",PANEL,"GMS_Frame")

/*---------------------------------------------------------
  Options menu
---------------------------------------------------------*/
local PANEL = {}

PANEL.Colors = {["r"] = 255,["g"] = 255,["b"] = 255,["a"] = 255}
PANEL.Sliders = {}
PANEL.ColorButtons = {}


function PANEL:Init()
         self:SetTitle("Options")
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)

         self:SetSize(ScrW() / 2, ScrH() / 2)
         self:SetPos(ScrW() / 2 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))
         
         local space = self:GetWide() / 30
         local line = 60

         for col,v in pairs(self.Colors) do
             local slider = vgui.Create("Slider",self)
             slider:SetPos(space,line)
             slider:SetSize(self:GetWide() / 2, self:GetWide() / 25)

             slider:PostMessage( "SetInteger", "b", "1" )
             slider:PostMessage( "SetLower", "f", "0" )
	     slider:PostMessage( "SetHigher", "f", "255" )
             slider:PostMessage( "SetValue", "f", 255 )
             slider:SetActionFunction(self.UpdateColor)
             
             local label = vgui.Create("Label",self)
             label:SetPos(space, line - slider:GetTall())
             label:SetSize(slider:GetWide(),slider:GetTall())
             label:SetText(col.." = 255")

             slider.Label = label
             slider.Color = col
             slider.Value = 255
             
             self.Sliders[col] = slider
             
             line = line + slider:GetTall() + space
         end
end

function PANEL:UpdateColor( slider, message, value )
         if (message != "SliderMoved") then return end
	 slider.Label:SetText(slider.Color.." = "..tostring(math.Round(tonumber(value))))
         slider.Value = value
         
         surface.PlaySound(Sound("common/bugreporter_succeeded.wav"))
end

vgui.Register("GMS_OptionsMenu",PANEL,"GMS_Frame")

/*---------------------------------------------------------
  Chat menu
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetTitle("Server Chat")
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)

         self:SetSize(ScrW() / 1.5, ScrH() / 2)
         self:SetPos(ScrW() / 2 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))
         
         local space = self:GetWide() / 30
         
         self.ChatLog = vgui.Create("RichText",self)
         self.ChatLog:SetPos(space,space + (space / 2))
         self.ChatLog:SetSize(self:GetWide() - (space * 2), self:GetTall() / 1.4)
         self.ChatLog:SetText("Welcome to "..GetGlobalString("ServerName")..", enjoy your stay!\n")
         self.ChatLog.Text = "Welcome to "..GetGlobalString("ServerName")..", enjoy your stay!\n"

         local x,y = self.ChatLog:GetPos()
         
         local button = vgui.Create("gms_CommandButton",self)
         button:SetSize(self:GetWide() / 8, self:GetTall() - self.ChatLog:GetTall() - (space * 3))
         button:SetPos(self:GetWide() - space - button:GetWide(), x + self.ChatLog:GetTall() + space)
         button:SetText("Send")
         
         self.SendButton = button

         self.Input = vgui.Create("TextEntry",self)
         self.Input:SetSize(self:GetWide() - (space * 3) - button:GetWide(), button:GetTall())
         self.Input:SetPos(space, x + self.ChatLog:GetTall() + space)
         self.Input:SetMultiline(true)

         function button:DoClick()
                  local p = self:GetParent()
                  local text = string.Trim(p.Input:GetValue())

                  if !text then return end
                  if text == "" then return end

                  LocalPlayer():ConCommand("gms_say "..text.."\n")
                  p.Input:SetText("")
         end

         local input = self.Input

         function input:OnKeyCodePressed(kc)
                  if kc == 64 then
                     self:GetParent().SendButton:DoClick()
                  end
         end
end

function PANEL:AddChat(name, text)
         self.ChatLog:SetText(self.ChatLog.Text..name..": "..text.."\n")
         self.ChatLog.Text = self.ChatLog.Text..name..": "..text.."\n"
         surface.PlaySound(Sound("hl1/fvox/beep.wav"))
end

vgui.Register("GMS_ChatMenu",PANEL,"GMS_Frame")

/*---------------------------------------------------------
  Admin menu
---------------------------------------------------------*/
local PANEL = {}

PANEL.CmdButtons = {}
PANEL.CmdButtons["gms_admin_makefood"] = "Spawn food"
PANEL.CmdButtons["gms_admin_makerock"] = "Spawn rock"
PANEL.CmdButtons["gms_admin_maketree"] = "Spawn tree"
PANEL.CmdButtons["gms_admin_makebush"] = "Spawn random plant"
PANEL.CmdButtons["gms_admin_saveallcharacters"] = "Save all characters"
PANEL.CmdButtons["gms_admin_creategman"] = "Spawn Gman"
PANEL.CmdButtons["gms_admin_createstore"] = "Spawn Store"

function PANEL:Init()
	self:SetTitle("Admin Menu")
	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)
	
	local size = ScrH() / 30
	local space = 10
	self:SetSize(ScrW() / 1.5, ScrH() - 100)
	self:SetPos(ScrW() / 2 - (self:GetWide() / 2), 50)
	
	local line = 30
	local tab = 0

	//Populate area command stuff
	local button = vgui.Create("gms_CommandButton",self)
	button:SetSize(self:GetWide() / 5, size)
	button:SetPos(10, line)
	button:SetText("Populate Area")
	
	local tab = tab + button:GetWide() + space + 10
	
	self.PopulateType = vgui.Create("GMS_DropDown",self)
	self.PopulateType:SetInitSize(button:GetWide(),button:GetTall())
	self.PopulateType:SetPos(tab,line)
	self.PopulateType:AddItem("Trees","forest")
	self.PopulateType:AddItem("Rocks","rocks")
	self.PopulateType:AddItem("Random Plant","plant")

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Type")
	
	local tab = tab + self.PopulateType:GetWide() + space
	
	self.PopulateAmount = vgui.Create("TextEntry",self)
	self.PopulateAmount:SetSize(button:GetWide(),button:GetTall())
	self.PopulateAmount:SetPos(tab,line)

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Amount")
	
	local tab = tab + self.PopulateType:GetWide() + space
	
	self.PopulateRadius = vgui.Create("TextEntry",self)
	self.PopulateRadius:SetSize(button:GetWide(),button:GetTall())
	self.PopulateRadius:SetPos(tab,line)
	
	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Max radius")
	
	function button:DoClick()
			local p = self:GetParent()
			local strType = p.PopulateType:GetValue() or ""
			LocalPlayer():ConCommand("gms_admin_PopulateArea "..strType.." "..string.Trim(p.PopulateAmount:GetValue()).." "..string.Trim(p.PopulateRadius:GetValue()).."\n")
	end

	//Set ConVar stuff
	line = line + button:GetTall() + 30
	local tab = 0
	local button = vgui.Create("gms_CommandButton",self)
	button:SetSize(self:GetWide() / 5, size)
	button:SetPos(10, line)
	button:SetText("Set Convar")
	
	local tab = tab + button:GetWide() + space + 10
	
	self.ConVarList = vgui.Create("GMS_DropDown",self)
	self.ConVarList:SetInitSize(button:GetWide() * 2 + space,button:GetTall())
	self.ConVarList:SetPos(tab,line)
	
	for k,v in pairs(GMS.ConVarList) do
		self.ConVarList:AddItem(v,v)
	end

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Convar")
	
	local tab = tab + self.ConVarList:GetWide() + space

	self.ConVarValue = vgui.Create("TextEntry",self)
	self.ConVarValue:SetSize(button:GetWide(),button:GetTall())
	self.ConVarValue:SetPos(tab,line)

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Value")

	function button:DoClick()
			local p = self:GetParent()
			local ConVar = p.ConVarList:GetText() or ""
			LocalPlayer():ConCommand(ConVar.." "..string.Trim(p.ConVarValue:GetValue()).."\n")
	end
	
	//Spawn antlion barrow stuff
	line = line + button:GetTall() + 30
	local tab = space
	local button = vgui.Create("gms_CommandButton",self)
	button:SetSize(self:GetWide() / 5, size)
	button:SetPos(tab, line)
	button:SetText("Make antlion barrow")

	local tab = tab + button:GetWide() + space

	self.MaxAntlions = vgui.Create("TextEntry",self)
	self.MaxAntlions:SetSize(button:GetWide(),button:GetTall())
	self.MaxAntlions:SetPos(tab,line)

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Max antlions")

	function button:DoClick()
			LocalPlayer():ConCommand("gms_admin_MakeAntlionBarrow "..string.Trim(self:GetParent().MaxAntlions:GetValue()).."\n")
	end
	
	//Save game stuff
	line = line + button:GetTall() + 30
	local tab = space
	local button = vgui.Create("gms_CommandButton",self)
	button:SetSize(self:GetWide() / 5, size)
	button:SetPos(tab, line)
	button:SetText("Save Game")

	local tab = tab + button:GetWide() + space

	self.SaveGameEntry = vgui.Create("TextEntry",self)
	self.SaveGameEntry:SetSize(button:GetWide(),button:GetTall())
	self.SaveGameEntry:SetPos(tab,line)

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Save name")

	function button:DoClick()
			self:GetParent():SetVisible(false)
			LocalPlayer():ConCommand("gms_admin_savemap "..self:GetParent().SaveGameEntry:GetValue().."\n")
	end

	//Load game stuff
	line = line + button:GetTall() + 30
	local tab = space
	local button = vgui.Create("gms_CommandButton",self)
	button:SetSize(self:GetWide() / 5, size)
	button:SetPos(tab, line)
	button:SetText("Load Game")

	local tab = tab + button:GetWide() + space
	
	local Dbutton = vgui.Create("gms_CommandButton",self)
	Dbutton:SetSize(self:GetWide() / 5, size)
	Dbutton:SetPos(tab, line)
	Dbutton:SetText("Delete")

	local tab = tab + button:GetWide() + space

	self.LoadGameEntry = vgui.Create("GMS_DropDown",self)
	self.LoadGameEntry:SetInitSize(button:GetWide(),button:GetTall())
	self.LoadGameEntry:SetPos(tab,line)

	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Load name")

	function button:DoClick()
			self:GetParent():SetVisible(false)
			local name = self:GetParent().LoadGameEntry:GetValue() or ""
			LocalPlayer():ConCommand("gms_admin_loadmap "..name.."\n")
	end
	
	function Dbutton:DoClick()
			local name = self:GetParent().LoadGameEntry:GetValue() or ""
			LocalPlayer():ConCommand("gms_admin_deletemap "..name.."\n")
	end
	
	//Create Spawnpoint Stuff
	line = line + button:GetTall() + 30
	local tab = space
	local button = vgui.Create("gms_CommandButton",self)
	button:SetSize(self:GetWide() / 5, size)
	button:SetPos(tab, line)
	button:SetText("Set Spawnpoint")

	local tab = tab + button:GetWide() + space

	self.ClassName = vgui.Create("GMS_DropDown",self)
	self.ClassName:SetInitSize(button:GetWide(),button:GetTall())
	self.ClassName:SetPos(tab,line)
	
	local teams = team.GetAllTeams()
	for k, v in ipairs(teams) do
		self.ClassName:AddItem(teams[k]['Name'],k)
	end
	self.ClassName:AddItem('Jail', 'jail')
	
	local label = vgui.Create("Label",self)
	label:SetPos(tab,line - 20)
	label:SetSize(button:GetWide(),20)
	label:SetText("Class")

	function button:DoClick()
			self:GetParent():SetVisible(false)
			local name = self:GetParent().ClassName:GetValue() or ""
			LocalPlayer():ConCommand("gms_admin_setspawn "..name.."\n")
	end

	//Static command buttons
	line = line + button:GetTall() + 10

	for cmd,txt in pairs(self.CmdButtons) do
		local button = vgui.Create("gms_CommandButton",self)
		button:SetSize(self:GetWide() / 5, size)
		button:SetPos(10, line)
		button:SetConCommand(cmd.."\n")
		button:SetText(txt)
		
		line = line + button:GetTall() + 10
	end
end

vgui.Register("GMS_AdminMenu",PANEL,"GMS_Frame")

-- Gman Window
-- local PANEL = {}

-- function PANEL:Init()
	-- self:SetTitle("Planting")
	-- self:SetKeyboardInputEnabled(true)
	-- self:SetMouseInputEnabled(true)
	
	-- local size = ScrH() / 30
	-- local space = 10

	-- self:SetSize(ScrW() / 6, (table.Count(self.Plantables) * (size + space)) + 30)
	-- self:SetPos(ScrW() / 1.3 - (self:GetWide() / 2), ScrH() / 2 - (self:GetTall() / 2))

	-- local line = 25

	-- for cmd,txt in pairs(self.Plantables) do
		-- local button = vgui.Create("gms_CommandButton",self)
		-- button:SetSize(self:GetWide() - ((self:GetWide() / 8) * 2),ScrH() / 30)
		-- button:SetPos(self:GetWide() / 8, line)
		-- button:SetConCommand(cmd.."\n")
		-- button:SetText(txt)
		
		-- line = line + button:GetTall() + 10
	-- end
-- end
-- vgui.Register("GMS_GmanWindow",PANEL,"GMS_Frame")

/*---------------------------------------------------------
  Need HUD
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetPos(0,0)
         self:SetSize(ScrW() / 6,ScrH() / 12)
         
         self:SetVisible(true)
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(col.r,col.g,col.b,math.Clamp(col.a - 60,1,255))
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,math.Clamp(bordcol.a - 60,1,255))
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())

         local line = self:GetTall() / 10

         //Health
         local h = LocalPlayer():Health() / 100 * self:GetWide() - ((self:GetWide() / 14) * 2)
         surface.SetDrawColor(0,0,0,255)
         surface.DrawRect(self:GetWide() / 14, line, self:GetWide() - ((self:GetWide() / 14) * 2), self:GetTall() / 8)

         surface.SetDrawColor(170,0,0,255)
         surface.DrawRect(self:GetWide() / 14, line, h, self:GetTall() / 8)
         local line = line + (self:GetTall() / 8) + (self:GetTall() / 10)

         //Hunger
         local h = Hunger / 1000 * self:GetWide() - ((self:GetWide() / 14) * 2)
         surface.SetDrawColor(0,0,0,255)
         surface.DrawRect(self:GetWide() / 14, line, self:GetWide() - ((self:GetWide() / 14) * 2), self:GetTall() / 8)

         surface.SetDrawColor(0,170,0,255)
         surface.DrawRect(self:GetWide() / 14, line, h, self:GetTall() / 8)
         local line = line + (self:GetTall() / 8) + (self:GetTall() / 10)
         
         //Thirst
         local h = Thirst / 1000 * self:GetWide() - ((self:GetWide() / 14) * 2)
         surface.SetDrawColor(0,0,0,255)
         surface.DrawRect(self:GetWide() / 14, line, self:GetWide() - ((self:GetWide() / 14) * 2), self:GetTall() / 8)
         
         surface.SetDrawColor(0,0,170,255)
         surface.DrawRect(self:GetWide() / 14, line, h, self:GetTall() / 8)
         local line = line + (self:GetTall() / 8) + (self:GetTall() / 10)
         
         //Sleepiness
         local h = Sleepiness / 1000 * self:GetWide() - ((self:GetWide() / 14) * 2)
         surface.SetDrawColor(0,0,0,255)
         surface.DrawRect(self:GetWide() / 14, line, self:GetWide() - ((self:GetWide() / 14) * 2), self:GetTall() / 8)
         
         surface.SetDrawColor(170,0,140,255)
         surface.DrawRect(self:GetWide() / 14, line, h, self:GetTall() / 8)
         local line = line + (self:GetTall() / 8) + (self:GetTall() / 10)
         return true
end

vgui.Register("gms_NeedHud",PANEL,"Panel")

/*---------------------------------------------------------
  Skills panel
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetPos(0,GAMEMODE.NeedHud:GetTall())
         self:SetSize(ScrW() / 6,ScrH() / 20)

         self:SetVisible(true)
         
         self.Extended = false
         self.SkillLabels = {}
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(col.r,col.g,col.b,math.Clamp(col.a - 60,1,255))
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,math.Clamp(bordcol.a - 60,1,255))
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         draw.SimpleText("Skills (F1)","ScoreboardSub",5,5,Color(255,255,255,255))
         return true
end

function PANEL:RefreshSkills()
         for k,v in pairs(self.SkillLabels) do
             v:Remove()
         end
         
         self.SkillLabels = {}
         self.Line = ScrH() / 20
         self.Tab = 0

         for k,v in pairs(Skills) do
             local lbl = vgui.Create("gms_SkillPanel",self)
             lbl:SetPos(self.Tab,self.Line)
             lbl:SetSize( self:GetWide(), ScrH() / 15)
             local val = string.gsub(k,"_"," ")
             lbl:SetSkill(val)

             self.Line = self.Line + lbl:GetTall()
             table.insert(self.SkillLabels,lbl)
             if !self.Extended then lbl:SetVisible(false) end
         end

         if self.Extended then 
            self:SetSize(ScrW() / 6, ScrH() / 20 + (table.Count(Skills) * ScrH() / 15)) 
            GAMEMODE:RecalculateHUDPos()
         end
end

function PANEL:ToggleExtend()
         if !self.Extended then

            self:SetSize(ScrW() / 6, ScrH() / 20 + (table.Count(Skills) * ScrH() / 15))
            self.Extended = true

            GAMEMODE:RecalculateHUDPos()
            for k,v in pairs(self.SkillLabels) do
                v:SetVisible(true)
            end
         else
            self:SetSize(ScrW() / 6, ScrH() / 20)
            self.Extended = false

            GAMEMODE:RecalculateHUDPos()
            for k,v in pairs(self.SkillLabels) do
                v:SetVisible(false)
            end
         end
end

function PANEL:OnMousePressed(mc)
         if mc == 107 then
            self:ToggleExtend()
         end
end

vgui.Register("gms_SkillsHud",PANEL,"Panel")

function GM:RecalculateHUDPos()
         GAMEMODE.ResourcesHud:SetPos(0,GAMEMODE.NeedHud:GetTall() + GAMEMODE.SkillsHud:GetTall())
         GAMEMODE.CommandsHud:SetPos(0,GAMEMODE.NeedHud:GetTall() + GAMEMODE.SkillsHud:GetTall() + GAMEMODE.ResourcesHud:GetTall())
end

/*---------------------------------------------------------
  Skill Sub-Panel
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
end

function PANEL:Paint()
         draw.SimpleText(self.TxtSkill..": "..Skills[self.Skill],"ScoreboardText",5,0,Color(255,255,255,255))
         
         //XP bar background
         surface.SetDrawColor(00,0,00,170)
         surface.DrawRect(10, self:GetTall() / 2, self:GetWide() - 20, self:GetTall() / 2 - 10)

         //XP bar
         local XP = Experience[self.Skill] / 100 * (self:GetWide() - 20)
         surface.SetDrawColor(10,255,10,255)
         surface.DrawRect(10, self:GetTall() / 2, XP , self:GetTall() / 2 - 10)
         
         //Draw XP
         draw.SimpleText(Experience[self.Skill].." / 100","Default",self:GetWide() / 2, self:GetTall() / 2 + ((self:GetTall() / 2 - 10) / 2),Color(255,255,255,255),1,1)

         //XP bar outline
         surface.SetDrawColor(0,0,0,140)
         surface.DrawOutlinedRect(10, self:GetTall() / 2, self:GetWide() - 20, self:GetTall() / 2 - 10)

         //Box outline
         surface.SetDrawColor(70,70,20,140)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         return true
end

function PANEL:SetSkill(str)
         self.TxtSkill = str
         self.Skill = string.gsub(str," ","_")
end

vgui.Register("gms_SkillPanel",PANEL,"Panel")


/*---------------------------------------------------------
  Resource panel
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetPos(0,GAMEMODE.NeedHud:GetTall() + ScrH() / 20)
         self:SetSize(ScrW() / 6,ScrH() / 20)

         self:SetVisible(true)
         
         self.Extended = false
         self.ResourceLabels = {}
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(col.r,col.g,col.b,math.Clamp(col.a - 60,1,255))
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,math.Clamp(bordcol.a - 60,1,255))
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         draw.SimpleText("Resources (F2)","ScoreboardSub",5,5,Color(255,255,255,255))
         return true
end

function PANEL:RefreshResources()
         for k,v in pairs(self.ResourceLabels) do
             v:Remove()
         end

         self.ResourceLabels = {}
         self.Line = ScrH() / 20
         self.Tab = 5
         self.IntResources = 0

         for k,v in pairs(Resources) do
             local lbl = vgui.Create("Label",self)
             lbl:SetPos(self.Tab,self.Line)
             lbl:SetSize(self:GetWide(),20)
             local val = string.gsub(k,"_"," ")
             lbl:SetText(val..":  "..v)
             lbl:SetFont("ScoreboardText")

             self.IntResources = self.IntResources + v
             self.Line = self.Line + 20
             table.insert(self.ResourceLabels,lbl)
             if !self.Extended then lbl:SetVisible(false) end
         end
         
         local lbl = vgui.Create("Label",self)
         lbl:SetPos(self.Tab,self.Line + 20)
         lbl:SetSize(self:GetWide(),20)
         lbl:SetText("Total:  "..self.IntResources.." / "..MaxResources)
         lbl:SetFont("ScoreboardText")
             
         table.insert(self.ResourceLabels,lbl)
         if !self.Extended then lbl:SetVisible(false) end
         
         if self.Extended then
            self:SetSize(ScrW() / 6, ScrH() / 20 + (table.Count(Resources) * 20) + 60)
            GAMEMODE:RecalculateHUDPos()
         end
end

function PANEL:ToggleExtend()
         if !self.Extended then

            self:SetSize(ScrW() / 6, ScrH() / 20 + (table.Count(Resources) * 20) + 60)
            self.Extended = true
            
            GAMEMODE:RecalculateHUDPos()

            for k,v in pairs(self.ResourceLabels) do
                v:SetVisible(true)
            end
         else
            self:SetSize(ScrW() / 6, ScrH() / 20)
            self.Extended = false

            GAMEMODE:RecalculateHUDPos()

            for k,v in pairs(self.ResourceLabels) do
                v:SetVisible(false)
            end
         end
end

function PANEL:OnMousePressed(mc)
         if mc == 107 then
            self:ToggleExtend()
         end
end

vgui.Register("gms_ResourcesHud",PANEL,"Panel")

/*---------------------------------------------------------
  Command panel
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetPos(0,GAMEMODE.NeedHud:GetTall() + GAMEMODE.ResourcesHud:GetTall() + GAMEMODE.SkillsHud:GetTall())
         self:SetSize(ScrW() / 6,ScrH() / 20)

         self:SetVisible(true)
         
         self.Extended = false
         self.CommandLabels = {}
end

function PANEL:Paint()
         local col = StrandedColorTheme
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(col.r,col.g,col.b,math.Clamp(col.a - 60,1,255))
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,math.Clamp(bordcol.a - 60,1,255))
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         draw.SimpleText("Commands (F3)","ScoreboardSub",5,5,Color(255,255,255,255))
         return true
end

function PANEL:RefreshCommands()
         if LocalPlayer():IsAdmin() and !table.HasValue(GMS.Commands,"Admin menu") then
            GMS.Commands["gms_admin"] = "Admin menu"
         end

         for k,v in pairs(self.CommandLabels) do
             v:Remove()
         end

         self.CommandLabels = {}
         self.Line = ScrH() / 20
         self.Tab = 5

         for k,v in pairs(GMS.Commands) do
             local lbl = vgui.Create("gms_CommandButton",self)
             lbl:SetPos(self:GetWide() / 10,self.Line)
             lbl:SetSize(self:GetWide() - ((self:GetWide() / 10) * 2),20)
             lbl:SetText(v)
             lbl:SetConCommand(k)
             lbl:SetFont("ScoreboardText")

             self.Line = self.Line + 25
             table.insert(self.CommandLabels,lbl)
             if !self.Extended then lbl:SetVisible(false) end
         end
end

function PANEL:ToggleExtend()
         if !self.Extended then
            self:RefreshCommands()

            self:SetSize(ScrW() / 6, ScrH() / 20 + (table.Count(GMS.Commands) * 25) + 20)
            self.Extended = true
            gui.EnableScreenClicker(true)

            GAMEMODE:RecalculateHUDPos()

            for k,v in pairs(self.CommandLabels) do
                v:SetVisible(true)
            end
         else
            self:SetSize(ScrW() / 6, ScrH() / 20)
            self.Extended = false
            gui.EnableScreenClicker(false)

            GAMEMODE:RecalculateHUDPos()

            for k,v in pairs(self.CommandLabels) do
                v:SetVisible(false)
            end
         end
end

function PANEL:OnMousePressed(mc)
         if mc == 107 then
            self:ToggleExtend()
         end
end

vgui.Register("gms_CommandHud",PANEL,"Panel")
/*---------------------------------------------------------
  Command button
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self.Color = DefaultButtonTheme
         self.OutLineColor = Color(0,0,0,150)
end

function PANEL:DoClick()
         LocalPlayer():ConCommand(self.Command.."\n")
         surface.PlaySound(Sound("ui/buttonclickrelease.wav"))
end

function PANEL:Paint()
         draw.RoundedBox(8,0,0,self:GetWide(),self:GetTall(),self.OutLineColor)
         draw.RoundedBox(8,1,1,self:GetWide() - 3,self:GetTall() - 3,self.Color)
         
         draw.SimpleText(self.Text,"ScoreboardText",self:GetWide() / 2, self:GetTall() / 2, Color(255,255,255,255),1,1)
         return true
end

function PANEL:SetText(txt)
         self.Text = txt
end

function PANEL:SetConCommand(cmd)
         self.Command = cmd
end

function PANEL:OnCursorEntered()
         self.Color = DefaultHoveredTheme
         surface.PlaySound(Sound("ui/buttonrollover.wav"))
end

function PANEL:OnCursorExited()
         self.Color = DefaultButtonTheme
end

function PANEL:OnMousePressed(mc)
         if mc != 107 then return end
         self.OutLineColor = Color(200,0,0,200)
end

function PANEL:OnMouseReleased(mc)
         if mc != 107 then return end
         self.OutLineColor = Color(0,0,0,150)
		 self:DoClick()
end

vgui.Register("gms_CommandButton",PANEL,"Button")

/*---------------------------------------------------------
  Process bar
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetSize(ScrW() / 3,ScrH() / 30)
         self:SetPos(ScrW() / 2 - (self:GetWide() / 2),ScrH() / 30)
end

function PANEL:Paint()
         surface.SetDrawColor(30,30,30,150)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         local width = self.Progress / self.MaxProgress * self:GetWide()
         surface.SetDrawColor(0,200,0,255)
         surface.DrawRect(0,0,width,self:GetTall())
         
         surface.SetDrawColor(70,70,20,130)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         draw.SimpleText(self.Text, "ScoreboardText",self:GetWide() / 2, self:GetTall() / 2,Color(255,255,255,255),1,1)
         return true
end

function PANEL:DoProcessBar(name,time)
         self.Progress = 0
         self.MaxProgress = time
         self.IsStopped = false
         
         self.Text = name
         timer.Simple(0.1,self.UpdateProgress,self)
         self:SetVisible(true)
end

function PANEL:Stop()
         self.Progress = 0
         self.MaxProgress = 0
         self:SetVisible(false)
         self.IsStopped = true
end

function PANEL:UpdateProgress()
         if self.IsStopped then return end

         self.Progress = self.Progress + 0.1
         
         if self.Progress >= self.MaxProgress then
            self.Progress = self.MaxProgress
         return end
         
         timer.Simple(0.1,self.UpdateProgress,self)
end

vgui.Register("gms_ProcessBar",PANEL,"Panel")

/*---------------------------------------------------------
  Loading bar
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetSize(ScrW() / 2.7,ScrH() / 10)
         self:SetPos(ScrW() / 2 - (self:GetWide() / 2),ScrH() / 2 - (self:GetTall() / 2))
         
         self.Dots = "."
         self.Message = ""
end

function PANEL:Paint()
         //Background
         draw.RoundedBox(8,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,150))

         //Text
         draw.SimpleText("Loading"..self.Dots, "ScoreboardHead",self:GetWide() / 2, self:GetTall() / 2,Color(255,255,255,255),1,1)
         draw.SimpleText(self.Text, "ScoreboardText",self:GetWide() / 2, self:GetTall() / 1.2,Color(255,255,255,255),1,1)
         return true
end

function PANEL:Show(msg)
         self.IsStopped = false
         
         self.Text = msg
         timer.Simple(0.5,self.UpdateDots,self)
         self:SetVisible(true)
end

function PANEL:Hide()
         self.IsStopped = true
         self:SetVisible(false)
end

function PANEL:UpdateDots()
         if self.IsStopped then return end

         if self.Dots == "...." then
            self.Dots = "."
         else
            self.Dots = self.Dots.."."
         end

         timer.Simple(0.5,self.UpdateDots,self)
end

vgui.Register("gms_LoadingBar",PANEL,"Panel")
/*---------------------------------------------------------
  Info Panel
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Paint()
         local bordcol = StrandedBorderTheme
         
         surface.SetDrawColor(50,50,25,255)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,bordcol.a)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         return true
end

vgui.Register("GMS_InfoPanel",PANEL,"Panel")
/*---------------------------------------------------------
  Combination Window
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Init()
         self:SetKeyboardInputEnabled(true)
         self:SetMouseInputEnabled(true)

         self:SetPos(100,50)
         self:SetSize(ScrW() - 200, ScrH() - 100)
         
         local space = self:GetTall() / 30

         //Add bordered subwindows
         self.CombiList = vgui.Create("GMS_InfoPanel",self)
         self.CombiList:SetPos(self:GetWide() / 30,self:GetTall() / 20)
         local x,y = self.CombiList:GetPos()
         self.CombiList:SetSize(self:GetWide() - (self:GetWide() / 30) * 2, self:GetTall() / 1.5 - space - y)


         self.Info = vgui.Create("GMS_InfoPanel",self)
         self.Info:SetPos(self:GetWide() / 30, self:GetTall() / 1.5)
         local x2,y2 = self.Info:GetPos()
         self.Info:SetSize(self:GetWide() - (x2 * 2), self:GetTall() / 3 - space - y)
         self.Info:SetZPos(290)
         
         self.Info.NameLabel = vgui.Create("Label",self.Info)
         self.Info.NameLabel:SetPos(10,5)
         self.Info.NameLabel:SetSize(self.Info:GetWide(),20)
         self.Info.NameLabel:SetFont("ScoreboardSub")

         self.Info.DescLabel = vgui.Create("Label",self.Info)
         
         self.Info.DescLabel:SetName("GMS_TempLblName")
         self.Info.DescLabel:LoadControlsFromString([["GMS_TempLblName"{"GMS_TempLblName"{"wrap" "1"}}]])

         self.Info.DescLabel:SetPos(10,20)
         self.Info.DescLabel:SetSize(self.Info:GetWide(),self.Info:GetTall() - 20)
         
         self.Info.NameLabel:SetText("Select a recipe")
         self.Info.DescLabel:SetText("")
         
         local button = vgui.Create("gms_CommandButton",self)
         button:SetPos(self:GetWide() / 30,y2 + self.Info:GetTall() + 5)
         button:SetSize(self:GetWide() / 6, self:GetTall() / 17 - 10)
         button:SetText("Make")

         function button:DoClick()
                  local p = self:GetParent()
                  local combi = p.CombiGroupName or ""
                  local active = p.ActiveCombi or ""
                  LocalPlayer():ConCommand("gms_MakeCombination "..combi.." "..active.."\n")
         end

         //Make limits
         self.IconSize = 64
         self.Spacing = 10
         self.MaxLines = math.Round(self.CombiList:GetTall() / (self.IconSize + self.Spacing))
         self.MaxPerLine = math.Round(self.CombiList:GetWide() / (self.IconSize + self.Spacing))

         self.CombiPanels = {}
end

function PANEL:SetTable(str)
         self:SetTitle(str)
         self.CombiGroupName = str
         self.CombiGroup = GMS.Combinations[str]
         self:Clear()

         local line = self.Spacing
         local tab = self.Spacing
         
         local num = 0

         for name,tbl in pairs(self.CombiGroup) do
             local icon = vgui.Create("GMS_CombiIcon",self.CombiList)
             icon:SetPos(tab,line)
             icon:SetSize(self.IconSize,self.IconSize)
             icon:SetInfo(name,tbl)
             icon:SetZPos(400)
             table.insert(self.CombiPanels,icon)
             
             tab = tab + self.Spacing + icon:GetWide()
             num = num + 1

             if num >= self.MaxPerLine then
                tab = self.Spacing
                line = line + self.Spacing + self.IconSize
             end
         end
         
         self:ClearActive()
end

function PANEL:SetActive(combi,tbl)
         self.ActiveCombi = combi
         self.ActiveTable = tbl
         
         self.Info.NameLabel:SetText(tbl.Name)
         self.Info.DescLabel:SetText(tbl.Description)
end

function PANEL:ClearActive()
         self.ActiveCombi = nil
         self.ActiveTable = nil
            
         self.Info.NameLabel:SetText("Select a recipe")
         self.Info.DescLabel:SetText("")
end

function PANEL:Clear()
         for k,v in pairs(self.CombiPanels) do
             v:Remove()
         end

         self.CombiPanels = {}
end


vgui.Register("GMS_CombinationWindow",PANEL,"GMS_Frame")
/*---------------------------------------------------------
  Empty Combi Icon
---------------------------------------------------------*/
local PANEL = {}

function PANEL:Paint()
         local bordcol = StrandedBorderTheme

         surface.SetDrawColor(0,0,0,255)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,bordcol.a)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         return true
end

function PANEL:OnMousePressed(mc)
         if mc != 107 then return end
         surface.PlaySound(Sound("ui/buttonclickrelease.wav"))
         self:GetParent():GetParent():ClearActive()
end

vgui.Register("GMS_EmptyCombiIcon",PANEL,"Panel")


/*---------------------------------------------------------
  Combi Icon
---------------------------------------------------------*/
local PANEL = {}
PANEL.TexID = surface.GetTextureID( "gui/gmod_logo" )

function PANEL:Paint()
         local bordcol = StrandedBorderTheme
         
         surface.SetDrawColor(200,200,200,255)
         surface.DrawRect(0,0,self:GetWide(),self:GetTall())

         surface.SetTexture(self.TexID)
         surface.DrawTexturedRect(0,5,self:GetWide(),self:GetTall())

         surface.SetDrawColor(bordcol.r,bordcol.g,bordcol.b,bordcol.a)
         surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
         
         local hasskill = true
         if self.CombiTable.SkillReq then
            for k,v in pairs(self.CombiTable.SkillReq) do
                if GetSkill(k) < v then
                   hasskill = false
                end
            end
         end
         
         local hasres = true
         if self.CombiTable.Req then
            for k,v in pairs(self.CombiTable.Req) do
                if GetResource(k) < v then
                   hasres = false
                end
            end
         end
         
         if !hasskill then
            surface.SetDrawColor(200,200,0,150)
            surface.DrawRect(0,0,self:GetWide(),self:GetTall())
         elseif !hasres then
            surface.SetDrawColor(200,0,0,100)
            surface.DrawRect(0,0,self:GetWide(),self:GetTall())
         end

         if self.BeingHovered then
            local x1,y1 = gui.MouseX(),gui.MouseY()
            local x2,y2 = self:GetPos()
            local x3,y3 = self:GetParent():GetPos()
            local x4,y4 = self:GetParent():GetParent():GetPos()

            local x = x1 - x2 - x3 - x4
            local y = y1 - y2 - y3 - y4
            draw.SimpleTextOutlined(self.CombiTable.Name,"ScoreboardText",x,y - 10,Color(255,255,255,255),1,1,0.5,Color(100,100,100,140))
         end

         return true
end

function PANEL:SetInfo(name,tbl)
         if tbl.Texture then self.TexID = surface.GetTextureID( tbl.Texture ) end
         self.Combi = name
         self.CombiTable = tbl
end

function PANEL:OnMousePressed(mc)
         if mc != 107 then return end
         surface.PlaySound(Sound("ui/buttonclickrelease.wav"))
         self:GetParent():GetParent():SetActive(self.Combi,self.CombiTable)
end

function PANEL:OnCursorEntered()
         for k,icon in pairs(self:GetParent():GetParent().CombiPanels) do
             icon:SetZPos(400)
         end
         
         self:SetZPos(410)
         self.BeingHovered = true
         surface.PlaySound(Sound("ui/buttonrollover.wav"))
end

function PANEL:OnCursorExited()
         self.BeingHovered = false
end

vgui.Register("GMS_CombiIcon",PANEL,"Panel")

         
         
         
         
         
         
         
         
         
         
         

