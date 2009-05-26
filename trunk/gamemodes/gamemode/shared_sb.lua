
/*---------------------------------------------------------

  Space Build Gamemode

---------------------------------------------------------*/

Msg("Loading shared_sb.lua\n")

DeriveGamemode("sandbox")
GM.IsSandboxDerived = true
GM.IsSpaceBuildDerived = true
GM.affected = {
	"player",
	"prop_physics",
	"prop_physics_multiplayer",
	"prop_ragdoll",
	"npc_grenade_frag",
	"npc_grenade_bugbait",
	"npc_satchel",
	"grenade_ar2",
	"crossbow_bolt",
	"phys_magnet",
	"prop_vehicle_airboat",
	"prop_vehicle_jeep",
	"prop_vehicle_prisoner_pod",
	"prop_vehicle_jalopy"
}

volumes = {}
