local frame = CreateFrame("Frame")

local EMOTE_COOLDOWN = 0.30
local lastPlayTimeBySenderAndEmote = {}

-- Blizzard FileDataIDs for player-character voice emotes.
-- These mappings are taken from the current wowdev community listfile.
-- Each value is an array so additional voice variants can be added without
-- changing the playback code.
local voiceSounds = {
    roar = {
        DwarfFemale = { 539992 },
        DwarfMale = { 540087 },
        GnomeFemale = { 540457 },
        GnomeMale = { 540497 },
        HumanFemale = { 540615 },
        HumanMale = { 540697 },
        NightElfFemale = { 541072 },
        NightElfMale = { 541132 },
        OrcFemale = { 541347 },
        OrcMale = { 541398 },
        TaurenFemale = { 543016 },
        TaurenMale = { 543062 },
        TrollFemale = { 543226 },
        TrollMale = { 543311 },
        UndeadFemale = { 542680 },
        UndeadMale = { 542740 },
    },
    cheer = {
        DwarfFemale = { 540014 },
        DwarfMale = { 540024 },
        GnomeFemale = { 540434 },
        GnomeMale = { 540493 },
        HumanFemale = { 540628 },
        HumanMale = { 540694 },
        NightElfFemale = { 541043 },
        NightElfMale = { 541138 },
        OrcFemale = { 541328 },
        OrcMale = { 541435 },
        TaurenFemale = { 542976 },
        TaurenMale = { 543078 },
        TrollFemale = { 543253 },
        TrollMale = { 543331 },
        UndeadFemale = { 542697 },
        UndeadMale = { 542783 },
    },
    laugh = {
        DwarfFemale = { 539798 },
        DwarfMale = { 539883 },
        GnomeFemale = { 540268 },
        GnomeMale = { 540267 },
        HumanFemale = { 540540 },
        HumanMale = { 540739 },
        NightElfFemale = { 540877 },
        NightElfMale = { 540945 },
        OrcFemale = { 541153 },
        OrcMale = { 541230 },
        TaurenFemale = { 542806 },
        TaurenMale = { 542898 },
        TrollFemale = { 543091 },
        TrollMale = { 543094 },
        UndeadFemale = { 542518 },
        UndeadMale = { 542595 },
    },
    joke = {
        -- Classic /silly and /joke voice lines are stored as Pissed sounds.
        -- The chat event does not identify which random variant the sender heard,
        -- so one stable voice line is used for now.
        DwarfFemale = { 539989 },
        DwarfMale = { 540055 },
        GnomeFemale = { 540424 },
        GnomeMale = { 540517 },
        HumanFemale = { 540641 },
        HumanMale = { 540663 },
        NightElfFemale = { 541035 },
        NightElfMale = { 541122 },
        OrcFemale = { 541349 },
        OrcMale = { 541433 },
        TaurenFemale = { 542968 },
        TaurenMale = { 543055 },
        TrollFemale = { 543241 },
        TrollMale = { 543315 },
        UndeadFemale = { 542727 },
        UndeadMale = { 542753 },
    },
    moo = {
        -- /moo has dedicated player voice files only for Tauren.
        TaurenFemale = { 542820 },
        TaurenMale = { 542894 },
    },
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

local function BuildVoiceKey(raceFile, sex)
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

local function GetVoiceKeyForUnit(unit)
    if not UnitExists(unit) then
        return nil
    end

    local _, raceFile = UnitRace(unit)
    local sex = UnitSex(unit)
    return BuildVoiceKey(raceFile, sex)
end

local function GetVoiceKeyForGUID(guid)
    if not guid or not GetPlayerInfoByGUID then
        return nil
    end

    local _, _, _, raceFile, sex = GetPlayerInfoByGUID(guid)
    return BuildVoiceKey(raceFile, sex)
end

local function PlayEmoteByKey(emoteName, voiceKey)
    local emoteMap = voiceSounds[emoteName]
    local sounds = emoteMap and emoteMap[voiceKey]
    if not sounds or #sounds == 0 then
        return false
    end

    local fileDataID = sounds[math.random(#sounds)]
    local willPlay = PlaySoundFile(fileDataID, "Master")
    return willPlay and true or false, fileDataID
end

local function DetectEmote(text)
    if not text then
        return nil
    end

    text = string.lower(text)

    if string.find(text, " tells a joke", 1, true)
        or string.find(text, " tell a joke", 1, true) then
        return "joke"
    end

    if string.find(text, " roars", 1, true)
        or string.find(text, " roar", 1, true) then
        return "roar"
    end

    if string.find(text, " cheers", 1, true)
        or string.find(text, "you cheer", 1, true) == 1 then
        return "cheer"
    end

    if string.find(text, " laughs", 1, true)
        or string.find(text, "you laugh", 1, true) == 1 then
        return "laugh"
    end

    -- Untargeted /moo is just "Mooooooooooo." while targeted /moo contains
    -- normal emote text followed by the same long moo.
    if string.find(text, " moos", 1, true)
        or string.find(text, "you moo", 1, true) == 1
        or string.find(text, "mooooo", 1, true) then
        return "moo"
    end

    return nil
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

local function IsLocalPlayer(sender, guid)
    local playerGUID = UnitGUID("player")
    if guid and playerGUID and guid == playerGUID then
        return true
    end

    local senderName = NormalizeName(sender)
    local playerName = NormalizeName(UnitName("player"))
    return senderName and playerName and senderName == playerName
end

local function CanPlayForSender(sender, guid, emoteName)
    local senderKey = guid or NormalizeName(sender) or "unknown"
    local key = emoteName .. ":" .. senderKey
    local now = GetTime()
    local last = lastPlayTimeBySenderAndEmote[key]

    if last and (now - last) < EMOTE_COOLDOWN then
        return false
    end

    lastPlayTimeBySenderAndEmote[key] = now
    return true
end

local function GetSenderVoiceKey(sender, guid)
    local voiceKey = GetVoiceKeyForGUID(guid)
    if voiceKey then
        return voiceKey
    end

    local unit = FindUnitBySender(sender)
    if unit then
        return GetVoiceKeyForUnit(unit)
    end

    return nil
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event ~= "CHAT_MSG_TEXT_EMOTE" then
        return
    end

    local text, sender, _, _, _, _, _, _, _, _, _, guid = ...
    local emoteName = DetectEmote(text)

    if not emoteName then
        return
    end

    -- Forever already plays the local player's normal voiced emotes. Roar is
    -- the exception this addon was originally created to restore locally too.
    if emoteName ~= "roar" and IsLocalPlayer(sender, guid) then
        return
    end

    if not CanPlayForSender(sender, guid, emoteName) then
        return
    end

    local voiceKey = GetSenderVoiceKey(sender, guid)
    if voiceKey then
        PlayEmoteByKey(emoteName, voiceKey)
    end
end)

frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")

SLASH_ROARFOREVER1 = "/roarforever"
SLASH_ROARFOREVER2 = "/rf"

SlashCmdList.ROARFOREVER = function(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    local testEmote = msg:match("^test%s*(%a*)$")
    if testEmote then
        if testEmote == "" then
            testEmote = "roar"
        end

        if not voiceSounds[testEmote] then
            print("Roar Forever: unknown test emote '" .. testEmote .. "'.")
            print("Roar Forever: test options are roar, cheer, laugh, joke, moo.")
            return
        end

        local voiceKey = GetVoiceKeyForUnit("player")
        if not voiceKey then
            print("Roar Forever: could not determine your race/sex.")
            return
        end

        local sounds = voiceSounds[testEmote][voiceKey]
        if not sounds or #sounds == 0 then
            print("Roar Forever: no " .. testEmote .. " sound mapped for " .. voiceKey .. ".")
            return
        end

        local ok, fileDataID = PlayEmoteByKey(testEmote, voiceKey)
        print("Roar Forever: " .. testEmote .. " / " .. voiceKey .. " -> " .. fileDataID .. (ok and " (played)" or " (playback failed)"))
        return
    end

    if msg == "status" then
        local voiceKey = GetVoiceKeyForUnit("player") or "unknown"
        local mapped = {}

        for emoteName, emoteMap in pairs(voiceSounds) do
            if emoteMap[voiceKey] then
                table.insert(mapped, emoteName)
            end
        end

        table.sort(mapped)
        print("Roar Forever: detected " .. voiceKey .. "; mapped emotes: " .. (#mapped > 0 and table.concat(mapped, ", ") or "none"))
        return
    end

    local rawID = msg:match("^id%s+(%d+)$")
    if rawID then
        local fileDataID = tonumber(rawID)
        local ok, handle = PlaySoundFile(fileDataID, "Master")
        print("Roar Forever: FileDataID " .. fileDataID .. " ->", ok, handle)
        return
    end

    print("Roar Forever: /rf test [roar|cheer|laugh|joke|moo] | /rf status | /rf id <FileDataID>")
end
