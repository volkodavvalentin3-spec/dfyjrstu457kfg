AddCSLuaFile()
SWEP.Base = "weapon_base"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Other"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.PrintName = "RadioPhone"
SWEP.HoldType = "slam"
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/props_trainstation/payphone_reciever001a.mdl"
SWEP.WorldModel = "models/props_trainstation/payphone_reciever001a.mdl"
-- фикс гавно патроны начало
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = ""
-- фикс гавно патроны конец
SWEP.BobScale = 1
SWEP.SwayScale = 3

SWEP.Slot = 5

SWEP.ConnectionAttempts = 0
SWEP.EZradio = true

local STATE_OFF, STATE_CONNECTING = 0, 1
function SWEP:SetupDataTables()
	self:NetworkVar("Int", 1, "OutpostID")
	self:NetworkVar("Int", 2, "State")
end

function SWEP:GetVoice()
	return "normal"
end

function SWEP:PrimaryAttack()
    if self:GetOwner():IsSprinting() then return end
	if SERVER and self:GetState() == JMod.EZ_STATION_STATE_READY then
		net.Start("JMod_EZradio")
		net.WriteBool(false)
		net.WriteEntity(self)
		net.WriteString("aidradio")
		net.Send(self:GetOwner())
		self:GetOwner():EmitSound("snds_jack_gmod/radio_chk.ogg")
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end

	self:SetNextPrimaryFire(CurTime() + 2)
	self:SetNextSecondaryFire(CurTime() + 2)
end

function SWEP:SecondaryAttack()
    if self:GetState() == STATE_OFF then self:TurnOn() end
    self:SetNextSecondaryFire(CurTime() + 2)
end

function SWEP:Reload()
 
end

function SWEP:OnRemove()

end

function SWEP:Speak(msg, parrot)
	if self:GetState() < 1 then return end
	if not msg then msg = "uhhhh" end
	if SERVER and parrot then
		for _, ply in ipairs(player.GetAll()) do
			if ply:Alive() and (ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 or (self:UserIsAuthorized(ply) and ply.EZarmor and ply.EZarmor.effects.teamComms)) then
				net.Start("JMod_EZradio")
				net.WriteBool(true)
				net.WriteBool(true)
				net.WriteString(parrot)
				net.WriteEntity(self)
				net.Send(ply)
			end
		end
	end

	local MsgLength = string.len(msg)
	for i = 1, math.Round(MsgLength / 15) do
		timer.Simple(i * .75, function() if IsValid(self) and (self:GetState() > 0) then self:EmitSound("/npc/combine_soldier/vo/" .. self.Voices[math.random(1, #self.Voices)], 65, 120) end end)
	end

	timer.Simple(.5, function()
		if SERVER and IsValid(self) then
			for _, ply in ipairs(player.GetAll()) do
				if ply:Alive() and (ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 or (self:UserIsAuthorized(ply) and ply.EZarmor and ply.EZarmor.effects.teamComms)) then
					net.Start("JMod_EZradio")
					net.WriteBool(true)
					net.WriteBool(false)
					net.WriteString(msg)
					net.WriteEntity(self)
					net.Send(ply)
				end
			end
		end
	end)
end

function SWEP:TurnOn(activator)
	self:SetState(STATE_CONNECTING)
	self:GetOwner():EmitSound("snds_jack_gmod/ezsentry_startup.ogg", 50, 100)
	self.ConnectionAttempts = 0
	self:SetHoldType("slam")
end

function SWEP:TurnOff()
	local State = self:GetState()
	if State == STATE_OFF then return end
	self:SetState(STATE_OFF)
	self:GetOwner():EmitSound("snds_jack_gmod/ezsentry_shutdown.ogg", 50, 100)
	self:SetHoldType("normal")
end

function SWEP:Connect(ply)
	local Team = 0
	if IsValid(ply) then
		if ply:GetSquadID() == -1 then
            Team = ply:AccountID()
        else
            Team = ply:GetSquadID()
        end
	end

    if ply:GetSquadID() == -1 then
        self:Speak("Невозможно подтвердить вашу личность.")
		self:TurnOff()
        return
    end

	JMod.EZradioEstablish(self, tostring(Team)) -- we store team indices as strings because they might be huge (if it's a player's acct id)
	local OutpostID = self:GetOutpostID()
	local Station = JMod.EZ_RADIO_STATIONS[OutpostID]
	if not Station or Station == nil then
		self:Speak("Не удалось найти свободную станцию, попробуйте еще раз в следующий раз.")
		self:TurnOff()
	end
	self:SetState(Station.state)
	timer.Simple(1, function()
		if IsValid(self) then
			self:Speak("Установлена линия связи с радиостанцией J.I." .. OutpostID)
			self.ConnectionAttempts = 0
		end
	end)
end

function SWEP:CustomDrop(ent)
	if self.RadioOwner then
		ent.RadioOwner = self.RadioOwner
	end

    if IsValid(self.Cable) then
        self.Cable.Drop = true

        --timer.Simple(0, function()
            --if IsValid(self.Cable) then
                self.Cable:Remove()
            --end
        --end)
    end

    if IsValid(self.VisualCable) then
        self.VisualCable:Remove()
    end

    if IsValid(self.RadioOwner) then
        --local spine = self.RadioOwner:LookupBone( "ValveBiped.Bip01_Spine" )
        --local PhysSpine = self.RadioOwner:TranslateBoneToPhysBone( spine )
        
        ent.Cable, ent.VisualCable = constraint.Rope( ent, ent.RadioOwner, 0, 0, Vector(10,0,16), Vector(0,0,50), 120, 10, 1000, 2, "cable/cable2", false)

        ent.VisualCable:SetKeyValue("Slack", "120")

        ent.RadioOwner.RadioCable = ent.Cable
        
        ent.Cable.Ent = ent

        ent.Cable:CallOnRemove( "RemovePhoneCable", function( ent ) 
            if not ent.Pickup then
                if IsValid(ent.Ent.RadioOwner) then
                    ent.Ent.RadioOwner:Give("radiophone")
                    ent.Ent.RadioOwner:SelectWeapon("radiophone")
                    ent.Ent:Remove()
                end
            end
        end)
    end
end

function SWEP:CustomPickup(ent)
    if IsValid(ent.RadioOwner) then
        self.RadioOwner = ent.RadioOwner

        if self.RadioOwner ~= self:GetOwner() then
        
            ent.Cable.Pickup = true

            --[[local matrix = self:GetOwner():GetBoneMatrix(self:GetOwner():LookupBone( "ValveBiped.Bip01_R_Hand" ))
            local pos = matrix:GetTranslation()
            local ang = matrix:GetAngles()
    
            BonePos = self:GetOwner():WorldToLocal( pos ) + Vector(0,0,0)]]
    
            if IsValid(self.Cable) then
                self.Cable:Remove()
            end

            timer.Simple(0.1, function()
            
                self.Cable, self.VisualCable = constraint.Rope( self:GetOwner(), self.RadioOwner, 0, 0, Vector(0,0,50)--[[BonePos]], Vector(0,0,50), 150, 10, 1000, 2, "cable/cable2", false)
                
                self.VisualCable:SetKeyValue("Slack", "80")
                
                self.RadioOwner.RadioCable = self.Cable
            
                self.Cable.RadioOwner = self.RadioOwner
                self.Cable.Owner = self:GetOwner()
                
                --self:GetOwner():SelectWeapon("radiophone")
            
                self.Cable:CallOnRemove( "RemovePhoneCable", function( ent ) 
                    if IsValid(ent.RadioOwner) then
                        if ent.Drop then
                            ent.Owner:StripWeapon("radiophone")
                        else
                            ent.RadioOwner:Give("radiophone")
                            ent.RadioOwner:SelectWeapon("radiophone")
                        
                            ent.Owner:StripWeapon("radiophone")
                        end
                    end 
                end)
            end)
        end
    end
end

SWEP.DownAmt = 0

function SWEP:Initialize()
    self:SetHoldType("slam")
    self.DownAmt = 20

    local Path = "/npc/combine_soldier/vo/"
	local Files, Folders = file.Find("sound" .. Path .. "*.wav", "GAME")
	self.Voices = Files
	self.NextRealThink = 0
	self.ConnectionlessThinks = 0
	self:SetState(STATE_OFF)
	self:SetHoldType("normal")
	self.NextIdle = 0
end

function SWEP:Equip( NewOwner )
    if not self.RadioOwner then
        self.RadioOwner = NewOwner
    end

    --print(self.RadioOwner:Nick())
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime()+1)

    self.DownAmt = 20

    if self:GetState() == STATE_OFF then self:TurnOn() end

    if SERVER then
        timer.Simple(0.1, function()
            if IsValid(self.RadioOwner) then
                if self.RadioOwner == self:GetOwner() then
    
                    if IsValid(self.VisualCable) then
                        self.VisualCable:Remove()
                    end
    
                    self.VisualCable = constraint.CreateKeyframeRope( self:GetOwner():GetPos(), 2, "cable/cable2", nil, self:GetOwner(), Vector(0,0,0), 0, self:GetOwner(), Vector(0,0,0), 0, nil )
                    self.VisualCable:SetKeyValue("Slack", "150")
                end
            end
        end)
    end

    return true
end

function SWEP:Holster()
    if SERVER then
        if IsValid(self.Cable) then
            self.Cable:Remove()
        end

        if IsValid(self.VisualCable) then
            self.VisualCable:Remove()
        end

        if self.RadioOwner ~= self:GetOwner() then
            self:GetOwner():StripWeapon("radiophone")
        end

        self:TurnOff()
    end

    return true
end

function SWEP:Think()
    local State, Time = self:GetState(), CurTime()

    if SERVER then
        if self.NextRealThink < Time then
            self.NextRealThink = Time + 4

	    	if State == STATE_CONNECTING then
	    		self:Speak("Передача принята, устанавливается линия связи...")
	    		self:Connect(self:GetOwner())
	    		self.ConnectionAttempts = self.ConnectionAttempts + 1
	    		if self.ConnectionAttempts >= 2 then
	    			timer.Simple(1, function()
	    				if IsValid(self) then
	    					self:TurnOff()
	    					self.ConnectionAttempts = 0
	    				end
	    			end)
	    		end
	    	elseif State > 0 then
	    		self.ConnectionlessThinks = 0
	    	end
	    end
    end

    if self:GetOwner():KeyDown(IN_SPEED) then
        self:SetHoldType("normal")
    else
        self:SetHoldType("slam")
    end

    if IsValid(self.VisualCable) then
        --if self.RadioOwner == self:GetOwner() then
            local matrix = self.RadioOwner:GetBoneMatrix(self.RadioOwner:LookupBone( "ValveBiped.Bip01_Spine" ))
            local ang = matrix:GetAngles()
            --ang.p = 0
            local SpinePos = matrix:GetTranslation() + ang:Right() * 10 + ang:Forward() * 2 + ang:Up() * -5

            local LocalSpinePos = WorldToLocal( SpinePos , Angle(0,0,0), self.RadioOwner:GetPos(), Angle(0,0,0) )

            local matrix = self:GetOwner():GetBoneMatrix(self:GetOwner():LookupBone( "ValveBiped.Bip01_R_Hand" )) 
            local ang = matrix:GetAngles()
            --ang.p = 0
            local HandPos = matrix:GetTranslation() + ang:Right() * 3 + ang:Forward() * 3 + ang:Up() * 4
    

            local LocalHandPos = WorldToLocal( HandPos, Angle(0,0,0), self:GetOwner():GetPos(), Angle(0,0,0) ) + Vector(0,0,0)

            --[[PrintTable(self.VisualCable:GetKeyValues())
            print("----------------")]]

            self.VisualCable:SetKeyValue("StartOffset", tostring(LocalHandPos))
            self.VisualCable:SetKeyValue("EndOffset", tostring(LocalSpinePos))
            

            debugoverlay.Axis(HandPos, Angle(0,0,0), 2, 0.1, true)
            debugoverlay.Axis(SpinePos, Angle(0,0,0), 2, 0.1, true)
        --end
    end
end

function SWEP:UserIsAuthorized(ply)
	if not ply then return false end
	if not ply:IsPlayer() then return false end
	if self:GetOwner() and (ply == self:GetOwner()) then return true end
	local Allies = (self:GetOwner() and self:GetOwner().JModFriends) or {}
	if table.HasValue(Allies, ply) then return true end
    if ply:GetSquadID() ~= -1 then return true end
	return false
end

function SWEP:EZreceiveSpeech(ply, txt)
	local State = self:GetState()
	if State < 2 then return end
	if not self:UserIsAuthorized(ply) then return end
	txt = string.lower(txt)
	local NormalReq, BFFreq = string.sub(txt, 1, 14) == "supply radio: ", string.sub(txt, 1, 6) == "heyo: "
	if NormalReq or BFFreq then
		local Name, ParrotPhrase = string.sub(txt, 15), txt
		if BFFreq then Name = string.sub(txt, 7) end
		if Name == "help" then
			if State == 2 then
				local Msg, Num = 'stand near radio and say in chat "supply radio: status", or "supply radio: [package]". available packages are:', 1
				self:Speak(Msg, ParrotPhrase)
				local str = ""
				for name, items in pairs(JMod.Config.RadioSpecs.AvailablePackages) do
					str = str .. name
					if Num > 0 and Num % 10 == 0 then
						local newStr = str
						timer.Simple(Num / 10, function() if IsValid(self) then self:Speak(newStr) end end)
						str = ""
					else
						str = str .. ", "
					end

					Num = Num + 1
				end

				timer.Simple(Num / 10, function() if IsValid(self) then self:Speak(str) end end)
				JMod.Hint(self:GetOwner(), "aid package")
				return true
			end
		elseif Name == "status" then
			self:Speak(JMod.EZradioStatus(self, self:GetOutpostID(), ply, BFFreq), ParrotPhrase)
			return true
		elseif JMod.Config.RadioSpecs.AvailablePackages[Name] then
			self:Speak(JMod.EZradioRequest(self, self:GetOutpostID(), ply, Name, BFFreq), ParrotPhrase)
			return true
		end
	end
	return false
end

function SWEP:GetViewModelPosition(pos, ang)
    if not self.DownAmt then self.DownAmt = 0 end

    if self:GetOwner():KeyDown(IN_SPEED) then
        self.DownAmt = Lerp(FrameTime() * 2, self.DownAmt, 5)
    else
        self.DownAmt = Lerp(FrameTime() * 2, self.DownAmt, 0)
    end


	pos = pos - ang:Up() * (self.DownAmt + 17) + ang:Forward() * 25 + ang:Right() * 2
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Right(), -5)
    ang:RotateAroundAxis(ang:Forward(), 30)

    return pos,ang
end

if SERVER then return end

local StateMsgs = {
    [STATE_OFF] = "Off",
    [STATE_CONNECTING] = "Connecting...",
    [JMod.EZ_STATION_STATE_READY] = "Ready",
    [JMod.EZ_STATION_STATE_DELIVERING] = "Delivering",
    [JMod.EZ_STATION_STATE_BUSY] = "Busy"
}

local clr_hint1, clr_hint2, clr_hint3 = Color(255, 255, 255, 200), Color(255, 255, 255, 50), Color(0, 0, 0, 50)
function SWEP:DrawHUD()
    local W, H = ScrW(), ScrH()
    draw.SimpleTextOutlined("Status: " .. StateMsgs[self:GetState()], "Trebuchet24", W * .4, H * .7 + 30, clr_hint1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, clr_hint3)
    --draw.SimpleTextOutlined("Backspace: drop", "Trebuchet24", W * .4, H * .7 + 60, clr_hint2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, clr_hint3)
end

function SWEP:PrimaryAttack()
    return
end

local offsetVec = Vector(3, -11, 17)
local offsetAng = Angle(-180,-90, 0)

SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 11
SWEP.dwmUp = 18

SWEP.dwmAUp = -90
SWEP.dwmARight = 180
SWEP.dwmAForward = 0

SWEP.model = ClientsideModel(SWEP.WorldModel,RENDER_GROUP_OPAQUE_ENTITY)

function SWEP:DrawWorldModel()
    GDrawWorldModel = self.model
    self.model:SetNoDraw(true)

    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:DrawModel()

        return
    end

    local Pos,Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
    if not Pos then return end

    self.model:SetModel(self.WorldModel)
    
    Pos:Add(Ang:Forward() * self.dwmForward)
    Pos:Add(Ang:Right() * self.dwmRight)
    Pos:Add(Ang:Up() * self.dwmUp)

    self.model:SetPos(Pos)

    Ang:RotateAroundAxis(Ang:Up(),self.dwmAUp)
    Ang:RotateAroundAxis(Ang:Right(),self.dwmARight)
    Ang:RotateAroundAxis(Ang:Forward(),self.dwmAForward)
    self.model:SetAngles(Ang)

    self.model:SetModelScale(self.dwmModeScale)

    local isFocus = self:GetNWBool("Focus")

    if not isFocus or not firstPerson then
        self.model:DrawModel()
	end
end


