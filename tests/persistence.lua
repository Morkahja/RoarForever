-- Run from the repository root with Lua 5.1: lua tests/persistence.lua
-- Simulate separate client sessions, including a failed native restore.
local files = {}
for line in io.lines('RoarForever.toc') do
    if line:match('%.lua%s*$') then files[#files + 1] = line:match('^%s*(.-)%s*$') end
end

local function serialize(value)
    if type(value) == 'string' then return string.format('%q', value) end
    if type(value) ~= 'table' then return tostring(value) end
    local fields = {}
    for key, item in pairs(value) do
        fields[#fields + 1] = '[' .. serialize(key) .. ']=' .. serialize(item)
    end
    return '{' .. table.concat(fields, ',') .. '}'
end

local function session(snapshot, recovery, nativeRestore, guid)
    local env = setmetatable({}, {__index = _G})
    env._G = env
    env.frames = {}
    env.SlashCmdList = {}
    env.print = function() end
    env.UnitGUID = function() return guid or 'Player-test-1' end
    env.UnitName = function() return 'Tester' end
    env.GetRealmName = function() return 'Internal' end
    env.GetTime = function() return 100 end
    env.GetSpellInfo = function() return 'Battle Shout' end
    env.DoEmote = function(token) env.lastEmote = token end
    env.CreateFrame = function()
        local f = {events = {}}
        function f:RegisterEvent(event) self.events[event] = true end
        function f:SetScript(event, callback) self[event] = callback end
        env.frames[#env.frames + 1] = f
        return f
    end
    local function run(source)
        setfenv(assert(loadstring(source)), env)()
    end
    if recovery and snapshot then
        run(snapshot)
        env.RoarForever_RecoveryStorage = env.RoarForeverStorage
        env.RoarForever_RecoveryReady = type(env.RoarForeverStorage) == 'table'
    end
    for _, file in ipairs(files) do setfenv(assert(loadfile(file)), env)() end
    -- The failure can clear the normal global after addon code has loaded.
    env.RoarForeverStorage = nil
    if nativeRestore and snapshot then run(snapshot) end
    function env.fire(event, ...)
        for _, frame in ipairs(env.frames) do
            if frame.events[event] then frame.OnEvent(frame, event, ...) end
        end
    end
    env.fire('PLAYER_LOGIN')
    env.RoarForever_ActionStatus()
    return env
end

local first = session(nil, false, true)
first.RoarForeverDB.instances['battle shout'] = {
    name = 'Battle Shout', chance = 100, cooldown = 22, emotes = {ROAR = true}}
first.RoarForeverDB.instances.charge = {
    name = 'Charge', chance = 42, cooldown = 14, emotes = {CHARGE = true, ROAR = true}}
local disk = 'RoarForeverStorage=' .. serialize(first.RoarForeverStorage)
local broken = session(disk, false, false)
assert(next(broken.RoarForeverDB.instances) == nil, 'must reproduce beta reset without recovery')
for _, native in ipairs({false, true}) do
    local restored = session(disk, true, native)
    assert(restored.RoarForeverDB == restored.RoarForeverStorage.profiles['Player-test-1'])
    assert(restored.RoarForeverDB.instances.charge.chance == 42)
    assert(restored.RoarForeverDB.instances.charge.emotes.CHARGE)
    assert(restored.RoarForeverDB.instances['battle shout'].cooldown == 22)
    restored.fire('UNIT_SPELLCAST_SUCCEEDED', 'player', 'cast', 6673)
    assert(restored.lastEmote == 'ROAR')
    -- Changes and intentional deletions must survive another cold start.
    restored.RoarForeverDB.instances.charge = nil
    restored.RoarForeverDB.instances['battle shout'].cooldown = 23
    restored.RoarForeverDB.actionEmotesEnabled = false
    local nextDisk = 'RoarForeverStorage=' .. serialize(restored.RoarForeverStorage)
    local nextSession = session(nextDisk, true, native)
    assert(nextSession.RoarForeverDB.instances.charge == nil)
    assert(nextSession.RoarForeverDB.instances['battle shout'].cooldown == 23)
    assert(nextSession.RoarForeverDB.actionEmotesEnabled == false)
    local other = session(nextDisk, true, native, 'Player-test-2')
    assert(next(other.RoarForeverDB.instances) == nil)
    assert(other.RoarForeverStorage.profiles['Player-test-1'].instances['battle shout'].cooldown == 23)
end
for _, key in ipairs({'Tester', 'Tester-Internal'}) do
    local legacy = 'RoarForeverStorage={profiles={[' .. string.format('%q', key) ..
        ']={instances={saved={chance=42,cooldown=14}}}}}'
    local migrated = session(legacy, true, false)
    assert(migrated.RoarForeverDB.instances.saved.chance == 42)
    assert(migrated.RoarForeverStorage.profiles[key] == nil)
end
print('PASS: reproduced beta reset; restored separate sessions; subsequent edits, deletions, toggles, character isolation and legacy migration persist.')
