// Created by Crowbar 0.74

$modelname "weapons\w_k98k.mdl"

$bodygroup "studio"
{
	studio "w_snip_scout_reference.smd"
}


$surfaceprop "weapon"

$contents "solid"

$illumposition -0.308 -11.63 2.471

$cdmaterials "models\weapons\w_models\k98\"

$attachment "muzzle_flash" "ValveBiped.flash" 0.3 -0.4 1 rotate -90 0 0

$cbox 0 0 0 0 0 0

$bbox 34.5 34 6.7 44 16 19

$definebone "ValveBiped" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$definebone "ValveBiped.weapon_bone" "ValveBiped" -0.439957 6.30849 5.191682 0 0 0 0 0 0 0 0 0
$definebone "ValveBiped.flash" "ValveBiped.weapon_bone" 0.502212 -2.120895 28.556004 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"w_snip_scout_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "w_snip_scout_physics.smd"
{
	$mass 5
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}

$keyvalues
{
	prop_data 
	{
		"base" "Metal.Small"
	}
}
