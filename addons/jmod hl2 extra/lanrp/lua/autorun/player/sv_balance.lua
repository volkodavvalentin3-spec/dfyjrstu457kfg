--[[hook.Add( "EntityTakeDamage", "LVSArccwBalance", function( target, dmginfo )
        if scripted_ents.IsBasedOn( target:GetClass(), "lvs_renaultft" ) and dmginfo:GetAmmoType() == "Heavy Rifle Round" or "Mini Rocket" then
                
        local Force = dmginfo:GetDamageForce()
        local DamageForce = Force:Length()
        
        dmginfo:SetDamageForce( Force*2 )
        --print(DamageForce)
        end
end )]]



local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util


hook.Add( "OnEntityCreated", "ConveyorCollisions", function( ent )
    if ent:GetClass() == "sent_conveyor" then ent:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS ) end
end )

hook.Add( "DoPlayerDeath", "FixFire", function( ply, attacker, dmg )
    ply:Extinguish()
end )

hook.Add( "PlayerSpawn", "FixFireSpawn", function( ply )
    ply:Extinguish()
end )

--[[hook.Add( "PlayerSpawn", "WaterHurt", function( ply )
    if not timer.Exists( ply:EntIndex() .. " WaterHurt" ) then
        timer.Create( ply:EntIndex() .. " WaterHurt", 1.5, 0, function()
            if ply:WaterLevel() >= 1 then
                local dmg = DamageInfo()
	            dmg:SetDamage( 10 )
	            dmg:SetAttacker( game.GetWorld() )
	            dmg:SetInflictor( game.GetWorld() )
	            dmg:SetDamageType( DMG_DROWN )
	            ply:TakeDamageInfo( dmg )
            end
        end)
    end 
end )]]

hook.Add( "DoPlayerDeath", "WaterHurtDeath", function( ply, attacker, dmg )
    if timer.Exists( ply:EntIndex() .. " WaterHurt" ) then
        timer.Remove( ply:EntIndex() .. " WaterHurt" )
    end
end )


---------------------ARMOR--------------------------------
hook.Add("JModArmorEquip", "RadioBackpack", function(ply, armor)
    if armor.eff then    
        if armor.eff.radio then
            ply:Give("radiophone")

            if ply:GetNWInt( "RadioManSpawns") > 0 then
		        squad.SpawnsBase[ply] = ply:Nick()
	        end
        end
    end
end)
    
hook.Add("JModArmorRemove", "RadioBackpack", function(ply, Specs)
    if Specs.eff then
        if Specs.eff.radio then 

            if ply:GetActiveWeapon():GetClass() == "radiophone" then
                if IsValid(ply:GetActiveWeapon().VisualCable) then
                    ply:GetActiveWeapon().VisualCable:Remove()
                end
            end
            
            ply:StripWeapon("radiophone")
        
            if IsValid(ply.RadioCable) then
                ply.RadioCable:Remove()
            
                timer.Simple(0.1,function()
                    if IsValid(ply) then
                        ply:StripWeapon("radiophone")
                    end
                end)
            
            end

            local squad = SquadMenu:GetSquad(ply:GetSquadID())

            if ply:GetSquadID() ~= -1 then
		        squad.SpawnsBase[ply] = nil
	        end

        end
    end
end)

hook.Add("DoPlayerDeath", "DeleteRadioCable", function(ply, atacker, dmg)
    if IsValid(ply.RadioCable) then
        ply.RadioCable:Remove()
    end
end)