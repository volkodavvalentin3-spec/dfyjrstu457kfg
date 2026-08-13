
EntTbl = {"small","medium","large","huge"}
local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

local ICESSHK=CreateClientConVar("ice_screenshake",1,true,false,"Enable/disable Faraway screenshake. DOESN'T AFFECT SERVERSIDE SCREENSHAKE!!!",0,1)
local ICEPRTC=CreateClientConVar("ice_particles",1,true,false,"Enable/disable dust and spark particles. The main part of the addon. Severely impacts perfomance.",0,1)
local ICEECHO=CreateClientConVar("ice_farsounds",1,true,false,"Enable/disable muffled sounds far away.",0,1)
local ICEPRSZ=CreateClientConVar("ice_particlesize",1,true,false,"Dust/spark particle size. (0.25-4)",0.25,4)
local ICESSST=CreateClientConVar("ice_farshakestrength",1,true,false,"Faraway screenshake strength. Also does nothing about serverside screenshake (0.1-5)",0.1,5)
local ICESVOL=CreateClientConVar("ice_volume",1,true,false,"Near sound volume. (0.1-2)",0.1,2)

local ICEMINW=CreateConVar("ice_minweight",50,SERVER and {FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE})
local ICEMNSP=CreateConVar("ice_minspeed",250,SERVER and {FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE})
local ICEAABB=CreateConVar("ice_minaabb",24,SERVER and {FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE})

local ICEENSV=CreateConVar("ice_enabled_sv",1,SERVER and {FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE})
local ICEENCL=CreateClientConVar("ice_enabled_cl",1,true,false,"Enable/disable ICE clientside",0,1)

if SERVER and ICEENSV:GetBool() then
	util.AddNetworkString( "Ktotosh.ImmersiveEffects.Collision" )
	

	function ICEPhysCallback(ent, data) 
		local EntSize = math.Clamp(math.Round(((ent:OBBMaxs()-ent:OBBMins()):Length()+100)/100),1,4)

		if data.DeltaTime >= 1 then 
			if data.Speed>ICEMNSP:GetFloat() and (ent:OBBMaxs()-ent:OBBMins()):Length() > ICEAABB:GetFloat() and ent:GetPhysicsObject():GetMass() > ICEMINW:GetFloat() and ICEENSV:GetBool() and data.HitEntity:GetClass() != "player" then

				local Spd2Val = math.Clamp(math.SnapTo(data.Speed*10/EntSize,1000)/1000,1,5)
				if colmat==87 or colmat==68 then
					util.ScreenShake(ent:GetPos(), EntSize*Spd2Val/10, 3, EntSize, data.Speed, true)
				else
					util.ScreenShake(ent:GetPos(), EntSize*Spd2Val, 3, EntSize, data.Speed, true)
				end
				net.Start( "Ktotosh.ImmersiveEffects.Collision" )
				net.WriteEntity( ent )
				net.WriteFloat( Spd2Val )
				net.WriteFloat( EntSize )
				net.WriteVector( data.HitPos )
				net.WriteFloat(ent:GetMaterialType())
				net.Broadcast()
			end
		end

	end
	hook.Add( "OnEntityCreated", "Ktotosh.ImmersiveEffects.Callback", function( ent )
		if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "func_physbox" ) and ICEENSV:GetBool() then
			ent:AddCallback( "PhysicsCollide", ICEPhysCallback ) -- Add Callback
		end
	end )
end
if CLIENT then
	function CollisionDust(pos,size) 
		local emitter=ParticleEmitter(pos)
		

		for i=1,10*(size/15) do
			local smoke=emitter:Add("particle/smokesprites_000"..math.random(1,6),pos)
			smoke:SetDieTime(math.random(1,3))
			smoke:SetColor(200,200,150)
			smoke:SetStartAlpha(50*size)
			smoke:SetEndAlpha(0)	
			smoke:SetStartSize(4)
			smoke:SetEndSize(math.random(48,96)*size*ICEPRSZ:GetFloat())
			smoke:SetVelocity(VectorRand()*100*size*ICEPRSZ:GetFloat())
			smoke:SetAirResistance(384)
			smoke:SetRoll(60*180/math.pi)
			smoke:SetLighting(true)
		end

		emitter:Finish()
	end
	function CollisionSparks(pos,size,mat) 
		local emitter=ParticleEmitter(pos)
		

		for i=1,10*(size/25) do

			local sparks=emitter:Add(mat,pos)

			sparks:SetDieTime(math.Rand(0.2,1)*(size/3))
			sparks:SetColor(255,255,255)
			sparks:SetStartAlpha(255)
			sparks:SetEndAlpha(0)
			sparks:SetStartSize(3*size*ICEPRSZ:GetFloat())
			sparks:SetEndSize(1)
			sparks:SetAngles(AngleRand()*100)
			sparks:SetGravity(Vector(0,0,-600))
			sparks:SetVelocity(VectorRand()*100*size*ICEPRSZ:GetFloat())
			sparks:SetCollide(true)
			sparks:SetBounce(0.6) 
			sparks:SetAirResistance(50)
		end

		emitter:Finish()
	end


		net.Receive( "Ktotosh.ImmersiveEffects.Collision", function()

			local colent = net.ReadEntity()
			local colfrc = net.ReadFloat()
			local entsz = net.ReadFloat()
			local colpos = net.ReadVector()
			local colmat = net.ReadFloat()
			if colent != nil and colent:IsValid() and ICEENCL:GetBool() then
				if ICEPRTC:GetBool() then
					CollisionDust(colpos,colfrc)
					if colfrc > 2 then
						if colmat == 87 or colmat==68 then
							CollisionSparks(colpos,colfrc,"effects/fleck_wood"..math.random(1,2))
						else
							CollisionSparks(colpos,colfrc,"effects/spark")
						end
					end
				end
				local sspdist = colent:GetPos():Distance(LocalPlayer():GetPos())*1.905/100
				timer.Simple(sspdist/331,function()
					if colent != nil and colent:IsValid() then
						if colmat == 87 or colmat==68 then
							colent:EmitSound( "violentimpacts/wood/"..EntTbl[math.Clamp(entsz,1,3)].. colfrc.. ".wav", 80+(entsz*5), 100+math.random(-20,20)-(entsz*5), 0.5*ICESVOL:GetFloat(), CHAN_AUTO)
						else
							if entsz >= 2 and colfrc >= 3 and ICEECHO:GetBool() and sspdist > 100 then
								colent:EmitSound( "violentimpacts/"..EntTbl[entsz].. colfrc.. ".wav", 100+(entsz*10), 100, 0.5, CHAN_AUTO,0,132)
								util.ScreenShake(colent:GetPos(), math.Clamp((colfrc*entsz)/10-sspdist/331,0,4), 1/colfrc, 1, 1, true)
							else
								colent:EmitSound( "violentimpacts/"..EntTbl[entsz].. colfrc.. ".wav", 90+(entsz*5), 100+math.random(-20,20)-(entsz*5), 0.5*ICESVOL:GetFloat(), CHAN_AUTO)
							end
						end
					end
				end)
			end
			

		end )
	
end