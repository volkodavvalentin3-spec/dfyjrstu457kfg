SquadMenu = SquadMenu or {}

if CLIENT then
    -- Settings file
    SquadMenu.DATA_FILE = "squad_menu.json"
end

-- Chat prefixes that allow messaging squad members only
SquadMenu.CHAT_PREFIXES = { "/s", "!s", "/p", "!pchat" }

-- Primary color used for the UI theme
SquadMenu.THEME_COLOR = Color( 34, 52, 142 )

-- Max. length of a squad name
SquadMenu.MAX_NAME_LENGTH = 30

-- Size limit for JSON data
SquadMenu.MAX_JSON_SIZE = 49152 -- 48 kibibytes

-- Used on net.WriteUInt for the command ID
SquadMenu.COMMAND_SIZE = 4

-- Command IDs (Max. ID when COMMAND_SIZE = 4 is 15)
SquadMenu.BROADCAST_EVENT = 0
SquadMenu.SQUAD_LIST = 1
SquadMenu.SETUP_SQUAD = 2
SquadMenu.JOIN_SQUAD = 3
SquadMenu.LEAVE_SQUAD = 4
SquadMenu.ACCEPT_REQUESTS = 5
SquadMenu.REQUESTS_LIST = 6
SquadMenu.KICK = 7
SquadMenu.SQUAD_FRIENDS_REQUEST = 8
SquadMenu.SQUAD_FRIENDS_ANSWER = 9
SquadMenu.SQUAD_WAR = 10
SquadMenu.SQUAD_HEALTH = 11
SquadMenu.SQUAD_MONEY = 12
SquadMenu.SETLEADER = 13
SquadMenu.SQUAD_ENDWAR_REQUEST = 14
SquadMenu.SQUAD_ENDWAR_ANSWER = 15
--SquadMenu.SQUAD_PACTNOWAR_REQUEST = 16
--SquadMenu.SQUAD_PACTNOWAR_ANSWER = 17

-- Reasons given when a member is removed from a squad
SquadMenu.LEAVE_REASON_DELETED = 0
SquadMenu.LEAVE_REASON_LEFT = 1
SquadMenu.LEAVE_REASON_KICKED = 2
SquadMenu.LEAVE_REASON_DISCONNECT = 3

-- Server settings
CreateConVar(
    "squad_max_members",
    "10",
    FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY,
    "Limits how many members a single squad can have.",
    1, 100
)

CreateConVar(
    "squad_members_position",
    "6",
    FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY,
    "Sets the position of the squad members on the screen. Takes numbers betweek 1-9 and uses the same positions as a numpad.",
    1, 9
)

CreateConVar(
    "squad_broadcast_creation_message",
    "1",
    FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY,
    "When set to 1, Squad Menu will print when a new squad is created on the chat.",
    0, 1
)

function SquadMenu.PrintF( str, ... )
    MsgC( SquadMenu.THEME_COLOR, "[Squad Menu] ", Color( 255, 255, 255 ), string.format( str, ... ), "\n" )
end

function SquadMenu.TableToJSON( t )
    return util.TableToJSON( t, false )
end

function SquadMenu.JSONToTable( s )
    if type( s ) ~= "string" or s == "" then
        return {}
    end

    return util.JSONToTable( s ) or {}
end

function SquadMenu.GetMemberLimit()
    local cvar = GetConVar( "squad_max_members" )
    return cvar and cvar:GetInt() or 10
end

function SquadMenu.GetMembersPosition()
    local cvar = GetConVar( "squad_members_position" )
    return cvar and cvar:GetInt() or 6
end

function SquadMenu.GetShowCreationMessage()
    local cvar = GetConVar( "squad_broadcast_creation_message" )
    return cvar and cvar:GetInt() or 1
end

function SquadMenu.GetPlayerId( ply )
    if ply:IsBot() then
        return "BOT_" .. ply:AccountID()
    end

    return ply:SteamID()
end

local PID = SquadMenu.GetPlayerId

function SquadMenu.AllPlayersById()
    local all = player.GetAll()
    local byId = {}

    for _, ply in ipairs( all ) do
        byId[PID( ply )] = ply
    end

    return byId
end

function SquadMenu.FindPlayerById( id )
    local all = player.GetAll()

    for _, ply in ipairs( all ) do
        if id == PID( ply ) then return ply end
    end
end

function SquadMenu.ValidateNumber( n, default, min, max )
    return math.Clamp( tonumber( n ) or default, min, max )
end

function SquadMenu.ValidateString( s, default, maxLength )
    if type( s ) ~= "string" then
        return default
    end

    s = string.Trim( s )

    if s == "" then
        return default
    end

    if s:len() > maxLength then
        return string.Left( s, maxLength - 3 ) .. "..."
    end

    return s
end

function SquadMenu.StartCommand( id )
    net.Start( "squad_menu.command", false )
    net.WriteUInt( id, SquadMenu.COMMAND_SIZE )
end

function SquadMenu.WriteTable( t )
    local data = util.Compress( SquadMenu.TableToJSON( t ) )
    local bytes = #data

    net.WriteUInt( bytes, 16 )

    if bytes > SquadMenu.MAX_JSON_SIZE then
        SquadMenu.PrintF( "Tried to write JSON that was too big! (%d/%d)", bytes, SquadMenu.MAX_JSON_SIZE )
        return
    end

    net.WriteData( data )
end

function SquadMenu.ReadTable()
    local bytes = net.ReadUInt( 16 )

    if bytes > SquadMenu.MAX_JSON_SIZE then
        SquadMenu.PrintF( "Tried to read JSON that was too big! (%d/%d)", bytes, SquadMenu.MAX_JSON_SIZE )
        return {}
    end

    local data = net.ReadData( bytes )
    return SquadMenu.JSONToTable( util.Decompress( data ) )
end

if SERVER then
    -- Shared files
    include( "squad_menu/player.lua" )
    AddCSLuaFile( "squad_menu/player.lua" )

    -- Server files
    include( "squad_menu/server/main.lua" )
    include( "squad_menu/server/squad.lua" )
    include( "squad_menu/server/network.lua" )

    -- Client files
    AddCSLuaFile( "includes/modules/styled_theme_utils.lua" )

    AddCSLuaFile( "squad_menu/client/main.lua" )
    AddCSLuaFile( "squad_menu/client/config.lua" )
    AddCSLuaFile( "squad_menu/client/menu.lua" )
    AddCSLuaFile( "squad_menu/client/hud.lua" )

    AddCSLuaFile( "squad_menu/client/vgui/member_status.lua" )
    AddCSLuaFile( "squad_menu/client/vgui/squad_line.lua" )
    AddCSLuaFile( "squad_menu/client/vgui/tabbed_frame.lua" )
end

if CLIENT then
    -- Shared files
    include( "squad_menu/player.lua" )

    -- Client files
    require( "styled_theme_utils" )

    SquadMenu.Theme = STheme.New( {
        frameTitleBar = SquadMenu.THEME_COLOR,
        buttonPress = SquadMenu.THEME_COLOR,
        entryHighlight = SquadMenu.THEME_COLOR,
    } )

    function SquadMenu.ApplyTheme( panel, forceClass )
        STheme.Apply( SquadMenu.Theme, panel, forceClass )
    end

    include( "squad_menu/client/main.lua" )
    include( "squad_menu/client/config.lua" )
    include( "squad_menu/client/menu.lua" )
    include( "squad_menu/client/hud.lua" )

    include( "squad_menu/client/vgui/member_status.lua" )
    include( "squad_menu/client/vgui/squad_line.lua" )
    include( "squad_menu/client/vgui/tabbed_frame.lua" )

    ---Authors: sekta, maksum, RusLanConnection
    ---@param render_target ITexture
    ---@param squad_color Color
    ---@param squad_icon IMaterial
    function FlagMaker(render_target, squad_color, squad_icon)
    	render.PushRenderTarget(render_target)
    	render.Clear( 255, 255, 255, 255, true, true )

    	cam.Start2D()

    	local w, h = ScrW(), ScrH()
    	local isize = math.floor(math.min(w / 2, h / 2))

    	surface.SetDrawColor(squad_color.r, squad_color.g, squad_color.b, 255)
    	surface.DrawRect(0, 0, w, h)

    	surface.SetDrawColor(color_white)
    	surface.SetMaterial(squad_icon)
    	surface.DrawTexturedRect((w / 2) - (isize / 2), (h / 2) - (isize / 2), isize, isize)

    	cam.End2D()
    	render.PopRenderTarget()
    end

    CONST_MAX_RENDER_TARGETS = 20
    local RT_Pull = {}
    local RT_Free = {}
    local RT_PREFIX = "FLAG_RT1_"
    local RT_WIDTH = 256
    local RT_HEIGHT = 128

    ---Если есть какой нибудь свободный RenderTarget, то возвращает его, иначе создаёт новый
    function MakeRT()
    	if #RT_Free >= 1 and #RT_Pull > CONST_MAX_RENDER_TARGETS then
    		local free_rt = RT_Free[#RT_Free]
    		free_rt.IsFree = false
    		table.remove(RT_Free, #RT_Free)
    		return free_rt
    	end

    	local uid = #RT_Pull + 1
    	local rt = GetRenderTarget(RT_PREFIX .. uid, RT_WIDTH, RT_HEIGHT)

    	local name = "FlagMat_" .. uid

    	local mat = CreateMaterial(name, "VertexLitGeneric", {
    		["$basetexture"] = rt:GetName(),
    		["$nocull"] = 1,
    		["$halflambert"] = 1,
    		["$detail"] = "models/jmod_construction/flag01",
    		["$detailscale"] = 1,
    		["$detailblendmode"] = 8
    	})

    	RT_Pull[uid] = {
    		UID = uid,
    		RenderTarget = rt,
    		IsFree = false,
    		MatName = name,
    		Mat = mat
    	}
    	return RT_Pull[uid]
    end

    ---"Освобождает" RenderTarget по UID, его можно будет заново использовать через MakeRT
    function FreeRT(uid)
    	local obj = RT_Pull[uid]
    	if not (obj and not RT_Pull[uid].IsFree) then return end
    	obj.IsFree = true
    	table.insert(RT_Free, obj)
    end
end