local _, route = ...
if not route.steps then return end

-- Guide fallback titles. The client's live quest title still takes precedence.
local quests = {
    [84146] = "红色背包的烦恼",
    [86577] = "腐化样本",
    [86612] = "雄鹿领主的饰物",
    [86746] = "雷加斯的威胁",
    [86752] = "向守门者报到",
    [86777] = "菲达雷德",
    [86791] = "失踪的黑喉斥候",
    [86792] = "削减敌军",
    [86796] = "告别萨特",
    [86797] = "回到守门者身边",
    [86798] = "木喉援军",
    [86814] = "黑喉反攻",
    [87346] = "血喉酋长",
    [87492] = "诡异的水晶",
    [87494] = "微晶污染",
    [90487] = "古老的盟友",
    [91697] = "拜访长老",
    [91734] = "远方的联络人",
    [91754] = "敷上一点泥土",
    [91755] = "以叶包扎",
    [91770] = "树皮试炼",
    [91794] = "先祖的旗帜",
    [91952] = "腐化之源",
    [92008] = "优质零件",
    [92009] = "工坊急送箱",
    [92011] = "翻找废墟",
    [92017] = "净化之风",
    [92020] = "霍尔安耶的大蜥蜴大百科",
    [92065] = "夺回黑喉要塞",
    [92066] = "双熊",
    [92069] = "尖爪与獠牙",
    [92070] = "遗失的纪念物",
    [92111] = "毛茸茸的朋友",
    [92147] = "高羽的帮手",
    [92328] = "攻城技艺",
    [92343] = "追根究底",
    [92346] = "诺达希尔之下",
    [92533] = "扭曲的工具",
    [92592] = "最后的死亡",
    [92594] = "姑且算作引火物",
    [92609] = "飞舞的羽毛",
    [92859] = "冬泉隐遁",
    [92960] = "汲取短暂精华",
    [93197] = "恢复通信",
    [93269] = "顶峰邮差",
    [93406] = "解冻的邮件",
    [93407] = "爪中之刺",
    [93584] = "终结教派",
    [93747] = "战火中新生的绿意",
    [93759] = "大自然的馈赠",
    [93825] = "树皮祝福",
    [93826] = "让死木闻风丧胆",
    [93827] = "风中的护符",
    [93831] = "甜爪果酱",
    [93952] = "力量铸就平衡",
    [94479] = "变废为宝",
    [94782] = "西部哨站",
    [95026] = "清除疫病",
    [95248] = "前往永恒峰",
    [95316] = "实验方法",
    [95317] = "记录、记录、再记录",
    [95318] = "灰烬的滋味",
    [95319] = "采集结晶",
    [95320] = "好奇的问题",
    [95378] = "多头蛇之首",
    [95379] = "甜美的复仇",
    [95380] = "丰饶之源",
    [95568] = "新一季的种子",
    [95569] = "雏鸟的希望",
    [95611] = "致敬仪式",
    [95766] = "羽翼伙伴",
    [95793] = "遏制恶魔大军",
    [95926] = "黑暗水晶",
    [95928] = "结晶元素",
    [96003] = "引出恶徒",
    [96025] = "循鸦而行",
    [96252] = "黯淡的宝物",
    [96262] = "刺手的松果",
    [96296] = "恶臭的腐化",
    [96435] = "应有的结局",
    [96796] = "林间工坊",
    [96830] = "远视指引",
    [97000] = "记忆的碎屑",
    [97001] = "伐木工的遗产",
    [97049] = "渗漏的软泥怪精华",
    [97197] = "火焰之地碎片",
    [97198] = "黑喉魔法",
    [97319] = "远方的表亲",
    [97327] = "黑喉袋子",
    [98462] = "冬泉隐遁",
    [98477] = "不稳定的魔法",
}

-- Exact NPC names from the installed Polestar_zhCN/Names.lua. Keep unknown
-- canonical names for the core's target button, which uses /targetexact.
local npcs = {
    [6200] = "雷加斯萨特", [6201] = "雷加斯潜行者", [6202] = "雷加斯唤魔者",
    [6652] = "菲达雷德", [9079] = "塞朵拉·穆瓦丹尼", [9462] = "血喉酋长",
    [13177] = "瓦格鲁克", [259118] = "穆恩·大地之怒", [259119] = "阿拉娜·风暴行者",
    [263445] = "玛耶娜·寻地者", [272633] = "努阿拉·震蹄",
}

-- Identification hints for NPCs missing from the bundled locale. The
-- original name still drives targeting. These hints are guide annotations.
local npcHints = {
    [40833] = "蒂亚拉·怀特迈恩", [41861] = "永恒峰的飞行管理员",
    [228216] = "永望镇的零件联系人", [235903] = "废墟的黑喉斥候联络人",
    [236573] = "熊怪村的守门者", [236770] = "东部营地外的斥候",
    [236867] = "雷加斯夺魂者", [236874] = "Legashi Hellraiser（与雷加斯唤魔者分开计数）",
    [236876] = "雷加斯黑卫", [237007] = "囚笼里的斥候",
    [243509] = "有毒软泥怪", [243815] = "塞贝莉娅", [243855] = "托隆·岩蹄",
    [244511] = "西北哨站的泽特甘", [244512] = "奥塔克·隆戈克",
    [247195] = "黑喉大熊首领", [247198] = "黑喉的野猪首领",
    [247209] = "黑喉的长老萨满", [247234] = "黑喉尾王瓦罗克斯·暗蹄",
    [248041] = "海加尔雄鹿", [248366] = "树皮试炼的古树",
    [248367] = "古树旁的海辛丝", [248395] = "受污染的拟态灌木",
    [249052] = "枯须", [249228] = "撕肉掠袭者", [249229] = "邪能卫士哨兵",
    [249230] = "污染猎犬", [249235] = "山麓的工坊联系人",
    [249247] = "被遗忘的士兵", [249490] = "野息奇美拉", [249491] = "山地大角鹰兽",
    [249551] = "黑棘教徒", [249853] = "双熊任务的传承者", [249855] = "饰链的失主",
    [252063] = "死木巢穴守卫", [252096] = "死木邪能看护者",
    [252116] = "死木图腾师", [252457] = "玛佐戈尔", [254915] = "希萨莉·黑鸦",
    [256222] = "山麓的隐士", [256627] = "雾爪长老", [256646] = "奥西·雾爪",
    [256650] = "松语长老", [256660] = "托本·树汁爪", [256978] = "布雷鲁法",
    [257753] = "好奇的乌鸦", [260148] = "天灾复活者", [260422] = "灰烬侍僧",
    [260440] = "布拉尚·暗影", [260443] = "达兹卡·影眠", [260444] = "提娅哈·暗誓",
    [260626] = "腐化山麓的飞行管理员", [260661] = "苏玛·苔鬃",
    [260818] = "弗雷兹利·砰哨", [260825] = "艾维娜神殿的高羽",
    [262684] = "渗漏的软泥怪", [263394] = "虚弱的贝瑟拉泽尔",
    [263406] = "伊莱娜·月语", [263757] = "灰烬营地南侧的水晶研究者",
    [264570] = "黑棘信徒", [264795] = "永恒峰附近的净化任务联系人",
    [265788] = "西北哨站的旗帜任务联系人", [266802] = "山路上接远视引导的联系人",
}

local items = {
    [235334] = "菲达雷德的护符", [236631] = "血喉粉碎者",
    [249692] = "瓦罗克斯·暗蹄的头颅", [249693] = "乌索尔的图腾",
    [249694] = "乌索克的图腾", [249696] = "不屈者之牙",
    [249697] = "巨熊之爪", [249698] = "羽饰护符项链",
    [250773] = "诺达希尔根帽", [271771] = "耗尽的水晶碎片",
    [271894] = "炽热的水晶", [271898] = "充能的水晶",
    [271902] = "有毒的水晶", [271912] = "潮湿的水晶",
    [273050] = "黑喉袋子", [273828] = "反冲的盘根法杖",
    [273832] = "邪恶仪祭师的波刃匕首", [276235] = "渗漏的软泥怪精华",
    [276893] = "黑喉仪祭图腾", [277129] = "火焰之地碎片",
}

local objects = {
    [164867] = "通缉", [164868] = "格杀勿论",
    [562377] = "纯净的土壤", [571603] = "磨损的线缆",
    [572028] = "钙化的粪便", [577731] = "部落旗帜",
    [617262] = "月纱苔藓", [617265] = "熊果",
    [626685] = "血色飞镖块茎", [637622] = "邪能软泥结晶",
    [644820] = "海加尔猫头鹰蛋", [648579] = "耗尽的水晶碎片",
    [650234] = "松脱的齿轮", [650902] = "黯淡的高羽手镯",
    [651048] = "刺手的松果", [651409] = "腐化结节",
    [652442] = "无瑕的邪能软泥结晶", [652449] = "骨堆",
}

-- Only for the three instance entrances. Keep taxi and zone predicate
-- names intact. The core first resolves an entrance with its area ID.
local entrances = {
    [1584] = "黑石深渊", [16554] = "黑喉要塞", [16985] = "造物者平台",
}

local prose = {
    ["Achromatic Crystal"] = "无色水晶",
    ["在山麓找 Bluebell。"] = "找腐化山麓的飞行管理员。",
    ["由负责 Bolt 的队友"] = "由负责黄色水晶的队友",
    ["由负责 Cinder 的队友"] = "由负责红色水晶的队友",
    ["Dreamscythe"] = "德姆塞卡尔",
    ["埃达拉斯废墟找 Ekkal"] = "在埃达拉斯废墟找黑喉斥候联络人",
    ["Ekkal 指引你向北报到"] = "按黑喉斥候联络人的指引向北报到",
    ["Fayran Elthas"] = "永恒峰的飞行管理员",
    ["Fel-Tainted Flesh"] = "被邪能污染的血肉",
    ["Feardred"] = "菲达雷德",
    ["顺路营救囚笼里的 Graal"] = "顺路营救囚笼里的斥候",
    ["护送 Graal"] = "护送斥候",
    ["找到东部营地外的 Korsa"] = "找到东部营地外的斥候",
    ["Korsa 回报斥候进展"] = "向东部营地外的斥候汇报",
    ["Lorekeeper Nok"] = "双熊任务的传承者",
    ["Mayena"] = "玛耶娜",
    ["Nanaya"] = "终战首领纳纳娅",
    ["Nuara"] = "努阿拉",
    ["Pillar of Assimilation"] = "同化之柱",
    ["Prince Halanox"] = "哈拉诺克斯王子",
    ["（Sebelia）"] = "",
    ["Shroud of the Winter Wilds"] = "《冬泉隐遁》",
    ["由负责 Snowtalon 的队友"] = "由负责蓝色水晶的队友",
    ["Tiala Whitemane"] = "蒂亚拉·怀特迈恩",
    ["Timbermaw War Banner"] = "木喉战旗",
    ["Unele"] = "饰链的失主",
    ["Ursolan"] = "艾萨拉的熊怪村",
    ["Varrox Bleakhoof"] = "瓦罗克斯·暗蹄",
    ["Venomridge"] = "毒脊",
    ["由负责 Vitrix 的队友"] = "由负责绿色水晶的队友",
    ["召出 Cinder 后拾取"] = "召出首领，击败后拾取",
    ["召出 Bolt 后拾取"] = "召出首领，击败后拾取",
    ["召出 Vitrix 后拾取"] = "召出首领，击败后拾取",
    ["召出 Snowtalon 后拾取"] = "召出首领，击败后拾取",
    ["Weaver"] = "维沃尔",
}

local function zhCN()
    return GetLocale and GetLocale() == "zhCN"
end

local function fallback(entry, key, translated)
    local current = entry[key]
    if translated and type(current) == "string" and current:match("^[%w%p%s]+$") then
        entry[key] = translated
    end
end

local function localizeProse(value)
    if not value then return nil end
    for key, translated in pairs(prose) do
        value = value:gsub(key:gsub("%p", "%%%0"), translated)
    end
    return value
end

local function addNpcHint(goal)
    local id = goal.npc or goal.grind or (goal.fromKind == "npc" and goal.fromId)
    local hint = npcHints[id]
    if hint and not (goal.note and goal.note:find(hint, 1, true)) then
        goal.note = (goal.note and goal.note .. "\n" or "") .. "辨认目标时可找" .. hint .. "。"
    end
end

function route.localize()
    if not zhCN() or not route.steps then return end
    for _, step in ipairs(route.steps) do
        step.title = localizeProse(step.title)
        step.note = localizeProse(step.note)
        for _, goal in ipairs(step.goals) do
            fallback(goal, "title", quests[goal.quest])
            fallback(goal, "itemName", items[goal.item])
            fallback(goal, "objName", objects[goal.object])
            fallback(goal, "npcName", npcs[goal.npc or goal.grind])
            fallback(goal, "target", npcs[goal.npc])
            if goal.fromKind == "npc" then
                fallback(goal, "from", npcs[goal.fromId])
            elseif goal.fromKind == "object" then
                fallback(goal, "from", objects[goal.fromId])
            end
            for _, source in ipairs(goal.fromNpcs or {}) do
                fallback(source, "npcName", npcs[source.npc])
            end
            if goal.t == "enter" then
                fallback(goal, "location", entrances[goal.area])
            end
            goal.text = localizeProse(goal.text)
            goal.note = localizeProse(goal.note)
            addNpcHint(goal)
        end
    end
end

function route.localizeInterface()
    -- Polestar/Core/Init.lua exposes the same locale table via the global.
    -- These two labels are read at runtime, after the dependent pack loads.
    local L = zhCN() and Polestar and Polestar.L
    if type(L) ~= "table" then return end
    for key, translated in pairs({
        ["Ride to %s"] = "骑乘前往%s",
        ["Ride to the flight master"] = "骑乘前往飞行管理员处",
    }) do
        local current = rawget(L, key)
        if current == nil or current == "" then L[key] = translated end
    end
end
