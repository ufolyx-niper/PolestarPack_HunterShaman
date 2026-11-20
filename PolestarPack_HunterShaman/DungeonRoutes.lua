local _, route = ...
if not route.steps then return end
local zone = route.zone
local point, npc, object, fields = route.point, route.npc, route.object, route.fields
local accept, turnin, collect, kill = route.accept, route.turnin, route.collect, route.kill
local travel, optional, step = route.travel, route.optional, route.step
local only, when, append = route.only, route.when, route.append
local onQuest, handed, ready, atLeast = route.onQuest, route.handed, route.ready, route.atLeast
local requireQuest = route.requireQuest

-- Forever quest log objectives and NPC records, supplemented by the installed
-- QuestDB and DungeonQuestAtlas. Keep outdoor coordinates off instance goals.
for id, data in pairs({
    [92343] = {"Get to the Roots of It", 45, {92346}},
    [86746] = {"The Legashi Threat", 47},
    [86752] = {"Report to Rageroar", 47, {86746}},
    [86791] = {"Missing Blackmaw Scouts", 47, {86752}},
    [86777] = {"Master Feardred", 47, {86791}},
    [86792] = {"Thinning Their Forces", 47, {86791}},
    [86796] = {"Later, Satyr", 47, {86791}},
    [86797] = {"Return to Rageroar", 47},
    [86798] = {"Timbermaw Reinforcements", 47, {86797}},
    [87346] = {"Chieftain Bloodmaw", 47, {86798}},
    [86814] = {"Blackmaw Counter-Offensive", 47, {87346}},
    [92065] = {"Blackmaw Reclamation", 47, {86814}},
    [92066] = {"The Twin Bears", 47},
    [92070] = {"A Lost Memento", 47},
    [97327] = {"Blackmaw Pouches", 55},
    [97198] = {"Blackmaw Magic", 52},
    [97197] = {"Fragment of the Firelands", 46},
    [95928] = {"Crystalline Elements", 55},
    [97049] = {"Essence of Seeping Slimes", 55},
    [95926] = {"The Dark Crystal", 55},
    [4081] = {"通缉：黑铁矮人", 48},
    [4082] = {"通缉：高阶黑铁军官", 50, {4081}},
    [4122] = {"格拉克·洛克鲁布", 52, {4082}},
    [4121] = {"困境", 52, {4122}},
    [4132] = {"行动：杀死安格弗将军", 52, {4121}},
    [4061] = {"机器的崛起", 52},
    [4062] = {"机器的崛起", 52, {4061}},
    [4063] = {"机器的崛起", 52, {4062}},
    [4133] = {"薇薇安·拉格雷", 50},
    [4134] = {"遗失的雷酒秘方", 50},
    [4136] = {"雷布里·斯库比格特", 48},
    [4123] = {"山脉之心", 50},
    [4022] = {"烈焰试炼", 52, {3481}},
    [4023] = {"烈焰试炼", 52},
    [4024] = {"烈焰试炼", 52},
    [3906] = {"不和谐的烈焰", 48},
    [3907] = {"不和谐的火焰", 48, {3906}},
    [3981] = {"指挥官哥沙克", 48, {3906}},
    [3982] = {"出了什么事？", 48, {3981}},
    [4001] = {"出了什么事？", 48, {3982}},
    [4002] = {"东部王国", 48, {4001}},
    [4003] = {"拯救公主", 48, {4002}},
    [7201] = {"最后的元素", 48, {3906}},
    [3801] = {"黑铁的遗产", 48},
    [3802] = {"黑铁的遗产", 48, {3801}},
    [4201] = {"爱情药水", 50},
}) do
    route.quest[id] = data
end

local function objective(id, instruction, where)
    return fields(route.questGoal("complete", id, where), {note = instruction})
end

local function carrying(item, count, negate)
    return {k = "has", item = item, n = count, neg = negate}
end

local function entrance(name, position, area, instruction)
    return travel("enter", name, position, {area = area, note = instruction})
end

local function bossLoot(id, item, name, count, index, target, targetName, instruction)
    return collect(id, item, name, count, index, npc(target, targetName), instruction)
end

local function handInIfReady(title, id, giver, instruction)
    return when(step(title, turnin(id, giver, instruction)), ready(id))
end

local ekkal = npc(235903, "Ekkal", zone.azshara, 41.9, 38.9)
local ogtinc = npc(8405, "奥汀克", zone.azshara, 42.3, 42.6)
local jediga = npc(8587, "杰迪加", zone.azshara, 22.4, 51.5)
local nara = npc(5770, "纳拉·蛮鬃", zone.thunderBluff, 75.7, 31.2)
local hamuul = npc(5769, "哈缪尔·符文图腾", zone.thunderBluff, 78.08, 29.02)
local ghede = npc(9076, "盖德", zone.thunderBluff, 77.13, 22.4)
local bashana = npc(9087, "巴珊娜·符文图腾", zone.thunderBluff, 71.09, 33.82)
local rageroar = npc(236573, "Gatekeeper Rageroar", zone.azshara, 42.4, 20.2)
local nok = npc(249853, "Lorekeeper Nok", zone.azshara, 41.4, 20)
local korsa = npc(236770, "Korsa", zone.azshara, 63, 23.3)
local graal = npc(237007, "Graal", zone.azshara, 65.9, 14.4)
local gorn = npc(11555, "独眼高恩", zone.felwood, 65.2, 2.7)
local muln = npc(259118, "Muln Earthfury", zone.mulgore, 33.3, 22.5)
local alaana = npc(259119, "Alaana Stormwalker", zone.mulgore, 33.3, 22.5)
local mayena = npc(263445, "Mayena Earthseeker", zone.mulgore, 34.9, 22.1)
local nuara = npc(272633, "Nuara Tremorhoof", zone.mulgore, 33.4, 22.6)
local timbermaw = {k = "rep", faction = 576, standing = 4}

function route.addBlackmaw()
    append({
        route.watchAlong(route.along("blackmaw-satyrs", step("再到艾萨拉时可顺路装满堕落之水",
            optional(route.coastVials()))), function(C) return C.IsOnQuest(3568) and not C.IsQuestReadyForTurnIn(3568) end),
        when(only(route.hunter, step("把神庙牙齿带给奥汀克", turnin(8232, ogtinc))), ready(8232)),
        step("艾萨拉领取根须与首领任务", optional(turnin(91734, jediga)), optional(turnin(3564, jediga)),
            accept(92346, jediga), accept(92069, ogtinc)),
        step("埃达拉斯废墟找 Ekkal", accept(86746, ekkal),
            optional(accept(97327, ekkal, "如果本人能领到袋子任务，就顺手带进本。"))),
        fields(when(step("清理东北的雷加什萨特营地",
            kill(86746, 6200, "Legashi Satyr", 5, 1, point(zone.azshara, 52, 18.6)),
            kill(86746, 6201, "Legashi Rogue", 5, 2, point(zone.azshara, 52, 20.1)),
            kill(86746, 6202, "Legashi Hellcaller", 5, 3, point(zone.azshara, 50.7, 18.5))), onQuest(86746)),
            {label = "blackmaw-satyrs"}),
        step("Ekkal 指引你向北报到", turnin(86746, ekkal), accept(86752, ekkal)),
        when(step("先把木喉熊怪声望做到中立", {
            t = "rep", faction = 576, factionName = "木喉要塞", standing = 4,
            map = zone.felwood, x = 62.8, y = 7.7,
            note = "去费伍德北部死木村清普通死木熊怪。北洞口纳菲恩可交每组 5 根死木羽毛。具名酋长等接了 87346 再杀。",
        }), handed(86798, true)),
        step("Ursolan 向守门者报到", turnin(86752, rageroar), accept(86791, rageroar),
            optional(accept(92066, nok, "木喉中立后找 Lorekeeper Nok 查双熊任务，出现时顺手接。"))),
        step("找到东部营地外的 Korsa", turnin(86791, korsa), accept(86777, korsa), accept(86792, korsa)),
        when(step("击败 Feardred 和要塞内的萨特",
            collect(86777, 235334, "Feardred's Amulet", 1, 1,
                npc(6652, "Master Feardred", zone.azshara, 61.5, 24.6)),
            kill(86792, 236874, "Legashi Hellraiser", 6, 1, point(zone.azshara, 65.7, 21.1)),
            kill(86792, 236867, "Legashi Soulstealer", 4, 2, point(zone.azshara, 65.5, 16.4)),
            kill(86792, 236876, "Legashi Blackguard", 2, 3, point(zone.azshara, 65.6, 19.6))),
            onQuest(86777, 86792)),
        step("顺路营救囚笼里的 Graal",
            accept(86796, graal, "附近先清怪。两人都接到任务后再护送。"),
            objective(86796, "护送 Graal 脱离要塞范围。", graal)),
        step("Korsa 回报斥候进展", turnin(86777, korsa), turnin(86792, korsa),
            turnin(86796, korsa), fields(accept(86797, korsa), {pre = {86777, 86792, 86796}})),
        step("守门者发出求援任务", turnin(86797, rageroar), accept(86798, rageroar)),
        step("把求援送到费伍德北口", turnin(86798, gorn), accept(87346, gorn,
            "两人先各自接酋长任务，再南下死木村。")),
        when(step("死木村击败酋长并取钉锤", collect(87346, 236631, "Bloodmaw's Basher", 1, 1,
            npc(9462, "Chieftain Bloodmaw", zone.felwood, 62.8, 7.7))), onQuest(87346)),
        step("回独眼高恩取战旗", turnin(87346, gorn), accept(86814, gorn)),
        when(step("回艾萨拉发起反攻",
            objective(86814, "到雷加什要塞的恶魔召唤法阵插 Timbermaw War Banner，再击杀 Prince Halanox。两人检查任务信用后才离开。",
                point(zone.azshara, 66.8, 19))), onQuest(86814)),
        step("向守门者复命后接尾王", turnin(86814, rageroar), accept(92065, rageroar),
            optional(accept(92066, nok, "先前未领到时，离开 Ursolan 前可再问一次。"))),
        route.handInAlong("blackmaw-mulgore", 3761, ghede),
        route.along("blackmaw-mulgore", step("雷霆崖顺手接交晨光麦研究",
            optional(accept(3782, hamuul)), optional(turnin(3782, bashana)))),
        step("雷霆崖换取采集根须任务", turnin(92346, nara), accept(92343, nara)),
        handInIfReady("天望高地交已有的十枚魔法微粒", 98477, nuara,
            "后续 98476 是额外交付，经过时材料足再考虑。"),
        fields(step("莫高雷天望高地预领三个副本任务",
            accept(97198, muln), accept(97197, alaana), accept(95928, mayena)), {label = "blackmaw-mulgore"}),
        route.along("blackmaw-exit", when(step("持有双熊任务时取双熊图腾",
            optional(collect(92066, 249694, "Totem of Ursoc", 1, 1)),
            optional(collect(92066, 249693, "Totem of Ursol", 1, 2))), onQuest(92066))),
        route.watchAlong(route.along("blackmaw-exit", when(step("持有袋子任务时沿途拾取",
            optional(collect(97327, 273050, "Blackmaw Pouch", 5, 1, nil, "途中查看熊怪和首领掉落。"))),
            onQuest(97327))), function(C) return C.GetInstanceMapID() == 2974 end),
        when(step("黑喉要塞 · 首次进本",
            entrance("Blackmaw Hold", point(zone.azshara, 34.9, 23.8), 16554,
                "从艾萨拉北部熊怪石门进洞，穿过隧道尽头的传送门。两人各核对尾王、大熊和野猪、根帽、长老萨满四项。若领到了双熊或袋子，再做对应支线。持有 98477 可先用吸引器。"),
            collect(92343, 250773, "Nordrassil Root Cap", 10, 1, nil, "进本后沿地面采集根帽。")),
            timbermaw, requireQuest(92065), requireQuest(92069), requireQuest(92343),
            requireQuest(97198), ready(92065, true), handed(92065, true)),
        when(step("击败大熊与野猪领取两份战利品",
            bossLoot(92069, 249697, "Claws of the Great Bear", 1, 1, 247195, "Withermaw"),
            bossLoot(92069, 249696, "Tusks of the Unbroken", 1, 2, 247198, "Bonesnout the Unbroken")),
            onQuest(92069)),
        when(step("长老萨满的黑喉仪祭图腾",
            bossLoot(97198, 276893, "Blackmaw Ritual Totem", 1, 1, 247209, "Elder Shaman Bloodmane")),
            onQuest(97198), handed(92065, true)),
        when(step("捡到饰链时接遗失纪念物", accept(92070,
            {item = 249698, itemName = "Feathered Charm Necklace"},
            "在背包使用饰链接任务，出本交给 Unele。")), carrying(249698)),
        when(step("击败尾王 Varrox Bleakhoof",
            bossLoot(92065, 249692, "Head of Varrox Bleakhoof", 1, 1, 247234, "Varrox Bleakhoof",
                "每人拾首级。若遇到可互动的鞭笞者且拾到 Fel-Tainted Flesh，可以试 92067。")),
            onQuest(92065)),
        fields(handInIfReady("出本向守门者交尾王首级", 92065, rageroar), {label = "blackmaw-exit"}),
        handInIfReady("在 Ursolan 归还双熊图腾", 92066, nok),
        handInIfReady("向 Unele 归还饰链", 92070, npc(249855, "Unele", zone.azshara, 43.4, 17.4)),
        handInIfReady("在艾萨拉交袋子", 97327, ekkal),
        handInIfReady("在奥汀克处交大熊爪和獠牙", 92069, ogtinc),
        handInIfReady("回雷霆崖交诺达希尔根帽", 92343, nara),
        handInIfReady("回天望高地交黑喉图腾", 97198, muln,
            "此前已交过 98477 的人，顺路向 Nuara 查 98476 能否再交。"),
        handInIfReady("天望高地交黑喉途中收齐的微粒", 98477, nuara),
    }, atLeast(55))
end

local badlands = zone.badlands
local thunderheart = npc(9084, "桑德哈特", badlands, 3.3, 48.2)
local vivian = npc(9078, "暗影法师薇薇安·拉格雷", badlands, 3, 47.7)
local theodora = npc(9079, "Hierophant Theodora Mulvadania", badlands, 3.1, 47.9)
local goretooth = npc(9077, "督军高图斯", badlands, 5.8, 47.5)
local galamav = npc(9081, "神射手贾拉玛弗", badlands, 6, 47.7)
local lexlort = npc(9080, "军官莱克斯洛特", badlands, 5.9, 47.6)
local lotwil = npc(2921, "鲁特维尔·沃拉图斯", badlands, 25.9, 45.3)
local wanted = object(164867, "WANTED", badlands, 3.7, 47.4)
local wantedSenior = object(164868, "KILL ON SIGHT", badlands, 3.9, 46.7)
local yuka = npc(9544, "尤卡·斯库比格特", zone.burning, 65.9, 22.1)
local maxwort = npc(9536, "麦克斯沃特·尤博格林", zone.burning, 65.2, 23.9)
local cyrus = npc(9459, "塞勒斯·萨雷芬图斯", zone.burning, 94.9, 31.6)
local franclorn = npc(8888, "弗兰克罗恩·铸铁", zone.burning, 28.9, 28.9)
local gorshak = npc(9020, "指挥官哥沙克")
local kharan = npc(9021, "卡兰·巨锤")
local thrall = npc(4949, "萨尔", zone.orgrimmar, 31.7, 37.8)

function route.addBRDPrep()
    append({
        handInIfReady("卡加斯向薇薇安交幽暗城转介", 4133, vivian),
        step("提前在卡加斯接黑石深渊任务",
            accept(3906, thunderheart, "首趟进门前通常同时带十条左右的深渊任务。先交已完成任务，并留约两格给狱内接取。"),
            accept(4134, vivian),
            accept(4061, theodora), accept(4081, wanted)),
        when(step("已完成第一张通缉再取高阶通缉",
            accept(4082, wantedSenior)), handed(4081)),
        handInIfReady("卡加斯交已完成的高阶通缉", 4082, goretooth),
        when(step("高阶通缉之后取格拉克线索",
            accept(4122, lexlort)), handed(4082)),
    }, atLeast(55))
end

function route.addBRD()
    append({
        step("烈焰峰接酒吧和宝库任务", accept(4136, yuka), accept(4123, maxwort)),
        when(step("燃烧平原打战争傀儡收碎片", collect(4061, 11266, "破碎的元素碎片", 10, 1,
            point(zone.burning, 65.4, 40.6), "击杀战争傀儡、作战傀儡和重型作战傀儡。")), onQuest(4061)),
        when(step("已经有格拉克任务时完成野外押送",
            turnin(4122, npc(9520, "格拉克·洛克鲁布", zone.burning, 40.2, 34.2)),
            accept(4121, npc(9520, "格拉克·洛克鲁布", zone.burning, 40.2, 34.2)),
            objective(4121, "在战斗中压低他的生命后使用瑟银镣铐，跟完押送。", point(zone.burning, 40.2, 34.2))),
            requireQuest(4122)),
        when(step("有灼热峡谷前置时接第一种烈焰试炼", accept(4022, cyrus)),
            handed(3481), handed(4023, true), handed(4024, true), route.notOnQuest(4023, 4024)),
        when(step("带着蜕皮完成塞勒斯的对话",
            objective(4022, "带着黑龙军团的蜕皮，在东北洞穴跟塞勒斯完成对话。", cyrus),
            turnin(4022, cyrus)), onQuest(4022)),
        when(step("没有灼热峡谷前置时接另一条烈焰试炼", accept(4023, cyrus)),
            handed(3481, true), handed(4022, true), handed(4024, true), route.notOnQuest(4022, 4024)),
        when(step("向塞勒斯证明实力",
            collect(4023, 10575, "黑龙军团的蜕皮", 1, 1, cyrus,
                "与塞勒斯对话；若没有蜕皮，选择承认无凭证，准备应付他召出的精英并拾取。"),
            turnin(4023, cyrus)), onQuest(4023)),
        step("塞勒斯交付捕获贝尔加精华的道具",
            fields(accept(4024, cyrus, "保留改变过的黑龙军团蜕皮，进本后对贝尔加尸体使用。"), {pre = {4022, 4023}})),
        when(step("先击杀副本传送门外的派隆", kill(3906, 9026, "征服者派隆", 1, 1,
            npc(9026, "征服者派隆", zone.searing, 25.4, 80.1),
            "从黑石山内的铁链下到采石场。打完派隆立即回卡加斯交 3906。")), onQuest(3906)),
        step("派隆之后回卡加斯换取三项任务", turnin(3906, thunderheart),
            accept(3907, thunderheart), accept(3981, galamav), accept(7201, vivian)),
        step("卡加斯交机械样本，把报告送给鲁特维尔",
            turnin(4061, theodora), accept(4062, theodora),
            turnin(4062, lotwil), accept(4063, lotwil)),
        handInIfReady("交格拉克押送任务", 4121, lexlort),
        when(step("已护送格拉克时接安格弗将军", accept(4132, goretooth)), handed(4121)),
        when(step("接暗炉钥匙的两环", accept(3801, franclorn,
            "弗兰克罗恩在黑石山中央石棺旁。只有灵魂状态能看到他，先与队伍约好。"),
            turnin(3801, franclorn), accept(3802, franclorn)), handed(3802, true)),
        when(step("黑石深渊 · 首次进本",
            entrance("Blackrock Depths", point(zone.searing, 34.9, 83.9), 1584,
                "从黑石山下链进入采石场，再穿过深渊副本门。约好监狱、伊森迪奥斯、宝库、酒吧、工匠和玛格姆斯。暗炉钥匙开启捷径，遗物宝箱钥匙开启宝库。持有 98477 可先用吸引器。")),
            requireQuest(4081), requireQuest(3907), requireQuest(3981), requireQuest(7201), requireQuest(97197),
            requireQuest(4063), requireQuest(4134), requireQuest(4136), requireQuest(4123),
            requireQuest(4024), requireQuest(3802), ready(97197, true), handed(97197, true)),
        when(step("监狱取钥匙，找哥沙克与卡兰",
            turnin(3981, gorshak, "从审讯官格斯塔恩取监狱钥匙，先找到哥沙克的牢房。"),
            accept(3982, gorshak),
            objective(3982, "击退进牢房的守卫，保护哥沙克。", gorshak),
            turnin(3982, gorshak), accept(4001, gorshak),
            objective(4001, "在附近另一间牢房与卡兰·巨锤对话，听完再离开监狱。", kharan)),
            requireQuest(3981)),
        when(step("拿弗诺斯的铁胆，向纪念碑交钥匙任务",
            bossLoot(3802, 10999, "铁胆之锤", 1, 1, 9056, "弗诺斯·达克维尔"),
            turnin(3802, object(164689, "弗兰克罗恩·铸铁的纪念碑"),
                "纪念碑在竞技场上层通往黑铁大道一侧。")), onQuest(3802)),
        when(step("打贝尔加并封存火焰精华",
            fields(route.questGoal("use", 4024, npc(9016, "贝尔加")), {
                item = 11231, itemName = "改变过的黑龙军团蜕皮", oi = 1,
                note = "打死贝尔加后对他的遗骸使用蜕皮，每人都做。"}),
            collect(4024, 11230, "被封印的火焰精华", 1, 1)), onQuest(4024)),
        when(step("伊森迪奥斯与元素掉落",
            kill(3907, 9017, "伊森迪奥斯", 1, 1),
            collect(3907, 11126, "库尔尼亚石板", 1, 2),
            collect(7201, 11129, "元素精华", 10, 1, nil, "一路拾取火元素和傀儡类敌人的掉落。")),
            onQuest(3907, 7201)),
        when(step("宝库开启十二个遗物保险箱", collect(4123, 11309, "山脉之心", 1, 1,
            object(165554, "山脉之心"),
            "全队凑够 12 把遗物宝箱钥匙逐个开普通保险箱，处理看守后从后墙保险箱取心。画像召出的黑暗守护者钥匙另开一箱。")),
            onQuest(4123)),
        when(step("工匠区收阿格曼奇的头与核心",
            bossLoot(4063, 11268, "阿格曼奇的头", 1, 1, 8983, "傀儡统帅阿格曼奇"),
            collect(4063, 11269, "完整的元素核心", 10, 2, nil, "同区击杀战斗傀儡和相关精英。")),
            onQuest(4063)),
        when(step("黑铁军官与安格弗将军", objective(4082, "逐项查看高阶军官的击杀数。"),
            kill(4132, 9033, "安格弗将军", 1, 1)), onQuest(4082, 4132)),
        when(step("酒吧交战前先确认雷布里与配方任务",
            bossLoot(4136, 11313, "雷布里的头", 1, 1, 9543, "雷布里·斯库比格特",
                "与雷布里对话前先清他身边容易连锁的怪。"),
            collect(4134, 11312, "遗失的雷酒秘方", 1, 1, nil,
                "雷酒桶事件引出霍尔雷·黑须，从霍尔雷或亲信处拾取秘方。"),
            optional(accept(4201, npc(9500, "娜玛拉小姐"), "只在酒吧顺手接。空瓶以后去安戈洛装水。"))),
            onQuest(4136, 4134)),
        when(step("通过讲学厅击败玛格姆斯",
            bossLoot(97197, 277129, "Fragment of the Firelands", 1, 1, 9938, "玛格姆斯",
                "由酒吧经过七贤与讲学厅，点燃两侧火盆开门后到王座前厅。两人各拾火焰之地碎片。")),
            onQuest(97197)),
        when(step("本人已有救公主任务时完成王座事件",
            kill(4003, 9019, "达格兰·索瑞森大帝", 1, 1, nil,
                "保留茉艾拉公主存活。国王倒下后再与她交谈。"),
            turnin(4003, npc(8929, "茉艾拉公主"))), onQuest(4003)),
        when(step("沿路补齐黑铁矮人通缉", objective(4081,
            "优先在监狱和前厅打守卫、狱卒和步兵，离开前核对三项击杀数。")), onQuest(4081)),
        handInIfReady("出本卡加斯交矮人通缉", 4081, goretooth,
            "首趟结束。第二张通缉留到以后，已接的本人任务以日志为准。"),
        handInIfReady("出本卡加斯交高阶军官通缉", 4082, goretooth),
        handInIfReady("出本卡加斯交安格弗将军", 4132, goretooth),
        handInIfReady("回卡加斯交伊森迪奥斯任务", 3907, thunderheart),
        handInIfReady("回卡加斯交雷酒秘方", 4134, vivian),
        handInIfReady("回卡加斯交元素精华", 7201, vivian),
        handInIfReady("回荒芜之地交机器头与核心", 4063, lotwil),
        handInIfReady("回烈焰峰交雷布里的头", 4136, yuka),
        handInIfReady("回烈焰峰交山脉之心", 4123, maxwort),
        handInIfReady("回燃烧平原东北交贝尔加精华", 4024, cyrus),
        route.watchAlong(route.handInAlong("brd-end", 4300, npc(8659, "杰斯雷蒙", zone.orgrimmar, 55.49, 34.12),
            "本次正到奥格瑞玛时，顺路交给杰斯雷蒙。"), function(C, name)
            return C.IsQuestReadyForTurnIn(4001) or name == "Orgrimmar" or (name and name == C.GetAreaName(1637))
        end),
        handInIfReady("首次出本后向萨尔汇报监狱", 4001, thrall),
        when(step("听萨尔讲东部王国", accept(4002, thrall), turnin(4002, thrall)),
            handed(4001)),
        route.along("brd-end", when(step("可顺手接以后再做的救公主任务",
            optional(accept(4003, thrall, "这是后续深渊行程。此时留在日志。"))), handed(4002))),
        handInIfReady("回莫高雷交火焰之地碎片", 97197, alaana),
        fields(handInIfReady("天望高地交深渊途中收齐的微粒", 98477, nuara), {label = "brd-end"}),
    }, atLeast(55))
end

local fuely = npc(10136, "药剂师弗雷", zone.undercity, 47.5, 73.3)
local faranell = npc(2055, "大药剂师法拉尼尔", zone.undercity, 48.7, 69.3)

function route.addShaperPrep()
    append({
        step("去瘟疫之地前在幽暗城接平台任务", accept(95926, faranell), accept(97049, fuely)),
    }, atLeast(55))
end

function route.addShaper()
    local portal = point(zone.crater, 48.1, 6.1)
    local liv = npc(8496, "莉芙·雷兹菲克斯", zone.barrens, 62.45, 38.71)
    local colors = {
        {11186, "红色能量水晶", "Cinder", "火红晶体"},
        {11188, "黄色能量水晶", "Bolt", "充能晶体"},
        {11185, "绿色能量水晶", "Vitrix", "剧毒晶体"},
        {11184, "蓝色能量水晶", "Snowtalon", "潮湿晶体"},
    }
    local goals = {}
    for _, color in ipairs(colors) do
        goals[#goals + 1] = optional(collect(nil, color[1], color[2], 15, nil, nil,
            "由负责 " .. color[3] .. " 的队友凑齐 15 个同色并操作面板，目标产出 " .. color[4] .. "。"))
    end
    append({
        handInIfReady("顺路去热砂港向叶基亚交哈卡之卵", 3528,
            npc(8579, "叶基亚", zone.tanaris, 66.9, 22.4)),
        step("出发前补接漏掉的平台任务",
            accept(95928, mayena), accept(95926, faranell), accept(97049, fuely)),
        handInIfReady("在马绍尔营地向拉瑞安交燃料", 4146,
            npc(9118, "拉瑞安", zone.crater, 45.5, 8.7)),
    }, atLeast(59))
    route.addOozeField()
    append({
        route.along("shaper-uc", when(step("第二次经过环形山补取火羽山灰烬",
            route.craterAsh("从火羽山的火元素拾取。收齐后下次经过棘齿城工坊时再交。")),
            onQuest(4502), ready(4502, true))),
        fields(when(step("造物者平台 · 首次进本",
            entrance("The Shaper's Terrace", portal, 16985,
                "从马绍尔营地上方山路登坡，穿过副本传送门。四个机关各要一人持 15 个同色，先在队里分好。每人空出三格接任务，持有 98477 可先用吸引器。"),
            unpack(goals)),
            requireQuest(95928), requireQuest(97049), requireQuest(95926), ready(95928, true), handed(95928, true)),
            {label = "shaper-entry"}),
        when(step("沿途击杀渗漏软泥取精华",
            bossLoot(97049, 276235, "Seeping Slime Essence", 8, 1, 262684, "Seeping Slime",
                "边打边收集。离开前两人各查 8 个。")), onQuest(97049)),
        when(step("点亮四色面板后击败召出的四个首领",
            collect(95928, 271894, "Fiery Crystal", 1, 1, nil, "红 15，西边火元素区域召出 Cinder 后拾取。"),
            collect(95928, 271898, "Charged Crystal", 1, 2, nil, "黄 15，Venomridge 附近南侧召出 Bolt 后拾取。"),
            collect(95928, 271902, "Noxious Crystal", 1, 3, nil, "绿 15，北部洞穴召出 Vitrix 后拾取。"),
            collect(95928, 271912, "Moist Crystal", 1, 4, nil, "蓝 15，西北双瀑布左侧洞中召出 Snowtalon 后拾取。")),
            onQuest(95928)),
        when(step("取无色晶体并与队伍打完终点",
            collect(95926, 271771, "Drained Crystal Fragment", 1, 1,
                object(648579, "Drained Crystal Fragment"),
                "检查 Achromatic Crystal 周围可拾取物。打完四色面板首领后，在 Pillar of Assimilation 启动终战迎击 Nanaya。每人出本前检查三项任务。")),
            onQuest(95926)),
        route.handInAlong("shaper-uc", 4502, liv, "若走棘齿城接奥格瑞玛交通，顺路进工坊。"),
        handInIfReady("天望高地向 Mayena 交四色任务晶体", 95928, mayena),
        handInIfReady("天望高地交平台途中收齐的微粒", 98477, nuara),
        fields(handInIfReady("幽暗城交渗漏软泥精华", 97049, fuely), {label = "shaper-uc"}),
        handInIfReady("幽暗城交无色晶体碎片", 95926, faranell),
    }, atLeast(59))
    route.addOozeTurnins()
end
