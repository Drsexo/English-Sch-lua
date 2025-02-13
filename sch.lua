-- v4.07 --
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
    1. Yimmenu Lua API - https://github.com/YimMenu/YimMenu/tree/master/docs/lua
    2. GTA5 Native Reference (Native functions) - https://nativedb.dotindustries.dev/natives
    3. GTA5 Decompiled Scripts - https://github.com/root-cause/v-decompiled-scripts
    4. PlebMaster (GTA5 data search & preview) - https://forge.plebmasters.de
    5. gta-v-data-dumps (Lookup PTFX/sounds/models) - https://github.com/DurtyFree/gta-v-data-dumps
    6. CodeWalker (view and edit scripts/resources in GTA V) - https://github.com/dexyfex/CodeWalker
    7. FiveM Native Reference - https://docs.fivem.net/docs/
	

Multi-language maintainer.
Simplified Chinese:sch https://github.com/sch-lda
English:Drsexo https://github.com/Drsexo
]]

luaversion = "v4.07"
path = package.path
if path:match("YimMenu") then
    log.info("sch-lua "..luaversion.." For personal testing and learning only, commercial use is prohibited")
else
    local_()
end

is_money = 0
is_GK = 0
is_collection1 = 0
verchkok = 0 --版本检查状态 0:不支持 1:支持
suppver = "1.68" --支持的游戏版本
autoresply = 0
devmode = 0 --0:禁用某些调试功能 1:启用某些调试功能
devmode2 = 0 --0:禁用某些调试功能 1:启用某些调试功能
devmode3 = 0 --0:禁用某些调试功能 1:启用某些调试功能
islistwed = 0 --是否已展开时间和金钱stats表单

gtaoversion = memory.scan_pattern("8B C3 33 D2 C6 44 24 20"):add(0x24):rip()
gtaoversionstr = gtaoversion:get_string()
if gtaoversion:get_string() ~= "3274" then
    verchkok = 0
    log.warning("sch-lua未完全更新,少数功能将自动停用!")
else
    log.info("sch-lua已适配您的当前游戏版本.")
    verchkok = 1
end

gentab = gui.add_tab("sch-lua-Alpha-"..luaversion)
TuneablesandStatsTab = gentab:add_tab("Adjustables and stats")
tpmenu = gentab:add_tab("Special Teleportation Point Menu")

LuaTablesTab = gentab:add_tab("++Table")

EntityTab = LuaTablesTab:add_tab("+Game entity list")

PlayerTableTab = EntityTab:add_tab("-Player list")
PlayerTableTab:add_button("Generate the player list", function()
    writeplayertable()
end)
PlayerTableTab:add_text("Player list is for aiming response")
NPCTableTab = EntityTab:add_tab("-NPC list")
NPCTableTab:add_button("Generate the NPC list", function()
    writepedtable()
end)
VehicleTableTab = EntityTab:add_tab("-Vehicle list")
VehicleTableTab:add_button("Generate the list of vehicles", function()
    writevehtable()
end)
ObjTableTab = EntityTab:add_tab("-Object list")
ObjTableTab:add_button("Generate the list of objects", function()
    writeobjtable()
end)

LuaownedTab = LuaTablesTab:add_tab("+lua internal table")
HeliTableTab = LuaownedTab:add_tab("-Bodyguard helicopter list")
NPCguardTableTab = LuaownedTab:add_tab("-Bodyguard NPC List")

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

function globals_set_int(supportedver, intglobal, intval) --当游戏版本不受支持时拒绝修改globals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        globals.set_int(intglobal, intval)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据修改.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function globals_get_int(supportedver, intglobal) --当游戏版本不受支持时拒绝读取globals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        return globals.get_int(intglobal)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据读取.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function globals_set_float(supportedver, floatglobal, floatval) --当游戏版本不受支持时拒绝修改globals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        globals.set_float(floatglobal, floatval)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据修改.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function globals_get_float(supportedver, floatglobal) --当游戏版本不受支持时拒绝读取globals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        return globals.get_float(floatglobal)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据读取.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function locals_set_int(supportedver, scriptname, intlocal, intlocalval) --当游戏版本不受支持时拒绝修改locals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        locals.set_int(scriptname, intlocal, intlocalval)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据修改.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function locals_get_int(supportedver, scriptname, intlocal) --当游戏版本不受支持时拒绝读取locals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        return locals.get_int(scriptname, intlocal)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据读取.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function locals_set_float(supportedver, scriptname, flocal, flocalval) --当游戏版本不受支持时拒绝修改locals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        locals.set_float(scriptname, flocal, flocalval)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据修改.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function locals_get_float(supportedver, scriptname, flocal) --当游戏版本不受支持时拒绝读取locals避免损坏线上存档
    if tostring(supportedver) == gtaoversionstr or verchkok == 5 then
        return locals.get_float(scriptname, flocal)
    else
        log.warning("此功能内存地址支持版本与游戏当前版本不匹配,可能未更新,已停止数据读取.您的游戏版本是"..gtaoversionstr.."支持的版本是"..supportedver)
    end
end

function packed_stat_set_bool(boolindex, boolval) --stats通常不随版本更新变化
    stats.set_packed_stat_bool(boolindex, boolval)
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

function upgrade_vehicle(vehicle,str)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)

    local table1 = {}
    for i = 0, 49 do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
        table.insert(table1, num)
    end
    local veh_mod_name = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(vehicle))
    local veh_disp_name = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(veh_mod_name)
    local result = table.concat(table1, ",")
    log.info("new VehicleInfo(){ Name=\""..veh_disp_name.."\", Value=\""..str.."\", Mods=new int[49]{ "..result.." } },")
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
    log.info("可卡因 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY0").."%")
    log.info("大麻 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY1").."%")
    log.info("冰毒 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY2").."%")
    log.info("假钞 原材料库存: "..stats.get_int("MPX_MATTOTALFORFACTORY3").."%")
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
    if math.random(0, 100) > 50 then 
        WEAPON.GIVE_WEAPON_TO_PED(peds_func, joaat("WEAPON_MICROSMG"), 9999, false, true)
    else
    --WEAPON.GIVE_WEAPON_TO_PED(peds_func, joaat("WEAPON_CARBINERIFLE_MK2"), 9999, false, true)
    WEAPON.GIVE_WEAPON_TO_PED(peds_func, joaat("WEAPON_RAILGUNXM3"), 1, false, true)
    end
    WEAPON.SET_PED_INFINITE_AMMO(peds_func, true, joaat("WEAPON_RAILGUNXM3"))
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
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 12, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 13, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 21, false)
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 27, true)
    PED.SET_PED_COMBAT_ATTRIBUTES(peds_func, 58, true)
    PED.SET_PED_CONFIG_FLAG(peds_func, 394, true)
    PED.SET_PED_CONFIG_FLAG(peds_func, 400, true)
    PED.SET_PED_CONFIG_FLAG(peds_func, 134, true)
    PED.SET_PED_CAN_RAGDOLL(peds_func, false)
    PED.SET_PED_SHOOT_RATE(peds_func, 1000)
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
        if objmod == 2202227855 or objmod == 3105373629 then
            ObjTableTab:add_text(obj_id.." Model: "..objmod.." Distance: "..formattedobjdistance.." Potential task entities")
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
        VehicleTableTab:add_button("Teleport to"..Veh_list_index, function()
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), ENTITY.GET_ENTITY_COORDS(t_veh_hd, true).x, ENTITY.GET_ENTITY_COORDS(t_veh_hd, true).y, ENTITY.GET_ENTITY_COORDS(t_veh_hd, true).z)
        end)
        VehicleTableTab:add_sameline()
        VehicleTableTab:add_button("Destroy the engine"..Veh_list_index, function()
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

function Is_NPC_H(peds)
   if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 3 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 1 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(peds)) == 49 or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Swat_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Cop_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_M_Y_Sheriff_01") or ENTITY.GET_ENTITY_MODEL(peds) == joaat("S_F_Y_Sheriff_01")) then
        return true
    else
        return false
    end
end

--------------------------------------------------------------------------------------- functions 供lua调用的用于实现特定功能的函数
--------------------------------------------------------------------------------------- TEST
--[[
gentab:add_button("test01", function()
    for fm2i=0,60000 do
        rst = locals_get_int(0, "fm_mission_controller_2020", fm2i)
        if rst == 291 then 
            log.info(tostring(fm2i.."  "..rst))
        end
    end
    log.info("done")
end)


gentab:add_button("localsnapshot", function()
    local monValues = {}

    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) ~= 0 then
        for i = 40000, 60000 do
            local value = locals_get_int(0, "fm_mission_controller_2020", i)
            if value ~= -1 then
                table.insert(monValues, string.format("%d:%d", i, value))
            end
        end
        log.info("Ready to print")
        for _, smt in ipairs(monValues) do
            log.info(tostring(smt))
        end
        log.info("Done")

    end
end)
gentab:add_sameline()

prevValues = {}
gentab:add_button("localbatchmon", function()
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) ~= 0 then
        for i = 0, 60000 do
            local newValue = locals_get_int(0, "fm_mission_controller", i)
            if prevValues[i] ~= newValue then
                log.info(string.format("%d : %d -> %d", i, prevValues[i] or 0, newValue))
                prevValues[i] = newValue
            end
        end
        log.info("Down")
    end
end)
gentab:add_sameline()
gentab:add_button("testmode on", function()
    devmode = 1
    deva1 = 71
    deva2 = 72
    deva3 = 73
    deva4 = 74
    deva5 = 75
    deva6 = 76
end)
gentab:add_sameline()
gentab:add_button("testmode off", function()
    devmode = 0
    deva1 = 71
    deva2 = 72
    deva3 = 73
    deva4 = 74
    deva5 = 75
    deva6 = 76
end)
gentab:add_sameline()
gentab:add_button("fulllocalmon on", function()
    devmode2 = 1
end)
gentab:add_sameline()
gentab:add_button("fulllocalmon off", function()
    devmode2 = 0
end)
gentab:add_sameline()
gentab:add_button("montable reset", function()
    prevValues = {}
end)

gentab:add_button("test02", function()
    script.run_in_fiber(function (vmod)

    local newvehtable = {    }
    table.insert(newvehtable, "castigator")
table.insert(newvehtable, "coquette5")
table.insert(newvehtable, "dominator10")
table.insert(newvehtable, "driftcypher")
table.insert(newvehtable, "driftnebula")
table.insert(newvehtable, "driftsentinel")
table.insert(newvehtable, "driftvorschlag")
table.insert(newvehtable, "envisage")
table.insert(newvehtable, "eurosX32")
table.insert(newvehtable, "niobe")
table.insert(newvehtable, "paragon3")
table.insert(newvehtable, "pipistrello")
table.insert(newvehtable, "pizzaboy")
table.insert(newvehtable, "poldominator10")
table.insert(newvehtable, "poldorado")
table.insert(newvehtable, "polgreenwood")
table.insert(newvehtable, "policet3")
table.insert(newvehtable, "polimpaler5")
table.insert(newvehtable, "polimpaler6")
table.insert(newvehtable, "vorschlaghammer")
table.insert(newvehtable, "yosemite1500")

    for _, veh in pairs(newvehtable) do
            STREAMING.REQUEST_MODEL(joaat(veh))

            while not STREAMING.HAS_MODEL_LOADED(joaat(veh)) do

                STREAMING.REQUEST_MODEL(joaat(veh))
                vmod:yield()
            end   
                spawncrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(), false)
                veh1 = VEHICLE.CREATE_VEHICLE(joaat(veh), spawncrds.x, spawncrds.y, spawncrds.z, 0 , true, true, true)
                PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh1, -1)
                vmod:sleep(1000)

                upgrade_vehicle(veh1,veh)
                vmod.yield()
        end
    end)

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
gentab:add_text("Data modification functions will be migrated to the 'Adjustables and Statistics' submenu") 

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
            locals_set_int(3274, "fm_mission_controller_2020", 50150 + 1, 51338752)  --关键代码  
            locals_set_int(3274, "fm_mission_controller_2020", 50150 + 1770 + 1, 100) --关键代码 
            locals_set_int(3274, "fm_mission_controller", 19746, 12) 
            locals_set_int(3274, "fm_mission_controller", 27489 + 859 + 18, 99999) 
            locals_set_int(3274, "fm_mission_controller", 31621 + 69, 99999) 
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
    if globals_get_int(3274, 1971648 + 1093) == 79 then  --确认抢劫计划面板未全屏渲染再刷新，避免脚本死亡
        locals_set_int(3274, "heist_island_planning", 1546, 2) 
    end
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
    if globals_get_int(3274, 1971648 + 1093) == 79 then  --确认抢劫计划面板未全屏渲染再刷新，避免脚本死亡
        locals_set_int(3274, "heist_island_planning", 1546, 2) 
    end
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
    if globals_get_int(3274, 1971648 + 1093) == 79 then  --确认抢劫计划面板未全屏渲染再刷新，避免脚本死亡
        locals_set_int(3274, "heist_island_planning", 1546, 2) 
    end
    gui.show_message("Attention","The planning panel will be restored to its initial state after buying the kosatka!")
end)

gentab:add_sameline()

gentab:add_button("Skip Firm Data Breach Contract (don't mess with DRE)", function()
    stats.set_int("MPx_FIXER_GENERAL_BS", -1)
    stats.set_int("MPx_FIXER_STORY_BS", 4092)
end)

gentab:add_button("Skip Casino heist prep (diamond)", function()
    stats.set_int("MPX_H3OPT_APPROACH", 2)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    stats.set_int("MPX_H3_LAST_APPROACH", 1)
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

gentab:add_button("Skip Casino heist prep (Gold)", function()
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


gentab:add_button("Switch CEO/Leader", function() 
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    --playerOrganizationTypeRaw: {Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10.f_429}  GLOBAL  
    --playerOrganizationType: {('1886967', '*609', '10', '429', '1')}  GLOBAL  global + (pid *pidmultiplier) + offset + offset + offset (values: 0 = CEO and 1 = MOTORCYCLE CLUB) 
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then --1886967+playerIndex*609+10+429+1 = 0 为CEO =1为摩托帮首领
        globals_set_int(3274, 1887305+playerIndex*609+10+430+1,1)
        gui.show_message("Prompt","converted to the leader of the MC club")
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            globals_set_int(3274, 1887305+playerIndex*609+10+430+1,0)
            gui.show_message("Prompt","has been converted to CEO")
        else
            gui.show_message("You are not the boss","You are neither the CEO nor the leader")
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show office computer", function() 
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        run_script("appfixersecurity", 4592)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            globals_set_int(3274, 1887305+playerIndex*609+10+430+1,0)
            gui.show_message("Prompt","has been converted to CEO")
            run_script("appfixersecurity", 4592)
            else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
            run_script("appfixersecurity", 4592)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show bunker computer", function() 
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        run_script("appbunkerbusiness", 1424)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            run_script("appbunkerbusiness", 1424)
            else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
                run_script("appbunkerbusiness", 1424)
            end
    end
end)

gentab:add_sameline()

gentab:add_button("Show hangar computer", function() 
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        run_script("appsmuggler", 4592)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            run_script("appsmuggler", 4592)
            else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
                un_script("appsmuggler", 4592)
            end
    end
end)

gentab:add_sameline()

gentab:add_button("Show arcade computer", function() 
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        PLAYER.FORCE_CLEANUP_FOR_ALL_THREADS_WITH_THIS_NAME("appArcadeBusinessHub", 1)
        run_script("apparcadebusinesshub", 1424)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            PLAYER.FORCE_CLEANUP_FOR_ALL_THREADS_WITH_THIS_NAME("appArcadeBusinessHub", 1)
            run_script("apparcadebusinesshub", 1424)
        else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
                run_script("apparcadebusinesshub", 1424)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show the Terrorbyte dashboard", function() 
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        run_script("apphackertruck", 4592)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            run_script("apphackertruck", 4592)
        else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
            run_script("apphackertruck",4592)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show Avengers panel", function()  
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        run_script("appAvengerOperations", 4592)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            run_script("appAvengerOperations", 4592)
        else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, a known problem, no feedback required")
            run_script("appAvengerOperations", 4592)
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show bail office panel", function()  
    local playerIndex = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 0 then
        run_script("appBailOffice", 4592)
    else
        if globals_get_int(3274, 1887305+playerIndex*609+10+430+1) == 1 then
            run_script("appBailOffice", 4592)
        else
            gui.show_message("Don't forget to register as CEO/Mc", "It could also be a script detection error, known issue, no feedback needed")
            run_script("appBailOffice", 4592)
        end
    end
end)

gentab:add_button("Increase team life count", function() --MC_TLIVES -3095
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) ~= 0 then 
        network.force_script_host("fm_mission_controller_2020") --抢脚本主机
        c_tlives_v = locals_get_int(3274, "fm_mission_controller_2020", 56798 + 873 + 1)
        locals_set_int(3274, "fm_mission_controller_2020", 56798 + 873 + 1, c_tlives_v + 5)
    end
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) ~= 0 then 
        network.force_script_host("fm_mission_controller") --抢脚本主机
        globals_set_int(3274, 4718592 + 3592 + 1 + 38, 1)
        c_tlives_v = locals_get_int(3274, "fm_mission_controller", 26172 + 1325 + 1)
        locals_set_int(3274, "fm_mission_controller", 26172 + 1325 + 1, c_tlives_v + 5)
        --[[
        int func_787(bool bParam0, bool bParam1)//Position - 0x200F2
{
	int iVar0;
	int iVar1;
	
	iVar0 = Global_4718592.f_3592[bParam0 /*25891*/].f_38;
	if (BitTest(Global_4718592.f_11, 5))
	{
		iVar0 = Global_4718592.f_3592[0 /*25891*/].f_38;
	}
	if (Local_28365[bParam0] < 17 && Global_4718592.f_3592[bParam0 /*25891*/].f_40[Local_28365[bParam0] ] != -1)
	{
		iVar0 = Global_4718592.f_3592[bParam0 /*25891*/].f_40[Local_28365[bParam0] ];
	}
	if (!(bParam1 && BitTest(uLocal_15178, 31)))
	{
		if (BitTest(Local_19746.f_2, 21) && (((((((((((BitTest(Local_19746.f_3, 30) || BitTest(Local_19746.f_4, 2)) || BitTest(Local_19746.f_4, 15)) || BitTest(Local_19746.f_4, 30)) || BitTest(Local_19746.f_4, 1)) || (BitTest(Local_19746.f_5, 18) && !func_605(Global_4718592.f_185586))) || BitTest(Local_19746.f_5, 31)) || BitTest(Local_19746.f_7, 4)) || (BitTest(Local_19746.f_7, 8) && !BitTest(Global_4718592.f_26, 28))) || (BitTest(Local_19746.f_4, 9) && BitTest(Global_4718592.f_24, 18))) || (BitTest(Local_19746.f_4, 9) && func_788(Global_4718592.f_185586))) || BitTest(Local_19746.f_8, 17)))
		{
			return 0;
		}
	}
	if (BitTest(Global_4718592.f_19, 0))
	{
		iVar0 = Local_22960.f_1470[bParam0];
		if (BitTest(Global_4718592.f_21, 16))
		{
			iVar0 = (iVar0 - 1);
		}
		return iVar0;
	}
	if (bParam1)
	{
		iVar1 = Local_31621[bLocal_3230 /*292*/].f_197;
	}
	else
	{
		iVar1 = Local_26172.f_1325[bParam0];
	}
	switch (iVar0)
	{
		case -1:
			return (0 + iVar1);
		
		case 0:
			return -1;
		
		case 1:
			return (1 + iVar1);
		
		case 2:
			return (2 + iVar1);
		
		case 3:
			return (3 + iVar1);
		
		case 4:
			return (4 + iVar1);
		
		case 5:
			return (5 + iVar1);
		
		case 6:
			return (6 + iVar1);
		
		case 7:
			return (7 + iVar1);
		
		case 8:
			return (8 + iVar1);
		
		case 9:
			return (9 + iVar1);
		
		case 10:
			return (10 + iVar1);
		
		case 11:
			return (15 + iVar1);
		
		case 12:
			return (20 + iVar1);
		
		case 13:
			return (30 + iVar1);
		
		case 14:
			return (50 + iVar1);
		
		case 15:
			return (100 + iVar1);
		
		case 16:
			return (Local_19746.f_1765[bParam0] + iVar1);
		
		case 17:
			return ((2 * Local_19746.f_1765[bParam0]) + iVar1);
		
		default:
	}
	return 0;
}
]]
    end
end)

gentab:add_text("MiniGameHack has been stripped from sch-lua, please use MiniGameHack Lua. (https://github.com/YimMenu-Lua/MiniGameHack)")

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
        upgrade_vehicle(myvehisin,"")
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

local vehengdmg = gentab:add_checkbox("Burn ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehfixr = gentab:add_checkbox("Repair ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehstopr = gentab:add_checkbox("Stop ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehjmpr = gentab:add_checkbox("Jump ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehdoorlk4p = gentab:add_checkbox("Lock the door for all players ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehbr = gentab:add_checkbox("Chaos ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehsp1 = gentab:add_checkbox("Rotate ##vehctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehrm = gentab:add_checkbox("Delete V ##vehctl0") --只是一个开关，代码往后面找

gentab:add_text("Hostile NPC vehicle control") 

gentab:add_sameline()

local vehengdmg2 = gentab:add_checkbox("Burn 2 ##vehctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehstopr2 = gentab:add_checkbox("Stop 2 ##vehctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehrm2 = gentab:add_checkbox("Delete 2 ##vehctl1") --只是一个开关，代码往后面找

gentab:add_text("NPC control") 

gentab:add_sameline()

local reactany = gentab:add_checkbox("Interrupt A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local react1any = gentab:add_checkbox("Fall A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local react2any = gentab:add_checkbox("Kill A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local react3any = gentab:add_checkbox("Burn A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local react4any = gentab:add_checkbox("Take off A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

gentab:add_button("Bodyguard ##npcctl0", function()
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

gentab:add_button("Heal A ##npcctl0", function()
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

local revitalizationped = gentab:add_checkbox("Resurrection (unstable) ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmdied = gentab:add_checkbox("Remove the body A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp = gentab:add_checkbox("Disarm A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany = gentab:add_checkbox("Electric shock A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_sameline()

local drawbox = gentab:add_checkbox("Light beam marker A ##npcctl0") --只是一个开关，代码往后面找

gentab:add_text("(BETA testing) NPC control automatically excludes friendly whitelisting (list not yet complete, see below), lightpost markers still work globally") 

gentab:add_text("Hostile NPC control") 

gentab:add_sameline()

local reactanyac = gentab:add_checkbox("Interrupt A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react1anyac = gentab:add_checkbox("Fall A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react2anyac = gentab:add_checkbox("Kill A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react3anyac = gentab:add_checkbox("Burn A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react4anyac = gentab:add_checkbox("Take off A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react5anyac = gentab:add_checkbox("Bodyguard A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react6anyac = gentab:add_checkbox("Beam marker A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp2 = gentab:add_checkbox("Disarm A1 ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany2 = gentab:add_checkbox("Electric shock B ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany7 = gentab:add_checkbox("Detonate ##npcctl1") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany8 = gentab:add_checkbox("Weakened combat power ##npcctl1") --只是一个开关，代码往后面找

gentab:add_text("NPCs target me for punishment") 

gentab:add_sameline()

local aimreact = gentab:add_checkbox("Interrupt B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact1 = gentab:add_checkbox("Fall B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact2 = gentab:add_checkbox("Kill B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact3 = gentab:add_checkbox("Burn B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact4 = gentab:add_checkbox("Take off B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact5 = gentab:add_checkbox("Bodyguard B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact6 = gentab:add_checkbox("Remove B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp3 = gentab:add_checkbox("Disarm B ##npcctl2") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany3 = gentab:add_checkbox("Electric shock C ##npcctl2") --只是一个开关，代码往后面找

gentab:add_text("Punish targeting NPC") 

gentab:add_sameline()

local aimreactany = gentab:add_checkbox("Interrupt C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact1any = gentab:add_checkbox("Fall C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact2any = gentab:add_checkbox("Kill C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact3any = gentab:add_checkbox("Burn C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact4any = gentab:add_checkbox("Take off C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact5any = gentab:add_checkbox("Bodyguard C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact6any = gentab:add_checkbox("Remove C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmpedwp4 = gentab:add_checkbox("Disarm C ##npcctl3") --只是一个开关，代码往后面找

gentab:add_sameline()

local stnpcany4 = gentab:add_checkbox("Electric shock D ##npcctl3") --只是一个开关，代码往后面找

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
    joaat("prop_cctv_pole_02"),
    joaat("prop_cctv_pole_03"),
    joaat("prop_cctv_pole_04"),
    joaat("prop_cctv_pole_01a"),
    joaat("h4_prop_h4_cctv_pole_04"),
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
        if Is_NPC_H(peds) and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and math.random(0,1) >= 0.5 and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() then 
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
        if Is_NPC_H(peds) and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() then 
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
    PED.SET_PED_COMBAT_ATTRIBUTES(heli_guards[1], 3, false)
    PED.SET_PED_COMBAT_ATTRIBUTES(heli_guards[2], 3, false)
    PED.SET_PED_COMBAT_ATTRIBUTES(heli_guards[3], 3, false)
    PED.SET_PED_COMBAT_ATTRIBUTES(heli_guards[4], 3, false)
    PED.SET_PED_CONFIG_FLAG(heli_guards[1], 402, true)
    PED.SET_PED_CONFIG_FLAG(heli_guards[2], 402, true)
    PED.SET_PED_CONFIG_FLAG(heli_guards[3], 402, true)
    PED.SET_PED_CONFIG_FLAG(heli_guards[4], 402, true)
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

gentab:add_text("Industry function - Risk level indicator: |- Almost no risk !!- Medium risk !!!- High risk !!!!- Extremely high risk  *- Temporary modification, invalid when switching session disabled") 

gentab:add_button("1 click completion of CEO warehouse shipments (!!)", function()
    locals_set_int(3274, "gb_contraband_sell",547,99999) --Local_545.f_2 
end)

gentab:add_sameline()

gentab:add_button("1 click completion of motorcycle shipment (!!)", function()
    if locals_get_int(3274, "gb_biker_contraband_sell",721) >= 1 then 
        locals_set_int(3274, "gb_biker_contraband_sell",826,15) --704 + 122 
    else
        gui.show_error("This task type does not support 1 click completion", "1 click for a total of one truck")
        log.info("该任务类型不支持一键完成,否则不会有任何收入.一共就一辆送货载具也要使用一键完成??")
    end
end)
--[[extremely unstable 
gentab:add_sameline()

gentab:add_button("1 click delivery of acid", function() 
    locals_set_int(0, "fm_content_acid_lab_sell",6596,9)
    locals_set_int(0, "fm_content_acid_lab_sell",6597,10)
    locals_set_int(0, "fm_content_acid_lab_sell",6530,2)
end)
]]
gentab:add_sameline()

gentab:add_button("1 click completion of bunker shipment (!!)", function()
    gui.show_message("Autoshipment","may show that the task failed, but you should get the money!")
    locals_set_int(3274, "gb_gunrunning",1985,0) 
    --  gb_gunrunning.c Local_1211.f_774
    --	while (iVar0 < func_837(func_3839(), func_60(), Local_1211.f_774, Local_1211.f_809))
    --  REMOVE_PARTICLE_FX_FROM_ENTITY
    gui.show_message("Autoship "," may show that the task failed, but you should get the money!")
end)

gentab:add_sameline()

gentab:add_button("1 click completion of hangar (air freight) shipment (!!)", function()
    gui.show_message("Autoshipment","may show that the task failed, but you should get the money!")
    local integer = locals_get_int(3274, "gb_smuggler", 3012)  --Local_1934.f_1078 SMOT_HLPDROP2
    locals_set_int(3274, "gb_smuggler",2969,integer) --1934 + 1035  
    gui.show_message("Autoshipment","may show that the task failed, but you should get the money!")
end)

local ccrgsl = gentab:add_checkbox("CEO warehouse shipment locks the transport ship (|)")

gentab:add_sameline()

local bkeasyms = gentab:add_checkbox("The motorcycle gang will ship only one truck (|)")

gentab:add_sameline()

local bussp2 = gentab:add_checkbox("Rapid production of acid in the motorcycle gang industrial bunker (!!!)")

gentab:add_sameline()

local bussp = gentab:add_checkbox("Extreme production of acid in the motorcycle gang industrial bunker (!!!!)")

gentab:add_sameline()

local ncspup = gentab:add_checkbox("Nightclub fast purchase (!!!!)")

local ncspupa1 = gentab:add_checkbox("Purchase at 4 times the speed of the nightclub (!!!)")

gentab:add_sameline()

local ncspupa2 = gentab:add_checkbox("Purchase at 10 times the speed of the nightclub (!!!!)")

gentab:add_sameline()

local ncspupa3 = gentab:add_checkbox("Purchase at 20 times the speed of the nightclub (!!!!)")

gentab:add_button("The MC club industry is full of supplies (!!)", function()
    globals_set_int(3274, 1663174+1+1,1) --大麻 --freemode.c  	if (func_11921(148, "OR_PSUP_DEL" /* GXT: Hey, the supplies you purchased have arrived at the ~a~. Remember, paying for them eats into profits! */, &Var3, 0, -99, 0, 0, 0, 0))
    globals_set_int(3274, 1663174+1+2,1) --冰毒
    globals_set_int(3274, 1663174+1+3,1) --假钞
    globals_set_int(3274, 1663174+1+4,1) --证件
    globals_set_int(3274, 1663174+1+0,1) --可卡因
    globals_set_int(3274, 1663174+1+6,1) --致幻剂
    gui.show_message("Auto-replenishment","All done")
end)

gentab:add_sameline()

gentab:add_button("The bunker is full of supplies (!!)", function()
    globals_set_int(3274, 1663174+1+5,1) --bunker
    gui.show_message("Auto-replenishment","All done")
end)

gentab:add_sameline()

local autorespl = gentab:add_checkbox("Warehouse automatic replenishment (possible crash)")

gentab:add_sameline()

gentab:add_button("Max nightclub's popularity (|)", function()
    stats.set_int("MPX_CLUB_POPULARITY", 10000)
end)

gentab:add_sameline()

gentab:add_button("CEO Warehouse staff restock once (!!)", function()
    --freemode.c void func_17501(int iParam0, BOOL bParam1) // Position - 0x56C7B6
    packed_stat_set_bool(32359,true) --无需更新
    packed_stat_set_bool(32360,true) --无需更新
    packed_stat_set_bool(32361,true) --无需更新
    packed_stat_set_bool(32362,true) --无需更新
    packed_stat_set_bool(32363,true) --无需更新
end)

gentab:add_sameline()

gentab:add_button("Hangar staff restock once (!!)", function()
    packed_stat_set_bool(36828,true)  --无需更新
end)

local checkCEOcargo = gentab:add_checkbox("The single purchase quantity of locked warehouse staff is")

gentab:add_sameline()

local inputCEOcargo = gentab:add_input_int("crates (!!)")

local check4 = gentab:add_checkbox("Lock hangar staff single purchase quantity is")

gentab:add_sameline()

local iputint3 = gentab:add_input_int("box (!!)")

gentab:add_button("Nightclub safe 300,000 cycles 10 times (!!!)", function()
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

local checklkw = gentab:add_checkbox("Casino carousel draw (the carousel may appear as something else, but you do get vehicles) Low risk for occasional use")

gentab:add_sameline()

local vehexportclasslock = gentab:add_checkbox("CEO Carrier Transaction Locked Acquisition Type is Top (|)")

local checkxsdped = gentab:add_checkbox("NPC drops 2000 bucks cycle (!!!!)")

gentab:add_sameline()

gentab:add_button("Disable industrial raids (|,*)", function()
    
    tunables.set_bool("EXEC_DISABLE_DEFEND_MISSIONS", true)
    tunables.set_bool("EXEC_DISABLE_DEFEND_FLEEING", true)
    tunables.set_bool("EXEC_DISABLE_DEFEND_UNDER_ATTACK", true)
    tunables.set_float("EXEC_WAREHOUSE_STOCK_DEFEND_THRESHOLD", 9999)

    tunables.set_float("BB_DEFEND_MISSIONS_STOCK_THRESHOLD_FOR_MISSION_LAUNCH_DEFAULT", 9999) --Nightclub
    tunables.set_float("BB_DEFEND_MISSIONS_STOCK_THRESHOLD_FOR_MISSION_LAUNCH_UPGRADED", 9999)

    tunables.set_bool("BIKER_DISABLE_DEFEND_GETAWAY", true)
    tunables.set_bool("BIKER_DISABLE_DEFEND_SHOOTOUT", true)
    tunables.set_bool("BIKER_DISABLE_DEFEND_CRASH_DEAL", true)
    tunables.set_bool("BIKER_DISABLE_DEFEND_SNITCH", true)
    tunables.set_bool("BIKER_DISABLE_DEFEND_RETRIEVAL", true)
    tunables.set_int("BIKER_DEFEND_GETAWAY_PRODUCT_THRESHOLD", 9999)
    tunables.set_int("BIKER_DEFEND_SHOOTOUT_PRODUCT_THRESHOLD", 9999)
    tunables.set_int("BIKER_DEFEND_CRASH_DEAL_PRODUCT_THRESHOLD", 9999)
    tunables.set_int("BIKER_DEFEND_SNITCH_PRODUCT_THRESHOLD", 9999)
    tunables.set_int("BIKER_DEFEND_RETRIEVAL_PRODUCT_THRESHOLD", 9999)

    tunables.set_int("GR_GENERAL_STOCK_LEVEL_LAUNCH_THRESHOLD", 9999)
end)

gentab:add_sameline()

gentab:add_button("Reduce MC Club + Bunker raw material consumption (!!,*)", function()

    tunables.set_int("BIKER_WEED_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("BIKER_WEED_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)
    tunables.set_int("BIKER_METH_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("BIKER_METH_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)
    tunables.set_int("BIKER_CRACK_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("BIKER_CRACK_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)
    tunables.set_int("BIKER_FAKEIDS_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("BIKER_FAKEIDS_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)
    tunables.set_int("BIKER_COUNTERCASH_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("BIKER_COUNTERCASH_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)

    tunables.set_int("BIKER_ACID_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("BIKER_ACID_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)

    tunables.set_int("GR_RESEARCH_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("GR_RESEARCH_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)
    tunables.set_int("GR_MANU_MATERIAL_PRODUCT_COST", 1)
    tunables.set_int("GR_MANU_MATERIAL_PRODUCT_COST_UPGRADE_REDUCTION", 1)

end)

gentab:add_sameline()

gentab:add_button("Easy Nightclub selling mission (|,*)", function()

    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_SINGLE_DROP", 2)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_MULTI_DROP", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_HACK_DROP", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_ROADBLOCK", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_PROTECT_BUYER", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_UNDERCOVER_COPS", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_OFFSHORE_TRANSFER", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_NOT_A_SCRATCH", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_FOLLOW_HELI", 0.01)
    tunables.set_float("BB_SELL_MISSIONS_WEIGHTING_FIND_BUYER", 0.01)

end)

gentab:add_sameline()

gentab:add_button("Easy CEO vehicle acquisition mission (|,*)", function()

    tunables.set_bool("IMPEXP_DISABLE_PARKED_CAR", false)		
    tunables.set_bool("IMPEXP_DISABLE_MOVING_CAR", true)		
    tunables.set_bool("IMPEXP_DISABLE_CARGOBOB", true)		
    tunables.set_bool("IMPEXP_DISABLE_DRUNK_DRIVER", true)		
    tunables.set_bool("IMPEXP_DISABLE_PHOTO_SHOOT", true)		
    tunables.set_bool("IMPEXP_DISABLE_PICTURE_MESSAGE", true)		
    tunables.set_bool("IMPEXP_DISABLE_CRIME_SCENE", true)		
    tunables.set_bool("IMPEXP_DISABLE_PROTECTED_CAR", true)		
    tunables.set_bool("IMPEXP_DISABLE_PARTY_CRASHER", true)		
    tunables.set_bool("IMPEXP_DISABLE_CAR_MEET", true)		
    tunables.set_bool("IMPEXP_DISABLE_POLICE_CHASE", true)		
    tunables.set_bool("IMPEXP_DISABLE_EYE_SKY", true)		
    tunables.set_bool("IMPEXP_DISABLE_BOMB_DEFUSE", true)		
    tunables.set_bool("IMPEXP_DISABLE_LAPPED_RACE", true)		
    tunables.set_bool("IMPEXP_DISABLE_STUNT_MAN", true)		
    tunables.set_bool("IMPEXP_DISABLE_RACE_DRIVER", true)		
    tunables.set_bool("IMPEXP_DISABLE_TAIL_VEHICLE", true)		
end)

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

gentab:add_sameline()

gentab:add_button("Random location", function()
    _,safepos = PATHFIND.GET_NTH_CLOSEST_VEHICLE_NODE_WITH_HEADING(math.random(-1794,2940), math.random(-3026,6298), 20, 1, 0, outheading, lanes, 0, 3.0, 0.0)
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), safepos.x, safepos.y, safepos.z)
end)

gentab:add_sameline()

gentab:add_button("L.S Customs", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  -337, -137, 38.5)
end)

gentab:add_sameline()

gentab:add_button("Ammunation with shooting range", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  20.80, -1107, 29.8)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 335)
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
                globals_set_int(3274, 2738934 + 975, 1) --呼叫虎鲸 --freemode.c 	func_12504("HELP_SUBMA_P" /*Go to the Planning Screen on board your new Kosatka ~a~~s~ to begin The Cayo Perico Heist as a VIP, CEO or MC President. You can also request the Kosatka nearby via the Services section of the Interaction Menu.*/, "H_BLIP_SUB2" /*~BLIP_SUB2~*/, func_2189(PLAYER::PLAYER_ID()), -1, false, true);
                SubBlip = HUD.GET_FIRST_BLIP_INFO_ID(760)
                SubControlBlip = HUD.GET_FIRST_BLIP_INFO_ID(773)    
                callkos:yield()
            end
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),1561.2369, 385.8771, -49.689915)
            PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 175)         
        end
    end)
end)

gentab:add_sameline()

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

local function GetNightClubPropertyID()
    local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    return globals_get_int(3274, 1845281 + 1 + (playerid * 883) + 268 + 358) 
end

function tpnc() --传送到夜总会
    local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    local property = globals_get_int(3274, 1845281 + 1 + (playerid * 883) + 268 + 358) 
    if property ~= 0  then
        local coords = NightclubPropertyInfo[property].coords
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z)
    end
end

gentab:add_sameline()

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

gentab:add_sameline()

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

gentab:add_button("Perico drain fence", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  5044.62, -5815.75, -12.3)
end)

gentab:add_sameline()

gentab:add_button("Perico Drainage Intrusion Point", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  5055, -5771, -6)
end)

gentab:add_sameline()

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

gentab:add_separator()
gentab:add_text("Miscellaneous")

local SEa = 0

gentab:add_button("Remove income and expenditure difference", function()
    SE = MONEY.NETWORK_GET_VC_BANK_BALANCE() + stats.get_int("MPPLY_TOTAL_SVC") - stats.get_int("MPPLY_TOTAL_EVC")
    log.info(tostring(SE))
    if SE >= 20000 and SEa == 0 and stats.get_int("MPPLY_TOTAL_SVC") > 0 and stats.get_int("MPPLY_TOTAL_EVC") > 0 and stats.get_int("MPPLY_TOTAL_SVC") < 2147483647 and stats.get_int("MPPLY_TOTAL_EVC") < 2147483647 then
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
    tuneales_veh_list = {
        "ENABLE_LOWRIDER2_VIRGO3",
        "ENABLE_LOWRIDER2_SABREGT",
        "ENABLE_LOWRIDER2_TORNADO5",
        "ENABLE_LOWRIDER2_MINIVAN",
        "ENABLE_LOWRIDER2_FACTION",
        "ENABLE_LOWRIDER2_SLAMVAN",
        "ENABLEEXEC1_GROTTI_PROTO",
        "ENABLEEXEC1_DEWBAUCHEE",
        "ENABLEEXEC1_PFISTER",
        "ENABLESTUNT_ET1",
        "ENABLESTUNT_TYRUS",
        "ENABLESTUNT_DRIFT_TAMPA",
        "ENABLESTUNT_LE7B",
        "ENABLESTUNT_OMNIS",
        "ENABLESTUNT_TROPOS_RALLYE",
        "ENABLESTUNT_BRIOSO_RA",
        "ENABLESTUNT_TROPHY_TRUCK",
        "ENABLESTUNT_TROPHY_CAR",
        "ENABLESTUNT_CONTENDER",
        "ENABLESTUNT_CLIFFHANGER",
        "ENABLESTUNT_BF400",
        "ENABLESTUNT_LYNX",
        "ENABLESTUNT_GARGOYLE",
        "ENABLESTUNT_RALLY_TRUCK",
        "ENABLESTUNT_STALLION",
        "ENABLESTUNT_GAUNTLET",
        "ENABLESTUNT_DOMINATOR",
        "ENABLESTUNT_BUFFALO",
        "ENABLE_BIKER_DEFILER",
        "ENABLE_BIKER_FAGGIO",
        "ENABLE_BIKER_NIGHTBLADE",
        "ENABLE_BIKER_ZOMBIEA",
        "ENABLE_BIKER_ESSKEY",
        "ENABLE_BIKER_AVARUS",
        "ENABLE_BIKER_ZOMBIEB",
        "ENABLE_BIKER_HAKUCHOU2",
        "ENABLE_BIKER_VORTEX",
        "ENABLE_BIKER_SHOTARO",
        "ENABLE_BIKER_CHIMERA",
        "ENABLE_BIKER_RAPTOR",
        "ENABLE_BIKER_WESTERNDAEMON",
        "ENABLE_BIKER_BLAZER4",
        "ENABLE_BIKER_SANCTUS",
        "ENABLE_BIKER_MANCHEZ",
        "ENABLE_BIKER_YOUGA2",
        "ENABLE_BIKER_WOLFSBANE",
        "ENABLE_BIKER_FAGGIO3",
        "ENABLE_BIKER_TORNADO6",
        "ENABLE_BIKER_BAGGER",
        "ENABLE_BIKER_RATBIKE",
        "ENABLE_IE_VOLTIC2",
        "ENABLE_IE_RUINER2",
        "ENABLE_IE_DUNE4",
        "ENABLE_IE_DUNE5",
        "ENABLE_IE_PHANTOM2",
        "ENABLE_IE_TECHNICAL2",
        "ENABLE_IE_BOXVILLE5",
        "ENABLE_IE_WASTELANDER",
        "ENABLE_IE_BLAZER5",
        "ENABLE_IE_COMET2",
        "ENABLE_IE_COMET3",
        "ENABLE_IE_DIABLOUS",
        "ENABLE_IE_DIABLOUS2",
        "ENABLE_IE_ELEGY",
        "ENABLE_IE_ELEGY2",
        "ENABLE_IE_FCR",
        "ENABLE_IE_FCR2",
        "ENABLE_IE_ITALIGTB",
        "ENABLE_IE_ITALIGTB2",
        "ENABLE_IE_NERO",
        "ENABLE_IE_NERO2",
        "ENABLE_IE_PENETRATOR",
        "ENABLE_IE_SPECTER",
        "ENABLE_IE_SPECTER2",
        "ENABLE_IE_TEMPESTA",
        "ENABLEGP1",
        "ENABLEINFERNUS2",
        "ENABLERUSTON",
        "ENABLETURISMO2",
        "ENABLE_CHEETAH2",
        "ENABLE_TORERO",
        "ENABLE_VAGNER",
        "ENABLE_ARDENT",
        "ENABLE_NIGHTSHARK",
        "ENABLE_ULTRALIGHT",
        "ENABLE_SEABREEZE",
        "ENABLE_HOWARD",
        "ENABLE_ROGUE",
        "ENABLE_ALPHAZ1",
        "ENABLE_CYCLONE",
        "ENABLE_VISIONE",
        "ENABLE_VIGILANTE",
        "ENABLE_RETINUE",
        "ENABLE_RAPIDGT3",
        "ENABLE_HAVOK",
        "ENABLE_NOKOTA",
        "ENABLE_MOGUL",
        "ENABLE_STARLING",
        "ENABLE_HUNTER",
        "ENABLE_PYRO",
        "ENABLE_MOLOTOK",
        "ENABLE_TULA",
        "ENABLE_BOMBUSHKA",
        "ENABLE_LAZER",
        "ENABLE_DELUXO",
        "ENABLE_STROMBERG",
        "ENABLE_RIOT2",
        "ENABLE_CHERNOBOG",
        "ENABLE_KHANJALI",
        "ENABLE_AKULA",
        "ENABLE_THRUSTER",
        "ENABLE_BARRAGE",
        "ENABLE_VOLATOL",
        "ENABLE_COMET4",
        "ENABLE_NEON",
        "ENABLE_STREITER",
        "ENABLE_SENTINEL3",
        "ENABLE_YOSEMITE",
        "ENABLE_SC1",
        "ENABLE_AUTARCH",
        "ENABLE_GT500",
        "ENABLE_HUSTLER",
        "ENABLE_REVOLTER",
        "ENABLE_PARIAH",
        "ENABLE_RAIDEN",
        "ENABLE_SAVESTRA",
        "ENABLE_RIATA",
        "ENABLE_HERMES",
        "ENABLE_COMET5",
        "ENABLE_Z190",
        "ENABLE_VISERIS",
        "ENABLE_KAMACHO",
        "ENABLE_VEHICLE_TOROS",
        "ENABLE_VEHICLE_CLIQUE",
        "ENABLE_VEHICLE_ITALIGTO",
        "ENABLE_VEHICLE_DEVIANT",
        "ENABLE_VEHICLE_TULIP",
        "ENABLE_VEHICLE_SCHLAGEN",
        "ENABLE_VEHICLE_BANDITO",
        "ENABLE_VEHICLE_THRAX",
        "ENABLE_VEHICLE_DRAFTER",
        "ENABLE_VEHICLE_LOCUST",
        "ENABLE_VEHICLE_NOVAK",
        "ENABLE_VEHICLE_ZORRUSSO",
        "ENABLE_VEHICLE_GAUNTLET3",
        "ENABLE_VEHICLE_ISSI7",
        "ENABLE_VEHICLE_ZION3",
        "ENABLE_VEHICLE_NEBULA",
        "ENABLE_VEHICLE_HELLION",
        "ENABLE_VEHICLE_DYNASTY",
        "ENABLE_VEHICLE_RROCKET",
        "ENABLE_VEHICLE_PEYOTE2",
        "ENABLE_VEHICLE_GAUNTLET4",
        "ENABLE_VEHICLE_CARACARA2",
        "ENABLE_VEHICLE_JUGULAR",
        "ENABLE_VEHICLE_S80",
        "ENABLE_VEHICLE_KRIEGER",
        "ENABLE_VEHICLE_EMERUS",
        "ENABLE_VEHICLE_NEO",
        "ENABLE_VEHICLE_PARAGON",
        "ENABLE_VEHICLE_DEVESTE",
        "ENABLE_VEHICLE_VAMOS",
        "ENABLE_VEHICLE_FORMULA_PODIUM",
        "ENABLE_VEHICLE_FORMULA2_PODIUM",
        "ENABLE_VEHICLE_ASBO",
        "ENABLE_VEHICLE_KANJO",
        "ENABLE_VEHICLE_EVERON",
        "ENABLE_VEHICLE_RETINUE2",
        "ENABLE_VEHICLE_YOSEMITE2",
        "ENABLE_VEHICLE_SUGOI",
        "ENABLE_VEHICLE_SULTAN2",
        "ENABLE_VEHICLE_OUTLAW",
        "ENABLE_VEHICLE_VAGRANT",
        "ENABLE_VEHICLE_KOMODA",
        "ENABLE_VEHICLE_STRYDER",
        "ENABLE_VEHICLE_FURIA",
        "ENABLE_VEHICLE_ZHABA",
        "ENABLE_VEHICLE_JB7002",
        "ENABLE_VEHICLE_FIRETRUCK",
        "ENABLE_VEHICLE_BURRITO2",
        "ENABLE_VEHICLE_BOXVILLE",
        "ENABLE_VEHICLE_STOCKADE",
        "ENABLE_VEHICLE_MINITANK",
        "ENABLE_VEHICLE_LGUARD",
        "ENABLE_VEHICLE_BLAZER2",
        "ENABLE_VEHICLE_FORMULA2",
        "ENABLE_VEH_GLENDALE2",
        "ENABLE_VEH_PENUMBRA2",
        "ENABLE_VEH_LANDSTALKER2",
        "ENABLE_VEH_SEMINOLE2",
        "ENABLE_VEH_MANANA2",
        "ENABLE_VEH_YOUGA3",
        "ENABLE_VEH_CLUB",
        "ENABLE_VEH_DUKES3",
        "ENABLE_VEH_TIGON",
        "ENABLE_VEH_OPENWHEEL1",
        "ENABLE_VEH_OPENWHEEL2",
        "ENABLE_VEH_COQUETTE4",
        "ENABLE_VEH_GAUNTLET5",
        "ENABLE_VEH_YOSEMITE3",
        "ENABLE_VEH_PEYOTE3",
        "ENABLE_VEHICLE_TOREADOR",
        "ENABLE_VEHICLE_ANNIHILATOR2",
        "ENABLE_VEHICLE_ALKONOST",
        "ENABLE_VEHICLE_PATROLBOAT",
        "ENABLE_VEHICLE_LONGFIN",
        "ENABLE_VEHICLE_WINKY",
        "ENABLE_VEHICLE_VETO",
        "ENABLE_VEHICLE_VETO2",
        "ENABLE_VEHICLE_ITALIRSX",
        "ENABLE_VEHICLE_WEEVIL",
        "ENABLE_VEHICLE_MANCHEZ2",
        "ENABLE_VEHICLE_SLAMTRUCK",
        "ENABLE_VEHICLE_VETIR",
        "ENABLE_VEHICLE_SQUADDIE",
        "ENABLE_VEHICLE_BRIOSO2",
        "ENABLE_VEHICLE_DINGY5",
        "ENABLE_VEHICLE_VERUS",
        "ENABLE_VEHICLE_TAILGATER2",
        "ENABLE_VEHICLE_EUROS",
        "ENABLE_VEHICLE_SULTAN3",
        "ENABLE_VEHICLE_RT3000",
        "ENABLE_VEHICLE_VECTRE",
        "ENABLE_VEHICLE_ZR350",
        "ENABLE_VEHICLE_WARRENER2",
        "ENABLE_VEHICLE_CALICO",
        "ENABLE_VEHICLE_REMUS",
        "ENABLE_VEHICLE_CYPHER",
        "ENABLE_VEHICLE_DOMINATOR7",
        "ENABLE_VEHICLE_JESTER4",
        "ENABLE_VEHICLE_FUTO2",
        "ENABLE_VEHICLE_DOMINATOR8",
        "ENABLE_VEHICLE_PREVION",
        "ENABLE_VEHICLE_GROWLER",
        "ENABLE_VEHICLE_COMET6",
        "ENABLE_VEHICLE_CHAMPION",
        "ENABLE_VEHICLE_BUFFALO4",
        "ENABLE_VEHICLE_DEITY",
        "ENABLE_VEHICLE_JUBILEE",
        "ENABLE_VEHICLE_IGNUS",
        "ENABLE_VEHICLE_CINQUEMILA",
        "ENABLE_VEHICLE_ASTRON",
        "ENABLE_VEHICLE_COMET7",
        "ENABLE_VEHICLE_ZENO",
        "ENABLE_VEHICLE_REEVER",
        "ENABLE_VEHICLE_IWAGEN",
        "ENABLE_VEHICLE_GRANGER2",
        "ENABLE_VEHICLE_PATRIOT3",
        "ENABLE_VEHICLE_SHINOBI",
        "ENABLE_VEHICLE_BALLER7",
        "ENABLE_VEHICLE_OMNISEGT",
        "ENABLE_VEHICLE_GREENWOOD",
        "ENABLE_VEHICLE_TORERO2",
        "ENABLE_VEHICLE_CORSITA",
        "ENABLE_VEHICLE_LM87",
        "ENABLE_VEHICLE_CONADA",
        "ENABLE_VEHICLE_SM722",
        "ENABLE_VEHICLE_DRAUGUR",
        "ENABLE_VEHICLE_RUINER4",
        "ENABLE_VEHICLE_BRIOSO3",
        "ENABLE_VEHICLE_VIGERO2",
        "ENABLE_VEHICLE_MODEL_CZ1",
        "ENABLE_VEHICLE_KANJOSJ",
        "ENABLE_VEHICLE_POSTLUDE",
        "ENABLE_VEHICLE_TENF",
        "ENABLE_VEHICLE_RHINEHART",
        "ENABLE_VEHICLE_WEEVIL2",
        "ENABLE_VEHICLE_TENF2",
        "ENABLE_VEHICLE_SENTINEL4",
        "ENABLE_VEHICLE_ENTITY3",
        "ENABLE_VEHICLE_TULIP2",
        "ENABLE_VEHICLE_JOURNEY2",
        "ENABLE_VEHICLE_SURFER3",
        "ENABLE_VEHICLE_R300",
        "ENABLE_VEHICLE_BRICKADE2",
        "ENABLE_VEHICLE_TAXI",
        "ENABLE_VEHICLE_TAHOMA",
        "ENABLE_VEHICLE_POWERSURGE",
        "ENABLE_VEHICLE_ISSI8",
        "ENABLE_VEHICLE_BROADWAY",
        "ENABLE_VEHICLE_PANTHERE",
        "ENABLE_VEHICLE_EVERON2",
        "ENABLE_VEHICLE_VIRTUE",
        "ENABLE_VEHICLE_EUDORA",
        "ENABLE_VEHICLE_BOOR",
        "ENABLE_HOTRING",
        "ENABLE_GB200",
        "ENABLE_FAGALOA",
        "ENABLE_TAIPAN",
        "ENABLE_CARACARA",
        "ENABLE_ENTITY2",
        "ENABLE_ELLIE",
        "ENABLE_TEZERACT",
        "ENABLE_FLASHGT",
        "ENABLE_ISSI3",
        "ENABLE_SEASPARROW",
        "ENABLE_CHEBUREK",
        "ENABLE_DOMINATOR3",
        "ENABLE_TYRANT",
        "ENABLE_MICHELLI",
        "ENABLE_JESTER3",
        "ENABLE_VEHICLE_FR36",
        "ENABLE_VEHICLE_TURISMO3",
        "ENABLE_VEHICLE_VIGERO3",
        "ENABLE_VEHICLE_POLICE5",
        "ENABLE_VEHICLE_POLICE4",
        "ENABLE_VEHICLE_RIOT",
        "ENABLE_VEHICLE_ALEUTIAN",
        "ENABLE_VEHICLE_DOMINATOR9",
        "ENABLE_VEHICLE_ASTEROPE2",
        "ENABLE_VEHICLE_PRANGER",
        "ENABLE_VEHICLE_CAVALCADE3",
        "ENABLE_VEHICLE_IMPALER5",
        "ENABLE_VEHICLE_POLGAUNTLET",
        "ENABLE_VEHICLE_VIVANITE",
        "ENABLE_VEHICLE_IMPALER6",
        "ENABLE_VEHICLE_DORADO",
        "ENABLE_VEHICLE_BALLER8",
        "ENABLE_VEHICLE_TERMINUS",
        "ENABLE_VEHICLE_BOXVILLE6",
        "ENABLE_VEHICLE_BENSON2",
        "ENABLE_VEHICLE_EXEMPLAR",
        "ENABLE_VEHICLE_COGCABRIO",
        "ENABLE_VEHICLE_THRUST",
        "ENABLE_VEHICLE_VINDICATOR",
        "ENABLE_VEHICLE_COQUETTE3",
        "ENABLE_VEHICLE_BRAWLER",
        "ENABLE_VEHICLE_COGNOSCENTI",
        "ENABLE_VEHICLE_COGNOSCENTI2",
        "ENABLE_VEHICLE_COG55",
        "ENABLE_VEHICLE_COG552",
        "ENABLE_VEHICLE_SUPERD",
        "ENABLE_VEHICLE_SCHAFTER4",
        "ENABLE_VEHICLE_SCHAFTER6",
        "ENABLE_VEHICLE_ALPHA",
        "ENABLE_VEHICLE_FELTZER2",
        "ENABLE_VEHICLE_MASSACRO",
        "ENABLE_VEHICLE_RAPIDGT",
        "ENABLE_VEHICLE_RAPIDGT2",
        "ENABLE_VEHICLE_SEVEN70",
        "ENABLE_VEHICLE_JESTER",
        "ENABLE_VEHICLE_BESTIAGTS",
        "ENABLE_VEHICLE_CARBONIZZARE",
        "ENABLE_VEHICLE_COQUETTE",
        "ENABLE_VEHICLE_FUROREGT",
        "ENABLE_VEHICLE_NINEF",
        "ENABLE_VEHICLE_NINEF2",
        "ENABLE_VEHICLE_VERLIERER2",
        "ENABLE_VEHICLE_BTYPE",
        "ENABLE_VEHICLE_FELTZER3",
        "ENABLE_VEHICLE_STINGERGT",
        "ENABLE_VEHICLE_STINGER",
        "ENABLE_VEHICLE_COQUETTE2",
        "ENABLE_VEHICLE_JB700",
        "ENABLE_VEHICLE_MAMBA",
        "ENABLE_VEHICLE_MONROE",
        "ENABLE_VEHICLE_BTYPE3",
        "ENABLE_VEHICLE_ZTYPE",
        "ENABLE_VEHICLE_VOLTIC",
        "ENABLE_VEHICLE_SHEAVA",
        "ENABLE_VEHICLE_CHEETAH",
        "ENABLE_VEHICLE_ENTITYXF",
        "ENABLE_VEHICLE_INFERNUS",
        "ENABLE_VEHICLE_VACCA",
        "ENABLE_VEHICLE_BULLET",
        "ENABLE_VEHICLE_FMJ",
        "ENABLE_VEHICLE_BALLER2",
        "ENABLE_VEHICLE_BALLER3",
        "ENABLE_VEHICLE_BALLER5",
        "ENABLE_VEHICLE_BALLER4",
        "ENABLE_VEHICLE_BALLER6",
        "ENABLE_VEHICLE_XLS",
        "ENABLE_VEHICLE_XLS2",
        "ENABLE_VEHICLE_PRAIRIE",
        "ENABLE_VEHICLE_ISSI2",
        "ENABLE_VEHICLE_DILETTANTE",
        "ENABLE_VEHICLE_FELON",
        "ENABLE_VEHICLE_FELON2",
        "ENABLE_VEHICLE_F620",
        "ENABLE_VEHICLE_JACKAL",
        "ENABLE_VEHICLE_ORACLE2",
        "ENABLE_VEHICLE_ORACLE",
        "ENABLE_VEHICLE_SENTINEL2",
        "ENABLE_VEHICLE_ZION",
        "ENABLE_VEHICLE_ZION2",
        "ENABLE_VEHICLE_AKUMA",
        "ENABLE_VEHICLE_DOUBLE",
        "ENABLE_VEHICLE_ENDURO",
        "ENABLE_VEHICLE_HEXER",
        "ENABLE_VEHICLE_INNOVATION",
        "ENABLE_VEHICLE_SANCHEZ",
        "ENABLE_VEHICLE_SANCHEZ2",
        "ENABLE_VEHICLE_BATI2",
        "ENABLE_VEHICLE_FAGGIO2",
        "ENABLE_VEHICLE_RUFFIAN",
        "ENABLE_VEHICLE_NEMESIS",
        "ENABLE_VEHICLE_HAKUCHOU",
        "ENABLE_VEHICLE_PCJ",
        "ENABLE_VEHICLE_VADER",
        "ENABLE_VEHICLE_SOVEREIGN",
        "ENABLE_VEHICLE_GAUNTLET",
        "ENABLE_VEHICLE_RATLOADER",
        "ENABLE_VEHICLE_PICADOR",
        "ENABLE_VEHICLE_VIGERO",
        "ENABLE_VEHICLE_RUINER",
        "ENABLE_VEHICLE_TAMPA",
        "ENABLE_VEHICLE_BLADE",
        "ENABLE_VEHICLE_BIFTA",
        "ENABLE_VEHICLE_DUNE",
        "ENABLE_VEHICLE_BFINJECTION",
        "ENABLE_VEHICLE_BODHI2",
        "ENABLE_VEHICLE_KALAHARI",
        "ENABLE_VEHICLE_RANCHERXL",
        "ENABLE_VEHICLE_REBEL2",
        "ENABLE_VEHICLE_REBEL",
        "ENABLE_VEHICLE_BLAZER",
        "ENABLE_VEHICLE_BLAZER3",
        "ENABLE_VEHICLE_SANDKING2",
        "ENABLE_VEHICLE_WASHINGTON",
        "ENABLE_VEHICLE_SCHAFTER2",
        "ENABLE_VEHICLE_ROMERO",
        "ENABLE_VEHICLE_FUGITIVE",
        "ENABLE_VEHICLE_SURGE",
        "ENABLE_VEHICLE_ASEA",
        "ENABLE_VEHICLE_PREMIER",
        "ENABLE_VEHICLE_REGINA",
        "ENABLE_VEHICLE_ASTEROPE",
        "ENABLE_VEHICLE_INTRUDER",
        "ENABLE_VEHICLE_TAILGATER",
        "ENABLE_VEHICLE_STANIER",
        "ENABLE_VEHICLE_INGOT",
        "ENABLE_VEHICLE_WARRENER",
        "ENABLE_VEHICLE_STRATUM",
        "ENABLE_VEHICLE_SCHWARZER",
        "ENABLE_VEHICLE_SURANO",
        "ENABLE_VEHICLE_BUFFALO",
        "ENABLE_VEHICLE_BUFFALO2",
        "ENABLE_VEHICLE_MASSACRO2",
        "ENABLE_VEHICLE_JESTER2",
        "ENABLE_VEHICLE_FUTO",
        "ENABLE_VEHICLE_PENUMBRA",
        "ENABLE_VEHICLE_FUSILADE",
        "ENABLE_VEHICLE_BTYPE2",
        "ENABLE_VEHICLE_PIGALLE",
        "ENABLE_VEHICLE_CAVALCADE",
        "ENABLE_VEHICLE_CAVALCADE2",
        "ENABLE_VEHICLE_BJXL",
        "ENABLE_VEHICLE_SERRANO",
        "ENABLE_VEHICLE_GRESLEY",
        "ENABLE_VEHICLE_SEMINOLE",
        "ENABLE_VEHICLE_GRANGER",
        "ENABLE_VEHICLE_LANDSTALKER",
        "ENABLE_VEHICLE_HABANERO",
        "ENABLE_VEHICLE_FQ2",
        "ENABLE_VEHICLE_BALLER",
        "ENABLE_VEHICLE_PATRIOT",
        "ENABLE_VEHICLE_ROCOTO",
        "ENABLE_VEHICLE_RADI",
        "ENABLE_VEHICLE_MESA3",
        "ENABLE_VEHICLE_MONSTER",
        "ENABLE_VEHICLE_FORMULA",
        "ENABLE_VEHICLE_IMORGEN",
        "ENABLE_VEHICLE_REBLA",
        "ENABLE_VEHICLE_VSTR",
        "ENABLE_XA21",
        "ENABLE_CHEETAH2",
        "ENABLE_TORERO",
        "ENABLE_VAGNER",
        "ENABLE_ARDENT",
        "ENABLE_NIGHTSHARK",
        "ENABLE_TERBYTE",
        "ENABLE_PBUS2",
        "ENABLE_PATRIOT2",
        "ENABLE_SWINGER",
        "ENABLE_STAFFORD",
        "ENABLE_POUNDER2",
        "ENABLE_MULE4",
        "ENABLE_BLIMP3",
        "ENABLE_FREECRAWLER",
        "ENABLE_MENACER",
        "ENABLE_OPPRESSOR2",
        "ENABLE_SCRAMJET",
        "ENABLE_STRIKEFORCE",
        "ENABLE_FUTO",
        "ENABLE_RUINER",
        "ENABLE_HEARSE",
        "ENABLE_PRAIRIE",
        "ENABLE_BALLER",
        "ENABLE_SERRANO",
        "ENABLE_FQ2",
        "ENABLE_PATRIOT",
        "ENABLE_HABANERO",
    }
    for i, veh in ipairs(tuneales_veh_list) do
        tunables.set_int(veh, 1)
    end
end)

gentab:add_sameline()

gentab:add_button("Remove Fooligan gang cooldown", function()
    stats.set_int("MPX_XM22JUGGALOWORKCDTIMER", -1)
end)

gentab:add_sameline()

gentab:add_button("Unlock acid lab equipment upgrades", function()
    if stats.get_int("MPX_AWD_CALLME") < 10 then
        stats.set_int("MPX_AWD_CALLME", 10)
    else
        gui.show_message("Prompt", "You've completed 10 Fooligan gang missions, you don't need to unlock them.")
    end
end)

gentab:add_sameline()

gentab:add_button("Remove security Contract/Phone Assassination cooldown", function()
    tunables.set_int("FIXER_SECURITY_CONTRACT_COOLDOWN_TIME", 0)
    tunables.set_int(1872071131, 0)
end)

gentab:add_sameline()

gentab:add_button("Remove CEO vehicle cooldown", function()
    tunables.set_int("GB_CALL_VEHICLE_COOLDOWN", 0) --呼叫ceo载具
    tunables.set_int("IMPEXP_STEAL_COOLDOWN", 0) --载具交易获取载具
    tunables.set_int("IMPEXP_SELL_COOLDOWN", 0) --载具交易出售载具
end)

gentab:add_sameline()

gentab:add_button("Remove self bounty", function()
    globals_set_int(3179, 1+2359296+5150+13,2880000)    
end)

gentab:add_sameline()

gentab:add_button("Force to story mode", function()
    if NETWORK.NETWORK_CAN_BAIL() then
        NETWORK.NETWORK_BAIL(0, 0, 0)
    end
end)

gentab:add_button("Reset Vincent Dispatch mission cooldown", function()
    stats.set_int("MPX_DISPATCH_WORK_CALL_CD", 0)
    stats.set_int("MPX_DISPATCH_WORK_REQUEST_CD", 0)
    globals_set_int(3274, 2685444 + 3078 + 265, 0)
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

gentab:add_button("Force save", function() 
    globals_set_int(3179, 2694471 + 1382 , 27)
end)

gentab:add_sameline()

gentab:add_button("Remove technicians, assets, and business management expenses", function() 
    tunables.set_int(-427481449 , 0)
    tunables.set_int(1119077650 , 0)
    tunables.set_int(1915529211 , 0)
    tunables.set_int(59427557 , 0)
    tunables.set_int(511176100 , 0)
    tunables.set_int(763803751 , 0)
    tunables.set_int(-2057763278 , 0)
    tunables.set_int(1231840091 , 0)
    tunables.set_int(354424266 , 0)
    tunables.set_int(1539239470 , 0)
    tunables.set_int(-438049908 , 0)
    tunables.set_int(-1892202067 , 0)
    tunables.set_int(-1522694107 , 0)
    tunables.set_int(-1135698070 , 0)
    tunables.set_int(-303744391 , 0)
    tunables.set_int(756741904 , 0)

    tunables.set_int("ACID_LAB_EQUIPMENT_UPGRADE_UTILITY_FEE" , 0)
    tunables.set_int("ACID_LAB_UTILITY_FEE" , 0)
    tunables.set_int("EXEC1_PA_FEES" , 0)
    tunables.set_int("AUTO_SHOP_UTILITY_COST" , 0)
    tunables.set_int("ARCADE_UTILITY_COST" , 0)
    tunables.set_int("FIXER_HQ_UTILITY_COST" , 0)
    tunables.set_int("EXEC1_OFFICE_FEES" , 0)
    tunables.set_int("SMUG_HANGAR_UTILITY_FEES" , 0)
    tunables.set_int("SMUG_HANGAR_STAFF_FEES" , 0)
    tunables.set_int("EXEC1_SMALL_WAREHOUSE_FEES" , 0)
    tunables.set_int("EXEC1_MEDIUM_WAREHOUSE_FEES" , 0)
    tunables.set_int("EXEC1_LARGE_WAREHOUSE_FEES" , 0)

    tunables.set_int("BIKER_COCAINE_UTILITY_COST" , 0)
    tunables.set_int("BIKER_COCAINE_EQUIPMENT_UPGRADE_UTILITY_COST" , 0)
    tunables.set_int("BIKER_COUNTERCASH_UTILITY_COST" , 0)
    tunables.set_int("BIKER_COUNTERCASH_EQUIPMENT_UPGRADE_UTILITY_COST" , 0)
    tunables.set_int("BIKER_FAKEIDS_UTILITY_COST" , 0)
    tunables.set_int("BIKER_FAKEIDS_EQUIPMENT_UPGRADE_UTILITY_COST" , 0)
    tunables.set_int("BIKER_METH_UTILITY_COST" , 0)
    tunables.set_int("BIKER_METH_EQUIPMENT_UPGRADE_UTILITY_COST" , 0)
    tunables.set_int("BIKER_WEED_UTILITY_COST" , 0)
    tunables.set_int("BIKER_WEED_EQUIPMENT_UPGRADE_UTILITY_COST" , 0)
    tunables.set_int("GR_MANU_UTILITY_COST" , 0)
    tunables.set_int("GR_MANU_EQUIPMENT_UPGRADE_UTILITY_COST" , 0)

    tunables.set_int("BIKER_COCAINE_STAFF_COST" , 0)
    tunables.set_int("BIKER_COCAINE_STAFF_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_COCAINE_SECURITY_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_FAKEIDS_SECURITY_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_FAKEIDS_STAFF_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_FAKEIDS_STAFF_COST" , 0)
    tunables.set_int("BIKER_COUNTERCASH_SECURITY_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_COUNTERCASH_STAFF_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_COUNTERCASH_STAFF_COST" , 0)
    tunables.set_int("BIKER_WEED_SECURITY_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_WEED_STAFF_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_WEED_STAFF_COST" , 0)
    tunables.set_int("BIKER_METH_SECURITY_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_METH_STAFF_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("BIKER_METH_STAFF_COST" , 0)
    tunables.set_int("GR_MANU_STAFF_COST" , 0)
    tunables.set_int("GR_MANU_STAFF_UPGRADE_STAFF_COST" , 0)
    tunables.set_int("GR_MANU_SECURITY_UPGRADE_STAFF_COST" , 0)

    tunables.set_int("YACHT_UTILITIES_COST" , 0)
    tunables.set_int("LOW_APRT_UTIL" , 0)
    tunables.set_int("MID_APRT_UTIL" , 0)
    tunables.set_int("HIGH_APRT_UTIL" , 0)
    tunables.set_int("VC_PENTHOUSE_UTILITY_EXPANSION" , 0)
    tunables.set_int("VC_PENTHOUSE_UTILITY_BASE" , 0)

    tunables.set_int("MECHANIC_DAILY_FEE" , 0)

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

selfled = gentab:add_checkbox("Portable light source")

local fakeban1 = gentab:add_checkbox("Display false ban warning") --只是一个开关，代码往后面找

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
    globals_set_int(3274, 2738934 + 917, 1) 
    globals_set_int(3274, 2738934 + 916, 1) 
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

followply_n = gui.add_tab(""):add_checkbox("Follow the player (regular)")
gui.get_tab(""):add_sameline()
followply_a = gui.add_tab(""):add_checkbox("Follow the Player (aggressive)")

gui.get_tab(""):add_sameline()

plydist = gui.get_tab(""):add_input_float("Distance (m)")

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
        createplayertable()
        for _, exptar_player_id in pairs(player_Index_table) do
            spawncrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(exptar_player_id), false)
            veh = VEHICLE.CREATE_VEHICLE(joaat("oppressor2"), spawncrds.x, spawncrds.y, spawncrds.z, 0 , true, true, true)
            upgrade_vehicle(veh,"")
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
    verchkok = 5
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
--emmode2:set_enabled(true) --开启上方创建的复选框，删除此行代码后紧急模式2不会默认监听快捷键

gentab:add_sameline()

local allclear = gentab:add_checkbox("Loop clear entity") --只是一个开关，代码往后面找

gentab:add_sameline()

gentab:add_button("Perico/Firm Contract Final Chapter/ULP 1 click Completion (Mandatory)", function()
    locals_set_int(3274, "fm_mission_controller_2020", 50150 + 1, 51338752)  --关键代码  
    locals_set_int(3274, "fm_mission_controller_2020", 50150 + 1770 + 1, 100) --关键代码 
    locals_set_int(3274, "fm_mission_controller", 19746, 12) 
    locals_set_int(3274, "fm_mission_controller", 27489 + 859 + 18, 99999) 
    locals_set_int(3274, "fm_mission_controller", 31621 + 69, 99999) 
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
plyaimkarma1 = EntityTab:add_checkbox("Shoot F ##plyctl0") --这只是一个复选框,代码往最后的循环脚本部分找
EntityTab:add_sameline()
plyaimkarma2 = EntityTab:add_checkbox("Blow F ##plyctl0") --这只是一个复选框,代码往最后的循环脚本部分找
EntityTab:add_sameline()
plyaimkarma3 = EntityTab:add_checkbox("Electroshock F ##plyctl0") --这只是一个复选框,代码往最后的循环脚本部分找
EntityTab:add_sameline()
plyaimkarma4 = EntityTab:add_checkbox("Kick out F ##plyctl0") --这只是一个复选框,代码往最后的循环脚本部分找

--------------------------------------------------------------------------------------- 可调整项
TuneablesandStatsTab:add_text("Tampering with adjustable items to obtain a lot of money may lead to a ban!")

TuneablesandStatsTab:add_button("Reload all adjustable items", function()
    NETWORK.NETWORK_REQUEST_CLOUD_TUNABLES()
end)
TuneablesandStatsTab:add_text("Modification process: 1.Retrieve 2.Modify 3.Apply")

t_heisttab = TuneablesandStatsTab:add_tab("Heists")
t_heisttab:add_text("Local cuts")
t_heisttab:add_text("Please change it after the mission starts, it won't be reflected on the planner board, it won't affect your teammates, and your teammates won't see it, it only affects your final income")
local_cut_h234 = t_heisttab:add_input_int("Perico/Casino/Doomsday")
local_cut_h1 = t_heisttab:add_input_int("Apartments")

t_heisttab:add_text("Move income to the right HUD")

hud_take = t_heisttab:add_input_int("Pacific Standard Bank and Casino Heist")

t_heisttab:add_button("Read ##lhcut", function()
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) ~= 0 or SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) ~= 0 then
        local_cut_h234:set_value(globals_get_int(3274, 2685444 + 6639)) 
        local_cut_h1:set_value(globals_get_int(3274, 2685444 + 6403 )) 
        hud_take:set_value(locals_get_int(3274, "fm_mission_controller", 19746 + 2686))  --"MONEY_HELD" /* GXT: TAKE */, 1000, 6, 2, 0, "HUD_CASH" /* GXT: $~1~ */
    else
        gui.show_error("Error","Please start the heist first")
    end
end)

t_heisttab:add_sameline()
t_heisttab:add_button("Apply ##lhcut", function()
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) ~= 0 or SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller_2020")) ~= 0 then
        globals_set_int(3274, 2685444 + 6639, local_cut_h234:get_value()) 
        globals_set_int(3274, 2685444 + 6403, local_cut_h1:get_value()) 
        locals_set_int(3274, "fm_mission_controller", 19746 + 2686, hud_take:get_value()) 
    else
        gui.show_error("Error","Please start the heist first")
    end
end)

t_heisttab:add_text("Cayo Perico")
t_heisttab:add_text("Main target value")
perico_value_STATUE = t_heisttab:add_input_int("Panther statue")
perico_value_DIAMOND = t_heisttab:add_input_int("Pink diamond")
perico_value_FILES = t_heisttab:add_input_int("Madraso Files")
perico_value_BONDS = t_heisttab:add_input_int("Bearer bonds")
perico_value_NECKLACE = t_heisttab:add_input_int("Necklace")
perico_value_TEQUILA = t_heisttab:add_input_int("Tequila")
t_heisttab:add_text("Miscellaneous")
perico_pack_vol = t_heisttab:add_input_int("Loot Bag Capacity")
perico_pm_v_m_n = t_heisttab:add_input_float("Perico Main Target Value Multiplier (Normal)")
perico_pm_v_m_h = t_heisttab:add_input_float("Perico main target value multiplier (Hard)")

t_heisttab:add_button("Retrieve ##preicov", function()
    perico_value_TEQUILA:set_value(tunables.get_int("IH_PRIMARY_TARGET_VALUE_TEQUILA"))
    perico_value_NECKLACE:set_value(tunables.get_int("IH_PRIMARY_TARGET_VALUE_PEARL_NECKLACE"))
    perico_value_BONDS:set_value(tunables.get_int("IH_PRIMARY_TARGET_VALUE_BEARER_BONDS"))
    perico_value_DIAMOND:set_value(tunables.get_int("IH_PRIMARY_TARGET_VALUE_PINK_DIAMOND"))
    perico_value_FILES:set_value(tunables.get_int("IH_PRIMARY_TARGET_VALUE_MADRAZO_FILES"))
    perico_value_STATUE:set_value(tunables.get_int("IH_PRIMARY_TARGET_VALUE_SAPPHIRE_PANTHER_STATUE"))

    perico_pack_vol:set_value(tunables.get_int(1859395035))
    perico_pm_v_m_n:set_value(tunables.get_float(1808919381))
    perico_pm_v_m_h:set_value(tunables.get_float(1759346392))
end)

t_heisttab:add_sameline()

perico_pri_target_val_lock = t_heisttab:add_checkbox("Apply ##preicov") --这只是一个复选框,代码往最后的循环脚本部分找

t_ottab = TuneablesandStatsTab:add_tab("Industry and factory")
bk_rs_t1 = t_ottab:add_input_int("Bunker research time")
bk_rs_t2 = t_ottab:add_input_int("Bunker research time - Equipment upgrades")
bk_rs_t3 = t_ottab:add_input_int("Bunker research time - Staff Upgrade")
t_ottab:add_button("Retrieve ##miscv", function()
    bk_rs_t1:set_value(tunables.get_int("GR_RESEARCH_PRODUCTION_TIME"))
    bk_rs_t2:set_value(tunables.get_int("GR_RESEARCH_UPGRADE_EQUIPMENT_REDUCTION_TIME"))
    bk_rs_t3:set_value(tunables.get_int("GR_RESEARCH_UPGRADE_STAFF_REDUCTION_TIME"))
end)
t_ottab:add_sameline()
misc_tu_lock = t_ottab:add_checkbox("Apply ##miscv") --这只是一个复选框,代码往最后的循环脚本部分找

biker_p_val_mtp = t_ottab:add_input_float("MC club industry and acid product value multipliers")
biker_far_mtp = t_ottab:add_input_float("MC club and acid long distance sales multipliers")

bk_p_val_mtp = t_ottab:add_input_float("Bunker product value multipliers")
bk_far_mtp = t_ottab:add_input_float("Bunker product long-distance reward multiplier")

biker_cap_0 = t_ottab:add_input_int("Current inventory of cocaine") --HUD_CASH 
biker_cap_1 = t_ottab:add_input_int("Current inventory of weed") --HUD_CASH 
biker_cap_2 = t_ottab:add_input_int("Current inventory of meth") --HUD_CASH 
biker_cap_3 = t_ottab:add_input_int("Current inventory of counterfeit money") --HUD_CASH 
biker_cap_4 = t_ottab:add_input_int("Current inventory of fake documents") --HUD_CASH 
biker_cap_5 = t_ottab:add_input_int("Current inventory of bunkers") --HUD_CASH 
biker_cap_6 = t_ottab:add_input_int("Current inventory of acid") --HUD_CASH 

biker_cap_max_0 = t_ottab:add_input_int("Max inventory of cocaine") --HUD_CASH 
biker_cap_max_1 = t_ottab:add_input_int("Max inventory of weed") --HUD_CASH 
biker_cap_max_2 = t_ottab:add_input_int("Max inventory of meth") --HUD_CASH 
biker_cap_max_3 = t_ottab:add_input_int("Max inventory of counterfeit money") --HUD_CASH 
biker_cap_max_4 = t_ottab:add_input_int("Max inventory of fake documents") --HUD_CASH 
biker_cap_max_5 = t_ottab:add_input_int("Max inventory of bunkers") --HUD_CASH 
biker_cap_max_6 = t_ottab:add_input_int("Max inventory of acid") --HUD_CASH 

t_ottab:add_button("Retrieve ##miscv2", function()
    biker_p_val_mtp:set_value(tunables.get_float(-823848572))
    biker_far_mtp:set_value(tunables.get_float("BIKER_SELL_PRODUCT_FAR_MODIFIER"))
    bk_p_val_mtp:set_value(tunables.get_float("GR_SELL_PRODUCT_LOCAL_MODIFIER"))
    bk_far_mtp:set_value(tunables.get_float("GR_SELL_PRODUCT_FAR_MODIFIER"))

    local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID
    biker_cap_0:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 0 * 13)+1)) 
    biker_cap_1:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 1 * 13)+1)) 
    biker_cap_2:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 2 * 13)+1)) 
    biker_cap_3:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 3 * 13)+1)) 
    biker_cap_4:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 4 * 13)+1)) 
    biker_cap_5:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 5 * 13)+1)) 
    biker_cap_6:set_value(globals_get_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 6 * 13)+1)) 
    biker_cap_max_0:set_value(tunables.get_int("BIKER_COCAINE_CAPACITY"))
    biker_cap_max_1:set_value(tunables.get_int("BIKER_WEED_CAPACITY"))
    biker_cap_max_2:set_value(tunables.get_int("BIKER_METH_CAPACITY"))
    biker_cap_max_3:set_value(tunables.get_int("BIKER_COUNTERCASH_CAPACITY"))
    biker_cap_max_4:set_value(tunables.get_int("BIKER_FAKEIDS_CAPACITY"))
    biker_cap_max_5:set_value(tunables.get_int("GR_MANU_CAPACITY"))
    biker_cap_max_6:set_value(tunables.get_int("ACID_LAB_PRODUCT_CAPACITY"))
end)
t_ottab:add_sameline()
t_ottab:add_button("Apply ##miscv2", function()
    tunables.set_float(-823848572, biker_p_val_mtp:get_value())
    tunables.set_float("BIKER_SELL_PRODUCT_FAR_MODIFIER", biker_far_mtp:get_value())
    tunables.set_float("GR_SELL_PRODUCT_LOCAL_MODIFIER", bk_p_val_mtp:get_value())
    tunables.set_float("GR_SELL_PRODUCT_FAR_MODIFIER", bk_far_mtp:get_value())
    local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID

    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 0 * 13)+1 , biker_cap_0:get_value()) 
    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 1 * 13)+1 , biker_cap_1:get_value()) 
    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 2 * 13)+1 , biker_cap_2:get_value()) 
    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 3 * 13)+1 , biker_cap_3:get_value()) 
    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 4 * 13)+1 , biker_cap_4:get_value()) 
    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 5 * 13)+1 , biker_cap_5:get_value()) 
    globals_set_int(3274, (1845281 + 1 + (playerid * 877) + 268 + 197 + 1 + 6 * 13)+1 , biker_cap_6:get_value()) 
    tunables.set_int("BIKER_COCAINE_CAPACITY", biker_cap_max_0:get_value())
    tunables.set_int("BIKER_WEED_CAPACITY", biker_cap_max_1:get_value())
    tunables.set_int("BIKER_METH_CAPACITY", biker_cap_max_2:get_value())
    tunables.set_int("BIKER_COUNTERCASH_CAPACITY", biker_cap_max_3:get_value())
    tunables.set_int("BIKER_FAKEIDS_CAPACITY", biker_cap_max_4:get_value())
    tunables.set_int("GR_MANU_CAPACITY", biker_cap_max_5:get_value())
    tunables.set_int("ACID_LAB_PRODUCT_CAPACITY", biker_cap_max_6:get_value())    

end)
t_ottab:add_sameline()
t_ottab:add_text("Modify the inventory carefully and do not exceed the limit")

smug_val = t_ottab:add_input_int("Unit price of hangar cargo")
t_ottab:add_button("Retrieve ##miscv3", function()
    smug_val:set_value(tunables.get_int(-954321460))
end)
t_ottab:add_sameline()
t_ottab:add_button("Apply ##miscv3", function()
    tunables.set_int(-954321460, smug_val:get_value())
end)

nc_cap_max_0 = t_ottab:add_input_int("Maximum inventory of transported goods")  
nc_cap_max_1 = t_ottab:add_input_int("Maximum inventory of shipped goods")  
nc_cap_max_2 = t_ottab:add_input_int("Maximum inventory of South American imports")  
nc_cap_max_3 = t_ottab:add_input_int("Maximum inventory of pharmaceutical products")  
nc_cap_max_4 = t_ottab:add_input_int("Maximum inventory of organic agricultural products")  
nc_cap_max_5 = t_ottab:add_input_int("Maximum inventory of print")  
nc_cap_max_6 = t_ottab:add_input_int("Maximum inventory of counterfeit money")  

t_ottab:add_button("Retrieve ##miscv4", function()

    nc_cap_max_1:set_value(tunables.get_int(-1318722703))
    nc_cap_max_2:set_value(tunables.get_int(-2136290534))
    nc_cap_max_3:set_value(tunables.get_int(1069721135))
    nc_cap_max_4:set_value(tunables.get_int(-8586474))
    nc_cap_max_5:set_value(tunables.get_int(-358911902))
    nc_cap_max_6:set_value(tunables.get_int(-879486246))
    nc_cap_max_0:set_value(tunables.get_int(-1168716160))

end)
t_ottab:add_sameline()
t_ottab:add_button("Apply ##miscv4", function()

        tunables.set_int(-1318722703, nc_cap_max_1:get_value())
        tunables.set_int(-2136290534, nc_cap_max_2:get_value())
        tunables.set_int(1069721135, nc_cap_max_3:get_value())
        tunables.set_int(-8586474, nc_cap_max_4:get_value())
        tunables.set_int(-358911902, nc_cap_max_5:get_value())
        tunables.set_int(-879486246, nc_cap_max_6:get_value())
        tunables.set_int(-1168716160, nc_cap_max_0:get_value())    
end)
t_ottab:add_sameline()
t_ottab:add_text("Modify inventory carefully and do not exceed limits")

t_heisttab:add_separator()
t_heisttab:add_text("Firm Data Breach Contract - Don't Mess With DRE")

fixer_final_value = t_heisttab:add_input_int("Reward for the final chapter")

t_heisttab:add_button("Retrieve ##drev", function()
    fixer_final_value:set_value(tunables.get_int("FIXER_FINALE_LEADER_CASH_REWARD"))
end)

t_heisttab:add_sameline()
fixer_final_val_lock = t_heisttab:add_checkbox("Apply ##drev") --这只是一个复选框,代码往最后的循环脚本部分找

t_heisttab:add_separator()
t_heisttab:add_text("Doomsday heist")

h2_d1_awd = t_heisttab:add_input_int("Doomsday 1")
h2_d2_awd = t_heisttab:add_input_int("Doomsday 2")
h2_d3_awd = t_heisttab:add_input_int("Doomsday 3")

t_heisttab:add_button("Retrieve ##h2v", function()
    h2_d1_awd:set_value(tunables.get_int("GANGOPS_THE_IAA_JOB_CASH_REWARD"))
    h2_d2_awd:set_value(tunables.get_int("GANGOPS_THE_SUBMARINE_JOB_CASH_REWARD"))
    h2_d3_awd:set_value(tunables.get_int("GANGOPS_THE_MISSILE_SILO_JOB_CASH_REWARD"))
end)

t_heisttab:add_sameline()
h2_awd_lock = t_heisttab:add_checkbox("Apply ##h2v") --这只是一个复选框,代码往最后的循环脚本部分找

t_heisttab:add_separator()
t_heisttab:add_text("Diamonds Casino Heist")

h3_t1_awd = t_heisttab:add_input_int("Cash")
h3_t2_awd = t_heisttab:add_input_int("Painting")
h3_t3_awd = t_heisttab:add_input_int("Gold")
h3_t4_awd = t_heisttab:add_input_int("Diamonds")

t_heisttab:add_button("Retrieve ##h3v", function()
    h3_t1_awd:set_value(tunables.get_int(-1638885821))
    h3_t2_awd:set_value(tunables.get_int(1934398910))
    h3_t3_awd:set_value(tunables.get_int(-582734553))
    h3_t4_awd:set_value(tunables.get_int(1277889925))
end)

t_heisttab:add_sameline()
h3_awd_lock = t_heisttab:add_checkbox("Apply ##h3v") --这只是一个复选框,代码往最后的循环脚本部分找

odatatab = TuneablesandStatsTab:add_tab("Time & Money")

odatatab:add_text("When the value is greater than 2147483647, it cannot be read normally, but it can still be written.")
odatatab:add_text("This lua can't restore the modified data to the default, take a picture of it before modifying it.")

odatatab:add_text("Modifying stats is risky, so make sure you know what you're doing.")

local statstable1 = {
    [1]  = {statstring = "MP_PLAYING_TIME", friendlyname = "Online mode playtime (ms)", p1 = mp_mo_ply_time_val, p2 = mp_mo_ply_time},
    [2]  = {statstring = "MP_FIRST_PERSON_CAM_TIME", friendlyname = "First-person playtime (ms)", p1 = mp_mo_ply_firstcam_time_val, p2 = mp_mo_ply_firstcam_time},
    [3]  = {statstring = "MP0_TOTAL_PLAYING_TIME", friendlyname = "Character 1 Third Person playtime(ms)", p1 = mp_mo_ply1_thirdcam_time_val, p2 = mp_mo_ply1_thirdcam_time},
    [4]  = {statstring = "MP1_TOTAL_PLAYING_TIME", friendlyname = "Character 2 Third Person playtime(ms)", p1 = mp_mo_ply2_thirdcam_time_val, p2 = mp_mo_ply2_thirdcam_time},

    [5]  = {statstring = "MPPLY_TOTAL_EVC", friendlyname = "Total income $", p1 = mp_mo_total_earn_val, p2 = mp_mo_total_earn},
    [6]  = {statstring = "MPPLY_TOTAL_SVC", friendlyname = "Total expenses $", p1 = mp_mo_total_sp_val, p2 = mp_mo_total_sp},

    [7]  = {statstring = "MP0_MONEY_EARN_JOBS", friendlyname = "Character 1 income $", p1 = mp_mo_job_ply1_val, p2 = mp_mo_job_ply1},
    [8]  = {statstring = "MP1_MONEY_EARN_JOBS", friendlyname = "Character 2 income $", p1 = mp_mo_job_ply2_val, p2 = mp_mo_job_ply2},
    [9]  = {statstring = "MP0_MONEY_EARN_BETTING", friendlyname = "Character 1 gambling income $", p1 = mp_mo_bt_ply1_val, p2 = mp_mo_bt_ply1},
    [10]  = {statstring = "MP1_MONEY_EARN_BETTING", friendlyname = "Character 2 gambling income$", p1 = mp_mo_bt_ply2_val, p2 = mp_mo_bt_ply2},
    [11]  = {statstring = "MP0_MONEY_EARN_SELLING_VEH", friendlyname = "Character 1 car sales income $", p1 = mp_mo_sv_ply1_val, p2 = mp_mo_sv_ply1},
    [12]  = {statstring = "MP1_MONEY_EARN_SELLING_VEH", friendlyname = "Character 2 car sales income $", p1 = mp_mo_sv_ply2_val, p2 = mp_mo_sv_ply2},
    [13]  = {statstring = "MP0_MONEY_EARN_GOOD_SPORT", friendlyname = "Character 1 good sport income $", p1 = mp_mo_gs_ply1_val, p2 = mp_mo_gs_ply1},
    [14]  = {statstring = "MP1_MONEY_EARN_GOOD_SPORT", friendlyname = "Character 2 good sport income $", p1 = mp_mo_gs_ply2_val, p2 = mp_mo_gs_ply2},
    [15]  = {statstring = "MP0_MONEY_EARN_PICKED_UP", friendlyname = "Character 1 picked up income $", p1 = mp_mo_pu_ply1_val, p2 = mp_mo_pu_ply1},
    [16]  = {statstring = "MP1_MONEY_EARN_PICKED_UP", friendlyname = "Character 2 picked up income $", p1 = mp_mo_pu_ply2_val, p2 = mp_mo_pu_ply2},

    [17]  = {statstring = "MP0_MONEY_SPENT_WEAPON_ARMOR", friendlyname = "Character 1 weapon armor expenses $", p1 = mp_mo_wa_ply1_val, p2 = mp_mo_wa_ply1},
    [18]  = {statstring = "MP1_MONEY_SPENT_WEAPON_ARMOR", friendlyname = "Character 2 weapon armor expenses $", p1 = mp_mo_wa_ply2_val, p2 = mp_mo_wa_ply2},
    [19]  = {statstring = "MP0_MONEY_SPENT_VEH_MAINTENANCE", friendlyname = "Character 1 vehicle expenses $", p1 = mp_mo_veh_ply1_val, p2 = mp_mo_veh_ply1},
    [20]  = {statstring = "MP1_MONEY_SPENT_VEH_MAINTENANCE", friendlyname = "Character 2 vehicle expenses $", p1 = mp_mo_veh_ply2_val, p2 = mp_mo_veh_ply2},
    [21]  = {statstring = "MP0_MONEY_SPENT_STYLE_ENT", friendlyname = "Character 1 style entertainment expenses $", p1 = mp_mo_st_ply1_val, p2 = mp_mo_st_ply1},
    [22]  = {statstring = "MP1_MONEY_SPENT_STYLE_ENT", friendlyname = "Character 2 style entertainment expenses $", p1 = mp_mo_st_ply2_val, p2 = mp_mo_st_ply2},
    [23]  = {statstring = "MP0_MONEY_SPENT_PROPERTY_UTIL", friendlyname = "Character 1 property expenses $", p1 = mp_mo_pr_ply1_val, p2 = mp_mo_pr_ply1},
    [24]  = {statstring = "MP1_MONEY_SPENT_PROPERTY_UTIL", friendlyname = "Character 2 property expenses $", p1 = mp_mo_pr_ply2_val, p2 = mp_mo_pr_ply2},
    [25]  = {statstring = "MP0_MONEY_SPENT_JOB_ACTIVITY", friendlyname = "Character 1 job activity expenses $", p1 = mp_mo_pre_ply1_val, p2 = mp_mo_pre_ply1},
    [26]  = {statstring = "MP1_MONEY_SPENT_JOB_ACTIVITY", friendlyname = "Character 2 job activity expenses $", p1 = mp_mo_pre_ply2_val, p2 = mp_mo_pre_ply2},
    [27]  = {statstring = "MP0_MONEY_SPENT_CONTACT_SERVICE", friendlyname = "Character 1 contact expenses $", p1 = mp_mo_ct_ply1_val, p2 = mp_mo_ct_ply1},
    [28]  = {statstring = "MP1_MONEY_SPENT_CONTACT_SERVICE", friendlyname = "Character 2 contact expenses $", p1 = mp_mo_ct_ply2_val, p2 = mp_mo_ct_ply2},
    [29]  = {statstring = "MP0_MONEY_SPENT_HEALTHCARE", friendlyname = "Character 1 medical expenses $", p1 = mp_mo_hc_ply1_val, p2 = mp_mo_hc_ply1},
    [30]  = {statstring = "MP1_MONEY_SPENT_HEALTHCARE", friendlyname = "Character 2 medical expenses $", p1 = mp_mo_hc_ply2_val, p2 = mp_mo_hc_ply2},
    [31]  = {statstring = "MP0_MONEY_SPENT_DROPPED_STOLEN", friendlyname = "Character 1 dropped expenses $", p1 = mp_mo_lt_ply1_val, p2 = mp_mo_lt_ply1},
    [32]  = {statstring = "MP1_MONEY_SPENT_DROPPED_STOLEN", friendlyname = "Character 2 dropped expenses $", p1 = mp_mo_lt_ply2_val, p2 = mp_mo_lt_ply2},

}

odatatab:add_button("I agree", function()
    if islistwed == 1 then
        return
    end
    islistwed = 1
    for i = 1, 32 do
        statstable1[i].p1 = odatatab:add_input_string(statstable1[i].friendlyname)
        odatatab:add_sameline()
        odatatab:add_button(tostring("Retrieve ##"..i), function()
            statstable1[i].p1:set_value(tostring(stats.get_int(statstable1[i].statstring)))
        end)
        odatatab:add_sameline()
        odatatab:add_button(tostring("Apply ##"..i), function()
            statstable1[i].p2 = tonumber(statstable1[i].p1:get_value())
            if statstable1[i].p2 > 2147483647 then
                local inc_time = string.format("%.0f",  statstable1[i].p2 / 2147483647)
                stats.set_int(tostring(statstable1[i].statstring), 2147483647)
                for c = 1, inc_time - 1 do
                    STATS.STAT_INCREMENT(joaat(statstable1[i].statstring), 2147483647)
                end
                STATS.STAT_INCREMENT(joaat(tostring(statstable1[i].statstring)), (statstable1[i].p2 - inc_time * 2147483647))
            else
                if statstable1[i].p2 < 0 then
                else
                    stats.set_int(tostring(statstable1[i].statstring), statstable1[i].p2)
                end
            end        
        end)
    end
end)

unlocktab = TuneablesandStatsTab:add_tab("Unlock##schlua")

unlocktab:add_text("XMAS GIFT TRUCK")
unlocktab:add_button("eCola Festive Sweater", function()
    packed_stat_set_bool(42128, true) --fm_content_xmas_truck.c func_6196("XT_TKR_SPCLa" /* GXT: eCola Festive Sweater */);
end)
unlocktab:add_button("Sprunk Festive Sweater", function()
    packed_stat_set_bool(42129, true)
end)
unlocktab:add_text("XMAS EVENTS")
unlocktab:add_button("The Gooch Outfit", function()
    packed_stat_set_bool(34761, true) --fm_content_xmas_mugger.c func_5997("XM_GOUTF" /* GXT: The Gooch Outfit */);
end)
unlocktab:add_button("The Yeti Outfit", function()
    packed_stat_set_bool(42119, true) --freemode YETIKILLHELP2
end)
unlocktab:add_button("The Snowman", function()
    packed_stat_set_bool(36776, true) --freemode SNOWOAWDHEL2
end)
unlocktab:add_text("TRICK OR TREAT")
unlocktab:add_button("Pumpkin Tee", function()
    packed_stat_set_bool(34380, true) --freemode TRICKOAWD2
end)
unlocktab:add_button("The Horror Pumpkin Mask", function()
    packed_stat_set_bool(34372, true) --freemode TRICKOAWDHEL
end)
unlocktab:add_text("Richard's Film Company Incident")
unlocktab:add_button("Space Interloper Outfit", function()
    packed_stat_set_bool(30240, true) --freemode MPROP_RWD_TCK1m
end)
unlocktab:add_text("Casino Heist")
unlocktab:add_button("The High Roller Outfit", function()
    packed_stat_set_bool(26969, true) --freemode HELPACCARCOLAL2
end)
unlocktab:add_text("RDR2 related")
unlocktab:add_button("The Frontier Outfit", function()
    packed_stat_set_bool(31736, true) --freemode BURIED_OUTTIC
end)
unlocktab:add_text("Salvage Yard DLC")
unlocktab:add_button("The McTony Security Outfit", function()
    packed_stat_set_bool(42153, true) --fm_content_vehrob_submarine SUB_OUTFITa
end)
unlocktab:add_button("The Los Santos Panic outfit", function()
    packed_stat_set_bool(42063, true) --fm_content_vehrob_arena MBA_OUTFITa
end)
unlocktab:add_button("Coast Guard Outfit outfit", function()
    packed_stat_set_bool(42111, true) --fm_content_vehrob_cargo_ship CSF_T_UNLKOTFT
end)

unlocktab:add_separator()

unlocktab:add_button("Unlock all bunker research", function()
    packed_stat_set_bool(15381, true)
    packed_stat_set_bool(15382, true)
    packed_stat_set_bool(15428, true)
    packed_stat_set_bool(15429, true)
    packed_stat_set_bool(15430, true)
    packed_stat_set_bool(15431, true)
    packed_stat_set_bool(15491, true)
    packed_stat_set_bool(15432, true)
    packed_stat_set_bool(15433, true)
    packed_stat_set_bool(15434, true)
    packed_stat_set_bool(15435, true)
    packed_stat_set_bool(15436, true)
    packed_stat_set_bool(15437, true)
    packed_stat_set_bool(15438, true)
    packed_stat_set_bool(15439, true)
    packed_stat_set_bool(15447, true)
    packed_stat_set_bool(15448, true)
    packed_stat_set_bool(15449, true)
    packed_stat_set_bool(15450, true)
    packed_stat_set_bool(15451, true)
    packed_stat_set_bool(15452, true)
    packed_stat_set_bool(15453, true)
    packed_stat_set_bool(15454, true)
    packed_stat_set_bool(15455, true)
    packed_stat_set_bool(15456, true)
    packed_stat_set_bool(15457, true)
    packed_stat_set_bool(15458, true)
    packed_stat_set_bool(15459, true)
    packed_stat_set_bool(15460, true)
    packed_stat_set_bool(15461, true)
    packed_stat_set_bool(15462, true)
    packed_stat_set_bool(15463, true)
    packed_stat_set_bool(15464, true)
    packed_stat_set_bool(15465, true)
    packed_stat_set_bool(15466, true)
    packed_stat_set_bool(15467, true)
    packed_stat_set_bool(15468, true)
    packed_stat_set_bool(15469, true)
    packed_stat_set_bool(15470, true)
    packed_stat_set_bool(15471, true)
    packed_stat_set_bool(15472, true)
    packed_stat_set_bool(15473, true)
    packed_stat_set_bool(15474, true)
    packed_stat_set_bool(15492, true)
    packed_stat_set_bool(15493, true)
    packed_stat_set_bool(15494, true)
    packed_stat_set_bool(15495, true)
    packed_stat_set_bool(15496, true)
    packed_stat_set_bool(15497, true)
    packed_stat_set_bool(15498, true)
    packed_stat_set_bool(15499, true)
end)

tstaba1 = TuneablesandStatsTab:add_tab("Miscellaneous")
tstaba1:add_button("Unlock the wholesale price of some vehicles", function()

    --机库相关
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_MICROLIGHT", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_ROGUE", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_ALPHAZ1", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_HAVOK", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_STARLING", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_MOLOTOK", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_TULA", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_BOMBUSHKA", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_HOWARD", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_MOGUL", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_HUNTER", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_SEABREEZE", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_NOKOTA", 0);
    tunables.set_int("SMUG_NUMBER_OF_STEAL_MISSIONS_TO_UNLOCK_PYRO", 0);

    --名钻赌场相关
    tunables.set_int(-1997603235, 1)
    tunables.set_int(1293915021, 1)
    tunables.set_int(-423431250, 1)
    tunables.set_int(-1491164275, 1)
    tunables.set_int(-170684478, 1)
    tunables.set_int(-1541063863, 1)
    tunables.set_int(2075481779, 1)
    tunables.set_int(-1775833032, 1)
    tunables.set_int(-1971661685, 1)
    tunables.set_int(1161220966, 1)
    tunables.set_int(-1874913332, 1)
    tunables.set_int(-595990903, 1)
    tunables.set_int(829638346, 1)
    tunables.set_int(1362146058, 1)
    tunables.set_int(-758040390, 1)
    tunables.set_int(1378787619, 1)
    tunables.set_int(1041883040, 1)
    tunables.set_int(-463901261, 1)
    tunables.set_int(1961619344, 1)
    tunables.set_int(-2141495545, 1)
    tunables.set_int(-349041781, 1)
    tunables.set_int(-410267195, 1)
    tunables.set_int(-1071451023, 1)

    --佩里科相关 维泰尔\长鳍等
    stats.set_bool("MPX_COMPLETE_H4_F_USING_VETIR", true)
    stats.set_bool("MPX_COMPLETE_H4_F_USING_LONGFIN", true)
    stats.set_bool("MPX_COMPLETE_H4_F_USING_ANNIH", true)
    stats.set_bool("MPX_COMPLETE_H4_F_USING_ALKONOS", true)
    stats.set_bool("MPX_COMPLETE_H4_F_USING_PATROLB", true)
    packed_stat_set_bool(41671, true)
    packed_stat_set_bool(41656, true)--appinternet.c		case joaat("squaddie"): return func_68(41656, -1);

    --车友会相关
    for ulkdisc = 31810, 34374 do
        packed_stat_set_bool(ulkdisc, true)
    end

    --末日豪劫DLC
    local dombit = stats.get_int("MPX_GANGOPS_FLOW_BITSET_MISS0")
    if (dombit & (1 << 1)) == 0 then
        dombit = dombit ~ (1 << 1)
    end
    if (dombit & (1 << 5)) == 0 then
        dombit = dombit ~ (1 << 5)
    end
    if (dombit & (1 << 6)) == 0 then
        dombit = dombit ~ (1 << 6)
    end
    if (dombit & (1 << 7)) == 0 then
        dombit = dombit ~ (1 << 7)
    end
    if (dombit & (1 << 10)) == 0 then
        dombit = dombit ~ (1 << 10)
    end    
    if (dombit & (1 << 11)) == 0 then
        dombit = dombit ~ (1 << 11)
    end    
    if (dombit & (1 << 11)) == 0 then
        dombit = dombit ~ (1 << 0)
    end
    if (dombit & (1 << 13)) == 0 then
        dombit = dombit ~ (1 << 13)
    end    
    if (dombit & (1 << 12)) == 0 then
        dombit = dombit ~ (1 << 12)
    end    
    if (dombit & (1 << 15)) == 0 then
        dombit = dombit ~ (1 << 15)
    end
    stats.set_int("MPX_GANGOPS_FLOW_BITSET_MISS0", dombit)

    --公寓抢劫
    local h1bit = stats.get_int("MPX_CHAR_FM_VEHICLE_1_UNLCK")
    if (h1bit & (1 << 12)) == 0 then
        h1bit = h1bit ~ (1 << 12)
    end
    if (h1bit & (1 << 14)) == 0 then
        h1bit = h1bit ~ (1 << 14)
    end
    if (h1bit & (1 << 16)) == 0 then
        h1bit = h1bit ~ (1 << 16)
    end
    if (h1bit & (1 << 9)) == 0 then
        h1bit = h1bit ~ (1 << 9)
    end
    if (h1bit & (1 << 20)) == 0 then
        h1bit = h1bit ~ (1 << 20)
    end
    if (h1bit & (1 << 7)) == 0 then
        h1bit = h1bit ~ (1 << 7)
    end
    if (h1bit & (1 << 8)) == 0 then
        h1bit = h1bit ~ (1 << 8)
    end
    if (h1bit & (1 << 10)) == 0 then
        h1bit = h1bit ~ (1 << 10)
    end
    if (h1bit & (1 << 11)) == 0 then
        h1bit = h1bit ~ (1 << 11)
    end
    if (h1bit & (1 << 5)) == 0 then
        h1bit = h1bit ~ (1 << 5)
    end
    if (h1bit & (1 << 6)) == 0 then
        h1bit = h1bit ~ (1 << 6)
    end
    if (h1bit & (1 << 21)) == 0 then
        h1bit = h1bit ~ (1 << 21)
    end
    if (h1bit & (1 << 18)) == 0 then
        h1bit = h1bit ~ (1 << 18)
    end
    if (h1bit & (1 << 22)) == 0 then
        h1bit = h1bit ~ (1 << 22)
    end
    if (h1bit & (1 << 19)) == 0 then
        h1bit = h1bit ~ (1 << 19)
    end
    if (h1bit & (1 << 13)) == 0 then
        h1bit = h1bit ~ (1 << 13)
    end
    if (h1bit & (1 << 15)) == 0 then
        h1bit = h1bit ~ (1 << 15)
    end
    if (h1bit & (1 << 17)) == 0 then
        h1bit = h1bit ~ (1 << 17)
    end
    stats.set_int("MPX_CHAR_FM_VEHICLE_1_UNLCK", h1bit)

    --军火霸业
    local grbit = stats.get_int("MPX_WVM_FLOW_VEHICLE_BS")
    if (grbit & (1 << 0)) == 0 then
        grbit = grbit ~ (1 << 0)
    end
    if (grbit & (1 << 1)) == 0 then
        grbit = grbit ~ (1 << 1)
    end
    if (grbit & (1 << 2)) == 0 then
        grbit = grbit ~ (1 << 2)
    end
    if (grbit & (1 << 3)) == 0 then
        grbit = grbit ~ (1 << 3)
    end
    if (grbit & (1 << 5)) == 0 then
        grbit = grbit ~ (1 << 5)
    end
    if (grbit & (1 << 7)) == 0 then
        grbit = grbit ~ (1 << 7)
    end
    stats.set_int("MPX_WVM_FLOW_VEHICLE_BS", grbit)

    --进出口大亨
    local atbit = stats.get_int("MPX_AT_FLOW_VEHICLE_BS")
    if (atbit & (1 << 0)) == 0 then
        atbit = atbit ~ (1 << 0)
    end
    if (atbit & (1 << 1)) == 0 then
        atbit = atbit ~ (1 << 1)
    end
    if (atbit & (1 << 2)) == 0 then
        atbit = atbit ~ (1 << 2)
    end
    if (atbit & (1 << 3)) == 0 then
        atbit = atbit ~ (1 << 3)
    end
    if (atbit & (1 << 4)) == 0 then
        atbit = atbit ~ (1 << 4)
    end
    if (atbit & (1 << 5)) == 0 then
        atbit = atbit ~ (1 << 5)
    end
    if (atbit & (1 << 6)) == 0 then
        atbit = atbit ~ (1 << 6)
    end
    if (atbit & (1 << 7)) == 0 then
        atbit = atbit ~ (1 << 7)
    end
    stats.set_int("MPX_AT_FLOW_VEHICLE_BS", atbit)

    --不夜城
    tunables.set_int(1416880888, 1)
    tunables.set_int(132690314, 1)
    tunables.set_int(407802353, 1)
    tunables.set_int(-26415325, 1)
    tunables.set_int(1547508956, 1)
    tunables.set_int(-1431059775, 1)

    --毒品战
    if stats.get_int("MPX_FINISHED_SASS_RACE_TOP_3") <21 then
        stats.set_int("MPX_FINISHED_SASS_RACE_TOP_3", 21)
    end
    stats.set_bool("MPX_AWD_TAXISTAR", true)

    --回收站
    packed_stat_set_bool(41942, true)
    packed_stat_set_bool(42123, true)
    packed_stat_set_bool(42234, true)
    packed_stat_set_bool(42233, true)
    
    local slbit = stats.get_int("MPX_SALV23_GEN_BS")
    if (slbit & (1 << 12)) == 0 then
        slbit = slbit ~ (1 << 12)
    end
    stats.set_int("MPX_SALV23_GEN_BS", slbit)
    local slbit2 = stats.get_int("MPX_SALV23_SCOPE_BS")
    if (slbit2 & (1 << 1)) == 0 then
        slbit2 = slbit2 ~ (1 << 1)
    end
    stats.set_int("MPX_SALV23_SCOPE_BS", slbit2)

    --圣安地列斯雇佣兵
    local mcbit = stats.get_int("MPX_SUM23_AVOP_PROGRESS") 
    if (mcbit & (1 << 2)) == 0 then
        mcbit = mcbit ~ (1 << 2) --raiju
    end
    stats.set_int("MPX_SUM23_AVOP_PROGRESS", mcbit)

    --犯罪集团
    local fzjtbit = stats.get_int("MPX_ULP_MISSION_PROGRESS")
    if (fzjtbit & (1 << 0)) == 0 then
        fzjtbit = fzjtbit ~ (1 << 0)
    end
    if (fzjtbit & (1 << 5)) == 0 then
        fzjtbit = fzjtbit ~ (1 << 5)
    end
    stats.set_int("MPX_ULP_MISSION_PROGRESS", fzjtbit)

    --bottom dollor
    if stats.get_int("mpx_awd_dispatchwork") <5 then
        stats.set_int("mpx_awd_dispatchwork", 5)
    end
    packed_stat_set_bool(42280, true)
    packed_stat_set_bool(42281, true)
    packed_stat_set_bool(42282, true)
    packed_stat_set_bool(42283, true)
    packed_stat_set_bool(42284, true)

    --fixer
    if stats.get_int("mpx_fixer_count") < 21 then
        stats.set_int("mpx_fixer_count", 21)
    end
end)
tstaba1:add_text("Supported DLCs : Smuggler's Run + Diamond Casino Heist + Cayo Perico Heist + Doomsday Heist + Apartment Heist + Arms Trafficking + Import/Export Tycoon + Nightclub + Customization Shop + Drug War + Minimum Price Bounty")

tstaba1:add_button("Complete the LS car meet prize vehicle challenge of the week", function()
    stats.set_bool("MPX_CARMEET_PV_CHLLGE_CMPLT", true)
end)

--------------------------------------------------------------------------------------- 传送点tab

tpmenu:add_text("Teleport page")

local v3snowmen = {
	{ -374.0548, 6230.472, 30.4462 },
	{ 1558.484, 6449.396, 22.8348 },
	{ 3314.504, 5165.038, 17.386 },
	{ 1709.097, 4680.172, 41.919 },
	{ -1414.734, 5101.661, 59.248 },
	{ 1988.997, 3830.344, 31.376 },
	{ 234.725, 3103.582, 41.434 },
	{ 2357.556, 2526.069, 45.5 },
	{ 1515.591, 1721.268, 109.26 },
	{ -45.725, 1963.218, 188.93 },
	{ -1517.221, 2140.711, 54.936 },
	{ -2830.558, 1420.358, 99.885 },
	{ -2974.729, 713.9555, 27.3101 },
	{ -1938.257, 589.845, 118.757 },
	{ -456.1271, 1126.606, 324.7816 },
	{ -820.763, 165.984, 70.254 },
	{ 218.7153, -104.1239, 68.7078 },
	{ 902.2285, -285.8174, 64.6523 },
	{ -777.0854, 880.5856, 202.3774 },
	{ 1270.095, -645.7452, 66.9289 },
	{ 180.9037, -904.4719, 29.6439 },
	{ -958.819, -780.149, 16.819 },
	{ -1105.382, -1398.65, 4.1505 },
	{ -252.2187, -1561.523, 30.8514 },
	{ 1340.639, -1585.771, 53.218 }
}

tpmenu:add_button("Snowman Teleportation Point", function()
    for i = 1, 25 do
        tpmenu:add_button(tostring("Snowman"..i), function()
            script.run_in_fiber(function (snmbm)

            local pos = v3snowmen[i]
            if pos then
                local x, y, z = pos[1], pos[2], pos[3]
                PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), x+5, y, z)
                snmbm:sleep(2000)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(x, y, z, x+1, y+1, z+1, 100, true, 1752584910, PLAYER.PLAYER_PED_ID(), true, true, 0.1)
            end
            end)
        end)
        if i % 5 ~= 0 then
            tpmenu:add_sameline()
        end
    end
end)

--------------------------------------------------------------------------------------- 当当钟农场任务

t_cluckinfarm = t_heisttab:add_tab("The Cluckin Bell Farm Raid")

t_cluckinfarm:add_text("Black market fund")

t_cluckinfarm:add_button("Quick cash pickup", function()
    locals_set_int(3274, "fm_mission_controller_2020",29465,5)   --CASINO_BLACKJACK_CAMERA --switch (Local_29465.f_0)
end)

t_cluckinfarm:add_text("Breaking and Entering")

t_cluckinfarm:add_button("Transfer to laptop", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.GET_ENTITY_MODEL(ent) == joaat("m23_2_prop_m32_laptop_01a") then
            local laptoppos = ENTITY.GET_ENTITY_COORDS(ent, false)
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), laptoppos.x, laptoppos.y, laptoppos.z)        
        end
    end
end)

t_cluckinfarm:add_button("Teleport to Terrorbyte", function()
    for _, ent in pairs(entities.get_all_vehicles_as_handles()) do
        if VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(ent)) == "terbyte" then
            local terbytepos = ENTITY.GET_ENTITY_COORDS(ent, false)
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), terbytepos.x, terbytepos.y, terbytepos.z + 5)        
        end
    end
end)

t_cluckinfarm:add_button("Shoot down the drone", function()
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        
        if ENTITY.GET_ENTITY_MODEL(ent) == joaat("reh_prop_reh_drone_02a") then
            log.info("d2")
            local dronepos = ENTITY.GET_ENTITY_COORDS(ent, true)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(dronepos.x, dronepos.y, dronepos.z + 1, dronepos.x, dronepos.y, dronepos.z, 1000, true, 2526821735, PLAYER.PLAYER_PED_ID(), false, true, 1.0)  --2526821735是特制卡宾步枪MK2的Hash值,相关数据可在 https://github.com/DurtyFree/gta-v-data-dumps/blob/master/WeaponList.ini 查询
        end
    end
end)

t_cluckinfarm:add_text("Disorganized Crime")

t_cluckinfarm:add_button("Fast drilling + 100% chance of obtaining access cards", function()
    local_CF_drill_v = locals_get_int(3274, "fm_mission_controller_2020", 30950 + 54)  --获得门禁卡 
    if (local_CF_drill_v & (1 << 4)) == 0 then
        local_CF_drill_v = local_CF_drill_v ~ (1 << 4)
    end
    if (local_CF_drill_v & (1 << 16)) == 0 then
        local_CF_drill_v = local_CF_drill_v ~ (1 << 16)
    end
    locals_set_int(3274, "fm_mission_controller_2020", 30950 + 54, local_CF_drill_v)
    locals_set_int(3274, "fm_mission_controller_2020",30950 + 56 ,4)   --获得门禁卡
    locals_set_int(3274, "fm_mission_controller_2020",30950 + 39 ,3)   --钻孔立即完成 --switch (uParam0->f_39) -- (tunable) ICH_VAULT_SAFETY_DEPOSIT_BOX_VALUE_LOOT_CHANCE
end)

t_cluckinfarm:add_text("Final Chapter: Scene of the Crime")
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
deva5 = 75
deva6 = 76
script.register_looped("schlua-test", function(script)
 
    if  devmode == 1 then
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) ~= 0 then

        localmon1 = 19746
        deva1 = locals_get_int(0, "fm_mission_controller", localmon1)
        if deva1 ~= deva2 then
            log.info(tostring(localmon1.." : "..deva2.." -> "..deva1))
            deva2 = deva1
        end

        localmon2 = 27489 + 859
        deva3 = locals_get_int(0, "fm_mission_controller", localmon2)
        if deva3 ~= deva4 then
            log.info(tostring(localmon2.." : "..deva4.." -> "..deva3))
            deva4 = deva3
        end

        localmon3 = 31603 + 69
        deva5 = locals_get_int(0, "fm_mission_controller", localmon3)
        if deva5 ~= deva6 then
            log.info(tostring(localmon3.." : "..deva6.." -> "..deva5))
            deva6 = deva5
        end

        end
    end

    if  devmode2 == 1 then
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("fm_mission_controller")) ~= 0 then
            for i = 0, 60000 do
                local newValue = locals_get_int(0, "fm_mission_controller", i)
                if prevValues[i] ~= newValue then
                    log.info(string.format("%d : %d -> %d", i, prevValues[i] or 0, newValue))
                    prevValues[i] = newValue
                end
            end
        end
    end

end)

script.register_looped("schlua-tuneables-lock", function(script)
    if  perico_pri_target_val_lock:is_enabled() then
        tunables.set_int("IH_PRIMARY_TARGET_VALUE_TEQUILA", perico_value_TEQUILA:get_value())
        tunables.set_int("IH_PRIMARY_TARGET_VALUE_PEARL_NECKLACE", perico_value_NECKLACE:get_value())
        tunables.set_int("IH_PRIMARY_TARGET_VALUE_BEARER_BONDS", perico_value_BONDS:get_value())
        tunables.set_int("IH_PRIMARY_TARGET_VALUE_PINK_DIAMOND", perico_value_DIAMOND:get_value())
        tunables.set_int("IH_PRIMARY_TARGET_VALUE_MADRAZO_FILES", perico_value_FILES:get_value())
        tunables.set_int("IH_PRIMARY_TARGET_VALUE_SAPPHIRE_PANTHER_STATUE", perico_value_STATUE:get_value())
        tunables.set_int(1859395035, perico_pack_vol:get_value())
        tunables.set_float(1808919381, perico_pm_v_m_n:get_value())
        tunables.set_float(1759346392, perico_pm_v_m_h:get_value())    
    end

    if  misc_tu_lock:is_enabled() then
        tunables.set_int("GR_RESEARCH_PRODUCTION_TIME", bk_rs_t1:get_value())
        tunables.set_int("GR_RESEARCH_UPGRADE_EQUIPMENT_REDUCTION_TIME", bk_rs_t2:get_value())
        tunables.set_int("GR_RESEARCH_UPGRADE_STAFF_REDUCTION_TIME", bk_rs_t3:get_value())
    end

    if  fixer_final_val_lock:is_enabled() then
        if fixer_final_value:get_value() > 2000000 or fixer_final_value:get_value() <= 0 then
            gui.show_message("Error", "Final chapter income may not exceed 2.000.000 and must be greater than 0")
            fixer_final_val_lock:set_enabled(false)
           return
       end
       tunables.set_int("FIXER_FINALE_LEADER_CASH_REWARD", fixer_final_value:get_value())   
    end

    if  h2_awd_lock:is_enabled() then
        if h2_d1_awd:get_value() > 2500000 or h2_d1_awd:get_value() <= 0 or h2_d2_awd:get_value() > 2500000 or h2_d2_awd:get_value() <= 0 or h2_d3_awd:get_value() > 2500000 or h2_d3_awd:get_value() <= 0 then
            gui.show_message("Error", "Final chapter income may not exceed 2.500.000 and must be greater than 0")
            h2_awd_lock:set_enabled(false)
           return
       end
       tunables.set_int("GANGOPS_THE_IAA_JOB_CASH_REWARD", h2_d1_awd:get_value())   
       tunables.set_int("GANGOPS_THE_SUBMARINE_JOB_CASH_REWARD", h2_d2_awd:get_value())   
       tunables.set_int("GANGOPS_THE_MISSILE_SILO_JOB_CASH_REWARD", h2_d3_awd:get_value())   
    end

    if  h3_awd_lock:is_enabled() then
       tunables.set_int(-1638885821, h3_t1_awd:get_value())   
       tunables.set_int(1934398910, h3_t2_awd:get_value())   
       tunables.set_int(-582734553, h3_t3_awd:get_value())   
       tunables.set_int(1277889925, h3_t4_awd:get_value())  
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

script.register_looped("schlua-ml2", function(script)  
    
    if  autorespl:is_enabled() then--自动补原材料
        if stats.get_int("MPX_MATTOTALFORFACTORY0") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY0") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+0,1) --kky
            log.info("可卡因原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY1") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY1") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+1,1) --dm
            log.info("大麻原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY2") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY2") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+2,1) --bd
            log.info("冰毒原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY3") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY3") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+3,1) --jc
            log.info("假钞原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY4") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY4") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+4,1) --id
            log.info("证件原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY5") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY5") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+5,1) --bk
            log.info("地堡原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
        if stats.get_int("MPX_MATTOTALFORFACTORY6") > 0 and stats.get_int("MPX_MATTOTALFORFACTORY6") <= 40 and autoresply == 0 then 
            globals_set_int(3274, 1663174+1+6,1) --acid
            log.info("致幻剂原材料不足,将自动补满")
            MCprintspl()
            autoresply = 1
        end
    end
end)

script.register_looped("schlua-dataservice", function(script) 

    if  check1:is_enabled() then --移除交易错误警告
        globals_set_int(3274, 4537455,0)   -- shop_controller.c 	 if (Global_4536677)    HUD::SET_WARNING_MESSAGE_WITH_HEADER("CTALERT_A" /*Alert*/, func_1372(Global_4536683), instructionalKey, 0, false, -1, 0, 0, true, 0);
        globals_set_int(3274, 4537456,0)   -- shop_controller.c   HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("CTALERT_F_1" /*Rockstar game servers could not process this transaction. Please try again and check ~HUD_COLOUR_SOCIAL_CLUB~www.rockstargames.com/support~s~ for information about current issues, outages, or scheduled maintenance periods.*/);
        globals_set_int(3274, 4537457,0)  -- shop_controller.c   HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("CTALERT_F_1" /*Rockstar game servers could not process this transaction. Please try again and check ~HUD_COLOUR_SOCIAL_CLUB~www.rockstargames.com/support~s~ for information about current issues, outages, or scheduled maintenance periods.*/);
    end

    if  checkCEOcargo:is_enabled() then--锁定CEO仓库进货数
        if inputCEOcargo:get_value() <= 111 then --判断一下有没有人一次进天文数字箱货物、或者乱按的

        globals_set_int(3274, 1882599+12,inputCEOcargo:get_value())  --核心代码 --freemode.c      func_17512("SRC_CRG_TICKER_1" /*~a~ Staff has sourced: ~n~1 Crate: ~a~*/, func_6676(hParam0), func_17513(Global_1890714.f_15), HUD_COLOUR_PURE_WHITE, HUD_COLOUR_PURE_WHITE);

        else
            gui.show_error("Exceeding the limit","The number of purchases exceeds the upper limit of warehouse capacity")
            checkCEOcargo:set_enabled(false)
        end
    end

    if  check4:is_enabled() then--锁定机库仓库进货数
        globals_set_int(3274, 1882623+6,iputint3:get_value()) --freemode.c   --  "HAN_CRG_TICKER_2"   -- func_10326("HAN_CRG_TICKER_1", str, HUD_COLOUR_PURE_WHITE, HUD_COLOUR_PURE_WHITE, false);
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
            locals_set_int(3274, "casino_lucky_wheel", 280 + 14, 18)   -- 280 + 14
        end
        --char* func_180() // Position - 0x7354   --return "CAS_LW_VEHI" /*Congratulations!~n~You won the podium vehicle.*/;
        --你可以自定义代码中的18来获取其他物品。设定为18是展台载具，16衣服，17经验，19现金，4载具折扣，11神秘礼品，15 chips不认识是什么
    end

    if  vehexportclasslock:is_enabled() then--锁定CEO交易载具获取载具类型为 顶级
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_vehicle_export")) ~= 0 then
            locals_set_int(3274, "gb_vehicle_export", 836 + 461, 3)
        end
    end

    if  bkeasyms:is_enabled() then--锁定摩托帮出货任务 
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_biker_contraband_sell")) ~= 0 then
            if locals_get_int(3274, "gb_biker_contraband_sell",721) ~= 0 then 
                log.info("已锁定摩托帮产业出货任务类型.目标出货载具生成前不要关闭此开关.注意:此功能与摩托帮一键完成出货冲突")
                locals_set_int(3274, "gb_biker_contraband_sell",721,0) -- gb_biker_contraband_sell.c	iVar0 = MISC::GET_RANDOM_INT_IN_RANGE(0, 13); --Local_704.f_17 = randomIntInRange;
            end    
        end
    end

    if  ccrgsl:is_enabled() then--锁定CEO仓库出货任务 
        if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat("gb_contraband_sell")) ~= 0 then
            if locals_get_int(3274, "gb_contraband_sell", 545 + 7) ~= 12 then 
                log.info("已锁定CEO仓库出货任务类型.目标出货载具生成前不要关闭此开关")
                locals_set_int(3274, "gb_contraband_sell", 545 + 7, 12) -- gb_contraband_sell.c	iVar0 = MISC::GET_RANDOM_INT_IN_RANGE(0, 14); --Local_545.f_7 = iVar0;
            end
        end
    end

    if  bussp:is_enabled() then--锁定地堡摩托帮致幻剂生产速度
        local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID  --用于判断当前是角色1还是角色2
        if loopa32 == 0 then
            bussp2:set_enabled(false)
            gui.show_message("Next time the production is triggered to take effect","Change session immediately ?")
            tunables.set_int("BIKER_WEED_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_METH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)

            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_CRACK_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_METH_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_WEED_UPGRADE_STAFF_REDUCTION_TIME", 0)
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

            tunables.set_int("BIKER_WEED_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 120000)
            tunables.set_int("BIKER_METH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 360000)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 45000)

            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_CRACK_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_METH_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_WEED_UPGRADE_STAFF_REDUCTION_TIME", 45000)

            loopa32 =0
        end    
    end

    if  bussp2:is_enabled() then--锁定地堡摩托帮致幻剂生产速度
        local playerid = stats.get_int("MPPLY_LAST_MP_CHAR") --读取角色ID  --用于判断当前是角色1还是角色2
        if loopa19 == 0 then
            bussp:set_enabled(false)
            tunables.set_int("BIKER_WEED_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_METH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)

            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_CRACK_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_METH_UPGRADE_STAFF_REDUCTION_TIME", 0)
            tunables.set_int("BIKER_WEED_UPGRADE_STAFF_REDUCTION_TIME", 0)
            gui.show_message("Next time the production is triggered to take effect","Change session immediately ?")
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

            tunables.set_int("BIKER_WEED_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 120000)
            tunables.set_int("BIKER_METH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 360000)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_EQUIPMENT_REDUCTION_TIME", 60000)
            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 45000)

            tunables.set_int("BIKER_ACID_UPGRADE_EQUIPMENT_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_FAKEIDS_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_COUNTERCASH_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_CRACK_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_METH_UPGRADE_STAFF_REDUCTION_TIME", 45000)
            tunables.set_int("BIKER_WEED_UPGRADE_STAFF_REDUCTION_TIME", 45000)

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
        tunables.set_int("IH_SUBMARINE_MISSILES_COOLDOWN", 0)  
        tunables.set_int("IH_SUBMARINE_MISSILES_DISTANCE", 80000) 
    end

    if checkbypassconv:is_enabled() then  --跳过NPC对话
        if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
            AUDIO.STOP_SCRIPTED_CONVERSATION(false)
        end
    end

    if checkzhongjia:is_enabled() then --锁定请求重甲花费
        if iputintzhongjia:get_value() <= 500 then --防止有人拿删除钱设置为负反向刷钱
            gui.show_error("Error","The amount needs to be greater than 500")
            checkzhongjia:set_enabled(false)
        else
            tunables.set_int("BALLISTICSUITCOSTDELIVERY", iputintzhongjia:get_value())
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

        if selfled:is_enabled() then
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            GRAPHICS.DRAW_LIGHT_WITH_RANGE(selfpos.x, selfpos.y, selfpos.z+0.5, 255, 255,255, 50, 5)
        end
end)

script.register_looped("schlua-miscservice", function(script) 
    if  followply_a:is_enabled() then
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), targpos.x, targpos.y, targpos.z + 1)
    end

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
                gui.show_error("Warning","The player is not in the vehicle")
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
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() and (HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 49 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 1 or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("police3") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("RIOT") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("Predator") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policeb") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policet") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("polmav") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("FBI2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("sheriff2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("SHERIFF")) then
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
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() and (HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 49 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 1 or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("police3") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("RIOT") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("Predator") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policeb") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policet") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("polmav") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("FBI2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("sheriff2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("SHERIFF")) then
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
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() and (HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 49 or HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(vehicle)) == 1 or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("police3") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("RIOT") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("Predator") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policeb") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("policet") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("polmav") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("FBI2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("sheriff2") or ENTITY.GET_ENTITY_MODEL(vehicle) == joaat("SHERIFF")) then
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
    
    if  vehforcefield:is_enabled() then --控制载具力场-test
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle, false)
            local force_dr1 = vehicle_pos.x - selfpos.x
            local force_dr2 = vehicle_pos.y - selfpos.y
            local force_dr3 = vehicle_pos.z - selfpos.z
            if calcDistance(selfpos, vehicle_pos) <= ffrange:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, force_dr1, force_dr2, force_dr3 + 1, 0, 0, 0.5, 0, false, false, true, false, false)
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
            local force_dr1 = aobj_pos.x - selfpos.x
            local force_dr2 = aobj_pos.y - selfpos.y
            local force_dr3 = aobj_pos.z - selfpos.z
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
            local force_dr1 = ped_pos.x - selfpos.x
            local force_dr2 = ped_pos.y - selfpos.y
            local force_dr3 = ped_pos.z - selfpos.z
            if calcDistance(selfpos, ped_pos) <= ffrange:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds, true) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds, true)
                    request_control(tarpensveh)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, force_dr1, force_dr2, force_dr3 + 1, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    request_control(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, force_dr1, force_dr2, force_dr3 + 1, 0, 0, 0.5, 0, false, false, true, false, false)
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
            local force_dr1 = vehicle_pos.x - selfpos.x
            local force_dr2 = vehicle_pos.y - selfpos.y
            local force_dr3 = vehicle_pos.z - selfpos.z
            if calcDistance(selfpos, vehicle_pos) <= ffrange:get_value() then
                if vehicle ~= vehisin then
                    request_control(vehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, force_dr1, force_dr2, force_dr3 + 1, 0, 0, 0.5, 0, false, false, true, false, false)
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
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
                if Is_NPC_H(peds) then 
                    ismarked = true
                    maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(peds) -100
                    cuhealth = ENTITY.GET_ENTITY_HEALTH(peds) -100
                    GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+0.8,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20 * cuhealth / maxhealth,255,76,0,255)
                    GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+20 * cuhealth / maxhealth,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20,255, 192, 203,255)
                    if PED.GET_PED_ARMOUR(peds) > 0 then
                        GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+20,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20+10 * PED.GET_PED_ARMOUR(peds) / maxhealth ,20, 50, 100,255)
                    end
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,true)  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID()  and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and ENTITY.GET_ENTITY_HEALTH(peds) > 0 and PED.IS_PED_A_PLAYER(peds) == false then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 then 
                maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(peds) -100
                cuhealth = ENTITY.GET_ENTITY_HEALTH(peds) -100
                GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+0.8,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20 * cuhealth / maxhealth,255,76,0,255)
                GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+20 * cuhealth / maxhealth,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20,255, 192, 203,255)
                if PED.GET_PED_ARMOUR(peds) > 0 then
                    GRAPHICS.DRAW_BOX(ped_pos.x-0.1,ped_pos.y-0.1,ped_pos.z+20,ped_pos.x+0.1,ped_pos.y+0.1,ped_pos.z+20+10 * PED.GET_PED_ARMOUR(peds) / maxhealth ,20, 50, 100,255)
                end
            end
        end
    end

    if  rmpedwp2:is_enabled() then --控制敌对NPC-缴械
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1  then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
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
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 1, 1, true, true, 1, false)
            end
        end
    end

    if  stnpcany8:is_enabled() then --控制敌对NPC-削弱战斗能力
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds, false)
            if Is_NPC_H(peds) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(peds) ~= 1 and ENTITY.GET_ENTITY_HEALTH(peds) > 0  then 
                PED.SET_PED_CAN_RAGDOLL(peds, true)
                PED.SET_PED_COMBAT_ABILITY(peds, 0)
                PED.SET_PED_SHOOT_RATE(peds, 0)
                PED.SET_PED_ACCURACY(peds,0)            
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 1, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 21, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 27, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 31, false)
                PED.SET_PED_ALERTNESS(peds, 0)
                PED.SET_PED_ARMOUR(peds, 0)
                PED.SET_PED_COMBAT_MOVEMENT(peds, 0)
                PED.SET_PED_HEARING_RANGE(peds, 0)
                --PED.SET_PED_FIRING_PATTERN(peds, 0xE2CA3A71)
                if ENTITY.GET_ENTITY_HEALTH(peds) > 100 then
                    ENTITY.SET_ENTITY_HEALTH(peds,100,0,0)
                end
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
        if distance > 5 and followply_n:is_enabled(true) then 
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), targpos.x, targpos.y, targpos.z + 1)
        end
        formattedDistance = string.format("%.3f", distance)
        plydist:set_value(tonumber(formattedDistance))
    end
end)

event.register_handler(menu_event.PlayerMgrInit, function ()
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

end)

--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能
---------------------------------------------------------------------------------------存储一些小发现、用不上的东西
--[[

    heist cut Regular Expression ([\S]+)\[0\][\s]*=[\s]*100;[\n\r\t]*\1\[1\][\s]*=[\s]*0;[\n\r\t]*\1\[2\][\s]*=[\s]*0;[\n\r\t]*\1\[3\][\s]*=[\s]*0;

    Global_1574996 = etsParam0;   Global_1574996 战局切换状态 0:TRANSITION_STATE_EMPTY  freemode.c

    local bsta
    if bsta == globals_get_int(0, 1574996) then
    else
        bsta = globals_get_int(0, 1574996)
        log.info(globals_get_int(0, 1574996))
    end

    -- MC_TLIVES 团队生命数

     3095
    佩里科个人本地分红(可能也适用于赌场、末日) Global_2685444.f_6615 
    可能适用于公寓抢劫的本地分红Global_2685444.f_6403
    Global_2685444.f_3485.f_79 celebration 结算页面显示的个人分红 "CELEB_C_EARN" /* GXT: ~1~% CUT OF EARNINGS */
    iVar7 = Global_2685444.f_6615; fm2020里面的个人分红，最终赋值给Global_2685444.f_3485.f_79

	1.68_3095 赌场右下角收入	func_3556(Local_19746.f_2686, "MONEY_HELD" /* GXT: TAKE */, 1000, 6, 2, 0, "HUD_CASH" /* GXT: $~1~ */, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 1, -1, 0);


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

--[[佩里科 门
    joaat("h4_prop_h4_gate_02a"),
    joaat("h4_prop_h4_gate_03a"),
    joaat("h4_prop_h4_gate_04a"),
    joaat("h4_prop_h4_gate_05a"),
    joaat("h4_prop_h4_door_01a"),
    joaat("h4_prop_h4_gate_l_01a"),
    joaat("h4_prop_h4_gate_r_01a"),
    joaat("h4_int_sub_cellgate"),
    joaat("h4_int_03_vault_ironwork"),
    joaat("h4_int_03_vault_ironwork"),

]]

--[[
	Global_262145.f_35557 /* Tunable: BOUNTY24_DISPATCH_WORK_CASH_REWARD */
	Global_262145.f_35558 /* Tunable: BOUNTY24_DISPATCH_WORK_RP_REWARD */
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
