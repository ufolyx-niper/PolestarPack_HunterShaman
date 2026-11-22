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
-- The old city predicates latched numeric step flags before the visit.
-- Native explicit Along skips use goal keys, and the step order is unchanged.
-- Translate goal positions only for the exact step keys shipped before this release.
local versions = {["0.3.2"]=true, ["0.3.3"]=true, ["0.3.4"]=true, ["0.3.5"]=true}
-- Each mixed step gained two goals. In the seed step, the old fourth goal
-- covered all three wrecks; an explicit check on it covers all three now.
local edits = {
    [3415617216] = {key=1675818646, first=4, split=true},
    [4196232677] = {key=1141849001, first=10},
}
local function migrateObjectives(state, id)
    local keys = state.stepKeys and state.stepKeys[id]
    if type(keys) ~= "table" or not versions[state.shapeVersions and state.shapeVersions[id]] then return end
    for step, oldKey in ipairs(keys) do
        local edit = edits[oldKey]
        if edit then
            for _, field in ipairs({"manual", "skipped"}) do
                local data = state[field] and state[field][id]
                if type(data) == "table" then
                    local moved = {}
                    for key, value in pairs(data) do
                        local i, j
                        if type(key) == "string" then i, j = key:match("^(%d+):(%d+)$") end
                        j = tonumber(j)
                        if tonumber(i) == step and j >= edit.first then
                            data[key] = nil
                            moved[step..":"..(j+2)] = value
                            if edit.split and j == edit.first then
                                moved[key] = value
                                moved[step..":"..(j+1)] = value
                            end
                        end
                    end
                    for key, value in pairs(moved) do data[key] = value end
                end
            end
            keys[step] = edit.key
        end
    end
end

Polestar.OnInit(function()
    local state = Polestar.CharState()
    migrateObjectives(state, guideId)
    local versions = state.shapeVersions
    local previous = versions and versions[guideId]
    if previous ~= "0.3.2" and previous ~= "0.3.3" then return end
    local keys = state.stepKeys and state.stepKeys[guideId]
    if type(keys) ~= "table" then return end
    -- Native step-key hashes for the old single-goal accept rows.
    local cityKeys = {[3330348535] = true, [100744090] = true, [100738646] = true}
    local skipped, latched = state.skipped[guideId], state.when[guideId]
    for index, key in ipairs(keys) do
        if cityKeys[key] then
            if skipped and skipped[index] == true then skipped[index] = nil end
            if latched and latched[index] == true then latched[index] = nil end
        end
    end
end)

route.startLiveGoals(guideId)
route.localizeInterface()

-- Native same-ID remapping can permanently hide a moved Along offer
-- it records as passed. Place the successor from the actual quest state.
local retired = {"start", "hunter", "shaman", "temple-prep", "temple", "ungoro", "felwood", "winterspring", "hyjal", "main", "50-60", "50-60-east"}
for i, name in ipairs(retired) do retired[i] = pack .. "/" .. name end
Polestar.RetireGuides(pack, retired)
