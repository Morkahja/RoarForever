local frame = CreateFrame("Frame")

local EMOTE_COOLDOWN = 0.30
local lastPlayTimeBySenderAndEmote = {}

-- Blizzard FileDataIDs for player-character voice emotes.
-- Classic names come from the wowdev community listfile. Joke variants, and
-- every Skyborne ID, are the files in that emote's sound kit on Forever
-- build 1.60.1.70009. Skyborne files are not named in the listfile yet.
-- /retreat uses the flee voice. /yes is the nod emote; its files are the Yes lines.
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
        -- Skyborne roar kit from EmotesTextSound on Forever build 1.60.1.70009.
        -- High Order and Windshaper share this voice set.
        SkyborneFemale = { 8036579, 8036581, 8036583 },
        SkyborneMale = { 8062196, 8062198, 8062200 },
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
        SkyborneFemale = { 7744884, 7961127 },
        SkyborneMale = { 7744477, 7744478 },
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
        SkyborneFemale = { 8036475, 8036477, 8036479, 8036481 },
        SkyborneMale = { 8062277, 8062279, 8062282 },
    },
    joke = {
        -- /silly and /joke use the race/sex Pissed sound kit.
        -- CHAT_MSG_TEXT_EMOTE does not say which line the sender's client picked,
        -- so playback chooses one at random from that race and sex's verified kit.
        DwarfFemale = { 539989, 540017, 539993, 539999, 539970, 539968 },
        DwarfMale = { 540055, 540067, 540032, 540030, 540050, 540049, 540084 },
        GnomeFemale = { 540424, 540423, 540426, 540443 },
        GnomeMale = { 540517, 540468, 540467, 540464, 540495, 540492 },
        HumanFemale = { 540641, 540633, 540617, 540634, 540622, 540643, 540639 },
        HumanMale = { 540663, 540716, 540699, 540679, 540680, 540710 },
        NightElfFemale = { 541035, 541038, 541067, 541028, 541077 },
        NightElfMale = { 541122, 541125, 541084, 541133, 541134, 541082, 541098, 541120 },
        OrcFemale = { 541349, 541357, 541371, 541351, 541327, 541356 },
        OrcMale = { 541433, 541432, 541403, 541397, 541422, 541409 },
        TaurenFemale = { 542968, 542994, 542996, 542989 },
        TaurenMale = { 543055, 543082, 543058, 543065, 543026 },
        TrollFemale = { 543241, 543247, 543228, 543245, 543257 },
        TrollMale = { 543315, 543285, 543323, 543337, 543329, 543327 },
        UndeadFemale = { 542727, 542705, 542700, 542693, 542713, 542690, 542732, 542688 },
        UndeadMale = { 542753, 542788, 542773, 542766, 542757 },
        SkyborneFemale = { 7744915, 7744916, 7744917 },
        SkyborneMale = { 7744509, 7930423, 7930426 },
    },
    moo = {
        -- /moo has dedicated player voice files only for Tauren.
        TaurenFemale = { 542820 },
        TaurenMale = { 542894 },
    },
    flee = {
        DwarfFemale = { 540000, 540009 },
        DwarfMale = { 540037, 540079, 540081 },
        GnomeFemale = { 540453, 540441, 540458 },
        GnomeMale = { 540479, 540480, 540465 },
        HumanFemale = { 540616, 540646 },
        HumanMale = { 540692, 540678 },
        NightElfFemale = { 541048, 541063 },
        NightElfMale = { 541106, 541114 },
        OrcFemale = { 541366, 541360 },
        OrcMale = { 541392, 541419 },
        TaurenFemale = { 543011, 542984 },
        TaurenMale = { 543041, 543056 },
        TrollFemale = { 543246, 543260 },
        TrollMale = { 543335, 543320 },
        UndeadFemale = { 542689, 542707 },
        UndeadMale = { 542767, 542785 },
        SkyborneFemale = { 7744885, 7744886, 7744887 },
        SkyborneMale = { 7744481, 7744480, 7744479 },
    },
    welcome = {
        DwarfFemale = { 540016, 539987, 539967 },
        DwarfMale = { 540026, 540038, 540078 },
        GnomeFemale = { 540417, 540448, 540411 },
        GnomeMale = { 540462, 540488, 540499 },
        HumanFemale = { 540651, 540656, 540620 },
        HumanMale = { 540677, 540666, 540669 },
        NightElfFemale = { 541050, 541076, 541064 },
        NightElfMale = { 541102, 541095, 541108 },
        OrcFemale = { 541353, 541359, 541324 },
        OrcMale = { 541405, 541436, 541385 },
        TaurenFemale = { 543018, 542999, 543017 },
        TaurenMale = { 543081, 543079, 543066 },
        TrollFemale = { 543238, 543275, 543276 },
        TrollMale = { 543333, 543294, 543308 },
        UndeadFemale = { 542701, 542709, 542696 },
        UndeadMale = { 542770, 542758 },
        SkyborneFemale = { 7744924, 7744926 },
        SkyborneMale = { 7930417, 7930420 },
    },
    yes = {
        DwarfFemale = { 540002, 540011, 539982 },
        DwarfMale = { 540047, 540062, 540022, 540044 },
        GnomeFemale = { 540418, 540422, 540446 },
        GnomeMale = { 540471, 540477, 540483 },
        HumanFemale = { 540624, 540605, 540632 },
        HumanMale = { 540702, 540709, 540667 },
        NightElfFemale = { 541071, 541058, 541046 },
        NightElfMale = { 541099, 541130, 541137 },
        OrcFemale = { 541331, 541365, 541319, 541338 },
        OrcMale = { 541424, 541399, 541379, 541377 },
        TaurenFemale = { 543022, 542983, 543021 },
        TaurenMale = { 543046, 543030, 543036 },
        TrollFemale = { 543267, 543268, 543249 },
        TrollMale = { 543313, 543306, 543328, 543312 },
        UndeadFemale = { 542729, 542703, 542718 },
        UndeadMale = { 542750, 542741, 542789 },
        SkyborneFemale = { 7744909, 7744910, 7744911 },
        SkyborneMale = { 7744503, 7744504, 7744505 },
    },
    no = {
        DwarfFemale = { 540003, 540012, 539996 },
        DwarfMale = { 540054, 540056, 540040, 540074 },
        GnomeFemale = { 540440, 540429, 540433 },
        GnomeMale = { 540496, 540514, 540506 },
        HumanFemale = { 540614, 540658, 540607 },
        HumanMale = { 540673, 540683, 540700, 540698 },
        NightElfFemale = { 541068, 541039, 541074 },
        NightElfMale = { 541128, 541094, 541083 },
        OrcFemale = { 541340, 541326, 541343 },
        OrcMale = { 541428, 541390, 541416 },
        TaurenFemale = { 542980, 543005, 542979 },
        TaurenMale = { 543042, 543080, 543059 },
        TrollFemale = { 543252, 543240, 543239 },
        TrollMale = { 543324, 543296, 543286, 543295 },
        UndeadFemale = { 542681, 542675, 542723 },
        UndeadMale = { 542749, 542743, 542780 },
        SkyborneFemale = { 7744906, 7744907, 7744908 },
        SkyborneMale = { 7744500, 7744501, 7744502 },
    },
}

voiceSounds.retreat = voiceSounds.flee

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

    -- JOKE text from EmotesTextData: "tells a joke", "tells a joke to",
    -- "tells you a joke", and the local "tell a joke" forms.
    if string.find(text, " tells a joke", 1, true)
        or string.find(text, " tells you a joke", 1, true)
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

    -- /flee and /retreat share the flee voice. Forever's flee lines all say
    -- "to flee". A retreat line is matched on its own wording.
    if string.find(text, " to flee", 1, true)
        or string.find(text, " retreat", 1, true)
        or string.find(text, "you retreat", 1, true) == 1 then
        return "flee"
    end

    if string.find(text, " welcomes", 1, true)
        or string.find(text, "you welcome", 1, true) == 1 then
        return "welcome"
    end

    -- /yes is the nod emote. The spoken lines are the Yes voice files.
    if string.find(text, " nods", 1, true)
        or string.find(text, "you nod", 1, true) == 1 then
        return "yes"
    end

    if string.find(text, " no.", 1, true)
        or string.find(text, "states, no", 1, true)
        or string.find(text, "state, no", 1, true) then
        return "no"
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
            print("Roar Forever: test options are roar, cheer, laugh, joke, moo, flee, retreat, welcome, yes, no.")
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

    print("Roar Forever: /rf test [roar|cheer|laugh|joke|moo|flee|retreat|welcome|yes|no] | /rf status | /rf id <FileDataID>")
end
