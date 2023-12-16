-- v3.04 --
--I don't restrict or even encourage players to modify and customize the lua to suit their needs.
--Some of the code I've even commented out to explain what it's for and where the relevant global is located in the decompiled scripts.
--[[
    Usage Policy:
    Allowed:
        Personal use
        Modified personal use
        Secondary distribution after modification

    Prohibited:
        Commercial use
        Secondary distribution after modification still using the name "sch"

    No guarantees (I can only guarantee no subjective malice at the time of writing, and I am not responsible for any unforeseen consequences).

    Also, please ensure that you download Lua scripts with the small assistant's download Lua script function or files released by yeahsch (sch) in the small assistant's official Discord. Lua scripts obtained in any other way may be outdated or malicious.

    Github: https://github.com/sch-lda/SCH-LUA-YIMMENU

    External Links:
    Yimmenu lib By Discord@alice2333 (zh_CN) - https://discord.com/channels/388227343862464513/1124473215436214372, providing support for developers
    GTA5OnlineTools Lua repo (zh_CN) - https://github.com/CrazyZhang666/GTA5OnlineTools
    Yimmenu official Lua repo (EN) https://github.com/YimMenu-Lua

    Globals and Locals used in Lua are widely copied from UnknownCheats forum, Heist Control script, and MusinessBanager script. Although Blue-Flag' Kiddion Lua is somewhat outdated, it also provides some inspiration.
    [Alice, nord123, rostal315 and wangzixuan in GTA5OnlineTools (zh_CN) official Discord server] & [gir489returns, tupoy-ya and xiaoxiao921 on Github] provided assistance in Lua writing.

Sites that may be helpful for lua writing
    1.Yimmenu Lua API https://github.com/YimMenu/YimMenu/tree/master/docs/lua
    2.GTA5 Native Reference https://nativedb.dotindustries.dev/natives
    3.GTA5 Decompile Script https://github.com/Primexz/GTAV-Decompiled-Scripts
    4.PlebMaster (fast search model hash) https://forge.plebmasters.de
    5.gta-v-data-dumps (Check ptfx/sound/model/action, provide preview) https://github.com/DurtyFree/gta-v-data-dumps
    6.FiveM Native Reference https://docs.fivem.net/docs/

Multi-language maintainer.
Simplified Chinese:sch https://github.com/sch-lda
English:Drsexo https://github.com/Drsexo
    Websites that may be helpful for Lua writing:
    1. Yimmenu Lua API - https://github.com/YimMenu/YimMenu/tree/master/docs/lua
    2. GTA5 Native Reference (Native functions) - https://nativedb.dotindustries.dev/natives
    3. GTA5 Decompiled Scripts - https://github.com/Primexz/GTAV-Decompiled-Scripts
    4. PlebMaster (GTA5 data search & preview) - https://forge.plebmasters.de
    5. gta-v-data-dumps (Lookup PTFX/sounds/models) - https://github.com/DurtyFree/gta-v-data-dumps
    6. FiveM Native Reference - https://docs.fivem.net/docs/
]]

luaversion = "v3.04"
path = package.path
if path:match("YimMenu") then
    log.info("sch-lua "..luaversion.." For personal testing and learning only, commercial use is prohibited")
else
    local_()
end

is_money = 0
is_GK = 0
is_collection1 = 0
verchka1 = 0 
verchkok = 2 --版本检查状态 0:不支持 1:支持 2:未检查
suppver = "1.68" --支持的游戏版本
autoresply = 0
devmode = 0 --0:禁用某些调试功能 1:启用某些调试功能

gentab = gui.add_tab("sch-lua-Alpha-"..luaversion)
local LuaTablesTab = gentab:add_tab("++ Table")

local EntityTab = LuaTablesTab:add_tab("+Game entity list")

local PlayerTableTab = EntityTab:add_tab("-Player table")
PlayerTableTab:add_button("Generate the player list", function()
    writeplayertable()
end)
PlayerTableTab:add_text("The player list is for the player's aiming response service")
local NPCTableTab = EntityTab:add_tab("-NPC list")
NPCTableTab:add_button("Generate the NPC list", function()
    writepedtable()
end)
local VehicleTableTab = EntityTab:add_tab("-Vehicle list")
VehicleTableTab:add_button("Generate a list of vehicles", function()
    writevehtable()
end)
local ObjTableTab = EntityTab:add_tab("-Object List")
ObjTableTab:add_button("Generate a list of objects", function()
    writeobjtable()
end)

local LuaownedTab = LuaTablesTab:add_tab("+Lua internal list")
local HeliTableTab = LuaownedTab:add_tab("-Bodyguard helicopter list")
local NPCguardTableTab = LuaownedTab:add_tab("-Bodyguard NPC list")

HeliTableTab:add_button("Generate a bodyguard helicopter list", function()
    writebodyguardhelitable()
end)
NPCguardTableTab:add_button("Generate the bodyguard NPC list", function()
    writebodyguardtable()
end)

--------------------------------------------------------------------------------------- Imgui Test
--[[
testwindow = gui.add_imgui(function()
    if ImGui.Begin("IMGUITEST") then
        if ImGui.Button("paused") then
            script.run_in_fiber(function(newimgui)
                MISC.SET_GAME_PAUSED(true)
            end)
        end
        if ImGui.Button("resume") then
            script.run_in_fiber(function(newimgui2)
                MISC.SET_GAME_PAUSED(false)
            end)
        end
        ImGui.End()
    end
end)
]]
--------------------------------------------------------------------------------------- Imgui Test
--------------------------------------------------------------------------------------- functions 供lua调用的用于实现特定功能的函数

function globals_set_int(intglobal, intval) --当游戏版本不受支持时拒绝修改globals避免损坏线上存档
    if verchkok == 2 then
        log.info("正在检查sch-lua是否支持当前游戏版本")
        if NETWORK.GET_ONLINE_VERSION() == suppver then
            verchka1 = 100
            verchkok = 1
            log.info("通过检测")
        end
    end
    if verchkok == 1 then
        globals.set_int(intglobal, intval)
    else
        log.warning("游戏版本不受支持,为了您的线上存档安全,已停止数据修改")
    end
end

function globals_set_float(floatglobal, floatval) --当游戏版本不受支持时拒绝修改globals避免损坏线上存档
    if verchkok == 2 then
        log.info("正在检查sch-lua是否支持当前游戏版本")
        if NETWORK.GET_ONLINE_VERSION() == suppver then
            verchka1 = 100
            verchkok = 1
            log.info("通过检测")
        end
    end
    if verchkok == 1 then
        globals.set_float(floatglobal, floatval)
    else
        log.warning("游戏版本不受支持,为了您的线上存档安全,已停止数据修改")
    end
end

function locals_set_int(scriptname, intlocal, intlocalval) --当游戏版本不受支持时拒绝修改locals避免损坏线上存档
    if verchkok == 2 then
        log.info("正在检查sch-lua是否支持当前游戏版本")
        if NETWORK.GET_ONLINE_VERSION() == suppver then
            verchka1 = 100
            verchkok = 1
            log.info("通过检测")
        end
    end
    if verchkok == 1 then
        locals.set_int(scriptname, intlocal, intlocalval)
    else
        log.warning("游戏版本不受支持,为了您的线上存档安全,已停止数据修改")
    end
end

function packed_stat_set_bool(boolindex, boolval) --当游戏版本不受支持时拒绝修改globals避免损坏线上存档
    if verchkok == 2 then
        log.info("正在检查sch-lua是否支持当前游戏版本")
        if NETWORK.GET_ONLINE_VERSION() == suppver then
            verchka1 = 100
            verchkok = 1
            log.info("通过检测")
        end
    end
    if verchkok == 1 then
        stats.set_packed_stat_bool(boolindex, boolval)
    else
        log.warning("游戏版本不受支持,为了您的线上存档安全,已停止数据修改")
    end
end

function calcDistance(pos, tarpos) -- 计算两个三维坐标之间的距离
    local dx = pos.x - tarpos.x
    local dy = pos.y - tarpos.y
    local dz = pos.z - tarpos.z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    return distance
end

function get_closest_veh(entity) -- 获取最近的载具
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    local vehicles = entities.get_all_vehicles_as_handles()
    local closestdist = 1000000
    local closestveh = 0
    for k, veh in pairs(vehicles) do
        if veh ~= PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false) and ENTITY.GET_ENTITY_HEALTH(veh) ~= 0 then
            local vehcoord = ENTITY.GET_ENTITY_COORDS(veh, true)
            local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(coords['x'], coords['y'], coords['z'], vehcoord['x'], vehcoord['y'], vehcoord['z'], true)
            if dist < closestdist then
                closestdist = dist
                closestveh = veh
            end
        end
    end
    return closestveh
end

function upgrade_vehicle(vehicle)
    for i = 0, 49 do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
    end
end

function run_script(scriptName, stackSize) --启动脚本线程
    script.run_in_fiber(function (runscript)
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(MISC.GET_HASH_KEY(scriptName)) >= 1 then
        gui.show_error("Warning","Do not start script threads repeatedly!")
        else
        SCRIPT.REQUEST_SCRIPT(scriptName)
        repeat runscript:yield() until SCRIPT.HAS_SCRIPT_LOADED(scriptName)
        SYSTEM.START_NEW_SCRIPT(scriptName, stackSize)
        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(scriptName)
        end
    end)
end

function screen_draw_text(text, x, y, p0 , size) --在屏幕上绘制文字
	HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING") --The following were found in the decompiled script files: STRING, TWOSTRINGS, NUMBER, PERCENTAGE, FO_TWO_NUM, ESMINDOLLA, ESDOLLA, MTPHPER_XPNO, AHD_DIST, CMOD_STAT_0, CMOD_STAT_1, CMOD_STAT_2, CMOD_STAT_3, DFLT_MNU_OPT, F3A_TRAFDEST, ES_HELP_SOC3
	HUD.SET_TEXT_FONT(0)
	HUD.SET_TEXT_SCALE(p0, size) --Size range : 0F to 1.0F --p0 is unknown and doesn't seem to have an effect, yet in the game scripts it changes to 1.0F sometimes.
	HUD.SET_TEXT_DROP_SHADOW()
	HUD.SET_TEXT_WRAP(0.0, 1.0) --限定行宽，超出自动换行 start - left boundry on screen position (0.0 - 1.0)  end - right boundry on screen position (0.0 - 1.0)
	HUD.SET_TEXT_DROPSHADOW(1, 0, 0, 0, 0) --distance - shadow distance in pixels, both horizontal and vertical    -- r, g, b, a - color
	HUD.SET_TEXT_OUTLINE()
	HUD.SET_TEXT_EDGE(1, 0, 0, 0, 0)
	HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
	HUD.END_TEXT_COMMAND_DISPLAY_TEXT(x, y, 0) --占坐标轴的比例
end

function CreatePed(index, Hash, Pos, Heading)
    script.run_in_fiber(function (ctped)
    STREAMING.REQUEST_MODEL(Hash)
    while not STREAMING.HAS_MODEL_LOADED(Hash) do ctped:yield() end
    local Spawnedp = PED.CREATE_PED(index, Hash, Pos.x, Pos.y, Pos.z, Heading, true, true)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
    return Spawnedp
    end)
end

function create_object(hash, pos)
    script.run_in_fiber(function (ctobjS)
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do ctobjS:yield() end
        local obj = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y, pos.z, true, false, false)
        return obj
    end)
end

function request_model(hash)
    script.run_in_fiber(function (rqmd)
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do
            rqmd:yield()
        end
        return STREAMING.HAS_MODEL_LOADED(hash)
    end)
end

function CreateVehicle(Hash, Pos, Heading, Invincible)
    script.run_in_fiber(function (ctveh)
        STREAMING.REQUEST_MODEL(Hash)
        while not STREAMING.HAS_MODEL_LOADED(Hash) do ctveh:yield() end
        CreateVehicle_rlt = VEHICLE.CREATE_VEHICLE(Hash, Pos.x,Pos.y,Pos.z, Heading , true, true, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
        if Invincible then
            ENTITY.SET_ENTITY_INVINCIBLE(SpawnedVehicle, true)
        end
        return CreateVehicle_rlt
    end)
end

function MCprintspl()
    log.info("假钞 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY0").."%")
    log.info("可卡因 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY1").."%")
    log.info("冰毒 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY2").."%")
    log.info("大麻 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY3").."%")
    log.info("假证 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY4").."%")
    log.info("地堡 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY5").."%")
    log.info("致幻剂 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY6").."%")
end

function delete_entity(ent)  --discord@rostal315
    if ENTITY.DOES_ENTITY_EXIST(ent) then
        ENTITY.DETACH_ENTITY(ent, true, true)
        ENTITY.SET_ENTITY_VISIBLE(ent, false, false)
        NETWORK.NETWORK_SET_ENTITY_ONLY_EXISTS_FOR_PARTICIPANTS(ent, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, 0.0, 0.0, -1000.0, false, false, false)
        ENTITY.SET_ENTITY_COLLISION(ent, false, false)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(ent)
        ENTITY.DELETE_ENTITY(ent)
    end
end

function request_control(entity) --请求控制实体
	if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
		local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
	end
	return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

allbodyguardtable = {} --保镖NPC表

function npc2bodyguard(peds_func) --将NPC设置为自己的保镖
    WEAPON.GIVE_WEAPON_TO_PED(peds_func, joaat("WEAPON_MICROSMG"), 9999, false, true)
    WEAPON.GIVE_WEAPON_TO_PED(peds_func, joaat("WEAPON_CARBINERIFLE_MK2"), 9999, false, true)
    PED.SET_PED_AS_GROUP_MEMBER(peds_func, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
    PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds_func, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
    PED.SET_PED_NEVER_LEAVES_GROUP(peds_func, true)
    PED.SET_CAN_ATTACK_FRIENDLY(peds_func, false, true)
    PED.SET_PED_COMBAT_ABILITY(peds_func, 2)
    PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds_func, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
    PED.SET_PED_FLEE_ATTRIBUTES(peds_func, 512, true)
    PED.SET_PED_FLEE_ATTRIBUTES(peds_func, 1024, true)
    PED.SET_PED_FLEE_ATTRIBUTES(peds_func, 2048, true)
    PED.SET_PED_FLEE_ATTRIBUTES(peds_func, 16384, true)
    PED.SET_PED_FLEE_ATTRIBUTES(peds_func, 131072, true)
    PED.SET_PED_FLEE_ATTRIBUTES(peds_func, 262144, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 5, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 13, true)
    PED.SET_PED_CONFIG_FLAG(peds_func, 394, true)
    PED.SET_PED_CONFIG_FLAG(peds_func, 400, true)
    PED.SET_PED_CONFIG_FLAG(peds_func, 134, true)
    if peds then
        PED.SET_PED_SHOOT_RATE(peds, 1000)
    end
    PED.SET_PED_ACCURACY(peds_func,100)
    TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds_func, 100, 67108864)
    ENTITY.SET_ENTITY_HEALTH(peds_func,1000,0,0)
    HUD.SET_PED_HAS_AI_BLIP_WITH_COLOUR(peds_func, true, 3)
    HUD.SET_PED_AI_BLIP_SPRITE(peds_func, 270)
    table.insert(allbodyguardtable,peds_func)            
end

function writebodyguardtable()
    NPCguardTableTab:clear()
    NPCguardTableTab:add_button("Refresh Bodyguard NPC List", function()
        writebodyguardtable()
    end)
    NPCguardTableTab:add_sameline()
    NPCguardTableTab:add_button("Empty the bodyguard NPC list", function()
        allbodyguardtable = {}
    end)
    local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

    local npcguard_list_index = 1
    for _, guard_ped_id in pairs(allbodyguardtable) do
        NPCguardTableTab:add_text(guard_ped_id)
        NPCguardTableTab:add_sameline()
        local ped_pos = ENTITY.GET_ENTITY_COORDS(guard_ped_id, true)
        local npcdist = calcDistance(selfpos,ped_pos)
        formattednpcDistance = string.format("%.1f", npcdist)
        local npc_t_health = ENTITY.GET_ENTITY_HEALTH(guard_ped_id)
        NPCguardTableTab:add_text(guard_ped_id.." distance: "..formattednpcDistance.." HP: "..npc_t_health)
        NPCguardTableTab:add_sameline()
        NPCguardTableTab:add_button("Teleport to "..npcguard_list_index, function()
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), ENTITY.GET_ENTITY_COORDS(guard_ped_id, true).x, ENTITY.GET_ENTITY_COORDS(guard_ped_id, true).y, ENTITY.GET_ENTITY_COORDS(guard_ped_id, true).z)
        end)
        NPCguardTableTab:add_sameline()
        NPCguardTableTab:add_button("Delete "..npcguard_list_index, function()
            request_control(guard_ped_id)
            delete_entity(guard_ped_id)        
        end)
        NPCguardTableTab:add_sameline()
        NPCguardTableTab:add_button("Heal "..npcguard_list_index, function()
            request_control(guard_ped_id)
            ENTITY.SET_ENTITY_HEALTH(guard_ped_id,1000,0,0)
        end)
        NPCguardTableTab:add_sameline()
        NPCguardTableTab:add_button("Clone "..npcguard_list_index, function()
            request_control(guard_ped_id)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(guard_ped_id, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true).z, false, false, false)
        end)
        npcguard_list_index = npcguard_list_index + 1
    end
end

function writebodyguardhelitable()
    HeliTableTab:clear()
    HeliTableTab:add_button("Refresh Bodyguard Helicopter list", function()
        writebodyguardhelitable()
    end)
    HeliTableTab:add_sameline()
    HeliTableTab:add_button("Empty Bodyguard Helicopter list", function()
        heli_sp_table = {}
    end)
    local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    local npcguardheli_list_index = 1
    for _, guard_veh_hd in pairs(heli_sp_table) do
        HeliTableTab:add_text(guard_veh_hd)
        HeliTableTab:add_sameline()
        local heli_pos = ENTITY.GET_ENTITY_COORDS(guard_veh_hd, true)
        local npcdist = calcDistance(selfpos,heli_pos)
        formattednpcDistance = string.format("%.1f", npcdist)
        HeliTableTab:add_text(guard_veh_hd.." distance: "..formattednpcDistance)
        HeliTableTab:add_sameline()
        HeliTableTab:add_button("Teleport to "..npcguardheli_list_index, function()
            if not VEHICLE.IS_VEHICLE_SEAT_FREE(guarddrvped, -1, 0) then
                guarddrvped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(guard_veh_hd, -1, false)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(guarddrvped)    
            end
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), guard_veh_hd, -1)
        end)
        HeliTableTab:add_sameline()
        HeliTableTab:add_button("Delete "..npcguardheli_list_index, function()
            request_control(guard_veh_hd)
            delete_entity(guard_veh_hd)        
        end)
        HeliTableTab:add_sameline()
        HeliTableTab:add_button("Clone "..npcguardheli_list_index, function()
            request_control(guard_veh_hd)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(guard_veh_hd, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true).z + 20, false, false, false)
        end)
        npcguardheli_list_index = npcguardheli_list_index + 1
    end
end

function createplayertable()  --获取当前玩家表，由于yimmenu没有像stand那样的API，只能自己模仿一个，这是玩家瞄准自动反击的基础
    player_Index_table = {}
    for i = 0, 32 do
        if PLAYER.GET_PLAYER_PED(i) ~= 0 then
            table.insert(player_Index_table,i)            
        end
    end
end

function writeplayertable() 
    PlayerTableTab:clear()
    PlayerTableTab:add_button("Refresh Player list", function()
        writeplayertable()
    end)
    PlayerTableTab:add_text("The player list is for the players reaction")

    createplayertable()
    for _, sg_player_id in pairs(player_Index_table) do
        PlayerTableTab:add_text(sg_player_id.." "..PLAYER.GET_PLAYER_NAME(sg_player_id))
        PlayerTableTab:add_sameline()
        PlayerTableTab:add_button("Place holder"..sg_player_id, function()
        end)
    end
end

function createobjtable()
    obj_handle_table = {}
    local objtable = entities.get_all_objects_as_handles()
    for _, objs in pairs(objtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local obj_pos = ENTITY.GET_ENTITY_COORDS(objs, true)
        if calcDistance(selfpos, obj_pos) <= 200 then 
            table.insert(obj_handle_table,objs)            
        end
    end
end

function writeobjtable()
    ObjTableTab:clear()
    ObjTableTab:add_button("Refresh object list", function()
        writeobjtable()
    end)
    createobjtable()
    local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    local obj_list_index = 1
    for _, obj_id in pairs(obj_handle_table) do
        local obj_pos = ENTITY.GET_ENTITY_COORDS(obj_id, true)
        local objdist = calcDistance(selfpos,obj_pos)
        formattedobjdistance = string.format("%.1f", objdist)
        local objmod = ENTITY.GET_ENTITY_MODEL(obj_id)
        if objmod == 2202227855 then
            ObjTableTab:add_text(obj_id.." Model: "..objmod.." Distance: "..formattedobjdistance.." Special object:ULP_Clear_Fuse")
        else
            ObjTableTab:add_text(obj_id.." Model: "..objmod.." Distance: "..formattedobjdistance)
        end
        ObjTableTab:add_sameline()
        ObjTableTab:add_button("Send"..obj_list_index, function()
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), ENTITY.GET_ENTITY_COORDS(obj_id, true).x, ENTITY.GET_ENTITY_COORDS(obj_id, true).y, ENTITY.GET_ENTITY_COORDS(obj_id, true).z)
        end)
        ObjTableTab:add_sameline()
        ObjTableTab:add_button("Delete"..obj_list_index, function()
            request_control(obj_id)
            delete_entity(obj_id)        
        end)
        obj_list_index = obj_list_index + 1
    end
end

function createpedtable()
    ped_handle_table = {}
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if calcDistance(selfpos, ped_pos) <= 200 and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) == false and ENTITY.GET_ENTITY_HEALTH(peds) > 0 then 
            table.insert(ped_handle_table,peds)            
        end
    end
end

function writepedtable()
    NPCTableTab:clear()
    NPCTableTab:add_button("Refresh NPC List", function()
        writepedtable()
    end)
    createpedtable()
    local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    local ped_list_index = 1
    for _, ped_id in pairs(ped_handle_table) do
        local ped_pos = ENTITY.GET_ENTITY_COORDS(ped_id, true)
        local npcdist = calcDistance(selfpos,ped_pos)
        formattednpcDistance = string.format("%.1f", npcdist)
        local npcblipsprite = HUD.GET_BLIP_SPRITE(HUD.GET_BLIP_FROM_ENTITY(ped_id))
        local npcblipcolor = HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(ped_id))
        local npc_t_health = ENTITY.GET_ENTITY_HEALTH(ped_id)
        NPCTableTab:add_text(ped_id.." Distance: "..formattednpcDistance.." Blip: "..npcblipsprite.." Color: "..npcblipcolor.." HP: "..npc_t_health)
        NPCTableTab:add_sameline()
        NPCTableTab:add_button("Teleport to "..ped_list_index, function()
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), ENTITY.GET_ENTITY_COORDS(ped_id, true).x, ENTITY.GET_ENTITY_COORDS(ped_id, true).y, ENTITY.GET_ENTITY_COORDS(ped_id, true).z)
        end)
        NPCTableTab:add_sameline()
        NPCTableTab:add_button("Delete "..ped_list_index, function()
            request_control(ped_id)
            delete_entity(ped_id)        
        end)
        NPCTableTab:add_sameline()
        NPCTableTab:add_button("Heal "..ped_list_index, function()
            request_control(ped_id)
            ENTITY.SET_ENTITY_HEALTH(ped_id,1000,0,0)
        end)
        ped_list_index = ped_list_index + 1
    end
end

function createvehtable()
    veh_handle_table = {}
    local vehtable = entities.get_all_vehicles_as_handles()
    for _, vehs in pairs(vehtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local veh_pos = ENTITY.GET_ENTITY_COORDS(vehs, true)
        if calcDistance(selfpos, veh_pos) <= npcctrlr:get_value() then 
            table.insert(veh_handle_table,vehs)            
        end
    end
end

function writevehtable()
    VehicleTableTab:clear()
    VehicleTableTab:add_button("Refresh vehicle List", function()
        writevehtable()
    end)
    createvehtable()
    local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    local Veh_list_index = 1
    for _, t_veh_hd in pairs(veh_handle_table) do
        local veh_pos = ENTITY.GET_ENTITY_COORDS(t_veh_hd, true)
        local vehdist = calcDistance(selfpos,veh_pos)
        formattedvehDistance = string.format("%.1f", vehdist)
        local vehblipsprite = HUD.GET_BLIP_SPRITE(HUD.GET_BLIP_FROM_ENTITY(t_veh_hd))
        local vehblipcolor = HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(t_veh_hd))
        local veh_t_health = ENTITY.GET_ENTITY_HEALTH(t_veh_hd)
        local veh_mod_name = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(t_veh_hd))
        local veh_disp_name = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(veh_mod_name)
        VehicleTableTab:add_text("Handle:"..t_veh_hd.." model:"..veh_mod_name.." name:"..veh_disp_name.." distance:"..formattedvehDistance.." Blip:"..vehblipsprite.." Color:"..vehblipcolor.." HP:"..veh_t_health)
        VehicleTableTab:add_sameline()
        VehicleTableTab:add_button("Delete "..Veh_list_index, function()
            request_control(t_veh_hd)
            delete_entity(t_veh_hd)        
        end)
        VehicleTableTab:add_sameline()
        VehicleTableTab:add_button("Teleport into "..Veh_list_index, function()
            request_control(t_veh_hd)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), t_veh_hd, -1)
        end)
        VehicleTableTab:add_sameline()
        VehicleTableTab:add_button("Destroy the engine "..Veh_list_index, function()
            request_control(t_veh_hd)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(t_veh_hd, -4000)
        end)
        VehicleTableTab:add_sameline()
        VehicleTableTab:add_button("Throw "..Veh_list_index, function()
            request_control(t_veh_hd)
            ENTITY.APPLY_FORCE_TO_ENTITY(t_veh_hd, 1, math.random(0, 3), math.random(0, 3), math.random(-10, 10), 0.0, 0.0, 0.0, 0, true, false, true, false, true)
        end)
        Veh_list_index = Veh_list_index + 1
    end
end

plyaimkarma = {}

function Is_Player_Aimming_Me()
    for _, playerPid in pairs(player_Index_table) do
        if PLAYER.IS_PLAYER_TARGETTING_ENTITY(playerPid, PLAYER.PLAYER_PED_ID()) or PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(playerPid, PLAYER.PLAYER_PED_ID()) then
            plyaimkarma = {karmaped = PLAYER.GET_PLAYER_PED(playerPid), karmaplyindex = playerPid}
            return true
        end
    end
    plyaimkarma = nil
    return false
end

--------------------------------------------------------------------------------------- functions 供lua调用的用于实现特定功能的函数


--------------------------------------------------------------------------------------- TEST
--[[
gentab:add_button("test01", function()
    for fm2i=0,60000 do
        rst = locals.get_int("fm_mission_controller_2020", fm2i)
        if rst == 291 then 
            log.info(tostring(fm2i.."  "..rst))
        end
    end
    log.info("done")
end)

gentab:add_button("testmode on", function()
    devmode = 1
    deva1 = 71
    deva2 = 72
    deva3 = 73
    deva4 = 74
end)
gentab:add_sameline()
gentab:add_button("testmode off", function()
    devmode = 0
    deva1 = 71
    deva2 = 72
    deva3 = 73
    deva4 = 74
end)
]]
--------------------------------------------------------------------------------------- TEST

FRDList = {   --友方NPC白名单
--赌场事务
joaat("IG_TaoCheng2"), --陈陶--已验证
joaat("IG_TaosTranslator2"), --陶的翻译员--已验证
joaat("IG_Agatha"), --贝克女士--已验证
joaat("CSB_Vincent_2"), --文森特
joaat("IG_Vincent_2"), --文森特
--别惹德瑞
joaat("IG_Johnny_Guns"), --约翰尼·贡斯
joaat("IG_ARY_02"), --德瑞
--老抢劫
joaat("CSB_Rashcosvki"), --越狱-囚犯
joaat("IG_Rashcosvki"), --越狱-囚犯
joaat("CSB_AviSchwartzman_02"), --阿维
joaat("CSB_AviSchwartzman_03"), --阿维
joaat("IG_AviSchwartzman_02"), --阿维
joaat("IG_AviSchwartzman_03"), --阿维
joaat("CS_LesterCrest"), --莱斯特
joaat("IG_LesterCrest"), --莱斯特
--末日豪劫
joaat("CSB_Bogdan"), --波格丹
--最后一剂
joaat("CSB_Dax"), --达克斯
joaat("IG_Dax"), --达克斯
joaat("CSB_Labrat"), --实验鼠
joaat("IG_Labrat"), --实验鼠
joaat("CSB_Luchadora"), --
joaat("IG_Luchadora"), --
joaat("IG_AcidLabCook"), --穆特
--拉玛和小查
joaat("CS_LamarDavis"), 
joaat("CS_LamarDavis_02"), 
joaat("IG_LamarDavis"), 
joaat("IG_LamarDavis_02"), 
joaat("A_C_Chop"), 
joaat("A_C_Chop_02"), 
}

--------------------------------------------------------------------------------------- Lua管理器页面

gentab:add_text("Minimum resolution required: 1920x1080. To use the player function, select a player in the yim player list and scroll to the bottom of the player page. Players aiming to counterattack from the sub-menu Entity Table Access") 

gentab:add_text("Task function") 

gentab:add_button("Perico/Firm Contract Final Chapter / ULP 1 click Completion", function()
    script.run_in_fiber(function (pericoinstcpl)
        network.force_script_host("fm_mission_controller_2020") --抢脚本主机
        network.force_script_host("fm_mission_controller") --抢脚本主机
        pericoinstcpl:yield()
        local FMMC2020host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller_2020",0,0)
        local FMMChost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller",0,0)
        local time = os.time()
        while PLAYER.PLAYER_ID() ~= FMMC2020host and PLAYER.PLAYER_ID() ~= FMMChost do   --如果判断不是脚本主机则自动抢脚本主机
            if os.time() - time >= 5 then
                break
            end
            network.force_script_host("fm_mission_controller_2020") --抢脚本主机
            network.force_script_host("fm_mission_controller") --抢脚本主机
            local FMMC2020host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller_2020",0,0)
            local FMMChost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller",0,0)    
            log.info("正在抢任务脚本主机以便一键完成...")
            pericoinstcpl:yield()
        end
        if FMMC2020host == PLAYER.PLAYER_ID() or FMMChost == PLAYER.PLAYER_ID() then
            gui.show_message("Has become the script host","Try to complete automatically...")
            locals_set_int("fm_mission_controller_2020",48514,51338752)  --关键代码  --3095
            locals_set_int("fm_mission_controller_2020",50279,100) --关键代码 --3095
            locals_set_int("fm_mission_controller", 19728, 12) --3095
            locals_set_int("fm_mission_controller", 27489 + 859, 99999) --3095
            locals_set_int("fm_mission_controller", 31603 + 69, 99999) --3095
        else
            log.info("失败,未成为脚本主机,队友可能任务立即失败,可能受到其他作弊者干扰.您真的在进行受支持的抢劫任务分红关吗?")
            log.info("已测试支持的任务:佩里科岛/ULP/数据泄露合约(别惹德瑞)")
            gui.show_error("Failed to become a script host","You may not be in a task that supports 1 click completion")
        end
    end)
end)

gentab:add_sameline()

gentab:add_button("Skip cayo perico setup (Panther statue)", function()
    stats.set_int("MPX_H4CNF_TARGET", 5)  --https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    stats.set_int("MPX_H4CNF_BS_GEN", 131071)
    stats.set_int("MPX_H4CNF_BS_ENTR", 63)
    stats.set_int("MPX_H4CNF_APPROACH", -1)
    stats.set_int("MPX_H4CNF_WEAPONS", 1)
    stats.set_int("MPX_H4CNF_WEP_DISRP", 3)
    stats.set_int("MPX_H4CNF_ARM_DISRP", 3)
    stats.set_int("MPX_H4CNF_HEL_DISRP", 3)
    stats.set_int("MPX_H4LOOT_GOLD_C", 255)
    stats.set_int("MPX_H4LOOT_GOLD_C_SCOPED", 255)
    stats.set_int("MPX_H4LOOT_PAINT_SCOPED", 127)
    stats.set_int("MPX_H4LOOT_PAINT", 127)
    stats.set_int("MPX_H4LOOT_GOLD_V", 585151)
    stats.set_int("MPX_H4LOOT_PAINT_V", 438863)
    stats.set_int("MPX_H4_PROGRESS", 124271)
    stats.set_int("MPX_H4_MISSIONS", 65279)
    stats.set_int("MPX_H4LOOT_COKE_I_SCOPED", 16777215)
    stats.set_int("MPX_H4LOOT_COKE_I", 16777215)
    locals.set_int("heist_island_planning", 1544, 2) --3095
end)

gentab:add_sameline()

gentab:add_button("Skip cayo perico setup (pink diamond)", function()
    stats.set_int("MPX_H4CNF_TARGET", 3) --https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    stats.set_int("MPX_H4CNF_BS_GEN", 131071)
    stats.set_int("MPX_H4CNF_BS_ENTR", 63)
    stats.set_int("MPX_H4CNF_APPROACH", -1)
    stats.set_int("MPX_H4CNF_WEAPONS", 1)
    stats.set_int("MPX_H4CNF_WEP_DISRP", 3)
    stats.set_int("MPX_H4CNF_ARM_DISRP", 3)
    stats.set_int("MPX_H4CNF_HEL_DISRP", 3)
    stats.set_int("MPX_H4LOOT_GOLD_C", 255)
    stats.set_int("MPX_H4LOOT_GOLD_C_SCOPED", 255)
    stats.set_int("MPX_H4LOOT_PAINT_SCOPED", 127)
    stats.set_int("MPX_H4LOOT_PAINT", 127)
    stats.set_int("MPX_H4LOOT_GOLD_V", 585151)
    stats.set_int("MPX_H4LOOT_PAINT_V", 438863)
    stats.set_int("MPX_H4_PROGRESS", 124271)
    stats.set_int("MPX_H4_MISSIONS", 65279)
    stats.set_int("MPX_H4LOOT_COKE_I_SCOPED", 16777215)
    stats.set_int("MPX_H4LOOT_COKE_I", 16777215)
    locals.set_int("heist_island_planning", 1544, 2) --3095
end)

gentab:add_sameline()

gentab:add_button("Reset cayo perico", function()
    stats.set_int("MPX_H4CNF_TARGET", 0)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    stats.set_int("MPX_H4CNF_BS_GEN", 0)
    stats.set_int("MPX_H4CNF_BS_ENTR", 0)
    stats.set_int("MPX_H4CNF_APPROACH", 0)
    stats.set_int("MPX_H4CNF_WEAPONS", 0)
    stats.set_int("MPX_H4CNF_WEP_DISRP", 0)
    stats.set_int("MPX_H4CNF_ARM_DISRP", 0)
    stats.set_int("MPX_H4CNF_HEL_DISRP", 0)
    stats.set_int("MPX_H4LOOT_GOLD_C", 0)
    stats.set_int("MPX_H4LOOT_GOLD_C_SCOPED", 0)
    stats.set_int("MPX_H4LOOT_PAINT_SCOPED", 0)
    stats.set_int("MPX_H4LOOT_PAINT", 0)
    stats.set_int("MPX_H4LOOT_GOLD_V", 0)
    stats.set_int("MPX_H4LOOT_PAINT_V", 0)
    stats.set_int("MPX_H4_PROGRESS", 0)
    stats.set_int("MPX_H4_MISSIONS", 0)
    stats.set_int("MPX_H4LOOT_COKE_I_SCOPED", 0)
    stats.set_int("MPX_H4LOOT_COKE_I", 0)
    locals_set_int("heist_island_planning", 1544, 2) --3095
    gui.show_message("Attention","The planning panel will be restored to its initial state after buying the kosatka!")
end)

gentab:add_button("Skip Casino heist prep (diamond)", function()
    stats.set_int("MPX_H3OPT_APPROACH", 2)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    stats.set_int("MPX_H3_LAST_APPROACH", 3)
    stats.set_int("MPX_H3OPT_TARGET", 3) --主目标:钻石
    stats.set_int("MPX_H3OPT_BITSET1", 159)
    stats.set_int("MPX_H3OPT_KEYLEVELS", 2)
    stats.set_int("MPX_H3OPT_DISRUPTSHIP", 3)
    stats.set_int("MPX_H3OPT_CREWWEAP", 1)
    stats.set_int("MPX_H3OPT_CREWDRIVER", 1)
    stats.set_int("MPX_H3OPT_CREWHACKER", 5)
    stats.set_int("MPX_H3OPT_VEHS", 0)
    stats.set_int("MPX_H3OPT_WEAPS", 0)
    stats.set_int("MPX_H3OPT_BITSET0", 443351)
    stats.set_int("MPX_H3OPT_MASKS", 12)
    stats.set_int("MPX_H3_COMPLETEDPOSIX", -1)
    stats.set_int("MPX_CAS_HEIST_FLOW", -1)
    stats.set_int("MPX_H3OPT_POI", 1023)
    stats.set_int("MPX_H3OPT_ACCESSPOINTS", 2047)
end)

gentab:add_sameline()

gentab:add_button("Skip Casino heist prep (Gold))", function()
    stats.set_int("MPX_H3OPT_APPROACH", 2)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    stats.set_int("MPX_H3_LAST_APPROACH", 3)
    stats.set_int("MPX_H3OPT_TARGET", 1) --主目标: 黄金
    stats.set_int("MPX_H3OPT_BITSET1", 159)
    stats.set_int("MPX_H3OPT_KEYLEVELS", 2)
    stats.set_int("MPX_H3OPT_DISRUPTSHIP", 3)
    stats.set_int("MPX_H3OPT_CREWWEAP", 1)
    stats.set_int("MPX_H3OPT_CREWDRIVER", 1)
    stats.set_int("MPX_H3OPT_CREWHACKER", 5)
    stats.set_int("MPX_H3OPT_VEHS", 0)
    stats.set_int("MPX_H3OPT_WEAPS", 0)
    stats.set_int("MPX_H3OPT_BITSET0", 443351)
    stats.set_int("MPX_H3OPT_MASKS", 12)
    stats.set_int("MPX_H3_COMPLETEDPOSIX", -1)
    stats.set_int("MPX_CAS_HEIST_FLOW", -1)
    stats.set_int("MPX_H3OPT_POI", 1023)
    stats.set_int("MPX_H3OPT_ACCESSPOINTS", 2047)
end)

gentab:add_sameline()

gentab:add_button("Reset Casino Plan Panel", function()
    stats.set_int("MPX_H3OPT_APPROACH", 0)
    stats.set_int("MPX_H3_LAST_APPROACH", 0)
    stats.set_int("MPX_H3OPT_TARGET", 0)
    stats.set_int("MPX_H3OPT_BITSET1", 0)
    stats.set_int("MPX_H3OPT_KEYLEVELS", 0)
    stats.set_int("MPX_H3OPT_DISRUPTSHIP", 0)
    stats.set_int("MPX_H3OPT_BITSET0", 0)
    stats.set_int("MPX_H3OPT_MASKS", 0)
    stats.set_int("MPX_H3_COMPLETEDPOSIX", 0)
    stats.set_int("MPX_CAS_HEIST_FLOW", 0)
    stats.set_int("MPX_H3OPT_POI", 0)
    stats.set_int("MPX_H3OPT_ACCESSPOINTS", 0)
end)


gentab:add_button("Switch CEO/Leader", function() --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    --playerOrganizationTypeRaw: {Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_429}  GLOBAL  
    --playerOrganizationType: {('1886967', '*609', '10', '429', '1')}  GLOBAL  global + (pid *pidmultiplier) + offset + offset + offset (values: 0 = CEO and 1 = MOTORCYCLE CLUB) 
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then --1886967+playerIndex*609+10+429+1 = 0 为CEO =1为摩托帮首领
        globals_set_int(1886967+playerIndex*609+10+429+1,1)
        gui.show_message("Prompt","has been converted to the leader of the MC club")
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            globals_set_int(1886967+playerIndex*609+10+429+1,0)
            gui.show_message("Prompt","has been converted to CEO")
        else
            gui.show_message("You are not the boss","You are neither the CEO nor the leader")
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show office computer", function() --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then
        run_script("appfixersecurity", 4592)
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            globals_set_int(1886967+playerIndex*609+10+429+1,0)
            gui.show_message("Prompt","has been converted to CEO")
            run_script("appfixersecurity", 4592)
            else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
            run_script("appfixersecurity", 4592)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show bunker computer", function() --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then
        run_script("appbunkerbusiness", 1424)
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            run_script("appbunkerbusiness", 1424)
            else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
                run_script("appbunkerbusiness", 1424)
            end
    end
end)

gentab:add_sameline()

gentab:add_button("Show hangar computer", function() --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then
        run_script("appsmuggler", 4592)
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            run_script("appsmuggler", 4592)
            else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
                un_script("appsmuggler", 4592)
            end
    end
end)

gentab:add_sameline()

gentab:add_button("Show arcade computer", function() --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then
        PLAYER.FORCE_CLEANUP_FOR_ALL_THREADS_WITH_THIS_NAME("appArcadeBusinessHub", 1)
        run_script("apparcadebusinesshub", 1424)
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            PLAYER.FORCE_CLEANUP_FOR_ALL_THREADS_WITH_THIS_NAME("appArcadeBusinessHub", 1)
            run_script("apparcadebusinesshub", 1424)
        else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
                run_script("apparcadebusinesshub", 1424)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show the Terrorbyte Dashboard", function() --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then
        run_script("apphackertruck", 4592)
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            run_script("apphackertruck", 4592)
        else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
            run_script("apphackertruck",4592)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show Avengers panel", function()  --3095
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals.get_int(1886967+playerIndex*609+10+429+1) == 0 then
        run_script("appAvengerOperations", 4592)
    else
        if globals.get_int(1886967+playerIndex*609+10+429+1) == 1 then
            run_script("appAvengerOperations", 4592)
        else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
            run_script("appAvengerOperations", 4592)
        end
    end
end)

gentab:add_separator()
gentab:add_text("Entertainment function (low stability, full of bugs) (the particle effect will not continue to be generated after reaching the memory limit, please enable and disable the function of cleaning PTFX water column and fire column at the bottom of this page)") --不解释，我自己也搞不明白

gentab:add_button("Light fireworks", function()
    script.run_in_fiber(function (firew)
        
    local animlib = 'anim@mp_fireworks'
    local ptfx_asset = "scr_indep_fireworks"
    local anim_name = 'place_firework_3_box'
    local effect_name = "scr_indep_firework_trailburst"

    STREAMING.REQUEST_ANIM_DICT(animlib)

    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
    local ped = PLAYER.PLAYER_PED_ID()

    ENTITY.FREEZE_ENTITY_POSITION(ped, true)
    TASK.TASK_PLAY_ANIM(ped, animlib, anim_name, -1, -8.0, 3000, 0, 0, false, false, false)

    firew:sleep(1500)

    STREAMING.REQUEST_MODEL(3176209716)
    while not STREAMING.HAS_MODEL_LOADED(3176209716) do firew:yield() end

    local firework_box = OBJECT.CREATE_OBJECT(3176209716, pos.x, pos.y, pos.z, true, false, false)

    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(firework_box)
    ENTITY.FREEZE_ENTITY_POSITION(ped, false)

    firew:sleep(1000)

    ENTITY.FREEZE_ENTITY_POSITION(firework_box, true)
    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_indep_fireworks")

    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_indep_fireworks") do firew:yield() end

    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")

    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, -1.0, 180.0, 0.0, 0.0, 1.0, false, false, false)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, -1.0, 180.0, 0.0, 0.0, 1.0, false, false, false)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, -1.0, 180.0, 0.0, 0.0, 1.0, false, false, false)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, -1.0, 180.0, 0.0, 0.0, 1.0, false, false, false)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, -1.0, 180.0, 0.0, 0.0, 1.0, false, false, false)

    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(firework_box, true, true)
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(firework_box)
    delete_entity(firework_box)

    end)
end)

gentab:add_sameline()

gentab:add_button("Broomstick", function()
    script.run_in_fiber(function (mk2ac1)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
        local broomstick = joaat("prop_tool_broom")
        local oppressor = joaat("oppressor2")
        while not STREAMING.HAS_MODEL_LOADED(broomstick) do		
            STREAMING.REQUEST_MODEL(broomstick)
            mk2ac1:yield()
        end
        while not STREAMING.HAS_MODEL_LOADED(oppressor) do	
            STREAMING.REQUEST_MODEL(oppressor)	
            mk2ac1:yield()
        end
        obj = OBJECT.CREATE_OBJECT(broomstick, pos.x,pos.y,pos.z, true, false, false)
        veh = VEHICLE.CREATE_VEHICLE(oppressor, pos.x,pos.y,pos.z, 0 , true, true, true)
        ENTITY.SET_ENTITY_VISIBLE(veh, false, false)
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, veh, 0, 0, 0, 0.3, -80.0, 0, 0, true, false, false, false, 0, true, 0) 
        myvehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        upgrade_vehicle(myvehisin)
    end)
end)

gentab:add_sameline()

local fwglb = gentab:add_checkbox("Range fireworks") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local stnfl = gentab:add_checkbox("Meteor rain") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local objectsix1 --注册为全局变量以便后续移除666
local objectsix2--注册为全局变量以便后续移除666
local objectsix3--注册为全局变量以便后续移除666
local object5201 --注册为全局变量以便后续移除520
local object5202--注册为全局变量以便后续移除520
local object5203--注册为全局变量以便后续移除520

local check666 = gentab:add_checkbox("Header 666") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local check520 = gentab:add_checkbox("Header 520") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local check6 = gentab:add_checkbox("Swim mode") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local partwater = gentab:add_checkbox("Separate bodies of water") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local checkfirebreath = gentab:add_checkbox("Fire breath")--这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local firemt = gentab:add_checkbox("Ghost Rider") --这只是一个复选框,代码往最后的循环脚本部分找


bigfireWings = {
    [1] = {pos = {[1] = 120, [2] =  75}},
    [2] = {pos = {[1] = 120, [2] = -75}},
    [3] = {pos = {[1] = 135, [2] =  75}},
    [4] = {pos = {[1] = 135, [2] = -75}},
    [5] = {pos = {[1] = 180, [2] =  75}},
    [6] = {pos = {[1] = 180, [2] = -75}},
    [7] = {pos = {[1] = 190, [2] =  75}},
    [8] = {pos = {[1] = 190, [2] = -75}},
    [9] = {pos = {[1] = 130, [2] =  75}},
    [10] = {pos = {[1] = 130, [2] = -75}},
    [11] = {pos = {[1] = 140, [2] =  75}},
    [12] = {pos = {[1] = 140, [2] = -75}},
    [13] = {pos = {[1] = 150, [2] =  75}},
    [14] = {pos = {[1] = 150, [2] = -75}},
    [15] = {pos = {[1] = 210, [2] =  75}},
    [16] = {pos = {[1] = 210, [2] = -75}},
    [17] = {pos = {[1] = 195, [2] =  75}},
    [18] = {pos = {[1] = 195, [2] = -75}},
    [19] = {pos = {[1] = 160, [2] =  75}},
    [20] = {pos = {[1] = 160, [2] = -75}},
    [21] = {pos = {[1] = 170, [2] =  75}},
    [22] = {pos = {[1] = 170, [2] = -75}},
    [23] = {pos = {[1] = 200, [2] =  75}},
    [24] = {pos = {[1] = 200, [2] = -75}},
}

gentab:add_sameline()

local checkfirew = gentab:add_checkbox("Flame wings")

gentab:add_separator()

gentab:add_text("Physical control it is recommended to turn on only one switch at the same time, otherwise it may seriously affect performance and cause some functions to fail") 

local vehforcefield = gentab:add_checkbox("Vehicle force field") --只是一个开关，代码往后面找

gentab:add_sameline()

local pedforcefield = gentab:add_checkbox("NPC force field") --只是一个开关，代码往后面找

gentab:add_sameline()

local forcefield = gentab:add_checkbox("Force field (vehicle + NPC)") --只是一个开关，代码往后面找

gentab:add_sameline()

local objforcefield = gentab:add_checkbox("Object force field") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehboost = gentab:add_checkbox("Simple vehicle acceleration controlled by Shift key (test)") --只是一个开关，代码往后面找

gentab:add_sameline()

local npcvehbr = gentab:add_checkbox("NPC vehicle upside down") --只是一个开关，代码往后面找

gentab:add_text("Vehicle control") 

gentab:add_sameline()

local vehengdmg = gentab:add_checkbox("Burn") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehfixr = gentab:add_checkbox("Repair") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehstopr = gentab:add_checkbox("Stop") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehjmpr = gentab:add_checkbox("Jump") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehdoorlk4p = gentab:add_checkbox("Lock the door for all players") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehbr = gentab:add_checkbox("Chaos") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehsp1 = gentab:add_checkbox("Rotate") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehrm = gentab:add_checkbox("Delete V") --只是一个开关，代码往后面找

gentab:add_text("Hostile NPC vehicle control") 

gentab:add_sameline()

local vehengdmg2 = gentab:add_checkbox("Burn 2") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehstopr2 = gentab:add_checkbox("Stop 2") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehrm2 = gentab:add_checkbox("Delete 2") --只是一个开关，代码往后面找

gentab:add_text("NPC control") 

gentab:add_sameline()

local reactany = gentab:add_checkbox("Interrupt A") --只是一个开关，代码往后面找

gentab:add_sameline()

local react1any = gentab:add_checkbox("Fall A") --只是一个开关，代码往后面找

gentab:add_sameline()

local react2any = gentab:add_checkbox("Kill a") --只是一个开关，代码往后面找

gentab:add_sameline()

local react3any = gentab:add_checkbox("Burn A") --只是一个开关，代码往后面找

gentab:add_sameline()

local react4any = gentab:add_checkbox("Take off A") --只是一个开关，代码往后面找

gentab:add_sameline()

gentab:add_button("Bodyguard", function()
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local foundfrd = false
        for __, frd in pairs(FRDList) do
            if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                foundfrd = true
                break
            end
        end    
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if calcDistance(selfpos, ped_pos) <= 200 and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) == false and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and foundfrd == false then 
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            pedblip = HUD.GET_BLIP_FROM_ENTITY(peds)
            HUD.REMOVE_BLIP(pedblip)
            npc2bodyguard(peds)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Heal A", function()
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID()  and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0 then 
            request_control(peds)
            ENTITY.SET_ENTITY_HEALTH(peds,1000,0,0)
        end
    end
end)

gentab:add_sameline()

local revitalizationped = gentab:add_checkbox("Resurrection (unstable)") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmdied = gentab:add_checkbox("Remove the body A") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp = gentab:add_checkbox("Disarm A") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany = gentab:add_checkbox("Electric shock A") --只是一个开关，代码往后面找

gentab:add_sameline()

local drawbox = gentab:add_checkbox("Light beam marker A") --只是一个开关，代码往后面找

gentab:add_text("(BETA testing) NPC control automatically excludes friendly whitelisting (list not yet complete, see below), lightpost markers still work globally") 

gentab:add_text("Hostile NPC control") 

gentab:add_sameline()

local reactanyac = gentab:add_checkbox("Interrupt A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react1anyac = gentab:add_checkbox("Fall A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react2anyac = gentab:add_checkbox("Kill A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react3anyac = gentab:add_checkbox("Burn A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react4anyac = gentab:add_checkbox("Take off A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react5anyac = gentab:add_checkbox("Bodyguard A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react6anyac = gentab:add_checkbox("Beam marker A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp2 = gentab:add_checkbox("Disarm A1") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany2 = gentab:add_checkbox("Electric shock B") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany7 = gentab:add_checkbox("Detonate") --只是一个开关，代码往后面找

gentab:add_text("NPCs target me for punishment") 

gentab:add_sameline()

local aimreact = gentab:add_checkbox("Interrupt B") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact1 = gentab:add_checkbox("Fall B") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact2 = gentab:add_checkbox("Kill B") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact3 = gentab:add_checkbox("Burn B") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact4 = gentab:add_checkbox("Take off B") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact5 = gentab:add_checkbox("Bodyguard B") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact6 = gentab:add_checkbox("Remove B") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp3 = gentab:add_checkbox("Disarm B") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany3 = gentab:add_checkbox("Electric shock C") --只是一个开关，代码往后面找

gentab:add_text("Punish targeting NPC") 

gentab:add_sameline()

local aimreactany = gentab:add_checkbox("Interrupt C") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact1any = gentab:add_checkbox("Fall C") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact2any = gentab:add_checkbox("Kill C") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact3any = gentab:add_checkbox("Burn C") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact4any = gentab:add_checkbox("Take off C") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact5any = gentab:add_checkbox("Bodyguard C") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact6any = gentab:add_checkbox("Remove C") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp4 = gentab:add_checkbox("Disarm C") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany4 = gentab:add_checkbox("Electric shock D") --只是一个开关，代码往后面找

local delallcam = gentab:add_checkbox("Remove all cameras") --只是一个开关，代码往后面找

CamList = {   --从heist control抄的,游戏中的各种摄像头
    joaat("prop_cctv_cam_01a"),
    joaat("prop_cctv_cam_01b"),
    joaat("prop_cctv_cam_02a"),
    joaat("prop_cctv_cam_03a"),
    joaat("prop_cctv_cam_04a"),
    joaat("prop_cctv_cam_04c"),
    joaat("prop_cctv_cam_05a"),
    joaat("prop_cctv_cam_06a"),
    joaat("prop_cctv_cam_07a"),
    joaat("prop_cs_cctv"),
    joaat("p_cctv_s"),
    joaat("hei_prop_bank_cctv_01"),
    joaat("hei_prop_bank_cctv_02"),
    joaat("ch_prop_ch_cctv_cam_02a"),
    joaat("xm_prop_x17_server_farm_cctv_01"),
}

gentab:add_sameline()

gentab:add_button("Removed Perico heavy armor", function()
    for _, entrmbal in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.GET_ENTITY_MODEL(entrmbal) == 193469166 then
            request_control(entrmbal)
            delete_entity(entrmbal)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Randomly shoot half of the NPCs in real name", function()
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local foundfrd = false
        for __, frd in pairs(FRDList) do
            if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                foundfrd = true
                break
            end
        end    
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and math.random(0,1) >= 0.5 and foundfrd == false then 
            if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            else
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            end
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Randomly shoot half of hostile NPCs in real name", function()
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and math.random(0,1) >= 0.5 and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() then 
            if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            else
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            end
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Real-name shooting NPC", function()
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local foundfrd = false
        for __, frd in pairs(FRDList) do
            if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                foundfrd = true
                break
            end
        end    
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and foundfrd == false then 
            if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            else
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            end
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Shoot and kill hostile NPCs in real name", function()
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() then 
            if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            else
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
            end
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Clean up the police and the National Security service", function()
    local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    MISC.CLEAR_AREA_OF_COPS(selfpos.x,selfpos.y,selfpos.z,npcctrlr:get_value(),0)
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() then 
            request_control(peds)
            ENTITY.SET_ENTITY_HEALTH(peds,0,0,0,0)
        end
    end
end)

gentab:add_text("Shooting and dying can keep NPC drops such as password clues and Perico access cards, but if you remove them, you will not be able to get any drops..") 
gentab:add_text("Real-name shooting will be counted in the player's archived statistics and kill experience points will be obtained. Deaths under NPC control will be regarded as natural deaths of NPC, and removal is also anonymous. Shooting is using a special carbine MK2 simulation shooting") 

gentab:add_button("Heal key NPCs", function()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        for __, frd in pairs(FRDList) do
            if ENTITY.GET_ENTITY_MODEL(ped) == frd then
                request_control(ped)
                ENTITY.SET_ENTITY_HEALTH(ped,1000,0,0)
            end
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Make blue dot NPCs on the mini-map invincible", function()
    for _, peds in pairs(entities.get_all_peds_as_handles()) do
        if peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 3 then 
            request_control(peds)
            ENTITY.SET_ENTITY_HEALTH(peds,1000,0,0)
            ENTITY.SET_ENTITY_PROOFS(peds, true, true, true, true, true, true, true, true) 
            ENTITY.SET_ENTITY_INVINCIBLE(peds,true)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Remove invincibility of blue dot NPCs", function()
    for _, peds in pairs(entities.get_all_peds_as_handles()) do
        if peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 3 then 
            request_control(peds)
            ENTITY.SET_ENTITY_HEALTH(peds,1000,0,0)
            ENTITY.SET_ENTITY_INVINCIBLE(peds,false)
            ENTITY.SET_ENTITY_PROOFS(peds, false, false, false, false, false, false, false) 
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Teleport blue dot NPCs to yourself", function()
    for _, peds in pairs(entities.get_all_peds_as_handles()) do
        if peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 3 then 
            request_control(peds)
            PED.SET_PED_COORDS_KEEP_VEHICLE(peds, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false).z)
        end
    end
end)

gentab:add_sameline()

gentab:add_text("Key NPC has been entered: see line 199 of the source code") 

gentab:add_text("Entity generation") 

heli_sp_table = {}
heli_guard_table = {}

gentab:add_button("Generate bodyguard helicopter", function()
    script.run_in_fiber(function (heli_guard_f)

    local heli_mod = joaat("valkyrie") --女武神 直升机
    local drv_mod = joaat("s_m_y_blackops_01")
    while not STREAMING.HAS_MODEL_LOADED(heli_mod) do	
        STREAMING.REQUEST_MODEL(heli_mod)
        heli_guard_f:yield()
    end    
    while not STREAMING.HAS_MODEL_LOADED(drv_mod) do	
        STREAMING.REQUEST_MODEL(drv_mod)
        heli_guard_f:yield()
    end    
    local selfpedPos_sp_heli = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
    selfpedPos_sp_heli.z = selfpedPos_sp_heli.z + math.random(40, 50)
    selfpedPos_sp_heli.x = selfpedPos_sp_heli.x + math.random(-7, 7)
    selfpedPos_sp_heli.y = selfpedPos_sp_heli.y + math.random(-7, 7)

    local heli_sp = VEHICLE.CREATE_VEHICLE(heli_mod, selfpedPos_sp_heli.x,selfpedPos_sp_heli.y,selfpedPos_sp_heli.z, CAM.GET_GAMEPLAY_CAM_ROT(0).z , true, true, true)
    table.insert(heli_sp_table, heli_sp)
    vehNetId = NETWORK.VEH_TO_NET(heli_sp)
    if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(NETWORK.NET_TO_PED(vehNetId)) then
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(vehNetId, true)
    end
    NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(vehNetId, PLAYER.PLAYER_ID(), true)
    VEHICLE.SET_VEHICLE_ENGINE_ON(heli_sp, true, true, true)
    VEHICLE.SET_HELI_BLADES_SPEED(heli_sp, 1.0)
    VEHICLE.SET_VEHICLE_SEARCHLIGHT(heli_sp, true, true)
    ENTITY.SET_ENTITY_INVINCIBLE(heli_sp, true)
    ENTITY.SET_ENTITY_MAX_HEALTH(heli_sp, 10000)
    ENTITY.SET_ENTITY_HEALTH(heli_sp, 10000, 0, 0)

    local heli_guards = {}
    for i = 1, 4 do
        local heli_guard = PED.CREATE_PED(29, drv_mod, selfpedPos_sp_heli.x, selfpedPos_sp_heli.y, selfpedPos_sp_heli.z, CAM.GET_GAMEPLAY_CAM_ROT(0).z, true, true)
        PED.SET_PED_KEEP_TASK(heli_guard, true)
        ENTITY.SET_ENTITY_INVINCIBLE(heli_guard, true)
        PED.SET_PED_MAX_HEALTH(heli_guard, 1000)
        ENTITY.SET_ENTITY_HEALTH(heli_guard, 1000, 0, 0)
        npc2bodyguard(heli_guard)
        table.insert(heli_guard_table, heli_guard)
        heli_guards[i] = heli_guard
    end

    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(heli_guards[1], true)
    PED.SET_PED_INTO_VEHICLE(heli_guards[4], heli_sp, 0)
    PED.SET_PED_INTO_VEHICLE(heli_guards[3], heli_sp, 2)
    PED.SET_PED_INTO_VEHICLE(heli_guards[2], heli_sp, 1)
    PED.SET_PED_INTO_VEHICLE(heli_guards[1], heli_sp, -1)
    TASK.TASK_VEHICLE_FOLLOW(heli_guards[1], heli_sp, PLAYER.PLAYER_PED_ID(), 80, 1, 10, 10)
    PED.SET_PED_KEEP_TASK(heli_guards[1], true)
end)
end)

gentab:add_sameline()

gentab:add_button("Remove Bodyguard Helicopter", function()
    for _, hgt_ele in pairs(heli_guard_table) do
        delete_entity(hgt_ele)
    end
    for _, hst_elm in pairs(heli_sp_table) do
        delete_entity(hst_elm)
    end
    heli_sp_table = {}
end)

gentab:add_sameline()

t_guard_table = {}

gentab:add_button("Generate bodyguards", function()
    script.run_in_fiber(function (t_guard_f)

    local guardteam_mod = joaat("CSB_Avon")
    while not STREAMING.HAS_MODEL_LOADED(guardteam_mod) do	
        STREAMING.REQUEST_MODEL(guardteam_mod)
        t_guard_f:yield()
    end    
    if gtnum:get_value() == nil or gtnum:get_value() < 1 then
        gtnum:set_value(5)
    end
    for i = 1, gtnum:get_value() do
        local selfpedPos_sp_heli = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        selfpedPos_sp_heli.z = selfpedPos_sp_heli.z + math.random(0, 1)
        selfpedPos_sp_heli.x = selfpedPos_sp_heli.x + math.random(-5, 5)
        selfpedPos_sp_heli.y = selfpedPos_sp_heli.y + math.random(-5, 5)
    
        local t_guard = PED.CREATE_PED(29, guardteam_mod, selfpedPos_sp_heli.x, selfpedPos_sp_heli.y, selfpedPos_sp_heli.z, CAM.GET_GAMEPLAY_CAM_ROT(0).z, true, true)
        PED.SET_PED_KEEP_TASK(t_guard, true)
        ENTITY.SET_ENTITY_INVINCIBLE(t_guard, true)
        PED.SET_PED_MAX_HEALTH(t_guard, 1000)
        ENTITY.SET_ENTITY_HEALTH(t_guard, 1000, 0, 0)
        npc2bodyguard(t_guard)
        table.insert(t_guard_table, t_guard)
    end
    PED.SET_GROUP_FORMATION(PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()),1)

    end)
end)

gentab:add_sameline()

gentab:add_button("Remove bodyguards", function()
    for _, tgt_ele in pairs(t_guard_table) do
        delete_entity(tgt_ele)
    end
end)

gentab:add_separator()

gentab:add_text("Industry function - medium and high risk") 

gentab:add_button("1 click completion of CEO warehouse shipments", function()
    locals_set_int("gb_contraband_sell",545,99999) --iLocal_543.f_2 --3095
end)

gentab:add_sameline()

gentab:add_button("1 click completion of motorcycle shipment", function()
    if locals.get_int("gb_biker_contraband_sell",719) >= 1 then --3095
        locals_set_int("gb_biker_contraband_sell",824,15) --702 + 122 --3095
    else
        gui.show_error("This task type does not support 1 click completion", "1 click for a total of one truck")
        log.info("该任务类型不支持一键完成,否则不会有任何收入.一共就一辆送货载具也要使用一键完成??")
    end
end)
--[[extremely unstable 
gentab:add_sameline()

gentab:add_button("1 click delivery of acid", function() 
    locals_set_int("fm_content_acid_lab_sell",6596,9)
    locals_set_int("fm_content_acid_lab_sell",6597,10)
    locals_set_int("fm_content_acid_lab_sell",6530,2)
end)
]]
gentab:add_sameline()

gentab:add_button("1 click completion of bunker shipment", function()
    gui.show_message("Autoshipment","may show that the task failed, but you should get the money!")
    locals_set_int("gb_gunrunning",1983,0) --3095
    --  gb_gunrunning.c iLocal_1209.f_774
    --	for (i = 0; i < func_833(func_3786(), func_60(), iLocal_1209.f_774, iLocal_1209.f_809); i = i + 1)
    --  REMOVE_PARTICLE_FX_FROM_ENTITY
    gui.show_message("Autoship "," may show that the task failed, but you should get the money!")
end)

gentab:add_sameline()

gentab:add_button("1 click completion of hangar (air freight) shipment", function()
    gui.show_message("Autoshipment","may show that the task failed, but you should get the money!")
    local integer = locals.get_int("gb_smuggler", 3010)  --1932 + 1078 --3095
    locals_set_int("gb_smuggler",2967,integer) --1932 + 1035 --3095
    gui.show_message("Autoshipment","may show that the task failed, but you should get the money!")
end)

local ccrgsl = gentab:add_checkbox("CEO warehouse shipment locks the transport ship")

gentab:add_sameline()

local bkeasyms = gentab:add_checkbox("The motorcycle gang will ship only one truck")

gentab:add_sameline()

local bussp2 = gentab:add_checkbox("Rapid production of acid in the motorcycle gang industrial bunker (risky)")

gentab:add_sameline()

local bussp = gentab:add_checkbox("Extreme production of acid in the motorcycle gang industrial bunker (risky)")

gentab:add_sameline()

local ncspup = gentab:add_checkbox("Nightclub fast purchase (risky)")

local ncspupa1 = gentab:add_checkbox("Purchase at 4 times the speed of the nightclub (risky)")

gentab:add_sameline()

local ncspupa2 = gentab:add_checkbox("Purchase at 10 times the speed of the nightclub (risky)")

gentab:add_sameline()

local ncspupa3 = gentab:add_checkbox("Purchase at 20 times the speed of the nightclub (risky)")

gentab:add_button("The MC club industry is full of supplies", function()
    globals_set_int(1662873+1+1,1) --可卡因 -- 3095--freemode.c  	if (func_12737(148, "OR_PSUP_DEL" /*Hey, the supplies you purchased have arrived at the ~a~. Remember, paying for them eats into profits!*/, &unk, false, -99, 0, 0, false, 0))
    globals_set_int(1662873+1+2,1) --冰毒-- 3095
    globals_set_int(1662873+1+3,1) --大麻-- 3095
    globals_set_int(1662873+1+4,1) --证件-- 3095
    globals_set_int(1662873+1+0,1) --假钞-- 3095
    globals_set_int(1662873+1+6,1) --致幻剂-- 3095
    gui.show_message("Auto-replenishment","All done")
end)

gentab:add_sameline()

gentab:add_button("The bunker is full of supplies", function()
    globals_set_int(1662873+1+5,1) --bunker-- 3095
    gui.show_message("Auto-replenishment","All done")
end)

gentab:add_sameline()

local autorespl = gentab:add_checkbox("Warehouse automatic replenishment (buggy)")

gentab:add_sameline()

gentab:add_button("Max nightclub's popularity", function()
    stats.set_int("MPX_CLUB_POPULARITY", 10000)
end)

gentab:add_sameline()

gentab:add_button("CEO Warehouse staff restock once", function()
    --freemode.c void func_17501(int iParam0, BOOL bParam1) // Position - 0x56C7B6
    packed_stat_set_bool(32359,true) --无需更新
    packed_stat_set_bool(32360,true) --无需更新
    packed_stat_set_bool(32361,true) --无需更新
    packed_stat_set_bool(32362,true) --无需更新
    packed_stat_set_bool(32363,true) --无需更新
end)

gentab:add_sameline()

gentab:add_button("Hangar staff restock once", function()
    packed_stat_set_bool(36828,true)  --无需更新
end)

local checkCEOcargo = gentab:add_checkbox("The single purchase quantity of locked warehouse staff is")

gentab:add_sameline()

local inputCEOcargo = gentab:add_input_int("crates")

local check4 = gentab:add_checkbox("Lock hangar staff single purchase quantity is")

gentab:add_sameline()

local iputint3 = gentab:add_input_int("box")

gentab:add_button("Nightclub safe 300,000 cycles 10 times", function()
    script.run_in_fiber(function (ncsafeloop)
        a2 =0
        while a2 < 10 do --循环次数
            a2 = a2 + 1
            gui.show_message("Number of times implemented", tostring(a2))
            tunables.set_int("NIGHTCLUBMAXSAFEVALUE", 300000)
            tunables.set_int("NIGHTCLUBINCOMEUPTOPOP100", 300000)
            stats.set_int("MPX_CLUB_POPULARITY", 10000)
            stats.set_int("MPX_CLUB_PAY_TIME_LEFT", -1)
            stats.set_int("MPX_CLUB_POPULARITY", 100000)
            gui.show_message("Warning", "This method is only used for occasional small recovery")
            ncsafeloop:sleep(10000) --执行间隔，单位ms
        end
    end)
end)

gentab:add_sameline()

local checklkw = gentab:add_checkbox("Casino carousel draw (the carousel may appear as something else, but you do get vehicles)")

local checkxsdped = gentab:add_checkbox("NPC drops 2000 bucks cycle (high risk)")

gentab:add_separator()
gentab:add_text("Send")

gentab:add_button("Navigation Points (Particle Effects)", function()
    script.run_in_fiber(function (tp2wp)
        command.call("waypointtp",{}) --调用Yimmenu自身传送到导航点命令
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2") --小丑出现烟雾
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
            tp2wp:yield()               
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("scr_clown_appears", PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0x8b93, 1.0, false, false, false, 0, 0, 0, 0)
    end)
end)

function tpfac() --传送到设施
    local Pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(590))
    if HUD.DOES_BLIP_EXIST(HUD.GET_FIRST_BLIP_INFO_ID(590)) then
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), Pos.x, Pos.y, Pos.z+4)
    end

end

gentab:add_button("Kosatka Panel", function()
    script.run_in_fiber(function (callkos)
        local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
        local Interior = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)
        if Interior == 281345 then
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),1561.2369, 385.8771, -49.689915)
            PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 175)
        else   
            local SubBlip = HUD.GET_FIRST_BLIP_INFO_ID(760)
            local SubControlBlip = HUD.GET_FIRST_BLIP_INFO_ID(773)
            while not HUD.DOES_BLIP_EXIST(SubBlip) and not HUD.DOES_BLIP_EXIST(SubControlBlip) do     
                globals_set_int(2738587 + 960, 1) --呼叫虎鲸 --freemode.c -- 3095	func_12504("HELP_SUBMA_P" /*Go to the Planning Screen on board your new Kosatka ~a~~s~ to begin The Cayo Perico Heist as a VIP, CEO or MC President. You can also request the Kosatka nearby via the Services section of the Interaction Menu.*/, "H_BLIP_SUB2" /*~BLIP_SUB2~*/, func_2189(PLAYER::PLAYER_ID()), -1, false, true);
                SubBlip = HUD.GET_FIRST_BLIP_INFO_ID(760)
                SubControlBlip = HUD.GET_FIRST_BLIP_INFO_ID(773)    
                callkos:yield()
            end
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),1561.2369, 385.8771, -49.689915)
            PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 175)         
        end
    end)
end)

gentab:add_button("Facility", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)

    if intr == 269313 then 
        gui.show_message("No need to teleport","You are already in the facility")
    else
        tpfac()
    end
end)

gentab:add_sameline()

gentab:add_button("Facility Plan Screen", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)
    if intr == 269313 then 
        if HUD.DOES_BLIP_EXIST(HUD.GET_FIRST_BLIP_INFO_ID(428)) then
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), 350.69284, 4872.308, -60.794243)
        end
    else
        gui.show_message("Make sure you are in the facility","Please enter the facility before teleporting to the planning screen")
        tpfac()
    end
end)

--从MusinessBanager抄的
local NightclubPropertyInfo = {
    [1]  = {name = "La Mesa Nightclub",           coords = {x = 757.009,   y =  -1332.32,  z = 27.1802 }},
    [2]  = {name = "Mission Row Nightclub",       coords = {x = 345.7519,  y =  -978.8848, z = 29.2681 }},
    [3]  = {name = "Strawberry Nightclub",        coords = {x = -120.906,  y =  -1260.49,  z = 29.2088 }},
    [4]  = {name = "West Vinewood Nightclub",     coords = {x = 5.53709,   y =  221.35,    z = 107.6566}},
    [5]  = {name = "Cypress Flats Nightclub",     coords = {x = 871.47,    y =  -2099.57,  z = 30.3768 }},
    [6]  = {name = "LSIA Nightclub",              coords = {x = -676.625,  y =  -2458.15,  z = 13.8444 }},
    [7]  = {name = "Elysian Island Nightclub",    coords = {x = 195.534,   y =  -3168.88,  z = 5.7903  }},
    [8]  = {name = "Downtown Vinewood Nightclub", coords = {x = 373.05,    y =  252.13,    z = 102.9097}},
    [9]  = {name = "Del Perro Nightclub",         coords = {x = -1283.38,  y =  -649.916,  z = 26.5198 }},
    [10] = {name = "Vespucci Canals Nightclub",   coords = {x = -1174.85,  y =  -1152.3,   z = 5.56128 }},
}

-- Business / Other Online Work Stuff [[update]]
local function GetOnlineWorkOffset()
    -- GLOBAL_PLAYER_STAT
        local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    return (1845263 + 1 + (playerid * 877) + 267) --3095
end

local function GetNightClubPropertyID()
    return globals.get_int(GetOnlineWorkOffset() + 356) --3095
end

local function IsPlayerInNightclub()
    return (GetPlayerPropertyID() > 101) and (GetPlayerPropertyID() < 112)
end

function tpnc() --传送到夜总会
    local property = GetNightClubPropertyID()
    if property ~= 0  then
        local coords = NightclubPropertyInfo[property].coords
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z)
    end
end

gentab:add_button("Nightclub", function()
    tpnc()
end)

gentab:add_sameline()

gentab:add_button("Nightclub safe (enter the nightclub first)", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), -1615.6832, -3015.7546, -75.204994)
end)

gentab:add_button("Arcade", function()

    local Blip = HUD.GET_FIRST_BLIP_INFO_ID(740) -- Arcade Blip
    local Pos = HUD.GET_BLIP_COORDS(Blip)
    local Label = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(ZONE.GET_NAME_OF_ZONE(Pos.x, Pos.y, Pos.z))

 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_1"), Label) ~= nil then 
    ArcadePos = vec3:new(-245.9931, 6210.773, 31.939024)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), -50)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_2"), Label) ~= nil then 
    ArcadePos = vec3:new(1695.5393, 4784.196, 41.94444)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), -95)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_3"), Label) ~= nil then 
    ArcadePos = vec3:new(-115.45246, -1772.0801, 29.858917)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), -125)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("FMC_LOC_WSTVNWD"), Label) ~= nil then 
    ArcadePos = vec3:new(-600.911, 279.97433, 82.041245)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 80)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_5"), Label) ~= nil then 
    ArcadePos = vec3:new(-1269.7747, -304.4372, 37.001965)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 75)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_6"), Label) ~= nil then 
    ArcadePos = vec3:new(758.91815, -814.60864, 26.301702)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 90)

 end

  PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  ArcadePos.x, ArcadePos.y,  ArcadePos.z)

end)

gentab:add_sameline()

gentab:add_button("Arcade Plan Panel (Advanced Arcade)", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  2711.773, -369.458, -54.781)
end)

gentab:add_button("Casino", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)

    if intr == 275201 then 
        gui.show_message("No need to teleport","You are already in the facility")
    else
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  924, 46, 81)
    end
end)

gentab:add_sameline()

gentab:add_button("Fortune Wheel", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)

    if intr == 275201 then 
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  1111, 228.75, -49.6)
        PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 352)
    else
        gui.show_message("Reminder","Please enter the casino first")

        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  924, 46, 81)
    end
end)

gentab:add_sameline()

gentab:add_button("Ms. Baker's Office", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)

    if intr == 275201 then 
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  1123.82, 264.45, -51)
    else
        gui.show_message("Reminder","Please enter the casino first")

        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  924, 46, 81)
    end
end)

gentab:add_button("LS Customs", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  -337, -137, 38.5)
end)

gentab:add_sameline()

gentab:add_button("Ammunition with firing range", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  20.80, -1107, 29.8)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 335)
end)

gentab:add_button("Perico underground vault", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  5006.74, -5756, 15.5)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 144)
end)

gentab:add_sameline()

gentab:add_button("Inside the mansion gate", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  4991, -5718, 20)
end)

gentab:add_sameline()

gentab:add_button("Sea escape point", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  4735.74, -6174, 20)
end)

gentab:add_button("Random location", function()
    _,safepos = PATHFIND.GET_NTH_CLOSEST_VEHICLE_NODE_WITH_HEADING(math.random(-1794,2940), math.random(-3026,6298), 20, 1, 0, outheading, lanes, 0, 3.0, 0.0)
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), safepos.x, safepos.y, safepos.z)
end)

gentab:add_separator()
gentab:add_text("Miscellaneous")

local SEa = 0

gentab:add_button("Remove balance", function()

    SE = MONEY.NETWORK_GET_VC_BANK_BALANCE() + stats.get_int("MPPLY_TOTAL_SVC") - stats.get_int("MPPLY_TOTAL_EVC")
    log.info(tostring(SE))
    if SE >= 20000 and SEa == 0 and stats.get_int("MPPLY_TOTAL_SVC")>0 and stats.get_int("MPPLY_TOTAL_EVC")>0 then
        SE = SE - 10000
        stats.set_int("MPX_MONEY_EARN_JOBS",stats.get_int("MPX_MONEY_EARN_JOBS") + SE )
        stats.set_int("MPPLY_TOTAL_EVC",stats.get_int("MPPLY_TOTAL_EVC") + SE )
        gui.show_message("Remove balance difference","Executed successfully")
        log.info("已移除收支差:"..tostring(SE))    
        SEa = 1
    else
        gui.show_message("Your income and expenditure are normal, no need to remove or trigger abnormal value protection","There is no difference in income and expenditure at all, but it may be abnormal")
        SEa = 1
    end

end)

gentab:add_sameline()

gentab:add_button("Restoration of deleted vehicules in 1.66", function()
    for x = 14936, 14944 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 17510, 17528 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 17682, 17703 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 19341, 19365 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 20422, 20425 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 21304, 21309 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 22103, 22122 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 23071, 23098 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 24292, 24405 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 26039, 26045 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 26050, 26070 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 27026, 27027 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 28890, 28910 do --3095
        globals_set_int(262145 + x, 1)
    end

    globals_set_int(262145 + 28888, 1) --3095
    globals_set_int(262145 + 28936, 1) --3095

    for x = 29604, 29611 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 29953, 29959 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 30418, 30434 do --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 31290, 31306 do --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 32214, 32228 do  --3095
        globals_set_int(262145 + x, 1)
    end
    
    for x = 33463, 33481 do  --3095
        globals_set_int(262145 + x, 1)
    end

    for x = 34446, 34461 do  --3095
        globals_set_int(262145 + x, 1)
    end
    
end)

gentab:add_sameline()

gentab:add_button("Dax cooldown removed", function()
    local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    stats.set_int("MPX_XM22JUGGALOWORKCDTIMER", -1)
end)

gentab:add_sameline()

gentab:add_button("Security Contract/Phone Assassination cooldown removed", function()
    tunables.set_int("FIXER_SECURITY_CONTRACT_COOLDOWN_TIME", 0)
    tunables.set_int(1872071131, 0)
end)

gentab:add_sameline()

gentab:add_button("Remove CEO vehicle cooldown", function()
    tunables.set_int("GB_CALL_VEHICLE_COOLDOWN", 0)
end)

gentab:add_sameline()

gentab:add_button("Remove self bounty", function() --3095
    globals_set_int(1+2359296+5150+13,2880000)   
end)

gentab:add_sameline()

gentab:add_button("Force to story mode", function()
    if NETWORK.NETWORK_CAN_BAIL() then
        NETWORK.NETWORK_BAIL(0, 0, 0)
    end
end)

gentab:add_button("Skip an NPC dialogue", function()
    AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
end)

gentab:add_sameline()

local checkbypassconv = gentab:add_checkbox("Automatically skip NPC dialogue")

gentab:add_sameline()

gentab:add_button("Stop all local sounds", function()
    for i=-1,100 do
        AUDIO.STOP_SOUND(i)
        AUDIO.RELEASE_SOUND_ID(i)
    end
end)

gentab:add_sameline()

gentab:add_button("Ground speedometer", function()
    script.run_in_fiber(function (crtspeedm)
    objHash = joaat("stt_prop_track_speedup_t1")
    while not STREAMING.HAS_MODEL_LOADED(objHash) do	
        STREAMING.REQUEST_MODEL(objHash)
        crtspeedm:yield()
    end
    local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
    local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
    local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z-0.2, true, true, false)
    ENTITY.SET_ENTITY_HEADING(obj, heading + 90)
    end)
end)

gentab:add_sameline()

gentab:add_button("Air speedometer", function()
    script.run_in_fiber(function (crtspeedm)
    objHash = joaat("ar_prop_ar_speed_ring")
    while not STREAMING.HAS_MODEL_LOADED(objHash) do	
        STREAMING.REQUEST_MODEL(objHash)
        crtspeedm:yield()
    end
    local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
    local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
    local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z-0.2, true, true, false)
    ENTITY.SET_ENTITY_HEADING(obj, heading)
    end)
end)

gentab:add_sameline()

gentab:add_button("Force save", function() --3095
    globals_set_int(2694471 + 1382 , 27)
end)

gentab:add_text("Vision")

gentab:add_sameline()

gentab:add_button("Remove all visual effects", function()
    GRAPHICS.ANIMPOSTFX_STOP_ALL()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
	PED.SET_PED_MOTION_BLUR(PLAYER.PLAYER_PED_ID(), false)
	CAM.SHAKE_GAMEPLAY_CAM("CLUB_DANCE_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("DAMPED_HAND_SHAKE", 0.0)
    CAM.SHAKE_GAMEPLAY_CAM("DEATH_FAIL_IN_EFFECT_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("DRONE_BOOST_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("gameplay_explosion_shake", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("GRENADE_EXPLOSION_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_BUMP_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_ENGINE_START_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_ENGINE_STOP_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_LOOP_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("HAND_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("HIGH_FALL_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("jolt_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("MEDIUM_EXPLOSION_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("PLANE_PART_SPEED_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("ROAD_VIBRATION_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("SKY_DIVING_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("SMALL_EXPLOSION_SHAKE", 0.0)
	CAM.SHAKE_GAMEPLAY_CAM("VIBRATE_SHAKE", 0.0)
end)

gentab:add_sameline()

gentab:add_button("Visual Effects: Taking Drugs", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("spectator6")
    PED.SET_PED_MOTION_BLUR(PLAYER.PLAYER_PED_ID(), true)
    AUDIO.SET_PED_IS_DRUNK(PLAYER.PLAYER_PED_ID(), true)
    CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 3.0)
end)

gentab:add_sameline()

gentab:add_button("Blurred", function()
    GRAPHICS.ANIMPOSTFX_PLAY("MenuMGSelectionIn", 5, true)
end)

gentab:add_sameline()

gentab:add_button("Increased brightness", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("AmbientPush")
end)

gentab:add_sameline()

gentab:add_button("Heavy fog", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("casino_main_floor_heist")
end)

gentab:add_sameline()

gentab:add_button("Drunk", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("Drunk")
end)

gentab:add_sameline()

local fakeban1 = gentab:add_checkbox("Display false warning") --只是一个开关，代码往后面找

gentab:add_sameline()

gentab:add_button("Prevent everyone from using orbital cannons", function()
    script.run_in_fiber(function (blockorbroom)
        local objHash = joaat("prop_fnclink_03e")
        STREAMING.REQUEST_MODEL(objHash)
        while not STREAMING.HAS_MODEL_LOADED(objHash) do
            STREAMING.REQUEST_MODEL(objHash)
            log.info(3)
            blockorbroom:yield()
        end   
        local object = {}
        object[1] = OBJECT.CREATE_OBJECT(objHash, 335.8 - 1.5,4833.9 + 1.5, -60,true, true, false)
        object[2] = OBJECT.CREATE_OBJECT(objHash, 335.8 - 1.5,4833.9 - 1.5, -60,true, true, false)
        object[3] = OBJECT.CREATE_OBJECT(objHash, 335.8 + 1.5,4833.9 + 1.5, -60,true, true, false)
        local rot_3 = ENTITY.GET_ENTITY_ROTATION(object[3], 2)
        rot_3.z = -90.0
        ENTITY.SET_ENTITY_ROTATION(object[3], rot_3.x, rot_3.y, rot_3.z, 1, true)
        object[4] = OBJECT.CREATE_OBJECT(objHash, 335.8 - 1.5,4833.9 + 1.5, -60,true, true, false)
        local rot_4 = ENTITY.GET_ENTITY_ROTATION(object[4], 2)
        rot_4.z = -90.0
        ENTITY.SET_ENTITY_ROTATION(object[4], rot_4.x, rot_4.y,rot_4.z, 1, true)
        ENTITY.IS_ENTITY_STATIC(object[1]) 
        ENTITY.IS_ENTITY_STATIC(object[2])
        ENTITY.IS_ENTITY_STATIC(object[3])
        ENTITY.IS_ENTITY_STATIC(object[4])
        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[1], false) 
        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[2], false) 
        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[3], false) 
        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[4], false) 
        for i = 1, 4 do ENTITY.FREEZE_ENTITY_POSITION(object[i], true) end
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)
end)

gentab:add_sameline()

gentab:add_button("Put on heavy armor immediately", function()
    globals_set_int(2738587 + 902, 1) --3095
    globals_set_int(2738587 + 901, 1) --3095
end)

local check1 = gentab:add_checkbox("Remove transaction error warning") --只是一个开关，代码往后面找

gentab:add_sameline()

local checkmiss = gentab:add_checkbox("Removed Orca missile cooldown and increased range")--只是一个开关，代码往后面找

gentab:add_sameline()

local lockmapang = gentab:add_checkbox("Lock the angle of the minimap")--只是一个开关，代码往后面找

gentab:add_sameline()

local lockhlt = gentab:add_checkbox("Semi-invincible")--只是一个开关，代码往后面找

gentab:add_sameline()

local antikl = gentab:add_checkbox("Explosion-proof head")--只是一个开关，代码往后面找

gentab:add_sameline()

local rdded = gentab:add_checkbox("Radar suspended animation")--只是一个开关，代码往后面找

local taxisvs = gentab:add_checkbox("Automation of online taxi work (continuous transmission)")--只是一个开关，代码往后面找
  
gentab:add_sameline()

local taxisvs2 = gentab:add_checkbox("Automation of online taxi work (simulation driving)")--只是一个开关，代码往后面找

local checkzhongjia = gentab:add_checkbox("Request heavy armor spend (used to remove black money)")--只是一个开关，代码往后面找

gentab:add_sameline()

local iputintzhongjia = gentab:add_input_int("Cash")

local checkfootaudio = gentab:add_checkbox("Turn off footsteps") --只是一个开关，代码往后面找

gentab:add_sameline()

local checkpedaudio = gentab:add_checkbox("Turn off your own PED sound") --只是一个开关，代码往后面找

gentab:add_sameline()

local disableAIdmg = gentab:add_checkbox("Lock NPC Zero Damage") --只是一个开关，代码往后面找

gentab:add_sameline()

local checkSONAR = gentab:add_checkbox("Minimap showing sonar") --只是一个开关，代码往后面找

gentab:add_sameline()

local disalight = gentab:add_checkbox("Global lights out") --只是一个开关，代码往后面找

gentab:add_sameline()

local DrawHost = gentab:add_checkbox("Display host information") --只是一个开关，代码往后面找

gentab:add_sameline()

local allpause = gentab:add_checkbox("Allow local pause online") --只是一个开关，代码往后面找

local pedgun = gentab:add_checkbox("PED gun (shoot NPC)") --只是一个开关，代码往后面找

gentab:add_sameline()

local bsktgun = gentab:add_checkbox("Basketball gun") --只是一个开关，代码往后面找

gentab:add_sameline()

local bballgun = gentab:add_checkbox("Big ball gun") --只是一个开关，代码往后面找

gentab:add_sameline()

local drawcs = gentab:add_checkbox("Draw + Sight") --只是一个开关，代码往后面找

gentab:add_sameline()

local disablecops = gentab:add_checkbox("Stop the police from being dispatched") --只是一个开关，代码往后面找

gentab:add_sameline()

local disapedheat = gentab:add_checkbox("No temperature (anti-thermal imaging)") --只是一个开关，代码往后面找

gentab:add_sameline()

local canafrdly = gentab:add_checkbox("Allow to attack teammate") --只是一个开关，代码往后面找

gentab:add_text("PTFX collection") 

local ptfxt1 = gentab:add_checkbox("Thunder and lightning A") --只是一个开关，代码往后面找

--------------------------------------------------------------------------------------- Players 页面

gui.get_tab(""):add_text("SCH LUA PLAYER OPTIONS -!!!!! NO FEEDBACK ACCEPTED!!!!!") 

local spcam = gui.get_tab(""):add_checkbox("Indirect viewing (not easily detected)")

gui.get_tab(""):add_sameline()

local plymk = gui.get_tab(""):add_checkbox("Light beam marker")

gui.get_tab(""):add_sameline()

local plyline = gui.get_tab(""):add_checkbox("Wire mark")

gui.get_tab(""):add_sameline()

local vehgodr = gui.get_tab(""):add_checkbox("Gives Vehicle Invulnerability")


gui.get_tab(""):add_sameline()

local vehnoclr = gui.get_tab(""):add_checkbox("The vehicle is completely collision-free")

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Repair vehicle", function()
    script.run_in_fiber(function (repvehr)
        if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
            gui.show_error("Warning","The player is not in the vehicle")
        else
            local tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
            local time = os.time()
            local rqctlsus = false
            while not rqctlsus do
                if os.time() - time >= 5 then
                    gui.show_error("sch lua","Request control failed")
                    break
                end
                rqctlsus = request_control(tarveh)
                repvehr:yield()
            end
            gui.show_message("sch lua","Request control was successful")
            VEHICLE.SET_VEHICLE_FIXED(tarveh)
        end
    end)
end)
--[[
gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Remove vehicle", function()
    script.run_in_fiber(function (rmvehr)
        if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
            gui.show_error("Warning","The player is not in the vehicle")
        else
            command.call( vehkick, {"PLAYER.GET_PLAYER_NAME(network.get_selected_player())"})
            tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh)  then
                local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh)
                NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                local time = os.time()
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh) do
                    if os.time() - time >= 5 then
                        break
                    end
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh)
                    rmvehr:yield()
                end
            end
            delete_entity(tarveh)
        end
    end)
end)
]]

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Deluxo", function()
    script.run_in_fiber(function (giftdls)
        local giftvehhash = joaat("deluxo")
        STREAMING.REQUEST_MODEL(giftvehhash)
        while not STREAMING.HAS_MODEL_LOADED(giftvehhash) do
            STREAMING.REQUEST_MODEL(giftvehhash)
            giftdls:yield()
        end   
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        firemtcrtveh = VEHICLE.CREATE_VEHICLE(joaat("deluxo"), ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).z, 0 , true, true, true)

        vehdls = VEHICLE.CREATE_VEHICLE(giftvehhash, targpos.x + 2, targpos.y, targpos.z, 0 , true, true, true)
        ENTITY.SET_ENTITY_INVINCIBLE(vehdls, true)
        VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(vehdls, false)
    end)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Teleport to player (particle effect)", function()
    script.run_in_fiber(function (ptfxtp2ply)
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), targpos.x, targpos.y, targpos.z)
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2") --小丑出现烟雾
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
            ptfxtp2ply:yield()               
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("scr_clown_appears", PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0x8b93, 1.0, false, false, false, 0, 0, 0, 0)

    end)
end)

gui.get_tab(""):add_button("Small cage", function()
    script.run_in_fiber(function (smallcage)
        local objHash = joaat("prop_gold_cont_01")
        STREAMING.REQUEST_MODEL(objHash)
        while not STREAMING.HAS_MODEL_LOADED(objHash) do		
            smallcage:yield()
        end
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local obj = OBJECT.CREATE_OBJECT(objHash, pos.x, pos.y, pos.z-1, true, true, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Fence cage", function()
    local objHash = joaat("prop_fnclink_03e")
    STREAMING.REQUEST_MODEL(objHash)

    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)

    pos.z = pos.z - 1.0
    local object = {}

    object[1] = OBJECT.CREATE_OBJECT(objHash, pos.x - 1.5, pos.y + 1.5, pos.z,true, true, false)
    object[2] = OBJECT.CREATE_OBJECT(objHash, pos.x - 1.5, pos.y - 1.5, pos.z,true, true, false)

    object[3] = OBJECT.CREATE_OBJECT(objHash, pos.x + 1.5, pos.y + 1.5, pos.z,true, true, false)
    local rot_3 = ENTITY.GET_ENTITY_ROTATION(object[3], 2)
    rot_3.z = -90.0
    ENTITY.SET_ENTITY_ROTATION(object[3], rot_3.x, rot_3.y, rot_3.z, 1, true)

    object[4] = OBJECT.CREATE_OBJECT(objHash, pos.x - 1.5, pos.y + 1.5, pos.z,true, true, false)
    local rot_4 = ENTITY.GET_ENTITY_ROTATION(object[4], 2)
    rot_4.z = -90.0
    ENTITY.SET_ENTITY_ROTATION(object[4], rot_4.x, rot_4.y, rot_4.z, 1, true)
    ENTITY.IS_ENTITY_STATIC(object[1]) 
    ENTITY.IS_ENTITY_STATIC(object[2])
    ENTITY.IS_ENTITY_STATIC(object[3])
    ENTITY.IS_ENTITY_STATIC(object[4])
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[1], false) 
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[2], false) 
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[3], false) 
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[4], false) 

    for i = 1, 4 do ENTITY.FREEZE_ENTITY_POSITION(object[i], true) end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Competitive tube cage", function()
    script.run_in_fiber(function (dubcage)
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        STREAMING.REQUEST_MODEL(2081936690)
        while not STREAMING.HAS_MODEL_LOADED(2081936690) do		
            dubcage:sleep(100)
        end
        local cage_object = OBJECT.CREATE_OBJECT(2081936690, pos.x, pos.y, pos.z+20, true, true, false)
        local rot  = ENTITY.GET_ENTITY_ROTATION(cage_object, 2)
        rot.y = 90
        ENTITY.SET_ENTITY_ROTATION(cage_object, rot.x,rot.y,rot.z,1,true)
    end)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Safe cage", function()
    script.run_in_fiber(function (safecage)
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local hash = 1089807209
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do		
            STREAMING.REQUEST_MODEL(hash)
            safecage:yield()
        end
        local objectsfcage = {}
        objectsfcage[1] = OBJECT.CREATE_OBJECT(hash, pos.x - 0.9, pos.y, pos.z - 1, true, true, false) 
        objectsfcage[2] = OBJECT.CREATE_OBJECT(hash, pos.x + 0.9, pos.y, pos.z - 1, true, true, false) 
        objectsfcage[3] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y + 0.9, pos.z - 1, true, true, false) 
        objectsfcage[4] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y - 0.9, pos.z - 1, true, true, false) 
        objectsfcage[5] = OBJECT.CREATE_OBJECT(hash, pos.x - 0.9, pos.y, pos.z + 0.4 , true, true, false) 
        objectsfcage[6] = OBJECT.CREATE_OBJECT(hash, pos.x + 0.9, pos.y, pos.z + 0.4, true, true, false) 
        objectsfcage[7] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y + 0.9, pos.z + 0.4, true, true, false) 
        objectsfcage[8] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y - 0.9, pos.z + 0.4, true, true, false) 
        for i = 1, 8 do ENTITY.FREEZE_ENTITY_POSITION(objectsfcage[i], true) end
    end)
end)

gui.get_tab(""):add_sameline()

local pedvehctl = gui.get_tab(""):add_checkbox("Vehicle rotation")

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Electric shock", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, joaat("weapon_stungun"), PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 1.0)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Bombing", function()
    script.run_in_fiber(function (airst)
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        airshash = joaat("vehicle_weapon_trailer_dualaa")
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z- 1 , pos.x, pos.y, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z- 1 , pos.x+2, pos.y, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z- 1 , pos.x-2, pos.y, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z- 1 , pos.x-2, pos.y-2, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z- 1 , pos.x-2, pos.y+2, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 1 , pos.x, pos.y, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 1 , pos.x+2, pos.y, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 1 , pos.x-2, pos.y, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 1 , pos.x-2, pos.y-2, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 1 , pos.x-2, pos.y+2, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 3 , pos.x, pos.y, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 3, pos.x+2, pos.y, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 3, pos.x-2, pos.y, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 3 , pos.x-2, pos.y-2, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 3 , pos.x-2, pos.y+2, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 5, pos.x, pos.y, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 5 , pos.x+2, pos.y, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 5 , pos.x-2, pos.y, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 5, pos.x-2, pos.y-2, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 5 , pos.x-2, pos.y+2, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 7 , pos.x, pos.y, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 7 , pos.x+2, pos.y, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 7 , pos.x-2, pos.y, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 7 , pos.x-2, pos.y-2, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 7 , pos.x-2, pos.y+2, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 9 , pos.x, pos.y, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 9 , pos.x+2, pos.y, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 9 , pos.x-2, pos.y, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 9 , pos.x-2, pos.y-2, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 9 , pos.x-2, pos.y+2, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 11 , pos.x, pos.y, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 11 , pos.x+2, pos.y, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 11 , pos.x-2, pos.y, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 11 , pos.x-2, pos.y-2, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 11 , pos.x-2, pos.y+2, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 13 , pos.x, pos.y, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 13 , pos.x+2, pos.y, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 13 , pos.x-2, pos.y, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 13 , pos.x-2, pos.y-2, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 13 , pos.x-2, pos.y+2, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 15 , pos.x, pos.y, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 15 , pos.x+2, pos.y, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 15 , pos.x-2, pos.y, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 15 , pos.x-2, pos.y-2, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 15 , pos.x-2, pos.y+2, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 17 , pos.x, pos.y, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 17 , pos.x+2, pos.y, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 17 , pos.x-2, pos.y, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 17 , pos.x-2, pos.y-2, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 17 , pos.x-2, pos.y+2, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 19 , pos.x, pos.y, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 19 , pos.x+2, pos.y, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 19 , pos.x-2, pos.y, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 19 , pos.x-2, pos.y-2, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 19 , pos.x-2, pos.y+2, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 21 , pos.x, pos.y, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 21 , pos.x+2, pos.y, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 21 , pos.x-2, pos.y, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 21 , pos.x-2, pos.y-2, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 21 , pos.x-2, pos.y+2, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 23 , pos.x, pos.y, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 23 , pos.x+2, pos.y, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 23 , pos.x-2, pos.y, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 23 , pos.x-2, pos.y-2, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 23 , pos.x-2, pos.y+2, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 25 , pos.x, pos.y, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 25 , pos.x+2, pos.y, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 25 , pos.x-2, pos.y, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 25 , pos.x-2, pos.y-2, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 25 , pos.x-2, pos.y+2, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 27 , pos.x, pos.y, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 27 , pos.x+2, pos.y, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 27 , pos.x-2, pos.y, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 27 , pos.x-2, pos.y-2, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 27 , pos.x-2, pos.y+2, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 29 , pos.x, pos.y, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 29 , pos.x+2, pos.y, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 29 , pos.x-2, pos.y, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 29 , pos.x-2, pos.y-2, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 29 , pos.x-2, pos.y+2, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 31 , pos.x, pos.y, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 31 , pos.x+2, pos.y, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 31 , pos.x-2, pos.y, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 31 , pos.x-2, pos.y-2, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 31 , pos.x-2, pos.y+2, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 33 , pos.x, pos.y, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 33 , pos.x+2, pos.y, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-22, pos.y, pos.z+ 33 , pos.x-2, pos.y, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 33 , pos.x-2, pos.y-2, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 33 , pos.x-2, pos.y+2, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 35 , pos.x, pos.y, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 35 , pos.x+2, pos.y, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 35 , pos.x-2, pos.y, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-22, pos.y-2, pos.z+ 35 , pos.x-2, pos.y-2, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 35 , pos.x-2, pos.y+2, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 37 , pos.x, pos.y, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 37 , pos.x+2, pos.y, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 37 , pos.x-2, pos.y, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 37 , pos.x-2, pos.y-2, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 37 , pos.x-2, pos.y+2, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 39 , pos.x, pos.y, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 39 , pos.x+2, pos.y, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 39 , pos.x-2, pos.y, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 39 , pos.x-2, pos.y-2, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 39 , pos.x-2, pos.y+2, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 41 , pos.x, pos.y, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 41 , pos.x+2, pos.y, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 41 , pos.x-2, pos.y, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 41 , pos.x-2, pos.y-2, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 41 , pos.x-2, pos.y+2, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 43 , pos.x, pos.y, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 43 , pos.x+2, pos.y, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 43 , pos.x-2, pos.y, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 43 , pos.x-2, pos.y-2, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 43 , pos.x-2, pos.y+2, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 45 , pos.x, pos.y, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 45 , pos.x+2, pos.y, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 45 , pos.x-2, pos.y, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 45 , pos.x-2, pos.y-2, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 45 , pos.x-2, pos.y+2, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
    end)
end)

gui.get_tab(""):add_sameline()

local check8 = gui.get_tab(""):add_checkbox("Water column")

gui.get_tab(""):add_sameline()

local checknodmgexp = gui.get_tab(""):add_checkbox("No damage explosion")

gui.get_tab(""):add_sameline()

local checkcollection1 = gui.get_tab(""):add_checkbox("Drop playing cards") --来自fhen123_06870

gui.get_tab(""):add_sameline()

local checkCollectible = gui.get_tab(""):add_checkbox("Figurines RP drop")

local check2 = gui.get_tab(""):add_checkbox("Drop frame attack (as far away from the target as possible)")

gui.get_tab(""):add_sameline()

local check5 = gui.get_tab(""):add_checkbox("Particle effect bombing (as far away from the target as possible)")

gui.add_tab(""):add_sameline()

local checkspped = gui.get_tab(""):add_checkbox("Cycle brush PED")

gui.add_tab(""):add_sameline()

local checkxsdpednet = gui.add_tab(""):add_checkbox("NPC drops 2000 bucks cycle")

gui.add_tab(""):add_sameline()

local checkmoney = gui.get_tab(""):add_checkbox("Cash drop (only visible to yourself)") --来自fhen123_06870

gui.add_tab(""):add_button("Fragment crash", function()
    script.run_in_fiber(function (fragcrash)
        if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
            return
        end
        fraghash = joaat("prop_fragtest_cnst_04")
        STREAMING.REQUEST_MODEL(fraghash)
        local TargetCrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local crashstaff1 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(crashstaff1, 1, false)
        local crashstaff2 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(crashstaff2, 1, false)
        local crashstaff3 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(crashstaff3, 1, false)
        local crashstaff4 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(crashstaff4, 1, false)
        for i = 0, 100 do 
            if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
                return
            end    
            local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff1, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff2, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff3, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff4, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            fragcrash:sleep(10)
            delete_entity(crashstaff1)
            delete_entity(crashstaff2)
            delete_entity(crashstaff3)
            delete_entity(crashstaff4)
        end
    end)
    script.run_in_fiber(function (fragcrash2)
        local TargetCrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        fraghash = joaat("prop_fragtest_cnst_04")
        STREAMING.REQUEST_MODEL(fraghash)
        for i=1,10 do
            if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
                return
            end    
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            delete_entity(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            fragcrash2:sleep(100)
            delete_entity(object)
        end
    end)
end)

gui.add_tab(""):add_sameline()

gui.add_tab(""):add_button("Parachute Crash 2", function()
    script.run_in_fiber(function (t2crash)
        if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            gui.show_message("The attack has stopped", "The target has been detected to have left or the target is himself")
            return
        end
        PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),0xE5022D03)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()))
        t2crash:sleep(20)
        local p_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(network.get_selected_player()), true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()),p_pos.x,p_pos.y,p_pos.z,false,true,true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()), 0xFBAB5776, 1000, false)
        TASK.TASK_PARACHUTE_TO_TARGET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()),-1087,-3012,13.94)
        t2crash:sleep(500)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()))
        t2crash:sleep(1000)
        PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID())
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID()))
    end)
end)

gui.add_tab(""):add_sameline()

gui.add_tab(""):add_button("Model crash", function()
    script.run_in_fiber(function (vtcrash)
        if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
            return
        end
        local ship = {-1043459709, -276744698, 1861786828, -2100640717,}
        local pos117 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        OBJECT.CREATE_OBJECT(0x9CF21E0F, pos117.x, pos117.y, pos117.z, true, true, false)
        for crash, value in pairs (ship) do 
            local c = {} 
            for i = 1, 10, 1 do 
                if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                    gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
                    return
                end        
                local pos2010 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
                local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
                if calcDistance(selfpos, pos2010) <= 300 then 
                    gui.show_message("The attack has stopped","Please stay away from the target first")
                    return
                end
                c[crash] = CreateVehicle(value, pos2010, 0)
                if c[crash] then
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(c[crash], true, false) 
                    ENTITY.FREEZE_ENTITY_POSITION(c[crash])
                    ENTITY.SET_ENTITY_VISIBLE(c[crash], false, false)    
                end
            end 
        end
    end)

    script.run_in_fiber(function (vtcrash3)
        if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
            return
        end
        local mdl = joaat("mp_m_freemode_01")
        local veh_mdl = joaat("taxi")
        request_model(veh_mdl)
        request_model(mdl)
            for i = 1, 10 do
                local pos114 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(network.get_selected_player())
                if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                    gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
                    return
                end        
                local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
                if calcDistance(selfpos, pos114) <= 300 then 
                    gui.show_message("The attack has stopped","Please stay away from the target first")
                    return
                end
                local veh = CreateVehicle(veh_mdl, pos114, 0)
                local jesus = CreatePed(2, mdl, pos114, 0)
                if veh and jesus then 
                    ENTITY.SET_ENTITY_VISIBLE(veh, false, false)
                    ENTITY.SET_ENTITY_VISIBLE(jesus, false, false)
                    PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                    PED.SET_PED_COMBAT_ATTRIBUTES(jesus, 46, true)
                    PED.SET_PED_COMBAT_RANGE(jesus, 4)
                    PED.SET_PED_COMBAT_ABILITY(jesus, 3)
                    vtcrash3:sleep(100)
                    TASK.TASK_VEHICLE_HELI_PROTECT(jesus, veh, ped, 10.0, 0, 10, 0, 0)
                    vtcrash3:sleep(1000)
                    delete_entity(jesus)
                    delete_entity(veh)    
                end
            end  
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
    end)
    script.run_in_fiber(function (vtcrash2)
        for i = 1, 10, 1 do 
            if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
                return
            end    
            local anim_dict = "anim@mp_player_intupperstinker"
            STREAMING.REQUEST_ANIM_DICT(anim_dict)
            while not STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) do
                vtcrash2:yield()
            end
        local pos115 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        if calcDistance(selfpos, pos115) <= 300 then 
            gui.show_message("The attack has stopped","Please stay away from the target first")
            return
        end
        local ped = PED.CREATE_RANDOM_PED(pos115.x, pos115.y, pos115.z+10)
        ENTITY.SET_ENTITY_VISIBLE(ped, false, false)
        ENTITY.FREEZE_ENTITY_POSITION(ped, true)
        PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
        PED.SET_PED_COMBAT_RANGE(ped, 4)
        PED.SET_PED_COMBAT_ABILITY(ped, 3)
        for i = 1, 10 do
            if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                gui.show_message("The attack has stopped","The target has been detected to have left or the target is himself")
                return
            end    
            local pos116 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            if calcDistance(selfpos, pos116) <= 300 then 
                gui.show_message("The attack has stopped","Please stay away from the target first")
                return
            end
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, pos116.x, pos116.y, pos116.z+5, true, true, true)
            TASK.TASK_SWEEP_AIM_POSITION(ped, anim_dict, "Y", "M", "T", -1, 0.0, 0.0, 0.0, 0.0, 0.0)
            vtcrash2:sleep(1000)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        end
        delete_entity(ped)
        vtcrash2:sleep(750)
        end
    end)
end)

gui.add_tab(""):add_sameline()

local audiospam = gui.add_tab(""):add_checkbox("Sound bombing")

gui.add_tab(""):add_sameline()

gui.add_tab(""):add_button("Blame explosion", function()
    createplayertable()
    for _, exptar_player_id in pairs(player_Index_table) do
        FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED(network.get_selected_player()), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), true).x, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), true).y, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), true).z, 82, 1, true, false, 100)
    end
end)

gui.add_tab(""):add_button("Launch upward", function()
    script.run_in_fiber(function (launchply)

    local ped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    local tarveh = joaat("mule5")
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)

    STREAMING.REQUEST_MODEL(tarveh)
    while not STREAMING.HAS_MODEL_LOADED(tarveh) do		
        STREAMING.REQUEST_MODEL(tarveh)
        launchply:yield()
    end
    spd_veh = VEHICLE.CREATE_VEHICLE(tarveh, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).x,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).y,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).z, ENTITY.GET_ENTITY_HEADING(ped) , true, true, true)
	NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(spd_veh),false)
    ENTITY.SET_ENTITY_VISIBLE(spd_veh, false, false)
    launchply:sleep(300)
    ENTITY.APPLY_FORCE_TO_ENTITY(spd_veh, 1, 0.0, 0.0, 1000.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
    end)
end)

gui.get_tab(""):add_sameline()

gui.add_tab(""):add_button("Squeeze down", function()
    script.run_in_fiber(function (launchply)

    local ped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    local tarveh = joaat("mule5")
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)

    STREAMING.REQUEST_MODEL(tarveh)
    while not STREAMING.HAS_MODEL_LOADED(tarveh) do		
        STREAMING.REQUEST_MODEL(tarveh)
        launchply:yield()
    end
    spd_veh = VEHICLE.CREATE_VEHICLE(tarveh, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, 3.0).x,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).y,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).z, ENTITY.GET_ENTITY_HEADING(ped) , true, true, true)
	NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(spd_veh),false)
    ENTITY.SET_ENTITY_VISIBLE(spd_veh, false, false)
    launchply:sleep(300)
    ENTITY.APPLY_FORCE_TO_ENTITY(spd_veh, 1, 0.0, 0.0, -1000.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
    end)
end)

local plydist = gui.get_tab(""):add_input_float("Distance (m)")

gentab:add_separator()
gentab:add_text("Global options") 

gentab:add_button("Global chaos explosion", function()
    createplayertable()
    for _, exptar_player_id in pairs(player_Index_table) do
        local calctableLength = #player_Index_table
        local randomelem = math.random(1, calctableLength)
        local randomexpvictim = player_Index_table[randomelem]
        FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED(randomexpvictim), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), true).x, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), true).y, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), true).z, 82, 1, true, false, 100)
    end
end)

gentab:add_sameline()

gentab:add_button("Gift the opressor MK2", function()
    script.run_in_fiber(function (giftmk2)
        STREAMING.REQUEST_MODEL(joaat("oppressor2"))
        while not STREAMING.HAS_MODEL_LOADED(joaat("oppressor2")) do
            STREAMING.REQUEST_MODEL(joaat("oppressor2"))
            giftmk2:yield()
        end   
        for i = 0, 31 do
            log.info(tostring(i))
            spawncrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i), false)
            veh = VEHICLE.CREATE_VEHICLE(joaat("oppressor2"), spawncrds.x, spawncrds.y, spawncrds.z, 0 , true, true, true)
        end
    end)
end)

gentab:add_sameline()

gentab:add_button("Air defense alert", function()
    for pid = 0, 31 do
        aucoords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(pid), true)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "Air_Defences_Activated", aucoords.x, aucoords.y, aucoords.z, "DLC_sum20_Business_Battle_AC_Sounds", true, 999999999, true)
    end
end)

gentab:add_sameline()

gentab:add_button("Apartment invitation", function()
    for pid = 0, 31 do
    network.trigger_script_event(1 << pid, {3592101251, 1, 0, -1, 4, 127, 0, 0, 0,PLAYER.GET_PLAYER_INDEX(), pid})
    end
end)

gentab:add_sameline()

gentab:add_button("PED collapse", function() --恶毒的东西
    script.run_in_fiber(function (pedpacrash)
        gui.show_message("Umbrella collapse", "Please wait patiently until the character lands")
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), -74.94, -818.58, 327)
        local spped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
        local ppos = ENTITY.GET_ENTITY_COORDS(spped, true)
        for n = 0 , 5 do
            local object_hash = joaat("prop_logpile_06b")
            STREAMING.REQUEST_MODEL(object_hash)
              while not STREAMING.HAS_MODEL_LOADED(object_hash) do
                pedpacrash:yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, 0,0,500, false, true, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(spped, 0xFBAB5776, 1000, false)
            pedpacrash:sleep(1000)
            for i = 0 , 20 do
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 144, 1.0)
                PED.FORCE_PED_TO_OPEN_PARACHUTE(spped)
            end
            pedpacrash:sleep(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, ppos.x, ppos.y, ppos.z, false, true, true)
    
            local object_hash2 = joaat("prop_beach_parasol_03")
            STREAMING.REQUEST_MODEL(object_hash2)
            while not STREAMING.HAS_MODEL_LOADED(object_hash2) do
                pedpacrash:yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash2)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, 0,0,500, false, false, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(spped, 0xFBAB5776, 1000, false)
            pedpacrash:sleep(1000)
            for i = 0 , 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(spped)
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 144, 1.0)
            end
            pedpacrash:sleep(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, ppos.x, ppos.y, ppos.z, false, true, true)
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, ppos.x, ppos.y, ppos.z, false, true, true)    
    end)
end)

gentab:add_separator()
gentab:add_text("Variable Adjustment - Even if you set the scope to a large value, it is actually still limited by the game") 

gentab:add_text("NPC/vehicle force field range") 
gentab:add_sameline()
local ffrange = gentab:add_input_int("Force field radius (meters)")
ffrange:set_value(15)

gentab:add_text("NPC/vehicle batch control range") 
gentab:add_sameline()
npcctrlr = gentab:add_input_int("Control radius (m)")
npcctrlr:set_value(200)

gentab:add_text("NPC targeting penalty area of effect") 
gentab:add_sameline()
npcaimprange = gentab:add_input_int("Penalty radius (m)")
npcaimprange:set_value(1000)

gentab:add_text("Taxi automation at random intervals") 
gentab:add_sameline()
local taximin = gentab:add_input_int("Min (ms)")
taximin:set_value(0)
local taximax = gentab:add_input_int("Max(ms)")
taximax:set_value(0)
gentab:add_sameline()
local taximina = 0
local taximaxa = 0
gentab:add_button("Write Interval", function()
    if taximax:get_value() >= taximin:get_value() and taximin:get_value() >= 0 then
        taximina = taximin:get_value()
        taximaxa = taximax:get_value()
        gui.show_message("SUCCESS","Applied")
    else
        gui.show_message("Error ","Illegal input, has been reset")
        taximin:set_value(0)
        taximax:set_value(0)
    end
end)

gentab:add_text("Viewing lens height") 
gentab:add_sameline()
spcamh = gentab:add_input_int("Height (m)")
spcamh:set_value(5)

gentab:add_text("Viewing lens FOV") 
gentab:add_sameline()
spcamfov = gentab:add_input_float("Field of view (°)")
spcamfov:set_value(80.0)

gentab:add_text("Number of bodyguards in formation") 
gentab:add_sameline()
gtnum = gentab:add_input_int("Number of people")
gtnum:set_value(5)

gentab:add_separator()
gentab:add_text("Debugging") 

local DrawInteriorID = gentab:add_checkbox("Show Interior ID") --只是一个开关，代码往后面找

gentab:add_sameline()

local DrawMyHeading = gentab:add_checkbox("Show Heading") --只是一个开关，代码往后面找

gentab:add_sameline()

local desync = gentab:add_checkbox("Desync") --只是一个开关，代码往后面找

gentab:add_sameline()

local ptfxrm = gentab:add_checkbox("Clean up PTFX flame water column") --只是一个开关，代码往后面找

gentab:add_sameline()

local DECALrm = gentab:add_checkbox("Clean up traces on the surface of objects") --只是一个开关，代码往后面找

gentab:add_sameline()

local efxrm = gentab:add_checkbox("Reset filters and lens shake") --只是一个开关，代码往后面找

gentab:add_sameline()

local skippcus = gentab:add_checkbox("Continuously removing transitions") --只是一个开关，代码往后面找

gentab:add_button("Disable compatibility check", function()
    verchka1 = 100
    verchkok = 1
    log.warning("The verification of lua mismatching with the game version will be ignored, use of outdated functionality is at your own risk of corrupting the online data.")
    gui.show_error("The verification of lua mismatching with the game version will be ignored","You must bear the risk of damaging the online data")
end)

gentab:add_sameline()

gentab:add_button("ClearPEDtask", function()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
    ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), false)
end)

gentab:add_sameline()

gentab:add_button("PauseProcess", function()
    MISC.SET_GAME_PAUSED(true)
end)

gentab:add_sameline()

gentab:add_button("ResumeProcess", function()
    MISC.SET_GAME_PAUSED(false)
end)

gentab:add_sameline()

gentab:add_button("Force script host", function()
    network.force_script_host("fm_mission_controller_2020") --抢脚本主机
    network.force_script_host("fm_mission_controller") --抢脚本主机
end)

gentab:add_sameline()

local keepschost = gentab:add_checkbox("Keep script host") --只是一个开关，代码往后面找

gentab:add_sameline()

gentab:add_button("Load stats", function()
    while STATS.STAT_SLOT_IS_LOADED(0) == false or STATS.STAT_SLOT_IS_LOADED(1) == false do
    log.info("LOADINGSTATS")
    STATS.STAT_LOAD(0)
    STATS.STAT_LOAD(1)
    end
    log.info("LOADED")
end)

gentab:add_sameline()

gentab:add_button("Save stats", function()
    iVar0 = 0
    while iVar0 <= 2 do 
      STATS.STAT_SAVE(iVar0, 0, 0, 0)
      iVar0 = iVar0 + 1
    end
end)

gentab:add_sameline()

gentab:add_button("List blips", function() --调试，增强NPC控制条件判断
    log.info("-----------------------------begin------------PED------------------------------------------")
    local pedtable = entities.get_all_peds_as_handles()
    for _, peds in pairs(pedtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
        if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
            if HUD.GET_BLIP_SPRITE(HUD.GET_BLIP_FROM_ENTITY(peds)) ~= -1 then
                log.info(HUD.GET_BLIP_SPRITE(HUD.GET_BLIP_FROM_ENTITY(peds)).." color :"..HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)))
            end
        end
    end
    log.info("-----------------------------end------------PED------------------------------------------")
    log.info("-----------------------------begin------------VEH------------------------------------------")
    local vehtable = entities.get_all_vehicles_as_handles()
    for _, vehs in pairs(vehtable) do
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local veh_pos = ENTITY.GET_ENTITY_COORDS(vehs, true)
        if calcDistance(selfpos, veh_pos) <= npcctrlr:get_value() then 
            if HUD.GET_BLIP_SPRITE(HUD.GET_BLIP_FROM_ENTITY(vehs)) ~= -1 then
                log.info(HUD.GET_BLIP_SPRITE(HUD.GET_BLIP_FROM_ENTITY(vehs)).." color :"..HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehs)))
            end
        end
    end
    log.info("-----------------------------end------------VEH------------------------------------------")
end)

local emmode = gentab:add_checkbox("Emergency mode-Press Ctrl+S+D at the same time when the game is stuck due to a large number of swiping models, quickly escape the scene and pause the network synchronization (no need to leave the war situation)-if necessary, use it with the cycle to clear the entity function") --只是一个开关，代码往后面找
--emmode:set_enabled(true) --开启上方创建的复选框，删除此行代码后紧急模式1不会默认监听快捷键

local emmode2 = gentab:add_checkbox("Emergency Mode 2 - Press Ctrl+A+D to quickly escape to a new session") --只是一个开关，代码往后面找
emmode2:set_enabled(true) --开启上方创建的复选框，删除此行代码后紧急模式2不会默认监听快捷键

gentab:add_sameline()

local allclear = gentab:add_checkbox("Loop clear entity") --只是一个开关，代码往后面找

gentab:add_sameline()

gentab:add_button("Perico/Firm Contract Final Chapter/ULP 1 click Completion (Mandatory)", function()
    locals_set_int("fm_mission_controller_2020",48514,51338752)  --关键代码  --3095
    locals_set_int("fm_mission_controller_2020",50279,100) --关键代码 --3095
    locals_set_int("fm_mission_controller", 19728, 12) --3095
    locals_set_int("fm_mission_controller", 27489 + 859, 99999) --3095
    locals_set_int("fm_mission_controller", 31603 + 69, 99999) --3095
end)

local emmode3 = gentab:add_checkbox("Emergency Mode 3 - Continuously removes any entities + stops PTFX fire/water columns + stops filter and lens shake + cleans up traces on the surface of objects") --只是一个开关，代码往后面找

local rHDonly = gentab:add_checkbox("Render HD only") --只是一个开关，代码往后面找

gentab:add_sameline()

local deautocalc = gentab:add_checkbox("Disable calculation of player distance") --只是一个开关，代码往后面找

gentab:add_text("Obj generation (Name)") 
gentab:add_sameline()
local iputobjname = gentab:add_input_string("objname")
gentab:add_sameline()
gentab:add_button("Generate N", function()
    script.run_in_fiber(function (cusobj2)
        objHash = joaat(iputobjname:get_value())
        while not STREAMING.HAS_MODEL_LOADED(objHash) do	
            STREAMING.REQUEST_MODEL(objHash)
            cusobj2:yield()
        end
        local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
        local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z, true, true, false)
        ENTITY.SET_ENTITY_HEADING(obj, heading)
        end)
end)

gentab:add_text("Obj generation (Hash)") 
gentab:add_sameline()
local iputobjhash = gentab:add_input_string("objhash")
gentab:add_sameline()
gentab:add_button("Generate H", function()
    script.run_in_fiber(function (cusobj1)
        objHash = tonumber(iputobjhash:get_value())
        if objHash then
            while not STREAMING.HAS_MODEL_LOADED(objHash) do	
                STREAMING.REQUEST_MODEL(objHash)
                cusobj1:yield()
            end
            local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
            local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
            local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z, true, true, false)
            ENTITY.SET_ENTITY_HEADING(obj, heading)    
        end
        end)
end)

gentab:add_text("PTFX generation") ;gentab:add_sameline()
local iputptfxdic = gentab:add_input_string("PTFX Dic")
local iputptfxname = gentab:add_input_string("PTFX Name")
iputptfxdic:set_value("scr_rcbarry2")
iputptfxname:set_value("scr_clown_appears")
gentab:add_sameline()
gentab:add_button("generate ptfx", function()
    script.run_in_fiber(function (cusptfx)
        iputptfxdicval = iputptfxdic:get_value()
        iputptfxnameval = iputptfxname:get_value()
        STREAMING.REQUEST_NAMED_PTFX_ASSET(iputptfxdicval)
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(iputptfxdicval) do
            cusptfx:yield()
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET(iputptfxdicval)
        local tar1 = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(iputptfxnameval, tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 1.0, true, true, true, false)
    end)
end)

gentab:add_text("Play cutscenes") ;gentab:add_sameline()
local iputcuts = gentab:add_input_string("CUTSCENE")
iputcuts:set_value("mp_intro_concat")
gentab:add_sameline()
gentab:add_button("Play c", function()
    CUTSCENE.REQUEST_CUTSCENE(iputcuts:get_value(), 8)
    CUTSCENE.START_CUTSCENE(0)
end)
gentab:add_sameline()
gentab:add_button("Stop c", function()
    CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
    CUTSCENE.REMOVE_CUTSCENE()
end)

local cashmtp = gentab:add_checkbox("Set up Contact Person service income ratio")

gentab:add_sameline()

local cashmtpin = gentab:add_input_float("times-contact")

gui.get_tab(""):add_text("Debugging") 

gui.get_tab(""):add_text("Obj generation (Name)") 
gui.get_tab(""):add_sameline()
local iputobjnamer = gui.get_tab(""):add_input_string("objname")
gui.get_tab(""):add_sameline()
gui.get_tab(""):add_button("Generate N", function()
    script.run_in_fiber(function (cusobj2r)
        local targetplyped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local remotePos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        objHashr = joaat(iputobjnamer:get_value())
        while not STREAMING.HAS_MODEL_LOADED(objHashr) do	
            STREAMING.REQUEST_MODEL(objHashr)
            cusobj2r:yield()
        end
        local headingr = ENTITY.GET_ENTITY_HEADING(targetplyped)
        local objr = OBJECT.CREATE_OBJECT(objHashr, remotePos.x, remotePos.y, remotePos.z, true, true, false)
        ENTITY.SET_ENTITY_HEADING(objr, headingr)
        end)
end)

gui.get_tab(""):add_text("Obj generation (Hash)") 
gui.get_tab(""):add_sameline()
local iputobjhashr = gui.get_tab(""):add_input_string("objhash")
gui.get_tab(""):add_sameline()
gui.get_tab(""):add_button("Generate H", function()
    script.run_in_fiber(function (cusobj1r)
        local targetplyped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local remotePos = ENTITY.GET_ENTITY_COORDS(targetplyped, false)
        objHashr = tonumber(iputobjhashr:get_value())
        if objHashr then
            while not STREAMING.HAS_MODEL_LOADED(objHashr) do	
                STREAMING.REQUEST_MODEL(objHashr)
                cusobj1r:yield()
            end
            local headingr = ENTITY.GET_ENTITY_HEADING(targetplyped)
            local objr = OBJECT.CREATE_OBJECT(objHashr, remotePos.x, remotePos.y, remotePos.z, true, true, false)
            ENTITY.SET_ENTITY_HEADING(objr, headingr)    
        end
        end)
end)

gui.get_tab(""):add_text("PTFX generation") ;gui.get_tab(""):add_sameline()
local iputptfxdicr = gui.get_tab(""):add_input_string("PTFX Dic")
local iputptfxnamer = gui.get_tab(""):add_input_string("PTFX Name")
gui.get_tab(""):add_sameline()
gui.get_tab(""):add_button("Generate ptfx", function()
    script.run_in_fiber(function (cusptfxr)
        iputptfxdicvalr = iputptfxdicr:get_value()
        iputptfxnamevalr = iputptfxnamer:get_value()
        STREAMING.REQUEST_NAMED_PTFX_ASSET(iputptfxdicvalr)
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(iputptfxdicvalr) do
            cusptfxr:yield()
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET(iputptfxdicvalr)
        local tar1 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(iputptfxnamevalr, tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 1.0, true, true, true, false)
    end)
end)

--------------------------------------------------------------------------------------- 实体表
EntityTab:add_text("Entity table function will be set in accordance with the scope of entity control to obtain the corresponding entity to write lua table, and presented in the GUI, so that developers can test the entity control function.")

EntityTab:add_button("Write the player table", function()
    writeplayertable()
end)

EntityTab:add_sameline()

EntityTab:add_button("Write a list of NPCs", function()
    writepedtable()
end)

EntityTab:add_sameline()

EntityTab:add_button("Write a list of vehicle", function()
    writevehtable()
end)

EntityTab:add_sameline()

EntityTab:add_button("Write a list of objects", function()
    writeobjtable()
end)

EntityTab:add_sameline()

tableautorf = EntityTab:add_checkbox("Getting the player table and refreshing it automatically (used to counterattack enemies)")
EntityTab:add_text("Player Aiming Reaction")
plyaimkarma1 = EntityTab:add_checkbox("Shoot F") --这只是一个复选框,代码往最后的循环脚本部分找
EntityTab:add_sameline()
plyaimkarma2 = EntityTab:add_checkbox("Blow F") --这只是一个复选框,代码往最后的循环脚本部分找
EntityTab:add_sameline()
plyaimkarma3 = EntityTab:add_checkbox("Electroshock F") --这只是一个复选框,代码往最后的循环脚本部分找
EntityTab:add_sameline()
plyaimkarma4 = EntityTab:add_checkbox("Kick out F") --这只是一个复选框,代码往最后的循环脚本部分找

--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能
--存放一些变量，阻止无限循环，间接实现 checkbox 的 on_enable() 和 on_disable()

loopa1 = 0  --控制PED脚步声有无
loopa2 = 0  --控制头顶666
loopa3 = 0  --控制PED所有声音有无
loopa4 = 0  --控制声纳开关
loopa5 = 0  --控制喷火
loopa6 = 0  --控制火焰翅膀
loopa7 = 0  --控制警察调度
loopa8 = 0  --控制NPC零伤害
loopa9 = 0  --控制取消同步
loopa10 = 0  --控制恶灵骑士
loopa11 = 0  --控制PED热量
loopa12 = 0  --控制是否允许攻击队友
loopa13 = 0  --控制观看
loopa14 = 0  --控制远程载具无敌
loopa15 = 0  --控制远程载具无碰撞
loopa16 = 0  --控制世界灯光开关
loopa17 = 0  --控制头顶520
loopa18 = 0  --控制载具锁门
loopa19 = 0  --控制摩托帮地堡致幻剂生产速度
loopa20 = 0  --控制夜总会生产速度
loopa21 = 0  --控制夜总会生产速度
loopa22 = 0  --控制夜总会生产速度
loopa23 = 0  --控制夜总会生产速度
loopa24 = 0  --控制锁定小地图角度
loopa25 = 0  --控制防爆头
loopa26 = 0  --控制雷达假死
loopa27 = 0  --PTFX1
loopa28 = 0  --线上模式暂停
loopa29 = 0  --紧急模式1
loopa30 = 0  --紧急模式3
loopa31 = 0  --仅渲染高清
loopa32 = 0  --控制摩托帮地堡致幻剂生产速度
--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能
deva1 = 71
deva2 = 72
deva3 = 73
deva4 = 74
script.register_looped("schlua-test", function(script) 
    if  devmode == 1 then
        localmon1 = 50279
        deva1 = locals.get_int("fm_mission_controller_2020", localmon1)
        if deva1 ~= deva2 then
            deva2 = deva1
            log.info(tostring(localmon1.." : "..deva2))
        end

        localmon2 = 48514
        deva3 = locals.get_int("fm_mission_controller_2020", localmon2)
        if deva3 ~= deva4 then
            deva4 = deva3
            log.info(tostring(localmon2.." : "..deva4))
        end
    end
end)


script.register_looped("schlua-luatableautorefresh", function(script) 
    if  tableautorf:is_enabled() then
        writeplayertable()
    end
end)

script.register_looped("schlua-aimkarmaservice", function(script) 
    if  plyaimkarma1:is_enabled() then  --玩家瞄准自动反击-射击
        if not tableautorf:is_enabled() then
            tableautorf:set_enabled(true)
            gui.show_error("Auto-refresh player table not enabled","Auto-enabled")
        else
            if Is_Player_Aimming_Me() and plyaimkarma ~= nil then
                local pos = ENTITY.GET_ENTITY_COORDS(plyaimkarma.karmaped, true)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z + 0.1, 100, true, 100416529, PLAYER.PLAYER_PED_ID(), true, false, 100.0)
            end    
        end
    end

    if  plyaimkarma2:is_enabled() then--玩家瞄准自动反击-爆炸
        if not tableautorf:is_enabled() then
            tableautorf:set_enabled(true)
            gui.show_error("Auto-refresh player table not enabled","Auto-enabled")
        else
            if Is_Player_Aimming_Me() and plyaimkarma ~= nil then
                local pos = ENTITY.GET_ENTITY_COORDS(plyaimkarma.karmaped, true)
                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 1, 1, true, true, 1, false)
            end    
        end
    end
    
    if  plyaimkarma3:is_enabled() then--玩家瞄准自动反击-电击
        if not tableautorf:is_enabled() then
            tableautorf:set_enabled(true)
            gui.show_error("Auto-refresh player table not enabled","Auto-enabled")
        else
            if Is_Player_Aimming_Me() and plyaimkarma ~= nil then
                local pos = ENTITY.GET_ENTITY_COORDS(plyaimkarma.karmaped, true)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 10, true, joaat("weapon_stungun"), false, false, true, 1.0)
            end    
        end
    end
        
    if  plyaimkarma4:is_enabled() then--玩家瞄准自动反击-踢出
        if not tableautorf:is_enabled() then
            tableautorf:set_enabled(true)
            gui.show_error("Auto-refresh player table not enabled","Auto-enabled")
        else
            if Is_Player_Aimming_Me() and plyaimkarma ~= nil then
                command.call("multikick", {plyaimkarma.karmaplyindex})
            end    
        end
    end
end)

local selfposen
script.register_looped("schlua-emodedeamon", function(script) --紧急模式1、2
    if  emmode2:is_enabled() then
        if PAD.IS_CONTROL_PRESSED(0, 35) and PAD.IS_CONTROL_PRESSED(0, 34) and PAD.IS_CONTROL_PRESSED(0, 36) then  
        --PAD.IS_CONTROL_PRESSED(0, 35)表示按下键码为33的键时接收一个信号，上面一行表示同时按 35、34、36 时激活这个功能
        --https://docs.fivem.net/docs/game-references/controls/ 如需自定义，到这个网站查询控制35这样的数字对应的是键盘或手柄上的什么物理按键，替换掉对应的数字即可
            command.call("joinsession", { 1 })
            log.info("sch lua紧急模式2,已创建新战局")
            gui.show_message("sch lua emergency mode 2","New session has been created")
        end
    end

    if  emmode3:is_enabled() then
        if loopa30 == 0 then 
            allclear:set_enabled(true)
            DECALrm:set_enabled(true)
            efxrm:set_enabled(true)
            ptfxrm:set_enabled(true)
            log.info("紧急模式3已开启")
            loopa30 = 1
        end
    else 
        if loopa30 == 1 then 
            allclear:set_enabled(false)
            DECALrm:set_enabled(false)
            efxrm:set_enabled(false)
            ptfxrm:set_enabled(false)
            log.info("紧急模式3已关闭")
            loopa30 = 0
        end
    end

    if  emmode:is_enabled() then
        if loopa29 == 0 and PAD.IS_CONTROL_PRESSED(0, 33) and PAD.IS_CONTROL_PRESSED(0, 36) and PAD.IS_CONTROL_PRESSED(0, 35) then  
            log.info("紧急模式已开启,与所有玩家取消同步,同时按下WAD关闭")
            gui.show_message("Emergency mode is turned on","Cancel synchronization with all players, and press WAD to close at the same time")
            NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
            selfposen = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), -832, 177, 3000)
            ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), true)
            STREAMING.SET_FOCUS_POS_AND_VEL(-400, 5989, 3000, 0.0, 0.0, 0.0)
            anticcam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", false)
			CAM.SET_CAM_ACTIVE(anticcam, true)
			CAM.RENDER_SCRIPT_CAMS(true, true, 500, true, true, 0)
            loopa29 = 1
        end
        if loopa29 ==1 then
            rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)
            CAM.SET_CAM_ROT(anticcam, rotation.x, rotation.y, rotation.z, 2)
            CAM.SET_CAM_COORD(anticcam, -400, 5989, 3000)
            STREAMING.SET_FOCUS_POS_AND_VEL(-400, 5989, 3000, 0.0, 0.0, 0.0)
        end
        if loopa29 == 1 and PAD.IS_CONTROL_PRESSED(0, 32) and PAD.IS_CONTROL_PRESSED(0, 34) and PAD.IS_CONTROL_PRESSED(0, 35) then  
            log.info("紧急模式已关闭,恢复同步并移动至原位")
            gui.show_message("Emergency mode is turned off", "Restore synchronization and move to the original position")
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), selfposen.x, selfposen.y, selfposen.z)
            NETWORK.NETWORK_END_TUTORIAL_SESSION()
            ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), false)
            STREAMING.CLEAR_FOCUS() 
            CAM.SET_CAM_ACTIVE(anticcam, false)
			CAM.RENDER_SCRIPT_CAMS(false, true, 500, true, true, 0)
			CAM.DESTROY_CAM(anticcam, false)
			STREAMING.CLEAR_FOCUS()    
            loopa29 = 0
        end
    else 
        if loopa29 == 1 then
            log.info("紧急模式已关闭,恢复同步并移动至原位")
            gui.show_message("Emergency mode is turned off", "Restore synchronization and move to the original position")
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), selfposen.x, selfposen.y, selfposen.z)
            NETWORK.NETWORK_END_TUTORIAL_SESSION()
            ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), false)
            STREAMING.CLEAR_FOCUS() 
            CAM.SET_CAM_ACTIVE(anticcam, false)
			CAM.RENDER_SCRIPT_CAMS(false, true, 500, true, true, 0)
			CAM.DESTROY_CAM(anticcam, false)
            loopa29 = 0
        end
    end
end)

script.register_looped("schlua-taxiservice", function(script) 
    if  taxisvs:is_enabled() then
    local psgcrd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(HUD.GET_CLOSEST_BLIP_INFO_ID(280)), 0, 6, 0)
    if HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) then
        if psgcrd.x ~= 0 then
            log.info("发现乘客")
            script:sleep(500)
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), psgcrd.x, psgcrd.y, psgcrd.z, false, false, false, false)
            script:sleep(1000)
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 86, 1)
            log.info("乘客将加速上车")
            local pedtable = entities.get_all_peds_as_handles()
            for _, peds in pairs(pedtable) do
                local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
                local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
                if calcDistance(selfpos, ped_pos) <= 15 and peds ~= PLAYER.PLAYER_PED_ID() and ped then 
                    PED.SET_PED_MOVE_RATE_OVERRIDE(ped, 50.0)
                end
            end
            while HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) do
                script:yield()
            end
            log.info("乘客已上车")
            script:sleep(500)
            command.call("objectivetp",{}) --调用Yimmenu自身传送到目标点命令
            log.info("传送到目的地")
            delms = math.random(taximina, taximaxa)
            log.info(delms.."毫秒后执行下一轮出租车工作")
            script:sleep(delms)
        end
    else
    end
    end

    if  taxisvs2:is_enabled() then
        local psgcrd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(HUD.GET_CLOSEST_BLIP_INFO_ID(280)), 0, 6, 0)
        if HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) then
            if psgcrd.x ~= 0 then
                log.info("发现乘客,正在驾驶前往.按下Shift可立即传送跳过")
                script:sleep(500)
                local ped = PLAYER.PLAYER_PED_ID()
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                local vehselfisin = ENTITY.GET_ENTITY_MODEL(vehicle)
                local psgcrd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(HUD.GET_CLOSEST_BLIP_INFO_ID(280)), 0, 6, 0)
                PED.SET_DRIVER_ABILITY(ped, 1.0)
                PED.SET_DRIVER_AGGRESSIVENESS(ped, 0.6)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, vehicle, psgcrd.x, psgcrd.y, psgcrd.z, 200, 1, vehselfisin, 787004, 5.0, 1.0) 
                script:sleep(1500)
                while calcDistance(ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true), ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(HUD.GET_CLOSEST_BLIP_INFO_ID(280)), 0, 6, 0)) >= 15 and not ENTITY.IS_ENTITY_STATIC(PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true), true) do
                    if PAD.IS_CONTROL_PRESSED(0, 352)  then --按下Shift
                        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), psgcrd.x, psgcrd.y, psgcrd.z, false, false, false, false)
                        script:sleep(1500)
                        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 86, 1)
                    end
                    script:yield()
                end
                script:sleep(1500)
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 86, 1)
                while HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) do
                    if PAD.IS_CONTROL_PRESSED(0, 352)  then --按下Shift
                        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), psgcrd.x, psgcrd.y, psgcrd.z, false, false, false, false)
                        script:sleep(1500)
                        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 86, 1)
                    end
                    script:yield()
                end
                log.info("乘客已上车")
                script:sleep(1500)
                objcrd = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(1))

                local vehselfisin = ENTITY.GET_ENTITY_MODEL(vehicle)
                local ped = PLAYER.PLAYER_PED_ID()
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                local psgcrd = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(HUD.GET_CLOSEST_BLIP_INFO_ID(280)), 0, 6, 0)
                PED.SET_DRIVER_ABILITY(ped, 1.0)
                PED.SET_DRIVER_AGGRESSIVENESS(ped, 0.6)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, vehicle, objcrd.x, objcrd.y, objcrd.z, 200, 1, vehselfisin, 787004, 5.0, 1.0) 
                script:sleep(1500)
                log.info("正在自动驾驶前往目的地,按下shift可立即传送跳过")
                while calcDistance(ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true), HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(1))) >= 15 and not ENTITY.IS_ENTITY_STATIC(PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)) do
                    if PAD.IS_CONTROL_PRESSED(0, 352)  then --按下Shift
                        command.call("objectivetp",{}) --调用Yimmenu自身传送到目标点命令
                    end
                    script:yield()
                end
                if HUD.DOES_BLIP_EXIST(HUD.GET_FIRST_BLIP_INFO_ID(1)) then
                    log.info("自动驾驶未能精准到达目的地,将使用传送补救")
                    command.call("objectivetp",{}) --调用Yimmenu自身传送到目标点命令
                end
                delms = math.random(taximina, taximaxa)
                log.info(delms.."毫秒后执行下一轮出租车工作")
                script:sleep(delms)
            end
        else
        end
        end
    
end)

script.register_looped("schlua-recoveryservice", function(script) 

    if  checkxsdped:is_enabled() then --NPC掉落2000元循环    --自身
        PED.SET_AMBIENT_PEDS_DROP_MONEY(true) --自由模式NPC是否掉钱
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        TargetPPos.z = TargetPPos.z + 10 --让 席桑达 生成在空中然后摔下来
        STREAMING.REQUEST_MODEL(3552233440)
        local PED1 = PED.CREATE_PED(28, 3552233440, TargetPPos.x, TargetPPos.y, TargetPPos.z, 0, true, true)--刷出的NPC是 席桑达
        PED.SET_PED_MONEY(PED1,2000) --上限就是2000,不能超过
        ENTITY.SET_ENTITY_HEALTH(PED1,1,0,0)--刷出的NPC 席桑达 血量只有 1
        script:sleep(300) --间隔 300 毫秒
    end

    if  checkxsdpednet:is_enabled() then --NPC掉落2000元循环    --玩家选项
        if PLAYER.GET_PLAYER_PED(network.get_selected_player()) ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            PED.SET_AMBIENT_PEDS_DROP_MONEY(true) --自由模式NPC是否掉钱
            local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
            TargetPPos.z = TargetPPos.z + 10 --让 席桑达 生成在空中然后摔下来
            STREAMING.REQUEST_MODEL(3552233440)
            local netxsdPed = PED.CREATE_PED(28, 3552233440, TargetPPos.x, TargetPPos.y, TargetPPos.z, 0, true, true)--刷出的NPC是 席桑达
            PED.SET_PED_MONEY(netxsdPed,2000) --上限就是2000,不能超过
            ENTITY.SET_ENTITY_HEALTH(netxsdPed,1,0,0)--刷出的NPC 席桑达 血量只有 1
            script:sleep(300) --间隔 300 毫秒

        else
            gui.show_message("Stopped", "The target cannot be yourself!")
            checkxsdpednet:set_enabled(false) --目标是自己，自动关掉开关
        end
    end

    if  checkcollection1:is_enabled() then --循环刷纸牌给玩家
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
        coords.z = coords.z + 2.0
        if is_collection1 == 0 then
            is_collection1 = 1 
            coordsObj =  create_object(joaat("vw_prop_vw_lux_card_01a"),coords)
        end
        OBJECT.CREATE_AMBIENT_PICKUP(-1009939663, coords.x, coords.y, coords.z, 0, 1, joaat("vw_prop_vw_lux_card_01a"), false, true)
    end

    if  checkCollectible:is_enabled() then --循环给手办玩家
        local  coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
        coords.z = coords.z + 2.0
        if is_GK == 0 then
            is_GK = 1 
            create_object(joaat("vw_prop_vw_colle_prbubble"), coords)
        end
        OBJECT.CREATE_AMBIENT_PICKUP(-1009939663, coords.x, coords.y, coords.z, 0, 1, joaat("vw_prop_vw_colle_prbubble"), false, true)
    end

    if  checkmoney:is_enabled() then --循环给钱袋玩家
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
        coords.z = coords .z + 2.0
        if is_money == 0 then
            is_money = 1 
            create_object(0x9CA6F755, coords)
        end
        money = joaat("PICKUP_MONEY_SECURITY_CASE")
        money_bag = 0x9CA6F755
        OBJECT.CREATE_AMBIENT_PICKUP(money, coords.x, coords.y, coords.z, 0, 2500,money_bag, false, true)
    end
    
end)

script.register_looped("schlua-ml2", function(script)  -- 3095
    
    if  autorespl:is_enabled() then--自动补原材料
        if stats.get_int("MPX_MATTOTALFORFACTORY0") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY0") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+0,1) --假钞
            log.info("假钞原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY1") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY1") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+1,1) --kky
            log.info("可卡因原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY2") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY2") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+2,1) --bd
            log.info("冰毒原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY3") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY3") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+3,1) --dm
            log.info("大麻原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY4") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY4") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+4,1) --id
            log.info("证件原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY5") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY5") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+5,1) --bk
            log.info("地堡原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY6") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY6") <= 40 and autoresply == 0 then 
            globals_set_int(1662873+1+6,1) --acid
            log.info("致幻剂原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
    end
end)

script.register_looped("schlua-dataservice", function(script) 

    if  check1:is_enabled() then --移除交易错误警告
        globals_set_int(4537356,0)  --3095 -- shop_controller.c 	 if (Global_4536677)    HUD::SET_WARNING_MESSAGE_WITH_HEADER("CTALERT_A" /*Alert*/, func_1372(Global_4536683), instructionalKey, 0, false, -1, 0, 0, true, 0);
        globals_set_int(4537357,0) --3095  -- shop_controller.c   HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("CTALERT_F_1" /*Rockstar game servers could not process this transaction. Please try again and check ~HUD_COLOUR_SOCIAL_CLUB~www.rockstargames.com/support~s~ for information about current issues, outages, or scheduled maintenance periods.*/);
        globals_set_int(4537358,0) --3095 -- shop_controller.c   HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("CTALERT_F_1" /*Rockstar game servers could not process this transaction. Please try again and check ~HUD_COLOUR_SOCIAL_CLUB~www.rockstargames.com/support~s~ for information about current issues, outages, or scheduled maintenance periods.*/);
    end

    if  checkCEOcargo:is_enabled() then--锁定CEO仓库进货数
        if inputCEOcargo:get_value() <= 111 then --判断一下有没有人一次进天文数字箱货物、或者乱按的

        globals_set_int(1882389+12,inputCEOcargo:get_value()) --3095 --核心代码 --freemode.c      func_17512("SRC_CRG_TICKER_1" /*~a~ Staff has sourced: ~n~1 Crate: ~a~*/, func_6676(hParam0), func_17513(Global_1890714.f_15), HUD_COLOUR_PURE_WHITE, HUD_COLOUR_PURE_WHITE);

        else
            gui.show_error("Exceeding the limit","The number of purchases exceeds the upper limit of warehouse capacity")
            checkCEOcargo:set_enabled(false)
        end
    end

    if  check4:is_enabled() then--锁定机库仓库进货数
        globals_set_int(1882413+6,iputint3:get_value()) --freemode.c  -- 3095 --  "HAN_CRG_TICKER_2"   -- func_10326("HAN_CRG_TICKER_1", str, HUD_COLOUR_PURE_WHITE, HUD_COLOUR_PURE_WHITE, false);
    end

    if  cashmtp:is_enabled() and cashmtpin:get_value() >= 0 then--锁定普通联系人差事奖励倍率
        if tunables.get_float("CASH_MULTIPLIER") ~= cashmtpin:get_value() then
            formattedcashmtpin = string.format("%.3f", cashmtpin:get_value())
            gui.show_message("Contact task income multiplier",formattedcashmtpin.."倍")
            tunables.set_float("CASH_MULTIPLIER",cashmtpin:get_value())
        end
    end

    if  checklkw:is_enabled() then--锁定名钻赌场幸运轮盘奖品--只影响实际结果，不影响转盘显示
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("casino_lucky_wheel")) ~= 0 then
            locals_set_int("casino_lucky_wheel",292,18) -- 3095  -- 276 + 14
        end
        --char* func_180() // Position - 0x7354   --return "CAS_LW_VEHI" /*Congratulations!~n~You won the podium vehicle.*/;
        --你可以自定义代码中的18来获取其他物品。设定为18是展台载具，16衣服，17经验，19现金，4载具折扣，11神秘礼品，15 chips不认识是什么
    end

    if  bkeasyms:is_enabled() then--锁定摩托帮出货任务 
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_biker_contraband_sell")) ~= 0 then
            if locals.get_int("gb_biker_contraband_sell",719) ~= 0 then --3095
                log.info("已锁定摩托帮产业出货任务类型.目标出货载具生成前不要关闭此开关.注意:此功能与摩托帮一键完成出货冲突")
                locals_set_int("gb_biker_contraband_sell",719,0) -- gb_biker_contraband_sell.c	randomIntInRange = MISC::GET_RANDOM_INT_IN_RANGE(0, 13); --iLocal_699.f_17 = randomIntInRange;
            end    
        end
    end

    if  ccrgsl:is_enabled() then--锁定CEO仓库出货任务 
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_contraband_sell")) ~= 0 then
            if locals.get_int("gb_contraband_sell",550) ~= 12 then -- 3095
                log.info("已锁定CEO仓库出货任务类型.目标出货载具生成前不要关闭此开关")
                locals_set_int("gb_contraband_sell",550,12) -- gb_contraband_sell.c	randomIntInRange = MISC::GET_RANDOM_INT_IN_RANGE(0, 14); --iLocal_541.f_7 = randomIntInRange;
            end
        end
    end

    if  bussp:is_enabled() then--锁定地堡摩托帮致幻剂生产速度
        local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID  --用于判断当前是角色1还是角色2
        if loopa32 == 0 then
            gui.show_message("Next time the production is triggered to take effect","Change session immediately?"")
        end
        if tunables.get_int("BIKER_WEED_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("BIKER_WEED_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("BIKER_METH_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("BIKER_METH_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("BIKER_CRACK_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("BIKER_CRACK_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("BIKER_FAKEIDS_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("BIKER_FAKEIDS_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("BIKER_COUNTERCASH_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("BIKER_COUNTERCASH_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("BIKER_ACID_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("BIKER_ACID_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("GR_MANU_PRODUCTION_TIME") ~= 5000 then
            tunables.set_int("GR_MANU_PRODUCTION_TIME", 5000)
        end
        if tunables.get_int("GR_MANU_UPGRADE_STAFF_REDUCTION_TIME") ~= 5000 then
            tunables.set_int("GR_MANU_UPGRADE_STAFF_REDUCTION_TIME", 5000)
        end
        if tunables.get_int("GR_MANU_UPGRADE_EQUIPMENT_REDUCTION_TIME") ~= 5000 then
            tunables.set_int("GR_MANU_UPGRADE_EQUIPMENT_REDUCTION_TIME", 5000)
        end
        loopa32 =1
    else
        if loopa32 == 1 then 
            tunables.set_int("BIKER_WEED_PRODUCTION_TIME", 360000) 
            tunables.set_int("BIKER_METH_PRODUCTION_TIME", 1800000) 
            tunables.set_int("BIKER_CRACK_PRODUCTION_TIME", 3000000) 
            tunables.set_int("BIKER_FAKEIDS_PRODUCTION_TIME", 300000) 
            tunables.set_int("BIKER_COUNTERCASH_PRODUCTION_TIME", 720000) 
            tunables.set_int("BIKER_ACID_PRODUCTION_TIME", 135000) 
            tunables.set_int("GR_MANU_PRODUCTION_TIME", 600000)
            tunables.set_int("GR_MANU_UPGRADE_STAFF_REDUCTION_TIME", 90000)
            tunables.set_int("GR_MANU_UPGRADE_EQUIPMENT_REDUCTION_TIME", 90000)
            loopa32 =0
        end    
    end

    if  bussp2:is_enabled() then--锁定地堡摩托帮致幻剂生产速度
        local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID  --用于判断当前是角色1还是角色2
        if loopa19 == 0 then
            gui.show_message("The next time the production is triggered, it will take effect", "Sometimes the battle change can take effect immediately?")
        end
        if tunables.get_int("BIKER_WEED_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("BIKER_WEED_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("BIKER_METH_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("BIKER_METH_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("BIKER_CRACK_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("BIKER_CRACK_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("BIKER_FAKEIDS_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("BIKER_FAKEIDS_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("BIKER_COUNTERCASH_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("BIKER_COUNTERCASH_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("BIKER_ACID_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("BIKER_ACID_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("GR_MANU_PRODUCTION_TIME") ~= 60000 then
            tunables.set_int("GR_MANU_PRODUCTION_TIME", 60000)
        end
        if tunables.get_int("GR_MANU_UPGRADE_STAFF_REDUCTION_TIME") ~= 60000 then
            tunables.set_int("GR_MANU_UPGRADE_STAFF_REDUCTION_TIME", 60000)
        end
        if tunables.get_int("GR_MANU_UPGRADE_EQUIPMENT_REDUCTION_TIME") ~= 60000 then
            tunables.set_int("GR_MANU_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
        end
        loopa19 =1
    else
        if loopa19 == 1 then 
            tunables.set_int("BIKER_WEED_PRODUCTION_TIME", 360000) 
            tunables.set_int("BIKER_METH_PRODUCTION_TIME", 1800000) 
            tunables.set_int("BIKER_CRACK_PRODUCTION_TIME", 3000000) 
            tunables.set_int("BIKER_FAKEIDS_PRODUCTION_TIME", 300000) 
            tunables.set_int("BIKER_COUNTERCASH_PRODUCTION_TIME", 720000) 
            tunables.set_int("BIKER_ACID_PRODUCTION_TIME", 135000) 
            tunables.set_int("GR_MANU_PRODUCTION_TIME", 600000)
            tunables.set_int("GR_MANU_UPGRADE_STAFF_REDUCTION_TIME", 90000)
            tunables.set_int("GR_MANU_UPGRADE_EQUIPMENT_REDUCTION_TIME", 90000)
            loopa19 =0
        end    
    end
    
    if  ncspup:is_enabled() then--锁定夜总会生产速度
        if loopa20 == 0 then
            gui.show_message("It will take effect the next time production is triggered","Reassign employees to take effect immediately")
        end
        if tunables.get_int(-147565853) ~= 5000 then
            tunables.set_int(-147565853, 5000)
        end
        if tunables.get_int(-1390027611) ~= 5000 then
            tunables.set_int(-1390027611, 5000)
        end
        if tunables.get_int(-1292210552) ~= 5000 then
            tunables.set_int(-1292210552, 5000)
        end
        if tunables.get_int(1007184806) ~= 5000 then
            tunables.set_int(1007184806, 5000)
        end
        if tunables.get_int(18969287) ~= 5000 then
            tunables.set_int(18969287, 5000)
        end
        if tunables.get_int(-863328938) ~= 5000 then
            tunables.set_int(-863328938, 5000)
        end
        if tunables.get_int(1607981264) ~= 5000 then
            tunables.set_int(1607981264, 5000)
        end
        loopa20 =1
    else
        if loopa20 == 1 then
            tunables.set_int(-147565853, 14400000)
            tunables.set_int(-1390027611, 7200000)
            tunables.set_int(-1292210552, 2400000)
            tunables.set_int(1007184806, 2400000)
            tunables.set_int(18969287, 1800000)
            tunables.set_int(-863328938, 3600000)
            tunables.set_int(1607981264, 8400000)
            loopa20 =0
        end    
    end

    if  ncspupa1:is_enabled() then--锁定夜总会生产速度x4
        if loopa21 == 0 then
            gui.show_message("It will take effect the next time production is triggered","Reassign employees to take effect immediately")
        end
        if tunables.get_int(-147565853) ~= 3600000 then
            tunables.set_int(-147565853, 3600000)
        end
        if tunables.get_int(-1390027611) ~= 1800000 then
            tunables.set_int(-1390027611, 1800000)
        end
        if tunables.get_int(-1292210552) ~= 600000 then
            tunables.set_int(-1292210552, 600000)
        end
        if tunables.get_int(1007184806) ~= 600000 then
            tunables.set_int(1007184806, 600000)
        end
        if tunables.get_int(18969287) ~= 450000 then
            tunables.set_int(18969287, 450000)
        end
        if tunables.get_int(-863328938) ~= 900000 then
            tunables.set_int(-863328938, 900000)
        end
        if tunables.get_int(1607981264) ~= 2100000 then
            tunables.set_int(1607981264, 2100000)
        end
        loopa21 =1
    else
        if loopa21 == 1 then 
            tunables.set_int(-147565853, 14400000)
            tunables.set_int(-1390027611, 7200000)
            tunables.set_int(-1292210552, 2400000)
            tunables.set_int(1007184806, 2400000)
            tunables.set_int(18969287, 1800000)
            tunables.set_int(-863328938, 3600000)
            tunables.set_int(1607981264, 8400000)
            loopa21 =0
        end    
    end

    if  ncspupa2:is_enabled() then--锁定夜总会生产速度x10
        if loopa22 == 0 then
            gui.show_message("It will take effect the next time production is triggered","Reassign employees to take effect immediately")
        end
        if tunables.get_int(-147565853) ~= 1440000 then
            tunables.set_int(-147565853, 1440000)
        end
        if tunables.get_int(-1390027611) ~= 720000 then
            tunables.set_int(-1390027611, 720000)
        end
        if tunables.get_int(-1292210552) ~= 240000 then
            tunables.set_int(-1292210552, 240000)
        end
        if tunables.get_int(1007184806) ~= 240000 then
            tunables.set_int(1007184806, 240000)
        end
        if tunables.get_int(18969287) ~= 180000 then
            tunables.set_int(18969287, 180000)
        end
        if tunables.get_int(-863328938) ~= 360000 then
            tunables.set_int(-863328938, 360000)
        end
        if tunables.get_int(1607981264) ~= 840000 then
            tunables.set_int(1607981264, 840000)
        end
        loopa22 =1
    else
        if loopa22 == 1 then 
            tunables.set_int(-147565853, 14400000)
            tunables.set_int(-1390027611, 7200000)
            tunables.set_int(-1292210552, 2400000)
            tunables.set_int(1007184806, 2400000)
            tunables.set_int(18969287, 1800000)
            tunables.set_int(-863328938, 3600000)
            tunables.set_int(1607981264, 8400000)
            loopa22 =0
        end    
    end

    if  ncspupa3:is_enabled() then--锁定夜总会生产速度x20
        if loopa23 == 0 then
            gui.show_message("It will take effect the next time production is triggered","Reassign employees to take effect immediately")
        end
        if tunables.get_int(-147565853) ~= 720000 then
            tunables.set_int(-147565853, 720000)
        end
        if tunables.get_int(-1390027611) ~= 360000 then
            tunables.set_int(-1390027611, 360000)
        end
        if tunables.get_int(-1292210552) ~= 120000 then
            tunables.set_int(-1292210552, 120000)
        end
        if tunables.get_int(1007184806) ~= 120000 then
            tunables.set_int(1007184806, 120000)
        end
        if tunables.get_int(18969287) ~= 90000 then
            tunables.set_int(18969287, 90000)
        end
        if tunables.get_int(-863328938) ~= 180000 then
            tunables.set_int(-863328938, 180000)
        end
        if tunables.get_int(1607981264) ~= 420000 then
            tunables.set_int(1607981264, 420000)
        end
        loopa23 =1
    else
        if loopa23 == 1 then 
            tunables.set_int(-147565853, 14400000)
            tunables.set_int(-1390027611, 7200000)
            tunables.set_int(-1292210552, 2400000)
            tunables.set_int(1007184806, 2400000)
            tunables.set_int(18969287, 1800000)
            tunables.set_int(-863328938, 3600000)
            tunables.set_int(1607981264, 8400000)
            loopa23 =0
        end    
    end


    

    if checkmiss:is_enabled() then --虎鲸导弹 冷却、距离
        tunables.set_int("IH_SUBMARINE_MISSILES_COOLDOWN", 0) --tuneables_processing.c 
        tunables.set_int("IH_SUBMARINE_MISSILES_DISTANCE", 80000) --tuneables_processing.c IH_SUBMARINE_MISSILES_DISTANCE
    end

    if checkbypassconv:is_enabled() then  --跳过NPC对话
        if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
            AUDIO.STOP_SCRIPTED_CONVERSATION(false)
        end
    end

    if checkzhongjia:is_enabled() then --锁定请求重甲花费
        if iputintzhongjia:get_value() <= 500 then --防止有人拿删除钱设置为负反向刷钱  乐
            gui.show_error("Error","The amount needs to be greater than 500")
            checkzhongjia:set_enabled(false)
            else
                globals_set_int(262145 + 20498, iputintzhongjia:get_value()) -- 3095 --核心代码 --am_pi_menu.c  func_1277("PIM_TBALLI" /*BALLISTIC EQUIPMENT SERVICES*/);
            end
    end
end)


defpttable = {}
defpscount2 = 1
defpscount = 200 --刷200个模型

script.register_looped("schlua-defpservice", function(script) 

    if  checkspped:is_enabled() then--刷模型
        local sppedtarget = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        if sppedtarget ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            request_model(0x705E61F2)
            local pcrds = ENTITY.GET_ENTITY_COORDS(sppedtarget, false)
            local spped = PED.CREATE_PED(26, 0x705E61F2, pcrds.x, pcrds.y, pcrds.z -1 , 0, true, false)
            WEAPON.GIVE_WEAPON_TO_PED(spped,-270015777,80,true,true)
            ENTITY.SET_ENTITY_HEALTH(spped,1000,0,0)
            MISC.SET_RIOT_MODE_ENABLED(true)
            script:sleep(30)
        else
            gui.show_message("The frame drop attack has stopped", "You are attacking yourself!")
            checkspped:set_enabled(false) --目标是自己，自动关掉开关
        end
    end
    
    if  audiospam:is_enabled() then--声音轰炸
        local targetplyped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local pcrds = ENTITY.GET_ENTITY_COORDS(targetplyped, false)
           -- AUDIO.PLAY_SOUND_FROM_COORD(-1, "Air_Defences_Activated", pcrds.x, pcrds.y, pcrds.z, "DLC_sum20_Business_Battle_AC_Sounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, 'Event_Message_Purple', pcrds.x, pcrds.y, pcrds.z, 'GTAO_FM_Events_Soundset', true, 1000, false)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, '5s', pcrds.x, pcrds.y, pcrds.z, 'GTAO_FM_Events_Soundset', true, 1000, false)
            AUDIO.PLAY_SOUND_FROM_COORD(-1,"10s",pcrds.x,pcrds.y,pcrds.z,"MP_MISSION_COUNTDOWN_SOUNDSET",true, 70, false)
    end

    if  check2:is_enabled() then--卡死玩家
        local defpstarget = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local targetcoords = ENTITY.GET_ENTITY_COORDS(defpstarget, true)
        
        local hash = joaat("tug")
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do script:yield() end
        
        for i = 1, defpscount do
            if defpstarget ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            
            defpttable[defpscount2] = VEHICLE.CREATE_VEHICLE(hash, targetcoords.x, targetcoords.y, targetcoords.z, 0, true, true, true)
        
            local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(defpttable[defpscount2])
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(defpttable[defpscount2])
            NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID, true)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, network.get_selected_player(), true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(defpttable[defpscount2], true, false)
            ENTITY.SET_ENTITY_VISIBLE(defpttable[defpscount2], false, false)
            else
                gui.show_message("The frame drop attack has stopped", "You are attacking yourself!")
                check2:set_enabled(false)--目标是自己，自动关掉开关
            end
        end
        end

        if  check5:is_enabled() then --粒子效果轰炸
            local defpstarget = PLAYER.GET_PLAYER_PED(network.get_selected_player())
            local tar1 = ENTITY.GET_ENTITY_COORDS(defpstarget, false)
            local ptfx = {dic = 'scr_rcbarry2', name = 'scr_clown_appears'}
        
            if defpstarget ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx.dic)
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfx.dic) do
                    script:yield()
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx.dic)
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD( ptfx.name, tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 10.0, true, true, true, false)
            else
                gui.show_message("ptfx bombing stopped", "You are attacking yourself!")
                check5:set_enabled(false)--目标是自己，自动关掉开关
            end

        end

        if  check8:is_enabled() then --水柱
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z - 2.0, 13, 1, true, false, 0, false)
        end

        if  checknodmgexp:is_enabled() then --循环无伤爆炸
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 1, 1, true, true, 1, true)
        end

end)

script.register_looped("schlua-miscservice", function(script) 
    if  checkfootaudio:is_enabled() then --控制自己是否产生脚步声
        AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(PLAYER.PLAYER_PED_ID(),false)
        if loopa1 == 0 then --这段代码只会在开启开关时执行一次，而不是循环
            gui.show_message("Footsteps Control","Mute")
        end
        loopa1 = 1
    else
        if loopa1 == 1 then     --这段代码只会在关掉开关时执行一次，而不是循环               
        AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(PLAYER.PLAYER_PED_ID(),true)
        gui.show_message("Footstep control","With sound")
        loopa1 = 0
        end
    end

    if  checkSONAR:is_enabled() then --控制声纳开关
        if loopa4 == 0 then  --这段代码只会在开启开关时执行一次，而不是循环
            HUD.SET_MINIMAP_SONAR_SWEEP(true)
            gui.show_message("Sonar","On")
        end
        loopa4 = 1
    else
        if loopa4 == 1 then   
            HUD.SET_MINIMAP_SONAR_SWEEP(false)        
            gui.show_message("Sonar","Off")
            loopa4 = 0
        end
    end

    if  lockmapang:is_enabled() then --Lock the angle of the minimap
        if loopa24 == 0 then  --这段代码只会在开启开关时执行一次，而不是循环
            HUD.LOCK_MINIMAP_ANGLE(0)
            gui.show_message("Lock the angle of the minimap","On")
        end
        loopa24 = 1
    else
        if loopa24 == 1 then   
            HUD.UNLOCK_MINIMAP_ANGLE()        
            gui.show_message("Lock the angle of the minimap","Off")
            loopa24 = 0
        end
    end

    if  antikl:is_enabled() then --防爆头
        if loopa25 == 0 then  --这段代码只会在开启开关时执行一次，而不是循环
            PED.SET_PED_SUFFERS_CRITICAL_HITS(PLAYER.PLAYER_PED_ID(),false)
        end
        loopa25 = 1
    else
        if loopa25 == 1 then   
            PED.SET_PED_SUFFERS_CRITICAL_HITS(PLAYER.PLAYER_PED_ID(),true)
            loopa25 = 0
        end
    end

    if  allpause:is_enabled() then --允许线上模式本地暂停
        if loopa28 == 0 and HUD.GET_PAUSE_MENU_STATE() == 15 then  --这段代码只会在开启开关时执行一次，而不是循环
            log.info("世界停止")
            MISC.SET_GAME_PAUSED(true)
            loopa28 = 1
        end
        if loopa28 == 1 and HUD.GET_PAUSE_MENU_STATE() == 0 then   
            log.info("世界恢复")
            MISC.SET_GAME_PAUSED(false)
            loopa28 = 0
        end
    else
    end

    if  rdded:is_enabled() then --雷达假死
        if loopa26 == 0 then  --这段代码只会在开启开关时执行一次，而不是循环
            if  ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) ~= 0 then
                ENTITY.SET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), 0)
            end
        end
        loopa26 = 1
    else
        if loopa26 == 1 then   
            ENTITY.SET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID(), 328)
            loopa26 = 0
        end
    end

    if  lockhlt:is_enabled() then --锁血
        ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID()), 0, 0)
    end

    if  disalight:is_enabled() then --控制世界灯光开关
        if loopa16 == 0 then
            GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(true)
        end
        loopa16 = 1
    else
        if loopa16 == 1 then   
            GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(false)
            loopa16 = 0
        end
    end

    if  vehgodr:is_enabled() then --控制远程载具无敌
        if loopa14 == 0 then
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("Warning","The player is not in the vehicle")
                vehgodr:set_enabled(false)
                loopa14 = 0
            else
                tarveh124 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
                local time124 = os.time()
                local rqctlsus124 = false
                while not rqctlsus124 do
                    if os.time() - time124 >= 5 then
                        gui.show_error("sch lua","Request control failed")
                        break
                    end
                    rqctlsus123 = request_control(tarveh124)
                    script:yield()
                end
                ggui.show_message("sch lua","Request control was successful")
                    --如果未被作弊者拦截,理论上应该请求控制成功了
                ENTITY.SET_ENTITY_PROOFS(tarveh124, true, true, true, true, true, false, false, true) --似乎没啥用...
                ENTITY.SET_ENTITY_INVINCIBLE(tarveh124, true)
                VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(tarveh124, false)
                gui.show_message("Vehicle invincible","Applied")
                loopa14 = 1
            end
        end
    else
        if loopa14 == 1 then   
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("Warning","Player not in vehicle")
                vehgodr:set_enabled(false)
                loopa14 = 0
            else
                tarveh125 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
                local time125 = os.time()
                local rqctlsus125 = false
                while not rqctlsus125 do
                    if os.time() - time125 >= 5 then
                        gui.show_error("sch lua","Request control failed")
                        break
                    end
                    rqctlsus123 = request_control(tarveh125)
                    script:yield()
                end
                gui.show_message("sch lua","Request control was successful")
                ENTITY.SET_ENTITY_PROOFS(tarveh125, false, false, false, false, false, false, false, false)
                ENTITY.SET_ENTITY_INVINCIBLE(tarveh125, false)
                VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(tarveh125, true)
                gui.show_message("Vehicle Invincible","Revoked")
                loopa14 = 0
            end
        end
    end

    if  vehnoclr:is_enabled() then --控制远程载具无碰撞
        if loopa15 == 0 then
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("Warning","The player is not in the vehicle")
                vehnoclr:set_enabled(false)
                loopa14 = 0
            else
                local tarveh2 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
                local time = os.time()
                local rqctlsus = false
                while not rqctlsus do
                    if os.time() - time >= 5 then
                        gui.show_error("sch lua","Request control failed")
                        break
                    end
                    rqctlsus = request_control(tarveh2)
                    script:yield()
                end
                gui.show_message("sch lua","Request control was successful")
                ENTITY.SET_ENTITY_COLLISION(tarveh2,false,false)
                gui.show_message("Vehicle No Collision","Applied")
                loopa15 = 1
            end
        end
    else
        if loopa15 == 1 then
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("Warning","The player is not in the vehicle)
                vehnoclr:set_enabled(false)
                loopa15 = 0
            else
                tarveh2 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
                local time122 = os.time()
                local rqctlsus122 = false
                while not rqctlsus122 do
                    if os.time() - time122 >= 5 then
                        gui.show_error("sch lua","Request control failed")
                        break
                    end
                    rqctlsus122 = request_control(tarveh2)
                    script:yield()
                end
                gui.show_message("sch lua","Request control was successful")
                ENTITY.SET_ENTITY_COLLISION(tarveh2,true,true)
                gui.show_message("Vehicle has no collision","Removed")
                loopa15 = 0
            end
        end
    end

    if  spcam:is_enabled() then --控制观看开关
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        STREAMING.SET_FOCUS_POS_AND_VEL(TargetPPos.x, TargetPPos.y, TargetPPos.z, 0.0, 0.0, 0.0)
        if loopa13 == 0 then
            specam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", false)
			CAM.SET_CAM_ACTIVE(specam, true)
			CAM.RENDER_SCRIPT_CAMS(true, true, 500, true, true, 0)
            loopa13 = 1
        end
        rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)
        CAM.SET_CAM_ROT(specam, rotation.x, rotation.y, rotation.z, 2)
        CAM.SET_CAM_COORD(specam, TargetPPos.x, TargetPPos.y, TargetPPos.z + spcamh:get_value())
        if spcamfov:get_value() > 130 or spcamfov:get_value() < 1 then
            gui.show_error("FOV exceeds the limit","the allowable range is 1-130")
            spcamfov:set_value(80.0)
        end 
        CAM.SET_CAM_FOV(specam,spcamfov:get_value())
        CAM.SET_CAM_MOTION_BLUR_STRENGTH(specam,0.0)
        CAM.SET_CAM_DOF_STRENGTH(specam,0.0)
        CAM.SET_CAM_AFFECTS_AIMING(specam,true)
    else
        if loopa13 == 1 then     
            CAM.SET_CAM_ACTIVE(specam, false)
			CAM.RENDER_SCRIPT_CAMS(false, true, 500, true, true, 0)
			CAM.DESTROY_CAM(specam, false)
			STREAMING.CLEAR_FOCUS()    
            loopa13 = 0
        end
    end

    if  plymk:is_enabled() then --控制玩家光柱标记开关
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("golfputting", true)
        GRAPHICS.DRAW_BOX(TargetPPos.x-0.1,TargetPPos.y-0.1,TargetPPos.z+0.8,TargetPPos.x+0.1,TargetPPos.y+0.1,TargetPPos.z+20,255,255,255,255)
    end

    if  plyline:is_enabled() then --控制玩家连线标记开关
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local selfpos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
        GRAPHICS.DRAW_LINE(selfpos.x, selfpos.y, selfpos.z, TargetPPos.x, TargetPPos.y, TargetPPos.z, 255, 255, 255, 100)    
    end

    if  checkpedaudio:is_enabled() then --控制自己的PED是否产生声音
        PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
        if loopa3 == 0 then
            gui.show_message("PED sound control ","Mute")
        end
        loopa3 = 1
    else
        if loopa3 == 1 then                    
        PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 1.0)
        gui.show_message("PED sound control ","With sound")
        loopa3 = 0
        end
    end

    if  disableAIdmg:is_enabled() then --覆写NPC伤害
        PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0.0)
        PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0.0)
        loopa8 = 1
    else
    if loopa8 == 1 then 
        PED.RESET_AI_WEAPON_DAMAGE_MODIFIER()
        PED.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
        gui.show_message("Prompt","NPC damage has been restored")
    loopa8 = 0
    end
    end

    if  check666:is_enabled() then --控制头顶666生成与移除
        if loopa2 == 0 then
            local md6 = "prop_mp_num_6"
            local user_ped = PLAYER.PLAYER_PED_ID()
            md6hash = joaat(md6)
        
            STREAMING.REQUEST_MODEL(md6hash)
            while not STREAMING.HAS_MODEL_LOADED(md6hash) do		
                script:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(md6hash)
        
            objectsix1 = OBJECT.CREATE_OBJECT(md6hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(objectsix1, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), 0.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true, 1) 
        
            STREAMING.REQUEST_MODEL(md6hash)
            while not STREAMING.HAS_MODEL_LOADED(md6hash) do		
                script:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(md6hash)
        
            objectsix2 = OBJECT.CREATE_OBJECT(md6hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(objectsix2, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), 1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true, 1) 
        
            STREAMING.REQUEST_MODEL(md6hash)
            while not STREAMING.HAS_MODEL_LOADED(md6hash) do		
                script:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(md6hash)
        
            objectsix3 = OBJECT.CREATE_OBJECT(md6hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(objectsix3, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), -1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true, 1) 
        
            gui.show_message("Header 666", "Generated")
        end
        loopa2 = 1
    else
        if loopa2 == 1 then 
            delete_entity(objectsix1)
            delete_entity(objectsix2)
            delete_entity(objectsix3)
            gui.show_message("Header 666", "Removed")
            loopa2 = 0
        end
    end

    if  check520:is_enabled() then --控制头顶520生成与移除
        if loopa17 == 0 then
            local num5 = "prop_mp_num_2"
            local num2 = "prop_mp_num_5"
            local num0 = "prop_mp_num_0"
            local user_ped = PLAYER.PLAYER_PED_ID()
            num5hash = joaat(num5)
            num2hash = joaat(num2)
            num0hash = joaat(num0)
        
            STREAMING.REQUEST_MODEL(num5hash)
            while not STREAMING.HAS_MODEL_LOADED(num5hash) do		
                script:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(num5hash)
        
            object5201 = OBJECT.CREATE_OBJECT(num5hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(object5201, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), 0.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true, 1) 
        
            STREAMING.REQUEST_MODEL(num2hash)
            while not STREAMING.HAS_MODEL_LOADED(num2hash) do		
                script:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(num2hash)
        
            object5202 = OBJECT.CREATE_OBJECT(num2hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(object5202, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0),  -1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true, 1) 
        
            STREAMING.REQUEST_MODEL(num0hash)
            while not STREAMING.HAS_MODEL_LOADED(num0hash) do		
                script:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(num0hash)
        
            object5203 = OBJECT.CREATE_OBJECT(num0hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(object5203, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0),   1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true, 1) 
        
            gui.show_message("Header 520", "Generated")
        end
        loopa17 = 1
    else
        if loopa17 == 1 then 
            delete_entity(object5201)
            delete_entity(object5202)
            delete_entity(object5203)
            gui.show_message("Header 520","Removed")
            loopa17 = 0
        end
    end

    if  firemt:is_enabled() then --控制恶灵骑士
        if loopa10 == 0 then
        while not STREAMING.HAS_MODEL_LOADED(joaat("sanctus")) do		
            STREAMING.REQUEST_MODEL(joaat("sanctus"))
            script:yield()
        end
        firemtcrtveh = VEHICLE.CREATE_VEHICLE(joaat("sanctus"), ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).z, 0 , true, true, true)
        ENTITY.SET_ENTITY_RENDER_SCORCHED(firemtcrtveh,true) --烧焦效果
        ENTITY.SET_ENTITY_INVINCIBLE(firemtcrtveh,true)  --载具无敌
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(firemtcrtveh,30,15)
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(),firemtcrtveh,-1) --坐进载具
        script:sleep(500) 
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
            script:yield()               
        end
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
            script:yield()               
        end
        local vehbone3 = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(firemtcrtveh, "wheel_rr")
        local vehbone4 = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(firemtcrtveh, "wheel_rf")
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        vehptfx6 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("fire_wrecked_plane_cockpit", firemtcrtveh, 0.0, 0.9, 0.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        vehptfx7 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("fire_wrecked_plane_cockpit", firemtcrtveh, 0.0, -0.9, -0.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx3 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.0, 0.7, 0.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx2 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.0, 0.0, 1.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx1 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.0, 0.7, 0.4, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx4 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, -0.5, 0.7, 0.3, 180.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx5 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.5, 0.7, 0.3, 180.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx7, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx6, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx2, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx3, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx4, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx5, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx1, 200, 200, 200, false)
        
        gui.show_message("Ghost Rider","On")
        end
        loopa10 = 1
    else
        if loopa10 == 1 then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
            ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), false)        
            delete_entity(firemtcrtveh)
            gui.show_message("Ghost Rider","Off")
            loopa10 = 0
        end
    end

    if  check6:is_enabled() then --随处游泳
        PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 65, true) --锁定玩家状态为游泳
    end

    if  rHDonly:is_enabled() then
        STREAMING.SET_RENDER_HD_ONLY(true)
    end

    if  keepschost:is_enabled() then
        local FMMC2020host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller_2020",0,0)
        local FMMChost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller",0,0)
        if PLAYER.PLAYER_ID() ~= FMMC2020host and PLAYER.PLAYER_ID() ~= FMMChost then   --如果判断不是脚本主机则自动抢脚本主机
            network.force_script_host("fm_mission_controller_2020") --抢脚本主机
            network.force_script_host("fm_mission_controller") --抢脚本主机
            script:yield()
        end
    end

    if  partwater:is_enabled() then --分开水体
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        WATER.SET_DEEP_OCEAN_SCALER(0.0)

        WATER.MODIFY_WATER(selfpos.x, selfpos.y, -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x+2, selfpos.y, -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x, selfpos.y+2, -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x-2, selfpos.y, -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x, selfpos.y-2, -500000.0, 0.2)

        WATER.MODIFY_WATER(selfpos.x+math.random(4,10), selfpos.y, -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x, selfpos.y+math.random(4,10), -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x-math.random(4,10), selfpos.y, -500000.0, 0.2)
        WATER.MODIFY_WATER(selfpos.x, selfpos.y-math.random(4,10), -500000.0, 0.2)

    end

    if vehboost:is_enabled() then --载具加速
        if PAD.IS_CONTROL_PRESSED(0, 352) and PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true) then --按下Shift且在载具中
            --https://docs.fivem.net/docs/game-references/controls/ 如需自定义，查询控制键位对应的数字，替换掉352即可
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
            local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)  
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(vehicle, 1, 0, 1, 0, false, true, true, true)
        end
    end

    if  pedgun:is_enabled() then --NPC枪
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)  
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then 
            peds = PED.CREATE_RANDOM_PED(pos.x, pos.y, pos.z)    
            ENTITY.SET_ENTITY_ROTATION(peds, camrot.x, camrot.y, camrot.z, 1, false)    
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(peds, 1, 0, 1000, 0, false, true, true, true)
            ENTITY.SET_ENTITY_HEALTH(peds,1000,0,0)
        end
    end

    if  bsktgun:is_enabled() then --篮球枪
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)
        objhash = joaat("prop_bskball_01")
        while not STREAMING.HAS_MODEL_LOADED(objhash) do		
            STREAMING.REQUEST_MODEL(objhash)
            script:yield()
        end
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then 
            bskt = OBJECT.CREATE_OBJECT(objhash,pos.x, pos.y, pos.z, true, true, false)
            ENTITY.SET_ENTITY_ROTATION(bskt, camrot.x, camrot.y, camrot.z, 1, false)    
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(bskt, 1, 0, 1000, 0, false, true, true, true)
        end
    end

    if  bballgun:is_enabled() then --大球枪
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)
        objhash = joaat("v_ilev_exball_blue")
        while not STREAMING.HAS_MODEL_LOADED(objhash) do		
            STREAMING.REQUEST_MODEL(objhash)
            script:yield()
        end
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then 
            bskt = OBJECT.CREATE_OBJECT(objhash,pos.x, pos.y, pos.z, true, true, false)
            ENTITY.SET_ENTITY_ROTATION(bskt, camrot.x, camrot.y, camrot.z, 1, false)    
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(bskt, 1, 0, 1000, 0, false, true, true, true)
        end
    end

    if  pedvehctl:is_enabled() then --玩家选项-载具旋转
        if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
            gui.show_error("Warning","The player is not in the vehicle")
        else
            tarveh123 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
            local time123 = os.time()
            local rqctlsus123 = false
            while not rqctlsus123 do
                if os.time() - time123 >= 5 then
                    gui.show_error("sch lua","Request control failed")
                    break
                end
                rqctlsus123 = request_control(tarveh123)
                script:yield()
            end
            gui.show_message("sch lua","Request control was successful")
        ENTITY.APPLY_FORCE_TO_ENTITY(tarveh123, 5, 0, 0, 150.0, 0, 0, 0, 0, true, false, true, false, true)
        end
    end

    if  drawcs:is_enabled() then --绘制准星
        HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING") --The following were found in the decompiled script files: STRING, TWOSTRINGS, NUMBER, PERCENTAGE, FO_TWO_NUM, ESMINDOLLA, ESDOLLA, MTPHPER_XPNO, AHD_DIST, CMOD_STAT_0, CMOD_STAT_1, CMOD_STAT_2, CMOD_STAT_3, DFLT_MNU_OPT, F3A_TRAFDEST, ES_HELP_SOC3
        HUD.SET_TEXT_FONT(0)
        HUD.SET_TEXT_SCALE(0.3, 0.3) --Size range : 0F to 1.0F --p0 is unknown and doesn't seem to have an effect, yet in the game scripts it changes to 1.0F sometimes.
        HUD.SET_TEXT_OUTLINE()
        HUD.SET_TEXT_CENTRE(true)
        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(string.format("+"))
        HUD.END_TEXT_COMMAND_DISPLAY_TEXT(0.5, 0.485, 0) --占坐标轴的比例
    end

    if  disablecops:is_enabled() then --控制是否派遣警察
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), false)
        loopa7 = 1
    else
        if loopa7 == 1 then 
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), true)
        gui.show_message("Prompt","the police will be dispatched when wanted")
        loopa7 = 0
        end
    end

    if  disapedheat:is_enabled() then --控制是否存在热量
        if loopa11 == 0 then 
            PED.SET_PED_HEATSCALE_OVERRIDE(PLAYER.PLAYER_ID(), 0)
            loopa11 = 1
        end
    else
        if loopa11 == 1 then 
            PED.SET_PED_HEATSCALE_OVERRIDE(PLAYER.PLAYER_ID(), 1)
            loopa11 = 0
        end
    end

    if  canafrdly:is_enabled() then --控制是否允许攻击队友
        if loopa12 == 0 then 
            PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_ID(), true, false)
            loopa12 = 1
        end
    else
        if loopa12 == 1 then 
            PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_ID(), false, false)
            loopa12 = 0
        end
    end

    if  desync:is_enabled() then --创建新手教程战局以取消与其他玩家同步
        if loopa9 == 0 then
            NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
            gui.show_message("Unsync","Will unsync with all players")
        end
        loopa9 = 1
    else
        if loopa9 == 1 then                    
            NETWORK.NETWORK_END_TUTORIAL_SESSION()
            gui.show_message("Cancel sync","Syncing back again")
        loopa9 = 0
        end
    end

    if  ptfxrm:is_enabled() then --清理PTFX和火焰效果
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        FIRE.STOP_FIRE_IN_RANGE(selfpos.x, selfpos.y, selfpos.z, 500)
        FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())    
        GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(selfpos.x, selfpos.y, selfpos.z, 1000)
        GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(PLAYER.PLAYER_PED_ID())
    else
    end

    if  DECALrm:is_enabled() then --清理弹孔、血渍、油污等表面特征
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        GRAPHICS.REMOVE_DECALS_IN_RANGE(selfpos.x, selfpos.y, selfpos.z, 100)
    else
    end

    if  skippcus:is_enabled() then --阻止过场动画
        if CUTSCENE.IS_CUTSCENE_PLAYING() then
            CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
            CUTSCENE.REMOVE_CUTSCENE()
        end
    end

    if  efxrm:is_enabled() then --阻止镜头抖动、视觉效果滤镜
        GRAPHICS.ANIMPOSTFX_STOP_ALL()
        GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        PED.SET_PED_MOTION_BLUR(PLAYER.PLAYER_PED_ID(), false)
        CAM.SHAKE_GAMEPLAY_CAM("CLUB_DANCE_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("DAMPED_HAND_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("DEATH_FAIL_IN_EFFECT_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("DRONE_BOOST_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("FAMILY5_DRUG_TRIP_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("gameplay_explosion_shake", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("GRENADE_EXPLOSION_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_BUMP_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_ENGINE_START_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_ENGINE_STOP_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("GUNRUNNING_LOOP_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("HAND_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("HIGH_FALL_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("jolt_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("MEDIUM_EXPLOSION_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("PLANE_PART_SPEED_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("ROAD_VIBRATION_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("SKY_DIVING_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("SMALL_EXPLOSION_SHAKE", 0.0)
        CAM.SHAKE_GAMEPLAY_CAM("VIBRATE_SHAKE", 0.0)
        end
end)

script.register_looped("schlua-vehctrl", function(script) 
    if  vehjmpr:is_enabled() then --控制载具跳跃
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, 0, 0, 10, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                end
            end
        end
        script:sleep(2500)
        if vehicle ~= vehisin and vehicle then
            ENTITY.SET_ENTITY_ROTATION(vehicle,0,0,0,2,true)
        end
    end
end)

script.register_looped("schlua-ectrlservice", function(script) 
    if  allclear:is_enabled() then --循环清除实体
        for _, ent1221 in pairs(entities.get_all_objects_as_handles()) do
            request_control(ent1221)
            delete_entity(ent1221)
        end
        for _, ent1222 in pairs(entities.get_all_peds_as_handles()) do
            request_control(ent1222)
            delete_entity(ent1222)
        end
        for _, ent1223 in pairs(entities.get_all_vehicles_as_handles()) do
            request_control(ent1223)
            delete_entity(ent1223)
        end
    end

    if  npcvehbr:is_enabled() then --控制NPC载具倒行
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            local veh = 0
            if not PED.IS_PED_A_PLAYER(ped) then 
                veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)
                if veh ~= 0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, false) == ped then 
                    request_control(ped)
                    TASK.SET_DRIVE_TASK_DRIVING_STYLE(ped, 1471)
                end
            end
        end
    end
    
    if  vehengdmg:is_enabled() then --控制载具引擎破坏
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                end
            end
        end
    end
            
    if  vehengdmg2:is_enabled() then --控制敌对载具引擎破坏
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() and (HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 49 or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("police3") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("RIOT") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("Predator") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policeb") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policet") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("polmav") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("FBI2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("sheriff2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("SHERIFF")) then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                end
            end
        end
    end
        
    if  vehbr:is_enabled() then --控制载具混乱
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, math.random(0, 3), math.random(0, 3), math.random(-3, 1), 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                end
            end
        end
    end
        
    if  vehrm:is_enabled() then --控制载具移除
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    delete_entity(vehicle)        
                end
            end
        end
    end
                  
    if  vehrm2:is_enabled() then --控制敌对载具移除
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() and (HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 49 or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("police3") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("RIOT") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("Predator") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policeb") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policet") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("polmav") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("FBI2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("sheriff2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("SHERIFF")) then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    delete_entity(vehicle)        
                end
            end
        end
    end

    if  vehsp1:is_enabled() then --控制载具旋转
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 5, 0, 0, 150.0, 0, 0, 0, 0, true, false, true, false, true)
                end
            end
        end
    end

    if  vehdoorlk4p:is_enabled() then --控制载具锁门
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                end
            end
        end
        loopa18 = 1
    else
        if loopa18 == 1 then
            local vehtable = entities.get_all_vehicles_as_handles()
            local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
            for _, vehicle in pairs(vehtable) do
                local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
                local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
                if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                    if vehicle ~= vehisin then
                        request_control(vehicle)
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
                    end
                end
            end
            gui.show_message("Prompt","Unlocked") 
        end
        loopa18 = 0
    end

    if  vehstopr:is_enabled() then --控制载具停止
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.SET_ENTITY_VELOCITY(vehicle,0,0,0)
                end
            end
        end
    end

    if  vehstopr2:is_enabled() then --控制敌对载具停止
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() and (HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 49 or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("police3") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("RIOT") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("Predator") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policeb") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policet") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("polmav") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("FBI2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("sheriff2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("SHERIFF")) then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.SET_ENTITY_VELOCITY(vehicle,0,0,0)
                end
            end
        end
    end

    if  vehfixr:is_enabled() then --控制载具修理
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                request_control(vehicle)
                VEHICLE.SET_VEHICLE_FIXED(vehicle)
            end
        end
    end

    if  vehforcefield:is_enabled() then --控制载具力场
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= ffrange:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, 0, 0, 3, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end
    
    if  objforcefield:is_enabled() then --控制物体力场
        local onjtable = entities.get_all_objects_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, aobj in pairs(onjtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local aobj_pos = ENTITY.GET_ENTITY_COORDS(aobj, false)
            if calcDistance(selfpos, aobj_pos) <= ffrange:get_value() then
                if aobj ~= vehisin then
                    request_control(aobj)
                    ENTITY.APPLY_FORCE_TO_ENTITY(aobj, 3, 0, 0, 3, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  pedforcefield:is_enabled() then --控制NPC力场
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= ffrange:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    request_control(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end
    
    if  forcefield:is_enabled() then --控制力场
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            if calcDistance(selfpos, vehicle_pos) <= ffrange:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, 0, 0, 3, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= ffrange:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    request_control(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  aimreact:is_enabled() then --控制NPC瞄准惩罚1-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  aimreact1:is_enabled() then --控制NPC瞄准惩罚2 -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  aimreact2:is_enabled() then --控制NPC瞄准惩罚3 -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                ENTITY.SET_ENTITY_HEALTH(peds,0,0,0)
            end
        end
    end

    if  aimreact3:is_enabled() then --控制NPC瞄准惩罚3 -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  aimreact6:is_enabled() then --控制NPC瞄准惩罚6 -移除
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                delete_entity(peds)            
            end
        end
    end

    if  rmpedwp3:is_enabled() then --控制NPC瞄准反应8 -缴械
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                WEAPON.REMOVE_ALL_PED_WEAPONS(peds,true)
            end
        end
    end

    if  stnpcany3:is_enabled() then --控制NPC瞄准反应9 -电击枪
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    request_control(peds)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                else
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 0, true, joaat("weapon_stungun"), PLAYER.PLAYER_PED_ID(), false, true, 1.0)
                end 
            end
        end
    end

    if  aimreact4:is_enabled() then --控制NPC瞄准惩罚4 -起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end
    
    if  aimreact5:is_enabled() then --控制NPC瞄准惩罚5 -保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and PED.IS_PED_A_PLAYER(peds) == false then 
                request_control(peds)
                pedblip = HUD.GET_BLIP_FROM_ENTITY(peds)
                HUD.REMOVE_BLIP(pedblip)
                npc2bodyguard(peds)                
            end
        end
    end

    if  aimreactany:is_enabled() then --控制NPC瞄准任何人惩罚1-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  aimreact1any:is_enabled() then --控制NPC瞄准任何人惩罚2 -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  aimreact2any:is_enabled() then --控制NPC瞄准任何人惩罚3 -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                ENTITY.SET_ENTITY_HEALTH(peds,0,0,0)
            end
        end
    end

    if  aimreact3any:is_enabled() then --控制NPC瞄准任何人惩罚3 -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  aimreact6any:is_enabled() then --控制NPC瞄准任何人惩罚6 -移除
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                delete_entity(peds)            
            end
        end
    end

    if  rmpedwp4:is_enabled() then --控制NPC瞄准任何人惩罚6 -缴械
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                WEAPON.REMOVE_ALL_PED_WEAPONS(peds,true)
            end
        end
    end

    if  stnpcany4:is_enabled() then --控制NPC瞄准任何人惩罚6 -电击枪
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                else
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 0, true, joaat("weapon_stungun"), PLAYER.PLAYER_PED_ID(), false, true, 1.0)
                end 
            end
        end
    end

    if  aimreact4any:is_enabled() then --控制NPC瞄准任何人惩罚4 -起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  aimreact5any:is_enabled() then --控制NPC瞄准任何人惩罚4 -保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and PED.IS_PED_A_PLAYER(peds) == false then 
                request_control(peds)
                pedblip = HUD.GET_BLIP_FROM_ENTITY(peds)
                HUD.REMOVE_BLIP(pedblip)
                TASK.CLEAR_PED_TASKS(peds)
                npc2bodyguard(peds)
            end
        end
    end

    if  delallcam:is_enabled() then --移除所有摄像头
        for _, ent in pairs(entities.get_all_objects_as_handles()) do
            for __, cam in pairs(CamList) do
                if ENTITY.GET_ENTITY_MODEL(ent) == cam then
                    request_control(ent)
                    delete_entity(ent)               
                end
            end
        end
    end

    if  reactany:is_enabled() then --控制NPC-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true) and PED.IS_PED_A_PLAYER(peds) ~= 1 and foundfrd == false then 
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  react1any:is_enabled() then --控制NPC -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and foundfrd == false then 
                request_control(peds)
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  react2any:is_enabled() then --控制NPC -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and foundfrd == false then 
                request_control(peds)
                ENTITY.SET_ENTITY_HEALTH(peds,0,0,0)
            end
        end
    end

    if  reactanyac:is_enabled() then --控制敌对NPC-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  react1anyac:is_enabled() then --控制敌对NPC -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  react2anyac:is_enabled() then --控制敌对NPC -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                ENTITY.SET_ENTITY_HEALTH(peds,0,0,0)
            end
        end
    end

    if  rmdied:is_enabled() then --控制NPC -移除尸体
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and ENTITY.GET_ENTITY_HEALTH(peds) <= 0 then 
                request_control(peds)
                delete_entity(peds)
            end
        end
    end

    if  react3any:is_enabled() then --控制NPC -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and foundfrd == false then 
                request_control(peds)
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  react4any:is_enabled() then --控制NPC-起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID()  and PED.IS_PED_A_PLAYER(peds) ~= 1 and foundfrd == false then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  rmpedwp:is_enabled() then --控制NPC-缴械
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID()  and PED.IS_PED_A_PLAYER(peds) ~= 1 and foundfrd == false then 
                request_control(peds)
                WEAPON.REMOVE_ALL_PED_WEAPONS(peds,true)
            end
        end
    end

    if  stnpcany:is_enabled() then --控制NPC-射击-电击枪
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local foundfrd = false
            for __, frd in pairs(FRDList) do
                if ENTITY.GET_ENTITY_MODEL(peds) == frd then
                    foundfrd = true
                    break
                end
            end    
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and foundfrd == false then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                else
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 0, true, joaat("weapon_stungun"), PLAYER.PLAYER_PED_ID(), false, true, 1.0)
                end 
            end
        end
    end

    if  drawbox:is_enabled() then --控制NPC-光柱标记
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            local ismarked = false
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0 then 
                if PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01") then 
                    ismarked = true
                    GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+0.8,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20,255,76,0,255)
                end
                if  HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 3 then 
                    ismarked = true
                    GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+0.8,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20,87,213,255,255)
                end
                if ismarked == false then
                    GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+0.8,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20,255,255,255,255)
                end
            end
        end
    end

    if  react3anyac:is_enabled() then --控制敌对NPC -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  react4anyac:is_enabled() then --控制敌对NPC-起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID()  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  react5anyac:is_enabled() then --控制敌对NPC 保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and PED.IS_PED_A_PLAYER(peds) == false then 
                request_control(peds)
                TASK.CLEAR_PED_TASKS(peds)
                pedblip = HUD.GET_BLIP_FROM_ENTITY(peds)
                HUD.REMOVE_BLIP(pedblip)
                npc2bodyguard(peds)                
            end
        end
    end

    if  react6anyac:is_enabled() then --控制敌对NPC-光柱标记
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("golfputting", true)
                GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+0.8,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20,255,0,0,255)
            end
        end
    end

    if  rmpedwp2:is_enabled() then --控制敌对NPC-缴械
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1  then 
                request_control(peds)
                WEAPON.REMOVE_ALL_PED_WEAPONS(peds,true)
            end
        end
    end

    if  stnpcany2:is_enabled() then --控制敌对NPC-射击-电击枪
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
                request_control(peds)
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
                else
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(ped_pos.x, ped_pos.y, ped_pos.z + 1, ped_pos.x, ped_pos.y, ped_pos.z, 0, true, joaat("weapon_stungun"), PLAYER.PLAYER_PED_ID(), false, true, 1.0)
                end 
            end
        end
    end

    if  stnpcany7:is_enabled() then --控制敌对NPC-爆炸
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 1, 1, true, true, 1, false)
            end
        end
    end

    if  revitalizationped:is_enabled() then --控制NPC-复活
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and ENTITY.GET_ENTITY_HEALTH(peds) <= 0 and PED.IS_PED_A_PLAYER(peds) == false then 
                request_control(peds)
                ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(peds, true,1)
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds, true, false)
                ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(peds, true)
                ENTITY.SET_ENTITY_COLLISION(peds,true,true)
                PED.SET_PED_AS_GROUP_MEMBER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
                PED.SET_CAN_ATTACK_FRIENDLY(peds, false, true)
                PED.SET_PED_COMBAT_ABILITY(peds, 2)
                PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 1024, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 16384, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 131072, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 262144, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
                PED.SET_PED_CONFIG_FLAG(peds, 394, true)
                PED.SET_PED_CONFIG_FLAG(peds, 400, true)
                PED.SET_PED_CONFIG_FLAG(peds, 134, true)
                WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("WEAPON_CARBINERIFLE_MK2"), 9999, false, true)
                PED.SET_PED_ACCURACY(peds,100)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(peds, 100, 67108864)
                ENTITY.SET_ENTITY_HEALTH(peds,1000,0,0)
                PED.RESURRECT_PED(peds)
            end
        end
    end
end)

script.register_looped("schlua-ptfxservice", function(script) 

    if  checkfirebreath:is_enabled() then --不太好用的喷火功能
        if loopa5 == 0 then
            STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
                script:yield()               
            end
            GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
            ptfxx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE('muz_xs_turret_flamethrower_looping', PLAYER.PLAYER_PED_ID(), 0, 0.12, 0.58, 30, 0, 0, 0x8b93, 1.0 , false, false, false, 255, 127, 80, 0)
            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(ptfxx, 255, 127, 80, false)    
        end
        loopa5 = 1
    else
        if loopa5 == 1 then 
            if ptfxx then
                GRAPHICS.REMOVE_PARTICLE_FX(ptfxx, true)
                GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(PLAYER.PLAYER_PED_ID())
                STREAMING.REMOVE_NAMED_PTFX_ASSET('weap_xs_vehicle_weapons')    
            end    
        end
        loopa5 = 0
    end 

    if  ptfxt1:is_enabled() then --PTFX1
        if loopa27 == 0 then
            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xs_pits")
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xs_pits")
            GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("scr_xs_sf_pit_long", PLAYER.PLAYER_PED_ID(), 0, 0, 0, 0, 0, 100, 5, false, false, false)
            loopa27 = 1
        end
    else
        if loopa27 == 1 then 
            GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(PLAYER.PLAYER_PED_ID())
        end
        loopa27 = 0
    end 

    if  fwglb:is_enabled() then --天空范围烟花
        local tarm = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_indep_fireworks")
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_indep_fireworks") do script:yield() end
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_indep_firework_trailburst", tarm.x + math.random(-100, 100), tarm.y + math.random(-100, 100), tarm.z + math.random(10, 30), 180, 0, 0, 1.0, true, true, true, false)
        script:sleep(100)
    end

    if  stnfl:is_enabled() then --天空范围陨石雨
        STREAMING.REQUEST_MODEL(3751297495)
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        coords.z = coords.z + math.random(10, 100)
        coords.x = coords.x + math.random(-1000, 1000)
        coords.y = coords.y + math.random(-1000, 1000)
        local asteroid = OBJECT.CREATE_OBJECT(3751297495, coords.x, coords.y, coords.z, true, false, false)
        ENTITY.SET_ENTITY_DYNAMIC(asteroid, true)    
        script:sleep(100)
    end

    if  checkfirew:is_enabled() then --不太好用的火焰翅膀功能
        if loopa6 == 0 then
            if  ptfxAegg == nil then
                local obj1 = 1803116220  --外星蛋,用于附加火焰ptfx
        
                local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    
                STREAMING.REQUEST_MODEL(obj1)
                while not STREAMING.HAS_MODEL_LOADED(obj1) do
                    STREAMING.REQUEST_MODEL(obj1)
                    script:yield() 
                end
    
                ptfxAegg = OBJECT.CREATE_OBJECT(obj1, pos.x, pos.y, pos.z, true, false, false)
    
                ENTITY.SET_ENTITY_COLLISION(ptfxAegg, false, false)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(obj1)
            end
            for i = 1, #bigfireWings do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
                    STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
                    script:sleep(20)
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
                bigfireWings[i].ptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("muz_xs_turret_flamethrower_looping", ptfxAegg, 0, 0, 0.1, bigfireWings[i].pos[1], 0, bigfireWings[i].pos[2], 1, false, false, false, 255, 127, 80, 0)
        
                local rot = ENTITY.GET_ENTITY_ROTATION(PLAYER.PLAYER_PED_ID(), 2)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(ptfxAegg, PLAYER.PLAYER_PED_ID(), -1, 0, 0, 0, rot.x, rot.y, rot.z, false, false, false, false, 0, false, 1)
                ENTITY.SET_ENTITY_ROTATION(ptfxAegg, rot.x, rot.y, rot.z, 2, true)
                    for i = 1, #bigfireWings do
                        if bigfireWings[i].ptfx then
                            GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(bigfireWings[i].ptfx, 0.6)
                            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(bigfireWings[i].ptfx, 255, 127, 80, false)    
                        end
                    end
                    if ptfxAegg then
                        ENTITY.SET_ENTITY_VISIBLE(ptfxAegg, false, false) 
                    end
            end
        end
        loopa6 =1
    else
        if loopa6 == 1 then 
            for i = 1, #bigfireWings do
                if bigfireWings[i].ptfx then
                    GRAPHICS.REMOVE_PARTICLE_FX(bigfireWings[i].ptfx, true)
                    bigfireWings[i].ptfx = nil
                end
                if ptfxAegg then
                    delete_entity(ptfxAegg)
                    ptfxAegg = nil
                end
            end
            STREAMING.REMOVE_NAMED_PTFX_ASSET('weap_xs_vehicle_weapons')
        end
        loopa6 = 0
    end

end)

script.register_looped("schlua-drawservice", function(script) 
    if  DrawHost:is_enabled() then
        if NETWORK.NETWORK_GET_HOST_PLAYER_INDEX() ~= -1 then
            screen_draw_text(string.format("战局主机:".. PLAYER.GET_PLAYER_NAME(NETWORK.NETWORK_GET_HOST_PLAYER_INDEX())),0.180,0.8, 0.4 , 0.4)
        end
        if SCRIPT.HAS_SCRIPT_LOADED("freemode") then
            freemodehost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode",-1,0)
            if freemodehost ~= -1 then
                screen_draw_text(string.format("战局脚本主机:".. PLAYER.GET_PLAYER_NAME(freemodehost)),  0.180, 0.828, 0.4 , 0.4)
            end
        end
        if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") or SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller_2020") then
            if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then 
                fmmchost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller",0,0)
                if fmmchost ~= -1 then
                    screen_draw_text(string.format("任务脚本主机:".. PLAYER.GET_PLAYER_NAME(fmmchost)), 0.180, 0.940, 0.4 , 0.4)
                end
            end
            if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then 
                fmmc2020host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller_2020",0,0)
                if fmmc2020host ~= -1 then
                    screen_draw_text(string.format("任务脚本主机:".. PLAYER.GET_PLAYER_NAME(fmmc2020host)), 0.180, 0.910, 0.4 , 0.4)
                end
            end
        end
    end

    if  DrawInteriorID:is_enabled() then
        local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
        local Interior = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)
        screen_draw_text(string.format("Interior ID:".. Interior),0.875,0.2, 0.4 , 0.4)
    end

    if  DrawMyHeading:is_enabled() then
        formattedselfheading = string.format("%.2f", ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))

        screen_draw_text(string.format("Heading:"..formattedselfheading),0.875,0.25, 0.4 , 0.4)
    end

    if  fakeban1:is_enabled() then --虚假的封号警告
        HUD.SET_WARNING_MESSAGE_WITH_HEADER_AND_SUBSTRING_FLAGS("WARN","JL_INVITE_ND",2,"",true,-1,-1,"You have been permanently banned from entering Grand Theft Auto Online Mode."," Return to Grand Theft Auto V.",true,0)
    end

end)

script.register_looped("schlua-calcservice", function(script) 
    if gui.get_tab(""):is_selected() and not deautocalc:is_enabled() then
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        distance = calcDistance(pos,targpos)
        formattedDistance = string.format("%.3f", distance)
        plydist:set_value(tonumber(formattedDistance))
    end
end)

event.register_handler(menu_event.PlayerMgrInit, function ()
    verchka1 = verchka1 + 1 --触发lua版本检查:检查lua是否适配当前游戏版本

    if cashmtpin:get_value() == 0 then -- 读取在线模式当前联系人差事 现金奖励倍率
        cashmtpin:set_value(tunables.get_float("CASH_MULTIPLIER"))
    end
end)

script.register_looped("schlua-verckservice", function(script) 
    if autoresply == 1 then
        time = os.time()
        while os.time() - time < 7 do
            script:yield()
        end
        autoresply = 0
    end

    if verchka1 > 0 and verchka1 < 99 then
        if NETWORK.GET_ONLINE_VERSION() ~= suppver then
            if STREAMING.IS_PLAYER_SWITCH_IN_PROGRESS() then
            else
                log.warning("sch-lua脚本不支持您的游戏版本,涉及数据修改的功能将自动停用!")
                gui.show_error("sch-lua does not support your version of the game","Functions involving data modification will be automatically deactivated.")
                verchka1 = 0
                verchkok = 0
                testwindow = gui.add_imgui(function()
                    shouldDraw = ImGui.Begin("sch lua warning")
                    ImGui.TextColored(1, 0, 0, 1, "sch lua current supported version is"..suppver)    
                    ImGui.TextColored(1, 0, 0, 1, "sch lua your game version is not supported")    
                    ImGui.TextColored(1, 0, 0, 1, "You can still use features that are not affected by the version, such as entity control")    
                    ImGui.TextColored(1, 0, 0, 1, "Affected features will be automatically disabled to protect the security of your account")    
                    ImGui.TextColored(1, 0, 0, 1, "High chance of crash")    
                    ImGui.SetWindowSize(500, 300)
                    ImGui.End()
                end)
            end
        else
            verchka1 = 100
            verchkok = 1
            log.info("已通过游戏版本适配检测,您可以使用所有功能")
        end
    end
end)

--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能
---------------------------------------------------------------------------------------存储一些小发现、用不上的东西
--[[

    heist cut Regular Expression ([\S]+)\[0\][\s]*=[\s]*100;[\n\r\t]*\1\[1\][\s]*=[\s]*0;[\n\r\t]*\1\[2\][\s]*=[\s]*0;[\n\r\t]*\1\[3\][\s]*=[\s]*0;

    Global_1574996 = etsParam0;   Global_1574996 战局切换状态 0:TRANSITION_STATE_EMPTY  freemode.c

    local bsta
    if bsta == globals.get_int(1574996) then
    else
        bsta = globals.get_int(1574996)
        log.info(globals.get_int(1574996))
    end

	1.67 赌场右下角收入    func_3521(iLocal_19710.f_2686, "MONEY_HELD" /*TAKE*/, 1000, 6, 2, 0, "HUD_CASH" /*$~1~*/, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 1, -1);


------------------------------------------------GTAOL 1.67 技工 呼叫 载具资产 freemode.c began

void func_12234(var uParam0, var uParam1, Blip* pblParam2, Blip* pblParam3, Blip* pblParam4, Blip* pblParam5, Blip* pblParam6, Blip* pblParam7, Blip* pblParam8) // Position - 0x42ED1D
{
	if (Global_2794162.f_928)
		if (Global_2794162.f_942)
			func_12267(uParam0, false, true, false, false, false, false, false, false);
		else
			func_12267(uParam0, false, false, false, false, false, false, false, false);

	if (Global_2794162.f_930 && !func_6130() || *uParam1 == 5 && Global_1648646 == 3)
		func_12267(uParam1, true, false, false, false, false, false, false, false);  //MOC

	func_12264(pblParam2);

	if (Global_2794162.f_938 && !func_5730() || *uParam1 == 5)
		func_12267(uParam1, false, false, true, false, false, false, false, false); //复仇者

	func_12258(pblParam3);

	if (Global_2794162.f_943 && !func_5020() || *uParam1 == 5 && Global_1648646 == 5)
		func_12267(uParam1, false, false, false, true, false, false, false, false);  //恐霸

	func_12255(pblParam4);

	if (Global_2794162.f_960 && !func_3870() || *uParam1 == 5 && Global_1648646 == 6)
		func_12267(uParam1, false, false, false, false, true, false, false, false);  //虎鲸

	func_12252(pblParam5);

	if (Global_2794162.f_972 && !func_10792() || *uParam1 == 5 && Global_1648646 == 7)
		func_12267(uParam1, false, false, false, false, false, true, false, false);

	func_12250(pblParam6);

	if (Global_2794162.f_944 && !func_2870() || *uParam1 == 5 && Global_1648646 == 8)
		func_12267(uParam1, false, false, false, false, false, false, false, true);  //致幻剂实验室

	func_12242(pblParam8);

	if (Global_2794162.f_994 && !func_10779() || *uParam1 == 5 && Global_1648646 == 9)
	{
		if (func_12240(PLAYER::PLAYER_ID()))
		{
			*uParam1 = 5;
			func_12239(false, false, true, false, true, false, false);  //致幻剂实验室 摩托车
			func_10001(false);
		}
	
		func_12267(uParam1, false, false, false, false, false, false, true, false);  
	}

	func_12235(pblParam7);
	return;
}
------------------------------------------------技工 呼叫 载具资产 end

]]
---------------------------------------------------------------------------------------存储一些小发现、用不上的东西


---------------------------------------------------------------------------------------以下是废弃的东西

--[[  已被检测
gentab:add_button("Remove casino roulette cooldown", function()
    stats.set_int("MPX_LUCKY_WHEEL_NUM_SPIN", 0)
    tunables.set_int(9960150,1)
    tunables.set_int(-312420223,1)
end)
]]--
