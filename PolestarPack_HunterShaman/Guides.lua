local addon = ...
local pack = "hunter-shaman-hyjal"
local title = "猎萨双人 · 上海加尔"
if not Polestar.RegisterPack({
    addon = addon, id = pack, title = title, author = "Codex",
    version = "0.1.0", format = 11, license = "Private use",
    source = "WoW Forever and Polestar 0.4.1. See README.txt.",
}) then return end

local zone = {
    azshara = 1447, alterac = 1416, western = 1422, tirisfal = 1420,
    swamp = 1435, hinterlands = 1425, feralas = 1444, tanaris = 1446,
    barrens = 1413, crater = 1449, felwood = 1448, moonglade = 1450,
    winterspring = 1452, hyjal = 2482, orgrimmar = 1454, thunderBluff = 1456,
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
    [1446] = {"预言者迦玛兰", 38}, [4787] = {"远古之卵", 40},
    [3528] = {"神灵哈卡", 40, {4787}}, [3373] = {"伊兰尼库斯精华", 48},
    [3380] = {"沉没的神庙", 46}, [3444] = {"石环", 46, {3380}},
    [3446] = {"深入神庙", 46, {3444}}, [3447] = {"雕像群的秘密", 46, {3444}},
    [4146] = {"除草器的燃料", 47}, [5096] = {"误导血色十字军", 50},
    [92346] = {"Beneath Nordrassil", 45}, [92069] = {"Claws That Rend, Tusks That Gore", 45},
    [4284] = {"能量水晶", 47}, [3882] = {"挖骨头", 49}, [3883] = {"异型的生态", 48},
    [3881] = {"抢救物资", 48}, [4145] = {"拉瑞安和穆尔金", 47},
    [4501] = {"当心翼手龙", 49}, [4503] = {"希兹尔的飞行器", 49},
    [4243] = {"找回A-Me 01", 48}, [3884] = {"威利德的日记", 48},
    [87494] = {"Microcrystal Contamination"}, [4290] = {"拉克维的食物", 48},
    [87492] = {"Uncanny Crystal", 50}, [4289] = {"安戈洛的猩猩", 47},
    [4291] = {"拉克维的气味", 48, {4290}}, [4147] = {"玛尔冯的车间", 47, {4145}},
    [3844] = {"无人知晓的秘密", 47}, [3845] = {"无人知晓的秘密", 47, {3844}},
    [3908] = {"无人知晓的秘密", 47, {3845}},
    [4285] = {"北部水晶塔", 47, {4284}}, [4287] = {"东部水晶塔", 47, {4284}},
    [4288] = {"西部水晶塔", 47, {4284}}, [4321] = {"分析水晶塔", 47, {4285, 4287, 4288}},
    [8460] = {"木喉熊怪盟友", 45}, [8462] = {"与纳菲恩交谈", 45, {8460}},
    [8461] = {"北方的死木熊怪", 45}, [8465] = {"与萨尔法交谈", 45, {8461}},
    [8466] = {"给格拉兹的羽毛", 45, {8460}}, [8467] = {"给纳菲恩的羽毛", 45, {8461}},
    [4102] = {"净化费伍德", 48}, [5155] = {"加德纳尔的势力", 48},
    [5156] = {"验证腐蚀", 48}, [5157] = {"收集堕落之水", 48, {5155}},
    [86577] = {"A Sampling of Putrescence"}, [4521] = {"冬泉谷的枭兽", 52},
    [7066] = {"生命之种", 45}, [8464] = {"冬泉熊怪的活动", 45},
    [5082] = {"冬泉熊怪的威胁", 52}, [5083] = {"冬泉火酒", 52},
    [3783] = {"雪怪计划！", 52}, [977] = {"雪怪计划！", 52, {3783}},
    [4808] = {"菲诺克", 50}, [4809] = {"冰风奇美拉角", 50, {4808}},
    [92859] = {"Shroud of the Winter Wilds", 55},
    [98462] = {"Shroud of the Winter Wilds", 55, {92859}},
    [84146] = {"Red Bag Blues", 55}, [96830] = {"Farsight Guided", 54},
    [93197] = {"Mending Communications", 56},
    [93406] = {"Unfrozen Deliveries", 56, {93197}}, [93269] = {"Top of the Post", 56, {93406}},
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

local function kill(id, target, name, count, index, where)
    return fields(questGoal("kill", id, where), {npc = target, target = name, count = count, oi = index})
end

local function travel(kind, location, where, extra)
    return fields(fields({t = kind, location = location}, where), extra)
end

local function task(text)
    return {t = "task", text = text}
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
    entry.when = {...}
    return entry
end

local function active(id)
    return {k = "onquest", q = {id}}
end

local function handed(id, negate)
    return {k = "turnedin", q = id, neg = negate}
end

local function atLeast(level)
    return {k = "level", op = ">=", n = level}
end

local function startEither(id, where, closedBy, note)
    return fields(accept(id, where, note), {either = true, closedBy = closedBy})
end

local ids = {"start", "hunter", "shaman", "temple-prep", "temple", "ungoro", "felwood", "winterspring", "hyjal"}
local function guide(number, name, map, minLevel, description, steps)
    local nextId = ids[number + 1]
    Polestar.RegisterGuide({
        id = pack .. "/" .. ids[number], pack = pack,
        title = string.format("猎萨双人 %02d · %s", number, name),
        category = "Miscellaneous", faction = "Horde", classes = {"HUNTER", "SHAMAN"},
        keywords = {"猎萨双人", "海加尔邮政背包", name},
        zone = map, minLevel = minLevel, maxLevel = 60, version = 1, why = description,
        next = nextId and pack .. "/" .. nextId, steps = steps,
    })
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

local function hunterStart()
    return step("接猎人的护符",
        startEither(8151, ormak, {8153, 8231, 8232}, "奥格瑞玛荣誉谷。用离你们近的训练师。"),
        startEither(8151, holt, {8153, 8231, 8232}, "雷霆崖猎人高地。已有下一环就继续。"))
end

local function shamanStart()
    return step("选择一条元素任务",
        startEither(8410, sagorne, {8411, 8412, 8413}, "奥格瑞玛智慧谷。两条元素任务只接一条。"),
        startEither(8410, beram, {8411, 8412, 8413}, "雷霆崖灵魂高地的同一任务。"),
        startEither(8411, bathrah, {8410, 8412, 8413}, "人在东部王国，或训练师没有任务时，直接问塔伦米尔东北的巴斯拉。"))
end

guide(1, "50级出发", zone.orgrimmar, 50, "核对两人的职业任务和神庙进度。", {
    step("核对当前进度", task("两人各看自己的职业任务和飞行点。已在后续的角色从相应章节接续。")),
    only(hunter, hunterStart()),
    only(shaman, shamanStart()),
    when(only(shaman, step("准备四种元素", task("留元素空气、元素火焰、元素之土、元素之水各一个。可以交易，也可在阿拉希打元素怪。"))),
        handed(8410, true), handed(8411, true), handed(8412, true), handed(8413, true),
        {k = "onquest", q = {8412, 8413}, neg = true}),
    step("决定神庙可选任务", task("各看日志里的远古之卵、神灵哈卡、预言者迦玛兰和阿塔哈卡神庙。人在辛特兰且想打迦玛兰时，先去找流放者。")),
})

guide(2, "艾萨拉猎人前置", zone.azshara, 50, "猎人拿鹿角和鳞片。萨满可同行协助。", {
    only(hunter, hunterStart()),
    step("学瓦罗莫克航点", travel("getfp", "瓦罗莫克", kroum, {node = 44})),
    only(hunter, step("从高地找奥汀克",
        turnin(8151, ogtinc, "从埃达拉斯废墟东北侧的高地绕过去。"),
        accept(8153, ogtinc))),
    only(hunter, step("猎人拾取两个鹿角",
        collect(8153, 20017, "完美的鹿角", 2, 1, point(zone.azshara, 52.1, 35.39), "打苔蹄快步者。可从瓦罗莫克东北和东南的丘陵找起。"))),
    only(hunter, step("交鹿角并接鳞片任务", turnin(8153, ogtinc), accept(8231, ogtinc))),
    only(hunter, step("猎人拾取六张鳞片",
        collect(8231, 20087, "碎浪多头怪的鳞片", 6, 1, point(zone.azshara, 84.6, 30.9), "打东北海岸的幼年碎浪多头怪。萨满可给水下呼吸，尽量拉到浅滩。"))),
    only(hunter, step("回奥汀克接神庙任务", turnin(8231, ogtinc), accept(8232, ogtinc))),
    only(shaman, step("协助打艾萨拉的猎物", task("同行时一起打丘陵的鹿和东北海岸的多头怪，等猎人接好进本任务。已经做完或分开行动时直接勾选。"))),
    step("留意黑喉可选前置",
        optional(accept(92069, ogtinc, "后续黑喉要塞的可选任务。留任务栏位置。")),
        optional(accept(92346, jediga, "顺路找瓦罗莫克的杰迪加。后续目前可以先放着。")),
        task("确认两人的下一站。同行去萨满前置的话，从奥格瑞玛城外坐飞艇去幽暗城。")),
})

local function elementTurnin(id)
    return when(only(shaman, step("把四种元素交给巴斯拉", turnin(id, bathrah))), active(id))
end

guide(3, "奥特兰克萨满前置", zone.alterac, 50, "萨满在 50 级即可准备到巫毒羽毛。", {
    when(only(shaman, shamanStart()), handed(8410, true), handed(8411, true), handed(8412, true), handed(8413, true),
        {k = "onquest", q = {8412, 8413}, neg = true}),
    when(only(shaman, step("准备元素材料",
        collect(nil, 7069, "元素空气", 1), collect(nil, 7068, "元素火焰", 1),
        collect(nil, 7067, "元素之土", 1), collect(nil, 7070, "元素之水", 1))),
        handed(8410, true), handed(8411, true), handed(8412, true), handed(8413, true),
        {k = "onquest", q = {8412, 8413}, neg = true}),
    elementTurnin(8410), elementTurnin(8411),
    only(shaman, step("接灵魂图腾", fields(accept(8412, bathrah,
        "从塔伦米尔沿村东的河向北到废墟。有任一元素任务已交即可。"), {pre = {8410, 8411}, closedBy = {8413}}))),
    only(shaman, step("西瘟疫取眼睛和熊爪",
        collect(8412, 20610, "充血的蜘蛛眼", 8, 1, point(zone.western, 31.08, 58.54), "从亡灵壁垒进西瘟疫。找冰风岗西北的毒雾潜伏者。"),
        collect(8412, 20611, "厚实的黑爪", 8, 2, point(zone.western, 31.28, 60.13), "同一片找生病的黑熊。食腐秃鹰也可能出其中一种。"))),
    only(shaman, step("回巴斯拉接神庙任务", turnin(8412, bathrah), accept(8413, bathrah))),
    only(hunter, step("协助打西瘟疫的材料", task("同行时帮打蜘蛛和熊。等萨满接到自己的神庙任务，或约定在斯通纳德集合。"))),
    step("前往斯通纳德",
        optional(accept(5096, npc(10837, "高级执行官德灵顿", zone.tirisfal, 83.05, 68.91), "路过亡灵壁垒可以先接，打塔楼留到以后。")),
        task("约好下一段集合地点。还差少量经验时，优先清附近未做的短任务。")),
})

local function templeReady(role, id)
    return when(only(role, step("检查自己的神庙任务", task("在任务日志确认「" .. quest[id][1]
        .. "」已接取。已经交过可继续，尚未接到就回职业前置章节。"))), handed(id, true))
end

guide(4, "神庙进本前", zone.swamp, 50, "斯通纳德集合，确认两人职业任务，再按已做进度补支线。", {
    templeReady(hunter, 8232), templeReady(shaman, 8413),
    step("决定这次要带的支线", task("先决定本次是否做部落神庙任务、迦玛兰、哈卡和雕像。已经走远的支线可留以后。")),
    step("斯通纳德查已有的部落前置",
        optional(accept(1424, felzerul, "从零做会绕辛特兰，按已走到哪一环决定。")),
        optional(accept(1445, felzerul, "交完 1444 后可接。进本收集 20 个哈卡神像。")),
        task("确认部落任务日志。要补「泪水之池」就在镇东遗迹外做。")),
    when(step("遗迹外收集十个阿塔莱神器",
        collect(1424, 6175, "阿塔莱神器", 10, 1, tears, "在泪水之池的遗迹外收集。要留以后可以右键跳过。"), turnin(1424, felzerul), optional(accept(1429, felzerul))), active(1424)),
    when(step("辛特兰找阿塔莱流放者", turnin(1429, exile), optional(accept(1444, exile)), optional(accept(1446, exile))), active(1429)),
    when(step("辛特兰顺手带预言者任务",
        optional(accept(1446, exile)), task("人在辛特兰才专门找流放者。两人分别接取或决定留待下次。")),
        {k = "zone", name = "The Hinterlands", area = 47}, handed(1446, true)),
    when(step("回斯通纳德接阿塔哈卡神庙", turnin(1444, felzerul), accept(1445, felzerul)), active(1444)),
    when(step("要打哈卡再去热砂港交卵", optional(turnin(4787, yehkinya)), optional(accept(3528, yehkinya)),
        task("要做哈卡时先问队里谁能启动。交远古之卵后，检查背包里的召唤用哈卡之卵。没有这项就继续。")),
        {k = "complete", q = 4787}),
    when(step("已交远古之卵时检查神灵哈卡", optional(accept(3528, yehkinya)),
        task("若去热砂港顺路则接「神灵哈卡」。已走远可留待下次。")), handed(4787), handed(3528, true),
        {k = "onquest", q = {3528}, neg = true}),
    step("确认雕像支线进度", task("已推进石环才补神庙的两项雕像任务。从头做是莫沙彻营地乌尔卡→塔纳利斯玛尔冯→棘齿城取石环→玛尔冯。未准备的支线可留以后。")),
    when(step("在莫沙彻营地顺路接石环引导", optional(accept(3380, npc(8115, "巫医尤克里", zone.feralas, 74.4, 43.5))),
        task("这条需要额外跨区，在菲拉斯或已准备时再做。")), {k = "zone", name = "Feralas", area = 357}, handed(3380, true)),
    when(step("将引导交给塔纳利斯的玛尔冯", optional(turnin(3380, marvon)), optional(accept(3444, marvon)),
        task("有引导并决定做雕像支线时，在碎柱遗迹找玛尔冯。")), active(3380)),
    when(step("取石环再找玛尔冯", collect(3444, 10556, "石环", 1, 1,
        object(149036, "玛尔冯的箱子", zone.barrens, 62.49, 38.53), "到棘齿城工坊开箱。"),
        turnin(3444, marvon)), active(3444)),
    when(step("核对深入神庙和雕像群的秘密", optional(accept(3446, marvon)), optional(accept(3447, marvon)),
        task("想做雕像支线的角色确认想做的任务已接、道具在包里，然后继续。")), handed(3444)),
    step("两人进本前对表", task("两人各报自己的职业任务已在日志或已交。凑齐通常的五人配置，向队伍说明需要六巨魔和摩弗拉斯，再决定哈卡等支线。")),
})

guide(5, "沉没的神庙", zone.swamp, 50, "一趟带齐猎人牙齿和萨满三色羽毛。", {
    step("核对两人可以进本", task("若直接打开本章，先确认双方各自接到职业任务或已完成，队里也同意打两处职业目标。已有队伍进度就继续。")),
    step("悲伤沼泽泪水之池", travel("enter", "沉没的神庙", tears,
        {area = 1417, note = "从斯通纳德向东到遗迹，沿南侧台阶下水，游入通道到传送门。已进本可直接勾选。"})),
    step("清六个上环阳台的巨魔", task("跟队走上环，六个阳台首领都打。先处理会治疗的米杉。")),
    when(only(shaman, step("萨满拾取三色羽毛",
        collect(8413, 20606, "琥珀巫毒羽毛", 2, 1, nil, "加什尔、祖罗尔。"),
        collect(8413, 20607, "蓝色巫毒羽毛", 2, 2, nil, "胡库、米杉。"),
        collect(8413, 20608, "绿色巫毒羽毛", 2, 3, nil, "祖罗、洛若。"))), active(8413)),
    step("打预言者和绿龙", task("打迦玛兰，再打 Weaver 和 Dreamscythe，随后清摩弗拉斯与哈扎斯。")),
    when(only(hunter, step("猎人拾取摩弗拉斯之牙",
        collect(8232, 20019, "摩弗拉斯之牙", 1, 1))), active(8232)),
    when(step("神庙的共同掉落",
        collect(1445, 6181, "哈卡神像", 20, 1, nil, "各自在小怪身上拾取。")), active(1445)),
    when(step("收集除草器的燃料", collect(4146, 11318, "阿塔莱之雾", 5, 1, nil,
        "已有任务的人在本内软泥怪和虫子身上找。")), active(4146)),
    when(step("收好迦玛兰的头颅", collect(1446, 6212, "加玛兰的头颅", 1, 1)), active(1446)),
    when(step("做哈卡仪式并检查任务卵",
        task("商量谁用卵启动。打血卫，用血灭四处火焰，再打哈卡化身。"),
        collect(3528, 10662, "装满的哈卡之卵", 1, 1, nil, "两位持任务者分别确认自己的卵。")), active(3528)),
    when(step("在哈卡祭坛交任务", turnin(3446, object(148836, "哈卡祭坛"), "带好玛尔冯给的石环。")), active(3446)),
    when(step("解雕像并到神像交任务", task("下层雕像顺序为南、北、西南、东南、西北、东北。打出现的守护者。"),
        turnin(3447, object(148838, "哈卡神像"))), active(3447)),
    step("尾王与离本确认",
        optional(accept(3373, {item = 10454, itemName = "伊兰尼库斯的精华"})),
        optional(turnin(3373, object(148512, "精华之泉"), "若击败伊兰尼库斯并接到精华任务，可在本内交。")),
        task("两人离本前各确认职业目标和已接的副本任务。需要的话留在同一个副本进度补目标。")),
    when(step("斯通纳德交哈卡神像", turnin(1445, felzerul)), active(1445)),
    when(step("顺路交迦玛兰", optional(turnin(1446, exile)),
        task("已完成就随东部王国行程交给阿塔莱流放者，或暂留日志。")), {k = "complete", q = 1446}),
    when(only(shaman, step("萨满回巴斯拉交羽毛",
        turnin(8413, bathrah, "现在去交最直接。若两人约好从河林坐船，右键跳过这一步，留待下次到塔伦米尔时交。"))), active(8413)),
    when(only(hunter, step("猎人约定交牙齿的时机",
        task("默认安戈洛清完北上时回奥汀克。若先回奥格瑞玛，也可以先去艾萨拉领奖。"))), active(8232)),
})

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

guide(6, "安戈洛任务圈", zone.crater, 50, "接营地任务，走东西两侧与水晶塔，再北上交猎人职业任务。", {
    step("按当前位置选跨海方式", task("已在奥特兰克北边就走幽暗城→奥格瑞玛飞艇，再飞加基森。还在斯通纳德且决定延后交羽毛，可经河林港口坐船到塔纳利斯热砂港。已有航点可按箭头直达。")),
    when(step("顺路在热砂港交哈卡", optional(turnin(3528, yehkinya)), task("若装满的卵已到手并路过热砂港，可交给叶基亚。")),
        {k = "complete", q = 3528}),
    step("开马绍尔营地航点", travel("getfp", "马绍尔营地", gryfe,
        {node = 79, note = "第一次可从塔纳利斯西南沿道路进入，再往北到营地。"})),
    step("在北营地一趟接齐",
        accept(4284, jd, "科琳在洞里。"), accept(3882, spark), accept(3881, williden), accept(4145, larion),
        optional(turnin(4146, larion)),
        optional(accept(3883, holanyee, "南边虫巢采样，可按队伍战力选择。")),
        accept(4501, object(174682, "当心翼手龙", zone.crater, 43.54, 8.28))),
    step("从营地南下接装备和机器人任务",
        accept(4503, shizzle), optional(accept(4243, npc(9618, "卡尔纳·雷塔维", zone.crater, 46.23, 13.44),
            "东北山洞交第一环就好。后续要秘银外壳。"))),
    step("捡四色能量水晶",
        collect(4284, 11186, "红色能量水晶", 7, 1, crystals),
        collect(4284, 11188, "黄色能量水晶", 7, 2, crystals),
        collect(4284, 11185, "绿色能量水晶", 7, 3, crystals),
        collect(4284, 11184, "蓝色能量水晶", 7, 4, crystals, "多余的各色水晶留作以后造物者平台用。")),
    step("北边沥青池旁打翼手龙和血瓣花",
        kill(4501, 9166, "翼手龙", 10, 1, point(zone.crater, 56.4, 11.4)),
        collect(4503, 11831, "精细的翼手龙鳞片", 8, 2, point(zone.crater, 56.8, 11.7)),
        kill(4145, 6510, "血瓣花掠夺者", 5, 3, point(zone.crater, 54.19, 13.68))),
    step("西南找骨头、双帆龙和营地物资",
        collect(3882, 11114, "恐龙骨头", 8, 1, point(zone.crater, 46.09, 68.5)),
        collect(4503, 11830, "精细的双帆龙鳞片", 8, 1, point(zone.crater, 46.74, 69.94)),
        kill(4145, 6512, "血瓣花捕兽者", 5, 2, point(zone.crater, 36.97, 69.79)),
        collect(3881, 11112, "研究设备", 1, 2, point(zone.crater, 38.5, 66.1))),
    when(step("南边虫巢采样",
        collect(3883, 11131, "虫穴内壁样本", 1, 1, point(zone.crater, 48.7, 85.3), "到虫巢深处用任务瓶采样。拉怪吃力可跳过这条。")), active(3883)),
    when(step("拾到日记时右键接任务", accept(3884, {item = 11116, itemName = "被撕破的日记"})),
        {k = "has", item = 11116}, handed(3884, true)),
    when(step("拾到注能水晶鳞片时右键接任务", accept(87494, {item = 280459, itemName = "注能水晶鳞片"})),
        {k = "has", item = 280459}, handed(87494, true)),
    step("东南营地找托尔瓦",
        accept(4290, torwa), accept(4289, torwa), optional(accept(87492, torwa)), optional(turnin(87494, torwa))),
    step("托尔瓦附近拾肉块和蓝水晶",
        collect(4290, 11504, "蛇颈龙肉块", 1, 1, point(zone.crater, 68.87, 57.64)),
        optional(collect(87492, 280417, "破损的蓝水晶", 1, 1, point(zone.crater, 66.3, 75.2)))),
    step("回托尔瓦接拉克维的气味", turnin(4290, torwa), accept(4291, torwa), optional(turnin(87492, torwa))),
    step("打母暴掠龙", collect(4291, 11509, "暴掠龙信息素", 2, 1, point(zone.crater, 67, 73), "在托尔瓦西北找拉克维的配偶。")),
    step("向托尔瓦交气味任务", turnin(4291, torwa)),
    step("湖边可选木筏任务", optional(accept(3844, wreck)),
        task("经过湖边时可开林克支线，取水下小包再回北营地交。想直走主路线就勾选。")),
    when(step("湖边打开水下小包", turnin(3844, smallPack), accept(3845, smallPack)), active(3844)),
    when(step("从湿漉漉的小包取出三件东西",
        collect(3845, 11104, "大指南针", 1, 1, smallPack),
        collect(3845, 11105, "卷曲的羊皮地图", 1, 2, smallPack),
        collect(3845, 11106, "狮头钥匙", 1, 3, smallPack)), active(3845)),
    step("沿东侧回营地时做剩余血瓣花和物资",
        kill(4145, 6509, "血瓣花鞭笞者", 5, 1, point(zone.crater, 73.19, 46.34)),
        kill(4145, 6511, "血瓣花猛击者", 5, 4, point(zone.crater, 75.1, 48.6)),
        collect(3881, 11113, "食物箱", 1, 1, point(zone.crater, 68.5, 36.5))),
    step("回马绍尔营地交一轮",
        turnin(4503, shizzle), turnin(4145, larion), optional(accept(4147, larion, "后续去棘齿城，可先留日志。")),
        optional(turnin(3845, link)), optional(accept(3908, link, "续篇去冬泉谷。")),
        turnin(3881, williden), optional(turnin(3884, williden)), optional(turnin(3883, holanyee)),
        turnin(3882, spark), turnin(4284, jd)),
    step("找科琳接三座水晶塔", accept(4285, jd), accept(4287, jd), accept(4288, jd)),
    step("点亮北部水晶塔", pylon(4285, 164955, "北部水晶塔", 56.52, 12.54)),
    step("东北台地各拿两张猩猩皮",
        optional(turnin(4243, npc(9623, "A-Me 01", zone.crater, 67.52, 16.75))),
        collect(4289, 11478, "安戈洛猩猩的皮", 2, 1, gorillas),
        collect(4289, 11479, "安戈洛巨猩猩的皮", 2, 2, gorillas),
        collect(4289, 11480, "安戈洛大猩猩的皮", 2, 3, gorillas, "够数就走，最深处的大猩猩可跳过。")),
    step("点亮东部水晶塔", pylon(4287, 164957, "东部水晶塔", 77.16, 49.98)),
    step("顺路回托尔瓦交猩猩皮", turnin(4289, torwa), optional(turnin(87494, torwa))),
    step("西部水晶塔和狂暴翼手龙", pylon(4288, 164956, "西部水晶塔", 23.86, 59.19),
        kill(4501, 9167, "狂暴的翼手龙", 15, 2, point(zone.crater, 21, 58.4))),
    step("回营地交塔和翼手龙", turnin(4501, npc(9997, "斯普拉格·弗劳克", zone.crater, 43.6, 8.65)),
        turnin(4285, jd), turnin(4287, jd), turnin(4288, jd), accept(4321, jd), turnin(4321, jd)),
    when(only(hunter, step("北上前到艾萨拉交绿龙任务", turnin(8232, ogtinc,
        "带着牙齿时顺路飞瓦罗莫克，找奥汀克交。已交可直接转费伍德。"))), {k = "complete", q = 8232}),
})

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

guide(7, "费伍德和木喉隧道", zone.felwood, 50, "沿费伍德北上，做到冷淡便可过隧道。", {
    step("从灰谷进入翡翠圣地", travel("goto", "翡翠圣地", point(zone.felwood, 50.9, 81.6))),
    step("翡翠圣地一起接野外任务",
        accept(5155, greta), accept(5156, taronn), accept(4102, maybess), optional(accept(86577, kelek))),
    step("格拉兹的木喉熊怪任务", accept(8460, grazle, "靠费伍德南边大路。击杀死木熊怪增加木喉声望。")),
    step("清南边三类死木熊怪",
        kill(8460, 7153, "死木战士", 6, 1, southDeadwood),
        kill(8460, 7155, "死木探路者", 6, 2, southDeadwood),
        kill(8460, 7154, "死木园丁", 6, 3, southDeadwood)),
    step("回格拉兹交接", turnin(8460, grazle), accept(8462, grazle)),
    when(step("可用羽毛补冷淡", fields(turnin(8466, grazle, "每五支交一次，交到够过洞即可。"),
        {direct = true, minLevel = 45})), handed(8460), feather, {k = "rep", faction = 576, standing = 3, neg = true}),
    step("加德纳尔外清四类敌人",
        kill(5155, 7125, "加德纳尔猎犬", 4, 1, jaedenar),
        kill(5155, 7113, "加德纳尔守护者", 4, 2, jaedenar),
        kill(5155, 7115, "加德纳尔精兵", 6, 3, jaedenar),
        kill(5155, 7112, "加德纳尔教徒", 6, 4, jaedenar)),
    step("交加德纳尔并续接取水", turnin(5155, greta), accept(5157, greta)),
    step("到腐化月亮井装水", collect(5157, 12907, "腐化的月亮井水", 1, 1, point(zone.felwood, 35.2, 59.8),
        "靠近月亮井使用任务给的空壶。")),
    step("学血毒岗哨航点", travel("getfp", "血毒岗哨", npc(11900, "布拉卡尔", zone.felwood, 34.4, 53.92), {node = 48}),
        optional(accept(4521, npc(10306, "特鲁尔·法贝恩", zone.felwood, 34.68, 52.76), "冬泉谷枭兽，可顺路接。"))),
    step("进碎痕谷验证腐蚀",
        kill(5156, 9878, "熵能之兽", 2, 1, point(zone.felwood, 41.73, 40.15)),
        kill(5156, 9879, "熵能恐魔", 2, 2, point(zone.felwood, 41.73, 40.15)),
        fields(questGoal("complete", 5156, point(zone.felwood, 42.2, 40.3)), {note = "还需进到碎痕谷深处，直到日志的探索目标完成。"})),
    step("北边清野兽和收血琥珀",
        collect(4102, 11503, "血琥珀", 15, 1, point(zone.felwood, 57.23, 21.94), "打铁木森林附近的元素怪。"),
        optional(collect(86577, 277958, "腐烂的熊器官", 8, 1, point(zone.felwood, 53.45, 28.06))),
        optional(collect(86577, 277959, "腐烂的狼器官", 10, 2, point(zone.felwood, 53.81, 27.74)))),
    step("在隧道南口找纳菲恩", turnin(8462, nafien), accept(8461, nafien)),
    step("打北边死木村的三类熊怪",
        kill(8461, 7156, "死木巢穴守卫", 6, 1, northDeadwood),
        kill(8461, 7157, "死木复仇者", 6, 2, northDeadwood),
        kill(8461, 7158, "死木萨满祭司", 6, 3, northDeadwood)),
    step("回纳菲恩交任务", turnin(8461, nafien), accept(8465, nafien)),
    when(step("羽毛还可以在北口交",
        fields(turnin(8467, nafien, "每五支交一次。已经冷淡就可以过洞。"), {direct = true, minLevel = 45})),
        handed(8461), feather, {k = "rep", faction = 576, standing = 3, neg = true}),
    step("两人各自达到木喉冷淡",
        fields({t = "rep", faction = 576, factionName = "木喉要塞", standing = 3}, northDeadwood),
        task("各确认面板至少冷淡再过洞。中立可以以后为了黑喉再补。")),
    step("回费伍德南部交完能交的任务",
        optional(turnin(5156, taronn)), optional(turnin(5157, greta)),
        optional(turnin(4102, maybess)), optional(turnin(86577, kelek)),
        task("还差经验且已做完目标时，可从血毒岗哨返回翡翠圣地交一趟。要先开冬泉谷航点就跳过这次回程。")),
    when(step("持生命之种时走月光林地支路", turnin(7066, npc(11832, "守护者雷姆洛斯", zone.moonglade, 36.1, 41.8),
        "从木喉隧道走月光林地分岔。交完回到隧道，再往冬泉谷。")), active(7066), cold),
    when(step("穿木喉隧道到冬泉谷", travel("goto", "冬泉谷隧道出口", point(zone.winterspring, 27.75, 34.53),
        {note = "洞内不要打木喉熊怪。"})), cold, {k = "taxi", name = "Everlook", node = 53, neg = true}),
    when(step("在冬泉谷出口找萨尔法", turnin(8465, salfa)), active(8465), cold),
    step("开永望镇航点", travel("getfp", "永望镇", inEverlook, {node = 53, area = 2255})),
})

local evie = npc(11188, "埃文·维布鲁", zone.winterspring, 60.8, 37.8)
local umi = npc(10305, "乌米", zone.winterspring, 60.88, 37.69)
local vizzie = npc(11118, "旅店老板维兹奇", zone.winterspring, 61.31, 38.89)
local felnok = npc(10468, "菲诺克", zone.winterspring, 61.57, 38.56)
local chimaeras = point(zone.winterspring, 61.19, 41.7)
local owls = point(zone.winterspring, 64.3, 37.7)
local yetis = point(zone.winterspring, 64.05, 39.83)
local noPotion = {k = "has", item = 281234, neg = true}

local function shroudMaterials(id)
    return when(step("收齐隐遁药水材料",
        collect(id, 281241, "冰风奇美拉的皮毛", 5, 1, chimaeras, "各自打冰风奇美拉，直到日志计满。"),
        collect(id, 281242, "冬泉巨枭的羽毛", 5, 2, owls, "在永望镇附近找冬泉巨枭。")), active(id))
end

guide(8, "冬泉谷和隐遁药水", zone.winterspring, 50, "做永望镇附近的任务，55 级拿进山药水，两人一起补到 56。", {
    step("到永望镇", travel("getfp", "永望镇", inEverlook, {node = 53, area = 2255})),
    when(step("木喉出口旁做熊怪备选", optional(accept(8464, salfa)), optional(accept(5082, donova)),
        task("还需要经验时，可从木喉出口向东做熊怪任务。已有足够经验直接勾掉。")),
        {k = "level", op = "<", n = 56}),
    when(step("西侧冬泉熊怪", kill(5082, 7442, "冬泉探路者", 8, 1, point(zone.winterspring, 33.36, 37.72)),
        kill(5082, 7440, "冬泉巢穴守卫", 8, 2, point(zone.winterspring, 30.5, 36.92)),
        kill(5082, 7441, "冬泉图腾师", 8, 3, point(zone.winterspring, 33.03, 36.83)),
        optional(accept(5083, {item = 12771, itemName = "空的火酒瓶"}, "拾到空瓶才右键接。")),
        turnin(5082, donova), optional(turnin(5083, donova))), active(5082)),
    when(step("东边冬泉熊怪", kill(8464, 7439, "冬泉萨满祭司", 8, 1, point(zone.winterspring, 67.1, 35.4)),
        kill(8464, 7440, "冬泉巢穴守卫", 8, 2, point(zone.winterspring, 67.1, 35.4)),
        kill(8464, 7438, "冬泉巨熊怪", 8, 3, point(zone.winterspring, 67.1, 35.4)), turnin(8464, salfa)), active(8464)),
    when(step("西边交林克的信", turnin(3908, donova)), active(3908)),
    when(step("补等级时接雪怪任务", accept(3783, umi), optional(turnin(4808, felnok)),
        optional(accept(4809, felnok))), {k = "level", op = "<", n = 56}),
    when(step("打冰蓟雪人取毛皮", collect(3783, 12366, "厚雪人毛皮", 10, 1, yetis), turnin(3783, umi)), active(3783)),
    step("到 55 级可以准备进山", {t = "level", level = 55,
        note = "还差经验时先交附近任务，可继续打雪人、冬泉熊怪，或回费伍德交已完成的任务。"}),
    step("永望镇接第一次药水任务",
        accept(92859, evie, "第一次在这里接 Shroud of the Winter Wilds。每人分别做。")),
    shroudMaterials(92859),
    when(step("交材料领冬泉隐遁药水", turnin(92859, evie)), active(92859)),
    when(step("需要补药再问埃文", optional(accept(98462, evie, "只在原药水缺失时做同名补领。")),
        task("各查背包有无冬泉隐遁药水。缺药时在埃文这里补领，再继续。如果海加尔航点已开，可以直接飞。")), handed(92859), noPotion),
    shroudMaterials(98462),
    when(step("交补领材料", turnin(98462, evie)), active(98462)),
    when(step("未到 56 继续永望镇任务",
        optional(accept(977, umi, "打冰蓟雌雪人或雄雪人，各拿两个角。")),
        optional(accept(4809, felnok, "已有前置就顺便接。")),
        task("按两人的差额补经验。只差一点先交已有完成任务，也可做冰蓟雪人或未清的冬泉熊怪。")),
        {k = "level", op = "<", n = 56}),
    when(step("完成雪怪角并回永望镇", collect(977, 12367, "完美的雪人角", 2, 1, point(zone.winterspring, 70.51, 37.62),
        "打较高等级的冰蓟雌雪人或雄雪人。经验够了可留待下次。"), turnin(977, umi)), active(977)),
    when(step("奇美拉角任务顺路交", collect(4809, 12444, "完整的冰风奇美拉角", 8, 1, chimaeras),
        turnin(4809, felnok)), active(4809)),
    step("两人都到 56 再上山", {t = "level", level = 56},
        optional(accept(84146, npc(228216, "娜米", zone.winterspring, 61.3, 36.9), "以后路过燃烧平原再做。实际奖励以任务窗口为准。")),
        task("各确认 56 级、药水、背包空间。还差经验的角色继续补，达到的角色可以一起帮打。")),
})

local bluebell = npc(260626, "Bluebell", zone.hyjal, 54.97, 82.78)
local fayran = npc(41861, "Fayran Elthas", zone.hyjal, 68.7, 44.1)
local sebelia = npc(243815, "Sebelia", zone.hyjal, 70.87, 51.55)
local noFoothills = {k = "taxi", name = "Tainted Foothills", node = 3242, neg = true}
local outsideHyjal = {k = "zone", name = "Mount Hyjal", area = 616, neg = true}

guide(9, "海加尔第一个18格包", zone.hyjal, 56, "经暗语峡谷首次进山，开两处航点，56 级完成全部邮差链。", {
    when(step("邮差链需要 56 级", {t = "level", level = 56, note = "两人均到 56 级才能同时接三段邮件。"}), handed(93269, true)),
    when(step("峡谷入口前检查并喝药",
        travel("goto", "暗语峡谷入口", point(zone.winterspring, 50.5, 82.8), {note = "坐标是南下的路线参考。遇见精英巡逻时等对方走开。"}),
        task("两人在安全的位置各喝冬泉隐遁药水。药水只降低被发现的几率。猎人收宠或设被动。缺药时回第 08 段。")),
        atLeast(56), handed(93269, true), outsideHyjal, noFoothills),
    when(step("沿暗语峡谷同行进海加尔", travel("enter", "海加尔山", point(zone.hyjal, 85.5, 73.2),
        {area = 616, note = "沿峡谷路线走，避开 60 级精英。先过峡谷再到低地开航点。"})),
        atLeast(56), handed(93269, true), outsideHyjal, noFoothills),
    when(step("开第一个中立航点",
        travel("getfp", "腐化山麓", bluebell, {node = 3242, area = 16853, note = "找 Bluebell。两人各自学习。"}),
        optional(accept(96830, npc(266802, "Thark Gorax", zone.hyjal, 79.98, 70.73),
            "海加尔入口的部落引导。可顺路接，之后再往西北交。"))), atLeast(56)),
    when(step("开永恒峰航点", travel("getfp", "永恒峰", fayran, {node = 559, area = 16849, note = "找 Fayran Elthas。两人都学，回永望镇的航线经山麓。"})),
        atLeast(56)),
    when(step("山顶营地接第一封邮件", accept(93197, sebelia,
        "找塞贝莉娅（Sebelia）。任务最低 56，需各自接取。")), atLeast(56)),
    when(step("飞回永望镇交信", travel("fly", "永望镇", inEverlook, {node = 53, area = 2255}), turnin(93197, vizzie)),
        atLeast(56), active(93197)),
    when(step("在永望镇接找回邮件", accept(93406, vizzie)), atLeast(56)),
    when(step("两人各找回四件邮件",
        collect(93406, 258323, "丢失的信件", 4, 1, point(zone.winterspring, 66, 41),
            "镇东南的冰蓟雪人有掉落。任务文本也指向镇北山地，按日志和实际掉落走。")), atLeast(56), active(93406)),
    when(step("回旅店交邮件并接回邮", turnin(93406, vizzie), accept(93269, vizzie)), atLeast(56)),
    when(step("飞回海加尔交最后一封信",
        travel("fly", "永恒峰", fayran, {node = 559, area = 16849}),
        turnin(93269, sebelia, "回到塞贝莉娅，领取海加尔邮政背包和移速饰品。")), atLeast(56), active(93269)),
    when(step("确认各自拿到海加尔邮政背包",
        task("看自己已领取或装备 18 格海加尔邮政背包，也确认队友已交。邮差饰品增加 5% 跑步和游泳速度。"),
        optional(collect(nil, 260307, "海加尔邮政背包", 1))),
        handed(93269)),
})
