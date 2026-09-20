local frame = CreateFrame("Frame")

local ROAR_COOLDOWN = 0.30
local lastRoarTimeBySender = {}

-- Blizzard FileDataIDs for the original player-character /roar voice lines.
-- These mappings are verified against the current wowdev community listfile.
-- GnomeFemale (540457) has also been confirmed to play in the WoW Forever beta client.
local roarSounds = {
    DwarfFemale = 539992,
    DwarfMale = 540087,
    GnomeFemale = 540457,
    GnomeMale = 540497,
    HumanFemale = 540615,
    HumanMale = 540697,
    NightElfFemale = 541072,
    NightElfMale = 541132,
    OrcFemale = 541347,
    OrcMale = 541398,
    TaurenFemale = 543016,
    TaurenMale = 543062,
    TrollFemale = 543226,
    TrollMale = 543311,
    UndeadFemale = 542680,
    UndeadMale = 542740,
}

local function NormalizeName(name)
    if not name then
        return nil
    end

    local dashPos = string.find(name, "-", 1, true)
    if dashPos then
        return string.sub(name, 1, dashPos - 1)
    end

    return name
end

local function NormalizeRace(raceFile)
    if raceFile == "Scourge" then
        return "Undead"
    end

    return raceFile
end

local function BuildRoarKey(raceFile, sex)
    raceFile = NormalizeRace(raceFile)

    if not raceFile then
        return nil
    end

    if sex == 2 then
        return raceFile .. "Male"
    elseif sex == 3 then
        return raceFile .. "Female"
    end

    return nil
end

local function GetRoarKeyForUnit(unit)
    if not UnitExists(unit) then
        return nil
    end

    local _, raceFile = UnitRace(unit)
    local sex = UnitSex(unit)
    return BuildRoarKey(raceFile, sex)
end

local function GetRoarKeyForGUID(guid)
    if not guid or not GetPlayerInfoByGUID then
        return nil
    end

    local _, _, _, raceFile, sex = GetPlayerInfoByGUID(guid)
    return BuildRoarKey(raceFile, sex)
end

local function PlayRoarByKey(roarKey)
    local fileDataID = roarSounds[roarKey]
    if not fileDataID then
        return false
    end

    local willPlay = PlaySoundFile(fileDataID, "Master")
    return willPlay and true or false
end

local function IsRoarText(text)
    if not text then
        return false
    end

    text = string.lower(text)

    if string.find(text, " roars", 1, true) then
        return true
    end

    if string.find(text, " roar", 1, true) then
        return true
    end

    return false
end

local function FindUnitBySender(sender)
    local wanted = NormalizeName(sender)
    if not wanted then
        return nil
    end

    local units = { "player", "target", "mouseover", "focus" }

    for _, unit in ipairs(units) do
        if UnitExists(unit) and NormalizeName(UnitName(unit)) == wanted then
            return unit
        end
    end

    if IsInRaid and IsInRaid() then
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitExists(unit) and NormalizeName(UnitName(unit)) == wanted then
                return unit
            end
        end
    elseif IsInGroup and IsInGroup() then
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) and NormalizeName(UnitName(unit)) == wanted then
                return unit
            end
        end
    end

    return nil
end

local function CanPlayForSender(sender, guid)
    local key = guid or NormalizeName(sender) or "unknown"
    local now = GetTime()
    local last = lastRoarTimeBySender[key]

    if last and (now - last) < ROAR_COOLDOWN then
        return false
    end

    lastRoarTimeBySender[key] = now
    return true
end

local function GetSenderRoarKey(sender, guid)
    local roarKey = GetRoarKeyForGUID(guid)
    if roarKey then
        return roarKey
    end

    local unit = FindUnitBySender(sender)
    if unit then
        return GetRoarKeyForUnit(unit)
    end

    return nil
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event ~= "CHAT_MSG_TEXT_EMOTE" then
        return
    end

    local text, sender, _, _, _, _, _, _, _, _, _, guid = ...

    if not IsRoarText(text) then
        return
    end

    if not CanPlayForSender(sender, guid) then
        return
    end

    local roarKey = GetSenderRoarKey(sender, guid)
    if roarKey then
        PlayRoarByKey(roarKey)
    end
end)

frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")

SLASH_ROARFOREVER1 = "/roarforever"
SLASH_ROARFOREVER2 = "/rf"

SlashCmdList.ROARFOREVER = function(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    if msg == "" or msg == "config" or msg == "ui" then
        if RoarForever_OpenConfig then
            RoarForever_OpenConfig()
        else
            print("Roar Forever: configuration UI is unavailable.")
        end
        return
    end

    if msg == "test" then
        local roarKey = GetRoarKeyForUnit("player")
        local fileDataID = roarKey and roarSounds[roarKey]

        if not roarKey then
            print("Roar Forever: could not determine your race/sex.")
            return
        end

        if not fileDataID then
            print("Roar Forever: no FileDataID mapped for " .. roarKey .. ".")
            return
        end

        local ok = PlayRoarByKey(roarKey)
        print("Roar Forever: " .. roarKey .. " -> " .. fileDataID .. (ok and " (played)" or " (playback failed)"))
        return
    end

    if msg == "status" then
        if RoarForever_StorageStatus then
            print("Roar Forever: " .. RoarForever_StorageStatus())
        end
        local roarKey = GetRoarKeyForUnit("player") or "unknown"
        local fileDataID = roarSounds[roarKey]
        print("Roar Forever: detected " .. roarKey .. ", FileDataID " .. (fileDataID or "not mapped"))

        if RoarForever_ActionStatus then
            local enabled, count = RoarForever_ActionStatus()
            print("Roar Forever: ability emotes " .. (enabled and "enabled" or "disabled") .. ", " .. tostring(count) .. " configured abilities")
        end
        return
    end

    local rawID = msg:match("^id%s+(%d+)$")
    if rawID then
        local fileDataID = tonumber(rawID)
        local ok, handle = PlaySoundFile(fileDataID, "Master")
        print("Roar Forever: FileDataID " .. fileDataID .. " ->", ok, handle)
        return
    end

    print("Roar Forever: /rf | /rf test | /rf status | /rf id <FileDataID>")
end
