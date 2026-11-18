local _, route = ...
if not route.steps then return end

local firstLate = #route.steps + 1
route.addBlackmaw()
route.addBRDPrep()
route.addBlackrockOutdoors()
route.addBRD()
route.addShaperPrep()
route.addPlaguelands()
route.addHyjalOutdoors()
route.append({
    route.step("造物者平台前补到 59 级", {
        t = "level", level = 59, map = route.zone.hyjal, x = 39.83, y = 65.89,
        grind = 252116, npcName = "死木图腾师",
        note = "还差经验时先交掉海加尔已完成的任务，也可到西南补打死木图腾师。到 59 后再跟路线进平台。",
    }),
})
route.addShaper()
route.addFinish()
for i = firstLate, #route.steps do
    route.when(route.steps[i], route.handed(93269))
end
route.localize()
route.prepareLiveGoals()

local pack = route.pack
local guideId = pack .. "/50-60-east-local"
if not Polestar.RegisterGuide({
    id = guideId, pack = pack, title = route.title, category = "Leveling",
    faction = "Horde", classes = {"HUNTER", "SHAMAN"}, zone = route.zone.swamp,
    minLevel = 50, maxLevel = 60, version = 1,
    why = "从职业任务到 60 级。沿路准备沉没的神庙、黑喉要塞、黑石深渊和造物者平台的首趟任务。",
    keywords = {"猎萨双人", "神庙", "安戈洛", "费伍德", "冬泉谷", "海加尔邮政背包", "黑喉", "黑石深渊", "造物者平台"},
    steps = route.steps,
}) then return end
route.startLiveGoals(guideId)
route.localizeInterface()

-- Native same-ID remapping can permanently hide a moved Along offer
-- it records as passed. Place the successor from the actual quest state.
local retired = {"start", "hunter", "shaman", "temple-prep", "temple", "ungoro", "felwood", "winterspring", "hyjal", "main", "50-60", "50-60-east"}
for i, name in ipairs(retired) do retired[i] = pack .. "/" .. name end
Polestar.RetireGuides(pack, retired)
