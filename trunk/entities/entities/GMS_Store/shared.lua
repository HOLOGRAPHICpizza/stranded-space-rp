 ENT.Base = "base_ai"  
 ENT.Type = "ai" 
   
 ENT.PrintName		= "" 
 ENT.Author			= "HOLOGRAPHICpizza" 
 ENT.Contact			= ""
 ENT.Purpose			= "" 
 ENT.Instructions	= "" 


 ENT.AutomaticFrameAdvance = true 
   
 function ENT:OnRemove() 
 end 
 
 function ENT:PhysicsCollide( data, physobj ) 
 end 
   
 function ENT:PhysicsUpdate( physobj ) 
 end 
   
 function ENT:SetAutomaticFrameAdvance( bUsingAnim ) 
   
 	self.AutomaticFrameAdvance = bUsingAnim 
   
 end  

