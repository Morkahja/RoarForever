-- Persistent storage for Roar Forever.
-- WoW Forever is realmless, so profiles are keyed by the character GUID.
-- A GUID is stable for the character and does not depend on realm naming.

-- The preceding XML loads the live saved file when local recovery is enabled.
-- Capture it before the client's normal SavedVariables pass can clear it.
local recoveryStorage = RoarForeverStorage
local recoveryReady = type(recoveryStorage) == "table"

local function EnsureRoot()
    if type(RoarForeverStorage) ~= "table" then
        if recoveryReady then
            RoarForeverStorage = recoveryStorage
        else
            RoarForeverStorage = {}
        end
    end

    if type(RoarForeverStorage.profiles) ~= "table" then
        RoarForeverStorage.profiles = {}
    end
end

local function LegacyKeys()
    local keys = {}
    local name = UnitName("player")
    if not name or name == "" then
        return keys
    end

    keys[#keys + 1] = name

    local realm = (GetRealmName and GetRealmName()) or ""
    if realm ~= "" then
        keys[#keys + 1] = name .. "-" .. realm
    end

    return keys
end

local function BindCharacterDB()
    EnsureRoot()

    local guid = UnitGUID("player")
    if not guid or guid == "" then
        return nil
    end

    local profile = RoarForeverStorage.profiles[guid]

    -- Migrate a profile created by the earlier name/realm-keyed version.
    if type(profile) ~= "table" then
        for _, oldKey in ipairs(LegacyKeys()) do
            local oldProfile = RoarForeverStorage.profiles[oldKey]
            if type(oldProfile) == "table" then
                profile = oldProfile
                RoarForeverStorage.profiles[oldKey] = nil
                break
            end
        end
    end

    if type(profile) ~= "table" then
        profile = {}
    end

    RoarForeverStorage.profiles[guid] = profile
    RoarForeverDB = profile
    return profile, guid
end

RoarForever_BindCharacterDB = BindCharacterDB

function RoarForever_StorageStatus()
    local _, guid = BindCharacterDB()
    if not guid then
        return "character profile unavailable"
    end
    if recoveryReady then
        return "built-in recovery loaded; profile " .. guid
    end
    return "standard client saving; profile " .. guid .. " (Forever beta may fail to restore settings)"
end

local storageFrame = CreateFrame("Frame")
storageFrame:RegisterEvent("PLAYER_LOGIN")
storageFrame:SetScript("OnEvent", function()
    BindCharacterDB()
end)
