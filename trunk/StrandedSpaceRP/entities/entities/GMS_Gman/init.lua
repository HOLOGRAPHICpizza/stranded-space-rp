 AddCSLuaFile( "cl_init.lua" ) 
 AddCSLuaFile( "shared.lua" ) 
   
 include('shared.lua') 

 function ENT:Initialize() 

 	self:SetModel( "models/gman_high.mdl" ) 
 	 
 	self:SetHullType( HULL_HUMAN ); 
 	self:SetHullSizeNormal(); 
 	 
 	self:SetSolid( SOLID_BBOX )  
 	self:SetMoveType( MOVETYPE_STEP ) 
 	 
 	self:CapabilitiesAdd( CAP_ANIMATEDFACE | CAP_TURN_HEAD )
 	 
 	self:SetMaxYawSpeed( 5000 ) 
 
 	self:SetHealth(1337)
	
	self:SetSchedule( SCHED_IDLE_STAND )

 end

function ENT:SelectSchedule() 

	-- self:StartSchedule( SCHED_IDLE_STAND )

end 

function ENT:Think()
	
end

function ENT:OnRemove()
	
end
