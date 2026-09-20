-- Persistent storage for Roar Forever.
-- We intentionally use an account-wide SavedVariables table and keep
-- character-separated profiles ourselves. This avoids relying on
-- SavedVariablesPerCharacter behavior in the Forever beta client.

local function ProfileKey()
    local name = UnitName("player") or "Unknown"
    local realm = (GetRealmName and GetRealmName()) or ""

    if realm == "" then
        return name
    end

    return name .. "-" .. realm
end

local function EnsureStorage()
    if type(RoarForeverStorage) ~= "table" then
        RoarForeverStorage = {}
    end

    if type(RoarForeverStorage.profiles) ~= "table" then
        RoarForeverStorage.profiles = {}
    end

    local key = ProfileKey()
    local profile = RoarForeverStorage.profiles[key]

    if type(profile) ~= "table" then
        profile = {}
        RoarForeverStorage.profiles[key] = profile
    end

    -- The rest of the addon continues to use RoarForeverDB. Point it at the
    -- current character's profile, while the serialised root is RoarForeverStorage.
    RoarForeverDB = profile
    return profile, key
end

RoarForever_BindCharacterDB = EnsureStorage
EnsureStorage()

local storageFrame = CreateFrame("Frame")
storageFrame:RegisterEvent("PLAYER_LOGIN")
storageFrame:SetScript("OnEvent", function()
    EnsureStorage()
end)
