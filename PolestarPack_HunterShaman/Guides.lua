local addon, route = ...
local pack = "hunter-shaman-hyjal"
local title = "猎萨双人 · 50–60"
if not Polestar.RegisterPack({
    addon = addon, id = pack, title = title, author = "Codex",
    version = "0.3.2", format = 11, license = "Private use",
    source = "WoW Forever and Polestar 0.4.1. See README.txt.",
}) then return end

local zone = {
    azshara = 1447, alterac = 1416, western = 1422, tirisfal = 1420,
    swamp = 1435, hinterlands = 1425, tanaris = 1446, feralas = 1444,
    barrens = 1413, crater = 1449, felwood = 1448, moonglade = 1450,
    winterspring = 1452, hyjal = 2482, orgrimmar = 1454, thunderBluff = 1456,
    badlands = 1418, searing = 1427, burning = 1428, undercity = 1458,
    mulgore = 1412, eastern = 1423, silithus = 1451,
}
local hunter = {classes = {"HUNTER"}}
local shaman = {classes = {"SHAMAN"}}

local function point(map, x, y)
    return {map = map, x = x, y = y}
end

local function npc(id, name, map, x, y)
    return {npc = id, npcName = name, map = map, x = x, y = y}
end

local function object(id, name, map, x, y)
    return {object = id, objName = name, map = map, x = x, y = y}
end

local function fields(goal, values)
    for key, value in pairs(values or {}) do goal[key] = value end
    return goal
end

local quest = {
    [8151] = {"猎人的护符", 50}, [8153] = {"苔蹄快步者的鹿角", 50, {8151}},
    [8231] = {"碎浪多头怪", 50, {8153}}, [8232] = {"神庙中的绿龙", 50, {8231}},
    [8410] = {"元素掌握", 50}, [8411] = {"控制元素", 50},
    [8412] = {"灵魂图腾", 50}, [8413] = {"巫毒羽毛", 50, {8412}},
    [1424] = {"泪水之池", 38}, [1429] = {"阿塔莱流放者", 38, {1424}},
    [1444] = {"向费泽鲁尔复命", 38, {1429}}, [1445] = {"阿塔哈卡神庙", 38, {1444}},
    [1446] = {"预言者迦玛兰", 38}, [4787] = {"远古之卵", 40, {3527}},
    [3528] = {"神灵哈卡", 40, {4787}}, [3373] = {"伊兰尼库斯精华", 48},
    [3380] = {"沉没的神庙", 46}, [3444] = {"石环", 46, {3380}},
    [3446] = {"深入神庙", 46, {3444}}, [3447] = {"雕像群的秘密", 46, {3444}},
    [4146] = {"除草器的燃料", 47, {4147}}, [5096] = {"误导血色十字军", 50},
    [5093] = {"战斗的号角：瘟疫之地！", 50}, [5094] = {"战斗的号角：瘟疫之地！", 50},
    [5095] = {"战斗的号角：瘟疫之地！", 50}, [5405] = {"银色黎明委任徽章", 50},
    [5098] = {"标记哨塔", 50, {5096}}, [5228] = {"瘟疫之锅", 50, {5096}},
    [5229] = {"目标：费尔斯通农场", 50, {5228}}, [5230] = {"返回亡灵壁垒", 50, {5229}},
    [5021] = {"迟到总比不到好", 50}, [5023] = {"迟到总比不到好", 50, {5021}},
    [5049] = {"杰雷米亚的忧伤", 50, {5023}}, [5050] = {"好运护符", 50},
    [5051] = {"两半合一", 50, {5050}},
    [98477] = {"Unstable Magic", 48}, [4494] = {"异种蝎的远征", 50},
    [4293] = {"软泥怪的样本…", 48}, [4294] = {"一大堆软泥怪", 48},
    [3568] = {"堕落之水", 45}, [3542] = {"安德隆·甘特的石版", 45, {3517}},
    [3564] = {"安德隆的报酬", 45, {3542}},
    [91734] = {"Remote Contact", 44},
    [92346] = {"Beneath Nordrassil", 45}, [92069] = {"Claws That Rend, Tusks That Gore", 45},
    [4284] = {"能量水晶", 47}, [3882] = {"挖骨头", 49}, [3883] = {"异型的生态", 48},
    [3881] = {"抢救物资", 48}, [4145] = {"拉瑞安和穆尔金", 47},
    [4501] = {"当心翼手龙", 49}, [4503] = {"希兹尔的飞行器", 49},
    [4243] = {"找回A-Me 01", 48}, [4244] = {"找回A-Me 01", 48, {4243}},
    [4245] = {"找回A-Me 01", 48, {4244}}, [3884] = {"威利德的日记", 48},
    [87494] = {"Microcrystal Contamination"}, [4290] = {"拉克维的食物", 48},
    [87492] = {"Uncanny Crystal", 50}, [4289] = {"安戈洛的猩猩", 47},
    [4291] = {"拉克维的气味", 48, {4290}}, [4147] = {"玛尔冯的车间", 47, {4145}},
    [4292] = {"拉克维的诱饵", 48, {4291}}, [4492] = {"走丢了！", 50},
    [4502] = {"火山的活动", 49}, [92020] = {"Hol'anyee's Big Book of Big Lizards", 55},
    [3844] = {"无人知晓的秘密", 47}, [3845] = {"无人知晓的秘密", 47, {3844}},
    [3908] = {"无人知晓的秘密", 47, {3845}},
    [4285] = {"北部水晶塔", 47, {4284}}, [4287] = {"东部水晶塔", 47, {4284}},
    [4288] = {"西部水晶塔", 47, {4284}}, [4321] = {"分析水晶塔", 47, {4285, 4287, 4288}},
    [4496] = {"异种蝎的远征", 50}, [4504] = {"极度粘稠的沥青", 48},
    [3761] = {"安戈洛的泥土", 47}, [3782] = {"晨光麦研究", 47, {3761}},
    [4300] = {"骨刃武器", 48},
    [8460] = {"木喉熊怪盟友", 45}, [8462] = {"与纳菲恩交谈", 45, {8460}},
    [8461] = {"北方的死木熊怪", 45}, [8465] = {"与萨尔法交谈", 45, {8461}},
    [8466] = {"给格拉兹的羽毛", 45, {8460}}, [8467] = {"给纳菲恩的羽毛", 45, {8461}},
    [4102] = {"净化费伍德", 48}, [5155] = {"加德纳尔的势力", 48},
    [5156] = {"验证腐蚀", 48}, [5157] = {"收集堕落之水", 48, {5155}},
    [86577] = {"A Sampling of Putrescence"}, [4521] = {"冬泉谷的枭兽", 52},
    [91952] = {"The Source of the Corruption", 55},
    [4505] = {"腐化之井", 49}, [4506] = {"腐化猫咪", 49, {4505}},
    [6162] = {"最后一战", 46}, [86612] = {"Stag Lord's Bauble", 48},
    [8470] = {"死木仪祭图腾", 45},
    [7066] = {"生命之种", 45}, [8464] = {"冬泉熊怪的活动", 45},
    [5082] = {"冬泉熊怪的威胁", 52}, [5083] = {"冬泉火酒", 52},
    [3783] = {"雪怪计划！", 52}, [977] = {"雪怪计划！", 52, {3783}},
    [4808] = {"菲诺克", 50}, [4809] = {"冰风奇美拉角", 50, {4808}},
    [92859] = {"Shroud of the Winter Wilds", 55},
    [98462] = {"Shroud of the Winter Wilds", 55, {92859}},
    [84146] = {"Red Bag Blues", 55}, [96830] = {"Farsight Guided", 54},
    [93197] = {"Mending Communications", 56},
    [93406] = {"Unfrozen Deliveries", 56, {93197}}, [93269] = {"Top of the Post", 56, {93406}},
    [6029] = {"永望镇报告", 50}, [6030] = {"尼古拉斯·瑟伦霍夫公爵", 50},
}

local function questGoal(verb, id, where)
    return fields({t = verb, quest = id, title = quest[id][1]}, where)
end

local function accept(id, where, note)
    local data = quest[id]
    return fields(questGoal("accept", id, where), {minLevel = data[2], preAll = data[3], note = note})
end

local function turnin(id, where, note)
    return fields(questGoal("turnin", id, where), {note = note})
end

local function collect(id, item, name, count, index, where, note)
    local goal = {t = "collect", item = item, itemName = name, count = count, oi = index, note = note}
    if id then goal.quest, goal.title = id, quest[id][1] end
    return fields(goal, where)
end

local function kill(id, target, name, count, index, where, details)
    return fields(questGoal("kill", id, where), {npc = target, target = name, count = count, oi = index, note = details})
end

local function travel(kind, location, where, extra)
    return fields(fields({t = kind, location = location}, where), extra)
end

local function note(text)
    return {t = "note", text = text}
end

local function optional(goal)
    goal.optional = true
    return goal
end

local function step(titleText, ...)
    return {title = titleText, goals = {...}}
end

local function only(role, entry)
    entry.only = role
    for _, goal in ipairs(entry.goals) do goal.only = role end
    return entry
end

local function when(entry, ...)
    entry.when = entry.when or {}
    for _, condition in ipairs({...}) do entry.when[#entry.when + 1] = condition end
    return entry
end

local function onQuest(...)
    return {k = "onquest", q = {...}}
end

local function notOnQuest(...)
    return fields(onQuest(...), {neg = true})
end

local function handed(id, negate)
    return {k = "turnedin", q = id, neg = negate}
end

local function atLeast(level)
    return {k = "level", op = ">=", n = level}
end

local function ready(id, negate)
    return {k = "complete", q = id, neg = negate}
end

-- With no extra availability fields, the engine tests only log membership
-- or completion. This also works after an earlier route handed it in.
local function requireQuest(id)
    return {k = "available", q = id, neg = true}
end

local function along(untilLabel, entry)
    return fields(entry, {along = untilLabel})
end

-- Along rows can be passed before the player arrives or takes an optional
-- quest. Keep their live conditions out of Polestar's latched step rules.
local liveGoals, liveGoalByGoal = {}, {}
local hiddenFromGuideClasses = {classes = {"!HUNTER", "!SHAMAN"}}

local function watchAlong(entry, predicate)
    for _, goal in ipairs(entry.goals) do
        local watched = liveGoalByGoal[goal]
        if not watched then
            watched = {goal = goal, only = goal.only, tests = {}}
            liveGoals[#liveGoals + 1] = watched
            liveGoalByGoal[goal] = watched
        end
        watched.tests[#watched.tests + 1] = predicate
    end
    return entry
end

local function refreshLiveGoals()
    local C = Polestar.Compat
    local zoneName, subzone = C.GetZoneText()
    local results = {}
    local changed = false
    for _, watched in ipairs(liveGoals) do
        local show = true
        for _, predicate in ipairs(watched.tests) do
            if results[predicate] == nil then
                results[predicate] = not not predicate(C, zoneName, subzone)
            end
            if not results[predicate] then
                show = false
                break
            end
        end
        local only = hiddenFromGuideClasses
        if show then only = watched.only end
        if watched.goal.only ~= only then
            watched.goal.only = only
            changed = true
        end
    end
    return changed
end

local function handInAlong(untilLabel, id, where, details)
    return watchAlong(along(untilLabel, step("顺路交付", optional(turnin(id, where, details)))),
        function(C) return C.IsOnQuest(id) and C.IsQuestReadyForTurnIn(id) and not C.IsQuestCompleted(id) end)
end

local function startEither(id, where, closedBy, note)
    return fields(accept(id, where, note), {either = true, closedBy = closedBy})
end

local steps = {}
local function append(entries, ...)
    for _, entry in ipairs(entries) do
        steps[#steps + 1] = when(entry, ...)
        if #entry.when == 0 then entry.when = nil end
    end
end

route.pack, route.title, route.steps = pack, title, steps
route.zone, route.quest, route.hunter, route.shaman = zone, quest, hunter, shaman
route.point, route.npc, route.object, route.fields = point, npc, object, fields
route.questGoal, route.accept, route.turnin, route.collect, route.kill = questGoal, accept, turnin, collect, kill
route.travel, route.note, route.optional, route.step = travel, note, optional, step
route.only, route.when, route.onQuest, route.notOnQuest = only, when, onQuest, notOnQuest
route.handed, route.atLeast, route.ready, route.requireQuest = handed, atLeast, ready, requireQuest
route.along, route.handInAlong, route.watchAlong, route.append = along, handInAlong, watchAlong, append
route.prepareLiveGoals = refreshLiveGoals

function route.startLiveGoals(guideId)
    local function update()
        if not refreshLiveGoals() then return end
        local engine = Polestar.Engine
        local active = engine and engine.GetGuide()
        if active and active.id == guideId then engine.RequestUpdate() end
    end
    Polestar.OnLogin(update)
    for _, event in ipairs({"PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS",
        "ZONE_CHANGED_NEW_AREA", "QUEST_LOG_UPDATE", "QUEST_ACCEPTED", "QUEST_TURNED_IN",
        "QUEST_REMOVED", "BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "PLAYER_LEVEL_UP"}) do
        Polestar.RegisterEvent(event, update)
    end
    Polestar.RegisterEvent("UNIT_QUEST_LOG_CHANGED", function(_, unit)
        if unit == "player" then update() end
    end)
end

local ormak = npc(3352, "奥玛克", zone.orgrimmar, 66.14, 18.56)
local holt = npc(3039, "浩特·雷角", zone.thunderBluff, 57.3, 89.2)
local sagorne = npc(13417, "萨格尼", zone.orgrimmar, 38.58, 36.11)
local beram = npc(3032, "博拉姆·逐星", zone.thunderBluff, 22.19, 19.06)
local bathrah = npc(6176, "捕风者巴斯拉", zone.alterac, 80.5, 66.9)
local ogtinc = npc(8405, "奥汀克", zone.azshara, 42.34, 42.61)
local kroum = npc(8610, "克隆姆", zone.azshara, 21.91, 49.67)
local jediga = npc(8587, "杰迪加", zone.azshara, 22.4, 51.5)
local felzerul = npc(1443, "费泽鲁尔", zone.swamp, 47.8, 54.9)
local exile = npc(5598, "阿塔莱流放者", zone.hinterlands, 33.6, 75.2)
local yehkinya = npc(8579, "叶基亚", zone.tanaris, 66.9, 22.4)
local marvon = npc(7771, "玛尔冯·瑞文斯克", zone.tanaris, 52.7, 45.9)
local tears = point(zone.swamp, 69, 54)
local liv = npc(8496, "莉芙·雷兹菲克斯", zone.barrens, 62.45, 38.71)
local nuara = npc(272633, "Nuara Tremorhoof", zone.mulgore, 33.4, 22.6)
local fuely = npc(10136, "化学家弗雷", zone.undercity, 47.5, 73.0)
local andron = npc(6522, "安德隆·甘特", zone.undercity, 54.6, 75.73)
local derrington = npc(10837, "高级执行官德灵顿", zone.tirisfal, 83.05, 68.91)
local garush = npc(10839, "银色黎明军官加鲁什", zone.tirisfal, 83.12, 68.32)
local vandis = npc(11055, "暗影牧师范蒂丝", zone.tirisfal, 82.95, 71.92)
local janice = fields(npc(10778, "詹妮丝·费尔斯通", zone.western, 38.32, 54.14), {z = 65.2})
local bauhaus = fields(npc(10781, "皇家管理人巴哈乌斯", zone.undercity, 69.65, 43.71), {z = -55.3})
local jeremiah = fields(npc(8403, "杰雷米亚·派森", zone.undercity, 67.65, 43.66), {z = -62})
local firstCauldron = object(176361, "瘟疫之锅", zone.western, 37.1, 56.92)
local janiceParcel = fields(object(175894, "詹妮丝的包裹", zone.western, 38.69, 55.33), {z = 59.8})
local atBulwark = {k = "subzone", name = "The Bulwark", area = 152}

local function isPlace(C, text, name, area)
    return type(text) == "string" and (text == name or text == C.GetAreaName(area))
end

local function bulwarkLetters()
    return turnin(5093, derrington), turnin(5094, derrington), turnin(5095, derrington)
end

local function commissionGoal()
    return fields(turnin(5405, garush, "领取后装备徽章，击杀天灾怪可拾天灾石。"),
        {direct = true, minLevel = 50})
end

local function commissionOffer(required)
    local commission = commissionGoal()
    if not required then optional(commission) end
    return when(step("亡灵壁垒 · 领取银色黎明委任徽章",
        commission),
        handed(5401, true), handed(5405, true), handed(5503, true),
        {k = "has", item = 12846, neg = true}, {k = "equipped", item = 12846, neg = true})
end

local function coastVials()
    return fields(questGoal("complete", 3568, point(zone.azshara, 35, 55)),
        {startItem = 10695, startItemName = "空的试剂瓶", note = "在埃达拉斯废墟岸边四个潮汐池各装一瓶。"})
end

route.bulwarkLetters, route.commissionOffer, route.coastVials = bulwarkLetters, commissionOffer, coastVials

local function plagueCall(id, giver)
    local closes = {5096}
    for _, alternative in ipairs({5093, 5094, 5095}) do
        if id ~= alternative then closes[#closes + 1] = alternative end
    end
    return optional(fields(accept(id, giver, "三地引导只需一份，交给亡灵壁垒的德灵顿。"), {closedBy = closes}))
end

local function undercityStops(untilLabel)
    local entries = {
        along(untilLabel, step("路过幽暗城 · 接东线引导和本地交接",
            plagueCall(5094, npc(10879, "传令官巴萨扎德", zone.undercity, 66.52, 43)),
            optional(turnin(3542, andron)), optional(accept(3564, andron, "下次实际到瓦罗莫克时交给杰迪加。")),
            optional(accept(3568, npc(8390, "药剂师科雷", zone.undercity, 48.64, 71.55),
                "以后到艾萨拉时带试剂瓶去海岸。")),
            optional(accept(4293, fuely)), optional(accept(4294, fuely)))),
    }
    for _, entry in ipairs(entries) do
        watchAlong(entry, function(C, name) return isPlace(C, name, "Undercity", 1497) end)
    end
    return entries
end

local function hunterStart()
    return step("阶段一 · 接猎人的护符",
        startEither(8151, ormak, {8153, 8231, 8232}, "奥格瑞玛荣誉谷。用离你们近的训练师。"),
        startEither(8151, holt, {8153, 8231, 8232}, "雷霆崖猎人高地。"),
        note("各自完成职业前置，然后在斯通纳德集合。"))
end

local function shamanStart()
    return step("阶段一 · 选择一条元素任务",
        startEither(8410, sagorne, {8411, 8412, 8413}, "奥格瑞玛智慧谷。两条元素任务只接一条。"),
        startEither(8410, beram, {8411, 8412, 8413}, "雷霆崖灵魂高地的同一任务。"),
        startEither(8411, bathrah, {8410, 8412, 8413}, "人在东部王国时，直接问塔伦米尔东北的巴斯拉。"),
        note("各自完成职业前置，然后在斯通纳德集合。"))
end

-- A later quest in the log is enough evidence to resume its part of the route.
local beforeMail = notOnQuest(93197, 93406, 93269)
local noMailYet = handed(93197, true)
local mailPending = handed(93269, true)
local beforeWinter = notOnQuest(92859, 98462, 93197, 93406, 93269)
local noWinterPotionYet = handed(92859, true)

local function atFelstone(C, _, subzone)
    return isPlace(C, subzone, "Felstone Field", 199)
end

local function atUndercity(C, name)
    return isPlace(C, name, "Undercity", 1497)
end

local function localPickup(titleText, goal, atPlace)
    local entry = along(true, step(titleText, optional(goal)))
    return watchAlong(entry, function(C, name, subzone)
        if not atPlace(C, name, subzone) or (C.GetPlayerInfo().level or 0) < goal.minLevel
            or C.IsOnQuest(goal.quest) or C.IsQuestCompleted(goal.quest) then return false end
        for _, id in ipairs(goal.preAll or {}) do
            if not C.IsQuestCompleted(id) then return false end
        end
        if not goal.pre then return true end
        for _, id in ipairs(goal.pre) do
            if C.IsQuestCompleted(id) then return true end
        end
        return false
    end)
end

local function localHandIn(titleText, id, where, atPlace)
    local entry = handInAlong(true, id, where)
    entry.title = titleText
    return watchAlong(entry, atPlace)
end

-- Native Along displays only rows before the live step. Place the local
-- parcel chain first, with no end label, so a visit at any stage can show it.
append({
    localPickup("费尔斯通农场 · 楼上可找詹妮丝接包裹", accept(5021, janice), atFelstone),
    localHandIn("费尔斯通农场 · 在包裹处交第一段", 5021, janiceParcel, atFelstone),
    localPickup("费尔斯通农场 · 可带包裹去幽暗城",
        accept(5023, janiceParcel, "下次实际进幽暗城时交。"), atFelstone),
    localHandIn("幽暗城 · 顺路交费尔斯通包裹", 5023, bauhaus, atUndercity),
    localPickup("幽暗城 · 可接杰雷米亚的忧伤", accept(5049, bauhaus), atUndercity),
    localHandIn("幽暗城 · 顺路见杰雷米亚", 5049, jeremiah, atUndercity),
    localPickup("幽暗城 · 可带好运护符",
        fields(accept(5050, jeremiah, "下次到费尔斯通农场再找詹妮丝。"), {pre = {5048, 5049}}),
        atUndercity),
    localHandIn("费尔斯通农场 · 顺路交好运护符", 5050, janice, atFelstone),
    localPickup("费尔斯通农场 · 可接两半合一", accept(5051, janice), atFelstone),
    watchAlong(along(true, step("费尔斯通农场 · 合成好运护符",
        optional(fields(questGoal("complete", 5051, point(zone.western, 38.4, 55.4)), {
            startItem = 12721, startItemName = "一半好运护符",
            objs = {{text = "Good Luck Charm", count = 1}},
            note = "打附近喋喋不休的食尸鬼，拾取另一半护符。用手里的半块合成整只护符。",
        })))), function(C, name, subzone)
            return atFelstone(C, name, subzone) and C.IsOnQuest(5051)
                and not C.IsQuestReadyForTurnIn(5051) and not C.IsQuestCompleted(5051)
        end),
    localHandIn("费尔斯通农场 · 顺路交两半合一", 5051, janice, atFelstone),
})

-- 1. Class prerequisites, followed by the western circuit and temple.
append({
    only(hunter, hunterStart()),
    only(hunter, step("学瓦罗莫克航点", travel("getfp", "瓦罗莫克", kroum, {node = 44}))),
    only(hunter, step("从高地找奥汀克",
        turnin(8151, ogtinc, "从埃达拉斯废墟东北侧的高地绕过去。"),
        fields(accept(8153, ogtinc), {closedBy = {8231, 8232}}),
        optional(accept(92069, ogtinc, "后续黑喉要塞的可选任务。")),
        optional(accept(92346, jediga, "瓦罗莫克的杰迪加有黑喉相关支线。")))),
    when(only(hunter, step("猎人拾取两个鹿角",
        collect(8153, 20017, "完美的鹿角", 2, 1, point(zone.azshara, 52.1, 35.39),
            "在瓦罗莫克东北和东南的丘陵打苔蹄快步者。"))), onQuest(8153)),
    only(hunter, step("交鹿角并接鳞片任务", turnin(8153, ogtinc), fields(accept(8231, ogtinc), {closedBy = {8232}}))),
    when(only(hunter, step("猎人拾取六张鳞片",
        collect(8231, 20087, "碎浪多头怪的鳞片", 6, 1, point(zone.azshara, 84.6, 30.9),
            "打东北海岸的幼年碎浪多头怪。同行时萨满可给水下呼吸，尽量拉到浅滩。"))), onQuest(8231)),
    only(hunter, step("回奥汀克接神庙任务", turnin(8231, ogtinc), accept(8232, ogtinc))),
}, notOnQuest(8232), handed(8232, true), beforeMail, noMailYet, mailPending)

-- The western circuit carries workshop and temple prerequisites back east.
append(undercityStops("crater-camp"), beforeMail, noMailYet, mailPending, beforeWinter, noWinterPotionYet)

append({
    watchAlong(along("crater-camp", step("正在奥格瑞玛时可接另一处瘟疫之地引导",
        plagueCall(5093, npc(10880, "战斗召唤者戈拉克", zone.orgrimmar, 48.2, 66.1)))),
        function(C, name) return isPlace(C, name, "Orgrimmar", 1637) end),
    watchAlong(along("crater-camp", step("正在雷霆崖时可接另一处瘟疫之地引导",
        plagueCall(5095, npc(10881, "雷霆崖卫兵风行者", zone.thunderBluff, 42.3, 56.5)))),
        function(C, name) return isPlace(C, name, "Thunder Bluff", 1638) end),
    along("crater-camp", when(step("幽暗城 · 可顺路带给杰迪加的送件",
        optional(accept(91734, andron, "后续实际路过艾萨拉瓦罗莫克时交杰迪加。"))),
        {k = "zone", name = "Undercity", area = 1497})),
    when(step("已有堕落之水时顺路到艾萨拉海岸",
        coastVials()),
        onQuest(3568), ready(3568, true), {k = "zone", name = "Azshara", area = 16}),
    along("crater-camp", step("路过奥格瑞玛时提前接安戈洛支线",
        optional(accept(4300, npc(8659, "杰斯雷蒙", zone.orgrimmar, 55.49, 34.12),
            "沿环形山暴掠龙路线拾爪子，留到回奥格瑞玛时交。")),
        optional(fields(accept(4494, npc(7010, "兹尔宾·鼓眼", zone.orgrimmar, 56.34, 46.45)),
            {pre = {32, 7732}})))),
    fields(step("莫高雷先取元素吸引器",
        accept(98477, nuara, "在天望高地各领元素吸引器。第一次进神庙前使用，沿后续副本累计微粒。")), {label = "mulgore-attractor"}),
    along("crater-camp", step("路过雷霆崖带安戈洛泥土任务",
        optional(accept(3761, npc(5769, "哈缪尔·符文图腾", zone.thunderBluff, 78.08, 29.02),
            "已经带异种蝎的远征时腾出 25 份泥土，分别交两项。")))),
    along("crater-camp", when(step("已经在棘齿城时接火山灰任务",
        optional(accept(4502, liv, "到了安戈洛火羽山再拾灰。"))),
        {k = "subzone", name = "Ratchet", area = 392})),
    step("菲拉斯莫沙彻营地接神庙引导",
        fields(accept(3380, npc(8115, "巫医尤克里", zone.feralas, 74.4, 43.5)),
            {closedBy = {3444, 3446, 3447}})),
    step("塔纳利斯玛尔冯处接石环",
        turnin(3380, marvon), fields(accept(3444, marvon), {closedBy = {3446, 3447}})),
    when(step("热砂港带上已解锁的远古之卵任务",
        fields(accept(4787, yehkinya, "需要从辛特兰辛萨罗取卵。已完成祖尔法拉克石板前置才接。"), {closedBy = {3528}})),
        handed(3527), handed(4787, true), notOnQuest(3528), handed(3528, true)),
}, beforeMail, noMailYet, mailPending, beforeWinter, noWinterPotionYet)

local gryfe = npc(10583, "格莱菲", zone.crater, 45.13, 5.89)
local jd = npc(9117, "科琳", zone.crater, 41.83, 2.58)
local spark = npc(9272, "斯巴克·尼米尔", zone.crater, 43.61, 7.35)
local holanyee = npc(9271, "霍莱伊·马绍尔", zone.crater, 43.78, 7.35)
local williden = npc(9270, "威利德·马绍尔", zone.crater, 43.82, 7.24)
local larion = npc(9118, "拉瑞安", zone.crater, 45.56, 8.57)
local shizzle = npc(9998, "希兹尔", zone.crater, 44.31, 11.4)
local torwa = npc(9619, "托尔瓦·寻路者", zone.crater, 71.51, 76.01)
local link = npc(8737, "林克", zone.crater, 44.77, 8.02)
local donova = npc(9298, "多诺瓦·雪山", zone.winterspring, 31.21, 45.15)
local wreck = object(161505, "破碎的木筏", zone.crater, 63.15, 68.37)
local smallPack = object(161504, "小背包", zone.crater, 63.03, 69.01)
local crystals = point(zone.crater, 55.8, 7.9)
local gorillas = point(zone.crater, 67.66, 16.62)

local function pylon(id, target, name, x, y)
    return fields(questGoal("interact", id, object(target, name, zone.crater, x, y)), {oi = 1})
end

local karna = npc(9618, "卡尔纳·雷塔维", zone.crater, 46.23, 13.44)
local ame = npc(9623, "A-Me 01", zone.crater, 67.52, 16.75)
local pestlezugg = npc(5594, "炼金师匹斯特苏格", zone.tanaris, 50.88, 27.01)
local tranrek = npc(7876, "特兰雷克", zone.tanaris, 51.56, 26.75)
local craterTar = point(zone.crater, 56.9, 13.8)
local gorishi = point(zone.crater, 45.5, 72.3)
local wreckedCamp = point(zone.crater, 38.5, 66.1)

local function crystalScale()
    return optional(accept(87494, {item = 280459, itemName = "注能水晶鳞片"},
        "拾到再右键接任务。附近的迅猛龙可掉落。"))
end

local function willidenJournal()
    return optional(accept(3884, {item = 11116, itemName = "被撕破的日记"},
        "拾到再右键接任务。"))
end

-- 2. Enter at Torwa, then sweep north, east, south and west from the refuge.
append({
    along("crater-camp", step("塔纳利斯顺路任务",
        optional(accept(4504, tranrek, "在加基森接，安戈洛北边沥青池取样。")),
        optional(fields(accept(4496, pestlezugg, "交过异种蝎前置可接，途中在南边虫巢取样。"), {pre = {4493, 4494}})))),
    handInAlong("crater-camp", 3528, yehkinya, "已有装满的卵，路过热砂港就找叶基亚。"),
    along("crater-camp", step("加基森交奥格瑞玛的异种蝎引导",
        optional(turnin(4494, pestlezugg, "持有奥格引导时在加基森交接；没有前置就继续。")))),
    handInAlong("crater-torwa-food", 87494, torwa),
    fields(step("阶段二 · 塔纳利斯入口找托尔瓦",
        accept(4290, torwa, "从塔纳利斯西南沿路入安戈洛，到东南角见托尔瓦。"),
        accept(4289, torwa), accept(87492, torwa),
        crystalScale()), {label = "crater-entry"}),
    step("东南拾蛇颈龙肉块和蓝水晶",
        collect(87492, 280417, "破损的蓝水晶", 1, 1, object(672518, "破损的蓝水晶", zone.crater, 66.3, 75.2)),
        collect(4290, 11504, "蛇颈龙肉块", 1, 1, object(166863, "新鲜的蛇颈龙尸体", zone.crater, 68.87, 57.64))),
    fields(step("托尔瓦交肉和水晶并续接气味",
        turnin(4290, torwa), turnin(87492, torwa), accept(4291, torwa)), {label = "crater-torwa-food"}),
    step("东南踩蛋引母暴掠龙",
        collect(4291, 11509, "暴掠龙信息素", 2, 1, point(zone.crater, 67, 73),
            "踩托尔瓦西北的暴掠龙蛋引出拉克维的配偶，再拾信息素。"), willidenJournal(), crystalScale()),
    step("湖边查看破木筏和水下背包",
        accept(3844, wreck), turnin(3844, smallPack, "木筏在岸边。小背包在旁边水下。"),
        accept(3845, smallPack, "右键任务物品「湿透的小包」，取出三件物品。"),
        collect(3845, 11104, "大指南针", 1, 1, smallPack),
        collect(3845, 11105, "卷曲的羊皮地图", 1, 2, smallPack),
        collect(3845, 11106, "狮头钥匙", 1, 3, smallPack)),
    handInAlong("crater-camp", 87494, torwa),
    step("东南交气味任务再往营地北上",
        turnin(4291, torwa), optional(accept(4292, torwa, "队伍能处理拉克维时，可在东塔附近做诱饵。")), willidenJournal(), crystalScale()),
    fields(step("开马绍尔营地航点",
        travel("getfp", "马绍尔营地", gryfe, {node = 79, note = "沿路去北边的马绍尔营地。"})), {label = "crater-camp"}),
    handInAlong("crater-camp-exit", 3845, link),
    step("在北营地接齐环线任务",
        accept(4284, jd, "科琳在洞里。"), accept(3882, spark), accept(3881, williden), accept(4145, larion),
        optional(accept(3908, link, "续篇顺路去冬泉谷。")),
        optional(accept(3883, holanyee, "南边虫巢采样，按队伍强度选择。")),
        optional(accept(4492, npc(9997, "斯普拉格·弗劳克", zone.crater, 43.59, 8.49), "路过火羽山时看林戈。")),
        accept(4501, object(174682, "当心翼手龙", zone.crater, 43.54, 8.28))),
    fields(step("出北营地找希兹尔和卡尔纳",
        accept(4503, shizzle), accept(4243, karna, "先找东北山洞里的机器人。包里有秘银外壳可连做后续。")),
        {label = "crater-camp-exit"}),
    step("在北坡收四色水晶并清沥青池外围",
        collect(4284, 11186, "红色能量水晶", 7, 1, crystals),
        collect(4284, 11188, "黄色能量水晶", 7, 2, crystals),
        collect(4284, 11185, "绿色能量水晶", 7, 3, crystals),
        collect(4284, 11184, "蓝色能量水晶", 7, 4, crystals,
            "这次两人各交每色七个。平台另需全队每色一组 15 个，沿途多留。"),
        kill(4501, 9166, "翼手龙", 10, 1, point(zone.crater, 56.4, 11.4)),
        collect(4503, 11831, "精细的翼手龙鳞片", 8, 2, point(zone.crater, 56.8, 11.7)),
        kill(4145, 6510, "血瓣花掠夺者", 5, 3, point(zone.crater, 54.19, 13.68)),
        optional(collect(4504, 11834, "极度粘稠的沥青", 12, 1, craterTar, "有加基森的任务时打沥青怪。"))),
    step("回科琳交四色水晶并接三座塔",
        turnin(4284, jd), accept(4285, jd), accept(4287, jd), accept(4288, jd)),
    step("点亮北部水晶塔", pylon(4285, 164955, "北部水晶塔", 56.52, 12.54)),
    step("东北台地收三种猩猩皮并找到 A-Me",
        collect(4289, 11478, "安戈洛猩猩的皮", 2, 1, gorillas),
        collect(4289, 11479, "安戈洛巨猩猩的皮", 2, 2, gorillas),
        collect(4289, 11480, "安戈洛大猩猩的皮", 2, 3, gorillas, "各两张，够了就走。"),
        turnin(4243, ame, "A-Me 在猩猩洞里，避开深处的大猩猩首领。")),
    when(step("已有秘银外壳时修好 A-Me",
        accept(4244, ame), turnin(4244, ame, "交一个随身携带的秘银外壳。")),
        {k = "has", item = 10561}, handed(4244, true)),
    when(step("护送 A-Me 回卡尔纳",
        accept(4245, ame, "接取会开始护送。先清附近猩猩，之后跟紧 A-Me。"),
        fields(questGoal("complete", 4245, karna), {escort = true, note = "保护它走到卡尔纳的营地。"}),
        turnin(4245, karna)), handed(4244)),
    step("东侧沿途清血瓣花并找食物箱",
        kill(4145, 6511, "血瓣花猛击者", 5, 4, point(zone.crater, 68.9, 26.3)),
        collect(3881, 11113, "食物箱", 1, 1, object(161526, "食物箱", zone.crater, 68.5, 36.5)),
        kill(4145, 6509, "血瓣花鞭笞者", 5, 1, point(zone.crater, 73.19, 46.34)),
        optional(collect(4300, 11477, "白色暴掠龙爪", 8, 1, point(zone.crater, 69.9, 50.1),
            "已有奥格瑞玛的任务时顺路打暴掠龙。")), willidenJournal(), crystalScale()),
    step("点亮东部水晶塔", pylon(4287, 164957, "东部水晶塔", 77.16, 49.98)),
    along("crater-turnins", when(step("东侧石板附近用诱饵召拉克维",
        optional(collect(4292, 11510, "拉克维的头", 1, 1, point(zone.crater, 79.65, 49.83),
            "用托尔瓦背包里的肉和信息素，击倒拉克维后拾取。"))), onQuest(4292))),
    handInAlong("crater-turnins", 87494, torwa),
    handInAlong("crater-turnins", 4292, torwa),
    step("顺路在东南交猩猩皮", turnin(4289, torwa), crystalScale()),
    along("crater-turnins", when(step("有虫巢任务再采样",
        optional(collect(4496, 11837, "格里什信息素", 1, 1, gorishi)),
        optional(fields(questGoal("use", 3883, point(zone.crater, 48.7, 85.3)),
            {item = 11132, itemName = "未使用的采样瓶", oi = 1, note = "进虫巢深处再用空瓶。"})),
        optional(collect(3883, 11131, "虫穴内壁样本", 1, 1, point(zone.crater, 48.7, 85.3)))),
        onQuest(4496, 3883))),
    along("crater-turnins", when(step("两项泥土任务合留 25 份",
        optional(collect(nil, 11018, "安戈洛的泥土", 25, nil, gorishi,
            "每人留 5 份交加基森，另留 20 份交雷霆崖。环形山多数地带可顺手拾。"))),
        onQuest(3761), onQuest(4496))),
    along("crater-turnins", when(step("只带雷霆崖任务时留 20 份泥土",
        optional(collect(3761, 11018, "安戈洛的泥土", 20, 1, gorishi))),
        onQuest(3761), notOnQuest(4496))),
    along("crater-turnins", when(step("只带加基森任务时留 5 份泥土",
        optional(collect(4496, 11018, "安戈洛的泥土", 5, 2, gorishi))),
        onQuest(4496), notOnQuest(3761))),
    along("crater-turnins", step("路过火羽山时找林戈、拾火山灰",
        optional(turnin(4492, npc(9999, "林戈", zone.crater, 51.92, 49.91), "在山腰洞里。")),
        optional(collect(4502, 11829, "安戈洛灰烬", 9, 1, point(zone.crater, 50.7, 49.3))))),
    along("crater-turnins", when(step("安戈洛西侧收原始软泥样本",
        optional(collect(nil, 12235, "安戈洛软泥怪样本", 25, nil, point(zone.crater, 36.1, 65.5),
            "从软泥怪身上拾取原始样本，可多带一些。下次到幽暗城再用弗雷的绿色试验器检验。"))),
        onQuest(4294), ready(4294, true))),
    step("西南扫骨头、双帆龙和营地物资",
        collect(3882, 11114, "恐龙骨头", 8, 1, point(zone.crater, 46.09, 68.5), "在地上拾取，避开精英剑龙。"),
        collect(4503, 11830, "精细的双帆龙鳞片", 8, 1, point(zone.crater, 46.74, 69.94)),
        kill(4145, 6512, "血瓣花捕兽者", 5, 2, point(zone.crater, 36.97, 69.79)),
        collect(3881, 11112, "研究设备", 1, 2, wreckedCamp), willidenJournal(), crystalScale()),
    step("点亮西部水晶塔并打狂暴翼手龙",
        pylon(4288, 164956, "西部水晶塔", 23.86, 59.19),
        kill(4501, 9167, "狂暴的翼手龙", 15, 2, point(zone.crater, 21, 58.4), "沿西崖打，等级高的单个拉。")),
    handInAlong("crater-research", 3883, holanyee),
    handInAlong("crater-research", 3845, link),
    fields(step("回马绍尔营地集中交任务",
        turnin(4501, npc(9997, "斯普拉格·弗劳克", zone.crater, 43.6, 8.65)),
        turnin(4503, shizzle), turnin(4145, larion), accept(4147, larion, "带去棘齿城工坊，和石环一起办。"),
        turnin(3881, williden), optional(turnin(3884, williden)),
        turnin(3882, spark), optional(accept(3908, link, "冬泉谷交给多诺瓦。")),
        optional(accept(92020, holanyee, "55 级再带书，后续上山时交给 Tiala Whitemane。"))),
        {label = "crater-turnins"}),
    handInAlong("felwood-entry", 4504, tranrek),
    handInAlong("felwood-entry", 4496, pestlezugg),
    fields(step("找科琳交三塔并分析水晶",
        turnin(4285, jd), turnin(4287, jd), turnin(4288, jd), accept(4321, jd), turnin(4321, jd)),
        {label = "crater-research"}),
}, beforeWinter, noWinterPotionYet, noMailYet, mailPending)

-- Both workshop errands share one Ratchet stop; the actual pickups unlock the dungeon.
append({
    handInAlong("stone-circle-return", 4502, liv),
    step("棘齿城工坊取石环、交车间并接燃料",
        collect(3444, 10556, "石环", 1, 1,
            object(149036, "玛尔冯的箱子", zone.barrens, 62.49, 38.53), "工坊的箱子。"),
        turnin(4147, liv), accept(4146, liv),
        optional(accept(4502, liv, "还没取过灰时，留到第二次经过安戈洛再做。"))),
    fields(step("塔纳利斯回交石环并接两项神庙任务",
        turnin(3444, marvon), accept(3446, marvon), accept(3447, marvon)), {label = "stone-circle-return"}),
    when(step("去热砂港交已取得的远古之卵",
        turnin(4787, yehkinya), accept(3528, yehkinya, "个人任务和队伍的召唤道具分别确认。")),
        ready(4787)),
    when(step("热砂港接已解锁的神灵哈卡",
        accept(3528, yehkinya, "可乘热砂港与河林之间的航船返回东部王国。")), handed(4787)),
}, beforeMail, noMailYet, mailPending, beforeWinter, noWinterPotionYet)

local function elementTurnin(id)
    return when(only(shaman, step("把四种元素交给巴斯拉", turnin(id, bathrah))), onQuest(id))
end

append(undercityStops("temple-exit"), beforeMail, noMailYet, mailPending)

append({
    when(only(shaman, shamanStart()), handed(8410, true), handed(8411, true)),
    when(only(shaman, step("准备元素材料",
        collect(nil, 7069, "元素空气", 1), collect(nil, 7068, "元素火焰", 1),
        collect(nil, 7067, "元素之土", 1), collect(nil, 7070, "元素之水", 1),
        note("四种材料各一个。可从阿拉希的元素怪取得，也可交易。"))),
        onQuest(8410, 8411), handed(8410, true), handed(8411, true)),
    elementTurnin(8410), elementTurnin(8411),
    when(only(shaman, step("接灵魂图腾", fields(accept(8412, bathrah,
        "从塔伦米尔沿村东的河向北到废墟。交过任一元素任务即可。从幽暗城来时可顺手接瘟疫之地引导。"),
        {pre = {8410, 8411}, closedBy = {8413}}))),
        notOnQuest(8412), handed(8412, true)),
}, notOnQuest(8413), handed(8413, true), beforeMail, noMailYet, mailPending)

-- This waypoint is on the Shaman's own material route. An actor already
-- in the Plaguelands or with the materials ready can continue directly.
local function diversionPickup()
    return fields(accept(5096, derrington, "出发前从德灵顿身边的箱子取燃烧瓶。想清第一农场时再烧血色帐篷。"),
        {crumbs = {5093, 5094, 5095}})
end

local function outboundWall()
    local goals = {bulwarkLetters()}
    table.insert(goals, 1, travel("enter", "亡灵壁垒", point(zone.tirisfal, 83.1, 69), {area = 152}))
    goals[#goals + 1] = diversionPickup()
    return step("从亡灵壁垒进入西瘟疫", unpack(goals))
end

append({
    when(only(shaman, outboundWall()),
        onQuest(8412), {k = "zone", name = "Western Plaguelands", area = 28, neg = true}),
}, ready(8412, true), handed(8412, true), notOnQuest(8413), handed(8413, true), beforeMail, noMailYet, mailPending)

append({
    only(shaman, commissionOffer(true)),
}, atBulwark, onQuest(8412), atLeast(50), ready(8412, true),
    notOnQuest(8413), handed(8413, true), beforeMail, noMailYet, mailPending)

local function localBulwark(C, _, subzone)
    return (C.GetPlayerInfo().level or 0) >= 50 and isPlace(C, subzone, "The Bulwark", 152)
end

local bulwarkOverlay = step("经过亡灵壁垒 · 交引导并接血色前线", bulwarkLetters())
bulwarkOverlay.goals[#bulwarkOverlay.goals + 1] = diversionPickup()
for _, goal in ipairs(bulwarkOverlay.goals) do optional(goal) end
local bulwarkBadge = along("temple-exit", step("在亡灵壁垒可领取银色黎明委任徽章", optional(commissionGoal())))
watchAlong(bulwarkBadge, function(C)
    local wearing = type(C.IsItemEquipped) == "function" and C.IsItemEquipped(12846)
    return not C.IsQuestCompleted(5401) and not C.IsQuestCompleted(5405) and not C.IsQuestCompleted(5503)
        and (C.GetItemCount(12846) or 0) == 0 and not wearing
end)
append({
    watchAlong(along("temple-exit", bulwarkOverlay), localBulwark),
    watchAlong(bulwarkBadge, localBulwark),
}, beforeMail, noMailYet, mailPending)

-- These are side stops alongside either character's own trip. Using
-- optional quest goals lets pickups open their later work without a new
-- step condition that would latch before the player chooses the branch.
local eastTrip = {8412, 5093, 5094, 5095, 5096, 5228, 5229, 5230}

local function onEastTrip(C, name, subzone)
    local atWall = isPlace(C, subzone, "The Bulwark", 152)
    local atFarm = isPlace(C, subzone, "Felstone Field", 199)
    local inPlaguelands = isPlace(C, name, "Western Plaguelands", 28)
    if not atWall and not atFarm and not inPlaguelands and not C.IsOnQuest(8412) then return false end
    for _, id in ipairs(eastTrip) do
        if C.IsOnQuest(id) then return true end
    end
    -- The log can be empty between turning in a quest and taking its
    -- follow-up. Keep that offer visible when the player is back locally.
    local done = C.IsQuestCompleted
    return (atWall and ((done(5096) and not done(5228)) or (done(5228) and not done(5229))))
        or (atFarm and done(5229) and not done(5230))
end

local function firstFarmStops()
    local entries = {
        step("血色前线 · 点帐篷并插旗",
            fields(questGoal("complete", 5096, object(176088, "血色十字军前线营地", zone.western, 40.69, 51.93)),
                {startItem = 12807, startItemName = "天灾战旗",
                    note = "先从亡灵壁垒的箱子（176092）拿燃烧瓶，再用它点燃指挥帐篷并插旗。"})),
        handInAlong("temple-exit", 5096, derrington),
        step("亡灵壁垒 · 回报后可接第一口瘟疫锅",
            accept(5098, derrington, "四塔留到之后的安多哈尔圈。"),
            accept(5228, derrington), turnin(5228, vandis), accept(5229, vandis)),
        handInAlong("temple-exit", 5229, firstCauldron),
        step("费尔斯通农场 · 锅钥匙",
            collect(5229, 13194, "费尔斯通农场的瘟疫之锅钥匙", 1, 1,
                npc(11075, "护锅者拜尔摩", zone.western, 36.9, 57.4), "拾钥匙后在农场的瘟疫之锅（37.1，56.9）交付，再接返回亡灵壁垒。"),
            accept(5230, firstCauldron)),
        step("亡灵壁垒 · 交第一农场报告", turnin(5230, vandis)),
    }
    for _, entry in ipairs(entries) do
        along("temple-exit", entry)
        for _, goal in ipairs(entry.goals) do optional(goal) end
        watchAlong(entry, onEastTrip)
    end
    return entries
end

append(firstFarmStops(), beforeMail, noMailYet, mailPending)

append({
    when(only(shaman, step("西瘟疫取眼睛和熊爪",
        collect(8412, 20610, "充血的蜘蛛眼", 8, 1, point(zone.western, 31.08, 58.54),
            "从亡灵壁垒进西瘟疫，在冰风岗西北打毒雾潜伏者。"),
        collect(8412, 20611, "厚实的黑爪", 8, 2, point(zone.western, 31.28, 60.13),
            "在同一片打生病的黑熊，食腐秃鹰也可能出其中一种。"))), onQuest(8412)),
    only(shaman, step("回巴斯拉接神庙任务", turnin(8412, bathrah),
        accept(8413, bathrah))),
}, notOnQuest(8413), handed(8413, true), beforeMail, noMailYet, mailPending)

-- Eastern pickups from the route's last pass before entering the temple.
append({
    step("斯通纳德接泪水之池",
        fields(accept(1424, felzerul, "从河林可经暮色森林往悲伤沼泽，沿路到斯通纳德。"),
            {closedBy = {1429, 1444, 1445}})),
    when(step("神庙外拾十件阿塔莱神器",
        collect(1424, 6175, "阿塔莱神器", 10, 1, tears, "在泪水之池遗迹外拾取。"),
        turnin(1424, felzerul), fields(accept(1429, felzerul), {closedBy = {1444, 1445}})), onQuest(1424)),
    when(step("斯通纳德接给阿塔莱流放者的信",
        fields(accept(1429, felzerul), {closedBy = {1444, 1445}})), handed(1424)),
    step("辛特兰把信交给流放者并接迦玛兰",
        turnin(1429, exile), fields(accept(1444, exile), {closedBy = {1445}}), accept(1446, exile)),
    when(step("辛萨罗洞穴取远古之卵",
        collect(4787, 12402, "远古之卵", 1, 1, point(zone.hinterlands, 57.6, 86.8),
            "已有叶基亚的任务才走这段。辛萨罗洞穴有精英，与队友一起去。")), onQuest(4787), ready(4787, true)),
    when(step("有远古之卵才回热砂港接神灵哈卡",
        turnin(4787, yehkinya, "用河林与热砂港的船往返，只为手上已解锁的卵任务。"),
        accept(3528, yehkinya)), ready(4787)),
    step("斯通纳德交复命并带阿塔哈卡神庙",
        turnin(1444, felzerul), accept(1445, felzerul)),
}, beforeMail, noMailYet, mailPending, beforeWinter, noWinterPotionYet)

local function templeEntrance()
    return travel("enter", "沉没的神庙", tears, {area = 1417,
        note = "在斯通纳德集合。首趟各留六条公共加一条职业任务的位置，先交附近已完成的任务。未解锁远古之卵时可留哈卡奖励到以后。从遗迹南侧台阶下水进入副本。"})
end

-- If the upstream quest is done or the egg is already in the log, The
-- God Hakkar is part of this character's first run. Otherwise the route
-- can enter without sending them to rerun Zul'Farrak.
local templeRequirements = {
    requireQuest(1445), requireQuest(1446), requireQuest(3446), requireQuest(3447), requireQuest(4146),
    {k = "available", q = 3528, preAll = {3527}, neg = true},
    {k = "available", q = 3528, preAll = {4787}, neg = true},
    {k = "available", q = 3528, parent = 4787, neg = true},
}

local function templeStop(role, classQuest, questId, titleText, objectives, needsReady)
    local goals = {templeEntrance()}
    for _, objective in ipairs(objectives) do goals[#goals + 1] = fields({}, objective) end
    local entry = when(only(role, step(titleText, unpack(goals))),
        requireQuest(classQuest), onQuest(questId), handed(questId, true))
    if needsReady then when(entry, ready(questId, true)) end
    append({entry}, unpack(templeRequirements))
end

append({
    along("temple-exit", when(step("进神庙前使用元素吸引器",
        optional(fields(questGoal("use", 98477, tears), {
            item = 281371, itemName = "元素吸引器", note = "进本前使用，效果在身时顺手拾微粒。十个微粒可跨副本累计。"
        })),
        optional(collect(98477, 274964, "不稳定的魔法微粒", 10, 1))), onQuest(98477), ready(98477, true))),
    along("temple-closed", step("尾王掉落后在本内交精华",
        optional(accept(3373, {item = 10454, itemName = "伊兰尼库斯的精华"}, "打倒伊兰尼库斯后右键掉落物。")),
        optional(turnin(3373, object(148512, "精华之泉"))))),
}, mailPending)

local templeShared = {
    {1445, "沉没的神庙 · 拾哈卡神像", {collect(1445, 6181, "哈卡神像", 20, 1, nil, "每个人自己拾小怪掉落。")}, true},
    {1446, "沉没的神庙 · 预言者迦玛兰", {collect(1446, 6212, "加玛兰的头颅", 1, 1)}, true},
    {4146, "沉没的神庙 · 收集燃料", {collect(4146, 11318, "阿塔莱之雾", 5, 1, nil, "软泥怪和虫子掉落。")}, true},
    {3446, "沉没的神庙 · 哈卡祭坛", {turnin(3446, object(148836, "哈卡祭坛"), "拿玛尔冯的石环去祭坛。")}},
    {3447, "沉没的神庙 · 雕像群", {turnin(3447, object(148838, "哈卡神像"),
        "在下层按南、北、西南、东南、西北、东北操作，击败守护者。")}},
    {3528, "沉没的神庙 · 哈卡仪式", {collect(3528, 10662, "装满的哈卡之卵", 1, 1, nil,
        "由有召唤物的队友启动。用血卫的血灭四处火焰，再打哈卡化身。各自留意日志。")}, true},
}
for _, spec in ipairs({
    {hunter, 8232, "沉没的神庙 · 摩弗拉斯", {
        collect(8232, 20019, "摩弗拉斯之牙", 1, 1, nil,
            "清六名阳台巨魔，再打预言者、Weaver 和 Dreamscythe，最后拾摩弗拉斯之牙。"),
    }},
    {shaman, 8413, "沉没的神庙 · 六名巨魔", {
        collect(8413, 20606, "琥珀巫毒羽毛", 2, 1, nil, "加什尔、祖罗尔。"),
        collect(8413, 20607, "蓝色巫毒羽毛", 2, 2, nil, "胡库、米杉。先处理米杉的治疗。"),
        collect(8413, 20608, "绿色巫毒羽毛", 2, 3, nil, "祖罗、洛若。"),
    }},
}) do
    local role, classQuest = spec[1], spec[2]
    local start = #steps + 1
    templeStop(role, classQuest, classQuest, spec[3], spec[4], true)
    for _, shared in ipairs(templeShared) do
        templeStop(role, classQuest, shared[1], shared[2], shared[3], shared[4])
    end
    for i = start, #steps do when(steps[i], mailPending) end
end

append({
    when(fields(step("出本回斯通纳德交哈卡神像",
        turnin(1445, felzerul)), {label = "temple-exit"}), ready(1445)),
    when(fields(step("出本去辛特兰交流放者的头颅",
        turnin(1446, exile, "本轮走东部北线时交预言者迦玛兰的头。")), {label = "temple-closed"}), ready(1446)),
    when(only(shaman, step("萨满回巴斯拉交羽毛", turnin(8413, bathrah))), onQuest(8413), ready(8413)),
}, mailPending)

local grazle = npc(11554, "格拉兹", zone.felwood, 50.9, 84.88)
local nafien = npc(15395, "纳菲恩", zone.felwood, 64.72, 8.21)
local salfa = npc(11556, "萨尔法", zone.winterspring, 27.75, 34.53)
local inEverlook = npc(11139, "尤格雷克", zone.winterspring, 60.43, 36.36)
local greta = npc(10922, "格雷塔·苔蹄", zone.felwood, 51.07, 82.17)
local taronn = npc(10921, "塔诺恩·红羽", zone.felwood, 50.9, 81.68)
local maybess = npc(9529, "梅贝丝·河风", zone.felwood, 46.77, 83.09)
local kelek = npc(10920, "科雷克·望天", zone.felwood, 51.07, 81.81)
local jaedenar = point(zone.felwood, 39.25, 59.27)
local southDeadwood = point(zone.felwood, 46.24, 89.98)
local northDeadwood = point(zone.felwood, 63.68, 6.05)
local feather = {k = "has", item = 21377, n = 5}
local cold = {k = "rep", faction = 576, standing = 3}

local bloodvenom = npc(11900, "布拉卡尔", zone.felwood, 34.4, 53.92)
local trull = npc(10306, "特鲁尔·法贝恩", zone.felwood, 34.68, 52.76)
local winna = npc(9996, "温娜·哈萨德", zone.felwood, 34.22, 52.29)
local dreka = npc(9620, "德雷卡苏", zone.felwood, 34.73, 52.65)
local jadefireWell = point(zone.felwood, 32.3, 66.6)
local noEverlook = {k = "taxi", name = "Everlook", node = 53, neg = true}
local belowCold = {k = "rep", faction = 576, standing = 3, neg = true}
local below56 = {k = "level", op = "<", n = 56}

append({
    fields(step("费伍德南部 · 翡翠圣地",
        accept(5155, greta, "从灰谷沿路向北进费伍德。"), accept(5156, taronn),
        accept(4102, maybess), optional(accept(86577, kelek)),
        optional(accept(91952, greta, "55 级时查格雷塔的引导，顺路带到海加尔。"))), {label = "felwood-entry"}),
    step("格拉兹的木喉熊怪任务", accept(8460, grazle, "靠费伍德南边大路。击杀死木熊怪提高木喉声望。")),
    step("清南边三类死木熊怪",
        kill(8460, 7153, "死木战士", 6, 1, southDeadwood),
        kill(8460, 7155, "死木探路者", 6, 2, southDeadwood),
        kill(8460, 7154, "死木园丁", 6, 3, southDeadwood),
        optional(collect(6162, 15879, "洛尔的爪子", 1, 1, npc(9464, "洛尔", zone.felwood, 48.2, 94.3),
            "已有「最后一战」可以去死木村南端。"))),
    step("回格拉兹交接", turnin(8460, grazle), accept(8462, grazle)),
    when(step("格拉兹收羽毛补木喉声望",
        fields(turnin(8466, grazle, "每五支交一次，达到冷淡即可。"), {direct = true, minLevel = 45})),
        handed(8460), feather, belowCold, noEverlook),
    step("加德纳尔外清四类敌人",
        kill(5155, 7125, "加德纳尔猎犬", 4, 1, jaedenar),
        kill(5155, 7113, "加德纳尔守护者", 4, 2, jaedenar),
        kill(5155, 7115, "加德纳尔精兵", 6, 3, jaedenar),
        kill(5155, 7112, "加德纳尔教徒", 6, 4, jaedenar)),
    step("交加德纳尔并续接取水", turnin(5155, greta), accept(5157, greta)),
    along("timbermaw", when(step("费伍德沿途收原始软泥样本",
        optional(collect(nil, 12230, "费伍德软泥怪样本", 25, nil, jaedenar,
            "加德纳尔入口的被污染软泥怪与碧火废墟的被诅咒软泥怪都可拾原始样本。到幽暗城用弗雷的红色试验器检验。"))),
        onQuest(4293), ready(4293, true))),
    step("在加德纳尔腐化月亮井装水",
        fields(questGoal("use", 5157, point(zone.felwood, 35.2, 59.8)),
            {item = 12922, itemName = "空水壶", oi = 1, note = "在加德纳尔的月亮井边使用任务空壶。"}),
        collect(5157, 12907, "腐化的月亮井水", 1, 1, point(zone.felwood, 35.2, 59.8))),
    step("开血毒岗哨航点并接腐化之井",
        travel("getfp", "血毒岗哨", bloodvenom, {node = 48}),
        accept(4505, winna), optional(accept(4521, trull, "冬泉谷枭兽，可顺路接。")),
        optional(accept(6162, dreka, "死木村南端的洛尔，可在回南段交任务时顺路做。"))),
    step("碧火萨特的月亮井取水",
        fields(questGoal("use", 4505, jadefireWell), {item = 12566, itemName = "坚硬的小瓶", oi = 1}),
        collect(4505, 12567, "装满的小瓶", 1, 1, jadefireWell)),
    step("血毒岗哨归还样本并接猫笼", turnin(4505, winna), accept(4506, winna)),
    when(step("在碧火月亮井放出小猫",
        travel("goto", "碧火月亮井", jadefireWell, {note = "到井边用温娜给的小猫笼。"}),
        optional(fields(questGoal("use", 4506, jadefireWell), {item = 12565, itemName = "温娜的猫笼", oi = 1}))),
        onQuest(4506), ready(4506, true), {k = "has", item = 12565}),
    step("带猫回血毒岗哨",
        fields(questGoal("complete", 4506, winna), {note = "在碧火月亮井用猫笼，等到小猫变形后带回岗哨。在温娜旁与小猫互动。"}),
        turnin(4506, winna)),
    step("碎痕谷南边接玛洛恩雕像任务",
        accept(86612, object(661778, "玛洛恩雕像", zone.felwood, 42, 47.3))),
    step("进碎痕谷验证腐化",
        kill(5156, 9878, "熵能之兽", 2, 1, point(zone.felwood, 41.73, 40.15)),
        kill(5156, 9879, "熵能恐魔", 2, 2, point(zone.felwood, 41.73, 40.15)),
        fields(questGoal("complete", 5156, point(zone.felwood, 42.2, 40.3)),
            {note = "走到谷里的三个水坑，直到日志的探索目标完成。"})),
    step("北边铁木森林收血琥珀",
        collect(4102, 11503, "血琥珀", 15, 1, point(zone.felwood, 57.23, 21.94), "打铁木森林的枯木元素。"),
        optional(collect(86577, 277958, "腐烂的熊器官", 8, 1, point(zone.felwood, 53.45, 28.06))),
        optional(collect(86577, 277959, "腐烂的狼器官", 10, 2, point(zone.felwood, 53.81, 27.74)))),
    step("到岗哨交雕像任务", turnin(86612, winna)),
    along("timbermaw", when(step("南部死木村找洛尔",
        optional(collect(6162, 15879, "洛尔的爪子", 1, 1, npc(9464, "洛尔", zone.felwood, 48.2, 94.3)))),
        onQuest(6162))),
    handInAlong("timbermaw", 6162, dreka, "已拾到爪子时回费伍德中段的血毒岗哨交德雷卡苏。"),
    handInAlong("timbermaw", 86577, kelek),
    when(step("南部翡翠圣地交阶段任务",
        turnin(5156, taronn), turnin(5157, greta), turnin(4102, maybess),
        optional(accept(91952, greta))), {k = "level", op = "<", n = 56}),
    fields(step("在隧道南口找纳菲恩", turnin(8462, nafien), accept(8461, nafien)), {label = "timbermaw"}),
    step("清北边死木村的三类熊怪",
        kill(8461, 7156, "死木巢穴守卫", 6, 1, northDeadwood),
        kill(8461, 7157, "死木复仇者", 6, 2, northDeadwood),
        kill(8461, 7158, "死木萨满祭司", 6, 3, northDeadwood),
        optional(accept(8470, {item = 20741, itemName = "死木仪祭图腾"}, "拾到再右键接任务。"))),
    step("回纳菲恩交任务", turnin(8461, nafien), accept(8465, nafien)),
    when(step("羽毛也可以在北口交",
        fields(turnin(8467, nafien, "每五支交一次，达到冷淡即可。"), {direct = true, minLevel = 45})),
        handed(8461), feather, belowCold, noEverlook),
    when(step("木喉至少冷淡才过隧道",
        fields({t = "rep", faction = 576, factionName = "木喉要塞", standing = 3,
            note = "继续打北边死木熊怪。达到冷淡便能安全过洞。"}, northDeadwood)), noEverlook),
    along("everlook", when(step("木喉中立时在洞里交图腾",
        optional(turnin(8470, npc(11558, "克尔达", zone.felwood, 65.5, 3.52)))), onQuest(8470),
        {k = "rep", faction = 576, standing = 4})),
    along("everlook", when(step("已有生命之种时走月光林地支路",
        optional(turnin(7066, npc(11832, "守护者雷姆洛斯", zone.moonglade, 36.1, 41.8),
            "木喉隧道里走月光林地分岔。交完回隧道再去冬泉谷。"))), onQuest(7066), cold)),
    along("everlook", when(step("木喉出口的冬泉熊怪备选",
        optional(accept(8464, salfa)), optional(accept(5082, donova, "需要经验时在出口东南的营地顺路接。"))),
        below56)),
    when(fields(step("穿木喉隧道到冬泉谷", travel("goto", "冬泉谷隧道出口", point(zone.winterspring, 27.75, 34.53),
        {note = "洞内避免攻击木喉熊怪。"})), {label = "winterspring-entry"}), cold, noEverlook),
    when(step("冬泉谷隧道出口找萨尔法", turnin(8465, salfa)), onQuest(8465), cold),
}, beforeWinter, noWinterPotionYet, noMailYet, mailPending)

append({
    step("西侧冬泉熊怪",
        kill(5082, 7442, "冬泉探路者", 8, 1, point(zone.winterspring, 33.36, 37.72)),
        kill(5082, 7440, "冬泉巢穴守卫", 8, 2, point(zone.winterspring, 30.5, 36.92)),
        kill(5082, 7441, "冬泉图腾师", 8, 3, point(zone.winterspring, 33.03, 36.83)),
        optional(accept(5083, {item = 12771, itemName = "空的火酒瓶"}, "拾到空瓶再右键接。")),
        turnin(5082, donova), optional(turnin(5083, donova))),
    step("西边交林克的信", turnin(3908, donova)),
    fields(step("开永望镇航点", travel("getfp", "永望镇", inEverlook, {node = 53, area = 2255})), {label = "everlook"}),
}, beforeMail, noMailYet, mailPending)

local evie = npc(11188, "埃文·维布鲁", zone.winterspring, 60.8, 37.8)
local umi = npc(10305, "乌米", zone.winterspring, 60.88, 37.69)
local vizzie = npc(11118, "旅店老板维兹奇", zone.winterspring, 61.31, 38.89)
local felnok = npc(10468, "菲诺克", zone.winterspring, 61.57, 38.56)
local gregor = npc(10431, "格雷戈·格雷斯通", zone.winterspring, 61.31, 38.91)
local chimaeras = point(zone.winterspring, 61.19, 41.7)
local owls = point(zone.winterspring, 64.3, 37.7)
local yetis = point(zone.winterspring, 64.05, 39.83)
local bluebell = npc(260626, "Bluebell", zone.hyjal, 54.97, 82.78)
local fayran = npc(41861, "Fayran Elthas", zone.hyjal, 68.7, 44.1)
local sebelia = npc(243815, "Sebelia", zone.hyjal, 70.87, 51.55)
local noFoothills = {k = "taxi", name = "Tainted Foothills", node = 3242, neg = true}
local noSummit = {k = "taxi", name = "Eternal Peak", node = 559, neg = true}
local outsideHyjal = {k = "zone", name = "Mount Hyjal", area = 616, neg = true}
local noPotion = {k = "has", item = 281234, neg = true}
local noShroud = {k = "buff", spell = 1310655, neg = true}
local canyon = point(zone.winterspring, 50.5, 82.8)

local function shroudMaterials(id)
    return when(step("收齐隐遁药水材料",
        collect(id, 281241, "冰风奇美拉的皮毛", 5, 1, chimaeras, "在永望镇南边打冰风奇美拉。"),
        collect(id, 281242, "冬泉巨枭的羽毛", 5, 2, owls, "在永望镇附近找冬泉巨枭。")), onQuest(id))
end

-- 3. Winterspring preparation and Hyjal delivery chain.
append({
    when(step("阶段三 · 冬泉谷补经验",
        accept(3783, umi, "可先做永望镇周边的雪人任务。"),
        optional(turnin(4808, felnok)), optional(accept(4809, felnok))),
        below56, notOnQuest(92859, 98462), noWinterPotionYet),
    when(step("打冰蓟雪人取毛皮", collect(3783, 12366, "厚雪人毛皮", 10, 1, yetis), turnin(3783, umi)),
        onQuest(3783)),
    when(step("东边冬泉熊怪",
        kill(8464, 7439, "冬泉萨满祭司", 8, 1, point(zone.winterspring, 67.1, 35.4)),
        kill(8464, 7440, "冬泉巢穴守卫", 8, 2, point(zone.winterspring, 67.1, 35.4)),
        kill(8464, 7438, "冬泉巨熊怪", 8, 3, point(zone.winterspring, 67.1, 35.4)),
        turnin(8464, salfa)), onQuest(8464), below56),
    along("level-56", when(step("北边枭兽补经验",
        optional(kill(4521, 7451, "狂怒的枭兽", 15, 1, point(zone.winterspring, 58.02, 31.66))),
        optional(kill(4521, 7450, "蓬乱的枭兽", 15, 2, point(zone.winterspring, 54.92, 37.68)))),
        onQuest(4521), below56)),
    step("到 55 级准备隐遁药水",
        fields({t = "level", level = 55, note = "还差经验时，可交附近任务或打冰蓟雪人。"}, yetis)),
    step("永望镇接第一次药水任务",
        accept(92859, evie, "两人分别接取 Shroud of the Winter Wilds。")),
    shroudMaterials(92859),
    when(step("交材料领冬泉隐遁药水", turnin(92859, evie)), onQuest(92859)),
}, beforeMail, noMailYet, mailPending, outsideHyjal, noFoothills, noSummit)

append({
    when(step("未到 56 继续永望镇任务",
        accept(977, umi, "打冰蓟雌雪人或雄雪人，各拿两个角。"),
        optional(accept(4809, felnok, "已有引导可顺路接。"))), below56),
    when(step("完成雪怪角并回永望镇",
        collect(977, 12367, "完美的雪人角", 2, 1, point(zone.winterspring, 70.51, 37.62)), turnin(977, umi)),
        onQuest(977)),
    when(step("奇美拉角任务顺路交",
        collect(4809, 12444, "完整的冰风奇美拉角", 8, 1, chimaeras), turnin(4809, felnok)),
        onQuest(4809), below56),
    fields(step("海加尔邮差任务需要 56 级",
        fields({t = "level", level = 56, note = "还差经验时，可交做完的任务或打镇东南的冰蓟雪人。"}, yetis),
        optional(accept(84146, npc(228216, "娜米", zone.winterspring, 61.3, 36.9), "以后路过燃烧平原可做。"))),
        {label = "level-56"}),
}, beforeMail, noMailYet, mailPending)

append({
    when(step("缺药时请埃文补领",
        accept(98462, evie, "首次药水已领过，包里没有余药且身上没有隐遁效果时接同名补领任务。")),
        handed(92859), noPotion, noShroud),
    shroudMaterials(98462),
    when(step("交补领材料", turnin(98462, evie)), onQuest(98462)),
    step("暗语峡谷入口使用隐遁药水",
        travel("goto", "暗语峡谷入口", canyon,
            {note = "在安全处使用冬泉隐遁药水。缺药且隐遁已消失时，先回永望镇找埃文·维布鲁补领。猎人先收宠或设被动。"}),
        optional(fields({t = "buff", spell = 1310655, spellName = "冬泉隐遁"}, canyon))),
    step("沿暗语峡谷同行进海加尔",
        travel("enter", "海加尔山", point(zone.hyjal, 85.5, 73.2),
            {area = 616, note = "缺药且隐遁已消失时，先回永望镇的埃文·维布鲁补领。沿途等精英巡逻走开再过。"})),
}, atLeast(56), beforeMail, noMailYet, mailPending, outsideHyjal, noFoothills, noSummit)

append({
    step("开腐化山麓航点",
        travel("getfp", "腐化山麓", bluebell, {node = 3242, area = 16853, note = "在山麓找 Bluebell。"}),
        optional(accept(96830, npc(266802, "Thark Gorax", zone.hyjal, 79.98, 70.73),
            "沿入口过去可接部落引导，之后顺路向西北交。"))),
    step("开永恒峰航点",
        travel("getfp", "永恒峰", fayran, {node = 559, area = 16849, note = "找 Fayran Elthas，回永望镇的航线走山麓。"})),
}, atLeast(56), beforeMail, noMailYet, mailPending)

append({
    step("山顶营地接第一封邮件", accept(93197, sebelia, "找塞贝莉娅（Sebelia）。两人分别接任务。")),
    when(step("飞回永望镇交信", travel("fly", "永望镇", inEverlook, {node = 53, area = 2255}),
        turnin(93197, vizzie), optional(accept(6029, gregor)), optional(accept(6030, gregor))),
        onQuest(93197)),
    step("在永望镇接找回邮件", accept(93406, vizzie)),
    when(step("两人各找回四件邮件",
        collect(93406, 258323, "丢失的信件", 4, 1, point(zone.winterspring, 66, 41),
            "镇东南的冰蓟雪人会掉落，任务文本也指向镇北山地。按各自计数拾取。")), onQuest(93406)),
    step("回旅店交邮件并接回邮", turnin(93406, vizzie), accept(93269, vizzie)),
    when(step("飞回海加尔交最后一封信",
        travel("fly", "永恒峰", fayran, {node = 559, area = 16849}),
        turnin(93269, sebelia, "各自交给塞贝莉娅，领取 18 格海加尔邮政背包和移速饰品。")), onQuest(93269)),
}, atLeast(56), mailPending)

