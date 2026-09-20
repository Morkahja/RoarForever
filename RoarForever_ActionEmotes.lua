local eventFrame = CreateFrame("Frame")

local DEFAULT_CHANCE = 100
local DEFAULT_COOLDOWN = 6
local lastFireByAbility = {}

local db
local ui
local selectedKey
local knownAbilities = {}
local knownEmotes = {}

local function Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

local function AbilityKey(name)
    return string.lower(Trim(name))
end

local function EnsureDB()
    -- Rebind on access as well as login, so an early event cannot leave UI
    -- edits in a session-only table when the character GUID becomes available.
    if RoarForever_BindCharacterDB then
        RoarForever_BindCharacterDB()
    end
    if type(RoarForeverDB) ~= "table" then
        RoarForeverDB = {}
    end

    if RoarForeverDB.actionEmotesEnabled == nil then
        RoarForeverDB.actionEmotesEnabled = true
    end

    if type(RoarForeverDB.instances) ~= "table" then
        RoarForeverDB.instances = {}
    end

    for key, cfg in pairs(RoarForeverDB.instances) do
        if type(cfg) ~= "table" then
            RoarForeverDB.instances[key] = nil
        else
            cfg.name = cfg.name or key
            cfg.chance = tonumber(cfg.chance) or DEFAULT_CHANCE
            cfg.cooldown = tonumber(cfg.cooldown) or DEFAULT_COOLDOWN
            if type(cfg.emotes) ~= "table" then
                cfg.emotes = { ROAR = true }
            end
        end
    end

    db = RoarForeverDB
    return db
end

local function GetSpellNameByID(spellID)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(spellID)
    end

    if GetSpellInfo then
        return GetSpellInfo(spellID)
    end

    return nil
end

local function IsPassive(spellID)
    if C_Spell and C_Spell.IsSpellPassive then
        return C_Spell.IsSpellPassive(spellID)
    end

    if IsPassiveSpell then
        return IsPassiveSpell(spellID)
    end

    return false
end

local function AddKnownAbility(list, seen, name, spellID)
    if not name or name == "" or not spellID or seen[spellID] then
        return
    end

    if IsPassive(spellID) then
        return
    end

    seen[spellID] = true
    table.insert(list, { name = name, spellID = spellID })
end

local function RefreshKnownAbilities()
    local list = {}
    local seen = {}

    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo then
        local bank = (Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player) or 0
        local numTabs = C_SpellBook.GetNumSpellBookSkillLines() or 0

        for tab = 1, numTabs do
            local tabInfo = C_SpellBook.GetSpellBookSkillLineInfo(tab)
            if tabInfo then
                local offset = tabInfo.itemIndexOffset or 0
                local count = tabInfo.numSpellBookItems or 0

                for index = offset + 1, offset + count do
                    local info = C_SpellBook.GetSpellBookItemInfo(index, bank)
                    if info then
                        local spellID = info.spellID or info.actionID
                        local name = info.name or GetSpellNameByID(spellID)
                        AddKnownAbility(list, seen, name, spellID)
                    end
                end
            end
        end
    elseif GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemInfo then
        local bookType = BOOKTYPE_SPELL or "spell"
        local numTabs = GetNumSpellTabs() or 0

        for tab = 1, numTabs do
            local _, _, offset, count = GetSpellTabInfo(tab)
            offset = offset or 0
            count = count or 0

            for index = offset + 1, offset + count do
                local name
                if GetSpellBookItemName then
                    name = GetSpellBookItemName(index, bookType)
                end

                local _, spellID = GetSpellBookItemInfo(index, bookType)
                name = name or GetSpellNameByID(spellID)
                AddKnownAbility(list, seen, name, spellID)
            end
        end
    end

    table.sort(list, function(a, b)
        if a.name == b.name then
            return (a.spellID or 0) < (b.spellID or 0)
        end
        return a.name < b.name
    end)

    knownAbilities = list
end

local function RefreshKnownEmotes()
    local list = {}
    local seen = {}

    for globalName, token in pairs(_G) do
        if type(globalName) == "string" and type(token) == "string" and string.match(globalName, "^EMOTE%d+_TOKEN$") then
            token = string.upper(token)
            if token ~= "" and not seen[token] then
                seen[token] = true
                table.insert(list, token)
            end
        end
    end

    if not seen.ROAR then
        table.insert(list, "ROAR")
        seen.ROAR = true
    end

    table.sort(list)
    knownEmotes = list
end

local function EmoteLabel(token)
    if GetEmoteSlashCmd then
        local ok, command = pcall(GetEmoteSlashCmd, token)
        if ok and type(command) == "string" and command ~= "" then
            return command
        end
    end

    return "/" .. string.lower(token)
end

local function SortedInstanceKeys()
    EnsureDB()
    local keys = {}

    for key in pairs(db.instances) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return (db.instances[a].name or a) < (db.instances[b].name or b)
    end)

    return keys
end

local function PickRandomEmote(cfg)
    local pool = {}

    for token, enabled in pairs(cfg.emotes or {}) do
        if enabled then
            table.insert(pool, token)
        end
    end

    if #pool == 0 then
        return nil
    end

    return pool[math.random(1, #pool)]
end

local function TryAbilityEmote(spellID)
    EnsureDB()

    if not db.actionEmotesEnabled then
        return
    end

    local spellName = GetSpellNameByID(spellID)
    if not spellName then
        return
    end

    local key = AbilityKey(spellName)
    local cfg = db.instances[key]
    if not cfg then
        return
    end

    cfg.spellID = spellID
    cfg.name = spellName

    local now = GetTime()
    local last = lastFireByAbility[key] or 0
    local cooldown = tonumber(cfg.cooldown) or 0

    if now - last < cooldown then
        return
    end

    local chance = tonumber(cfg.chance) or DEFAULT_CHANCE
    if math.random(1, 100) > chance then
        return
    end

    local token = PickRandomEmote(cfg)
    if not token then
        return
    end

    lastFireByAbility[key] = now
    DoEmote(token)
end

local function AddOrSelectAbility(ability)
    EnsureDB()

    local key = AbilityKey(ability.name)
    local cfg = db.instances[key]

    if not cfg then
        cfg = {
            name = ability.name,
            spellID = ability.spellID,
            chance = DEFAULT_CHANCE,
            cooldown = DEFAULT_COOLDOWN,
            emotes = { ROAR = true },
        }
        db.instances[key] = cfg
    else
        cfg.name = ability.name
        cfg.spellID = ability.spellID
    end

    selectedKey = key
end

local function CreateCheckbox(parent, label, x, y)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 2, 1)
    text:SetText(label)
    check.label = text
    return check
end

local function CreateUI()
    if ui then
        return ui
    end

    if not UIDropDownMenu_Initialize and C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_UIDropDownMenu")
    end

    ui = CreateFrame("Frame", "RoarForeverConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    ui:SetSize(620, 520)
    ui:SetPoint("CENTER")
    ui:SetFrameStrata("DIALOG")
    ui:SetMovable(true)
    ui:EnableMouse(true)
    ui:RegisterForDrag("LeftButton")
    ui:SetScript("OnDragStart", function(self) self:StartMoving() end)
    ui:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    ui:Hide()
    table.insert(UISpecialFrames, "RoarForeverConfigFrame")

    ui.TitleText:SetText("Roar Forever")

    ui.enabled = CreateCheckbox(ui, "Enable ability emotes", 18, -38)
    ui.enabled:SetScript("OnClick", function(self)
        EnsureDB()
        db.actionEmotesEnabled = self:GetChecked() and true or false
    end)

    local chooseLabel = ui:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chooseLabel:SetPoint("TOPLEFT", ui, "TOPLEFT", 18, -78)
    chooseLabel:SetText("Add ability")

    ui.abilityDrop = CreateFrame("Frame", "RoarForeverAbilityDropDown", ui, "UIDropDownMenuTemplate")
    ui.abilityDrop:SetPoint("TOPLEFT", ui, "TOPLEFT", 95, -67)
    UIDropDownMenu_SetWidth(ui.abilityDrop, 210)
    UIDropDownMenu_SetText(ui.abilityDrop, "Choose ability...")

    UIDropDownMenu_Initialize(ui.abilityDrop, function(self, level)
        for _, ability in ipairs(knownAbilities) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = ability.name
            info.notCheckable = true
            info.func = function()
                AddOrSelectAbility(ability)
                UIDropDownMenu_SetText(ui.abilityDrop, ability.name)
                ui:Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local leftTitle = ui:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leftTitle:SetPoint("TOPLEFT", ui, "TOPLEFT", 20, -120)
    leftTitle:SetText("Configured abilities")

    ui.instanceScroll = CreateFrame("ScrollFrame", nil, ui, "UIPanelScrollFrameTemplate")
    ui.instanceScroll:SetPoint("TOPLEFT", ui, "TOPLEFT", 18, -142)
    ui.instanceScroll:SetSize(210, 310)

    ui.instanceChild = CreateFrame("Frame", nil, ui.instanceScroll)
    ui.instanceChild:SetSize(190, 1)
    ui.instanceScroll:SetScrollChild(ui.instanceChild)
    ui.instanceButtons = {}

    ui.remove = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
    ui.remove:SetSize(95, 24)
    ui.remove:SetPoint("BOTTOMLEFT", ui, "BOTTOMLEFT", 20, 20)
    ui.remove:SetText("Remove")
    ui.remove:SetScript("OnClick", function()
        if selectedKey then
            EnsureDB()
            db.instances[selectedKey] = nil
            lastFireByAbility[selectedKey] = nil
            selectedKey = nil
            ui:Refresh()
        end
    end)

    ui.editor = CreateFrame("Frame", nil, ui)
    ui.editor:SetPoint("TOPLEFT", ui, "TOPLEFT", 250, -116)
    ui.editor:SetSize(342, 370)

    ui.editorTitle = ui.editor:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    ui.editorTitle:SetPoint("TOPLEFT", ui.editor, "TOPLEFT", 0, 0)

    ui.chance = CreateFrame("Slider", "RoarForeverChanceSlider", ui.editor, "OptionsSliderTemplate")
    ui.chance:SetPoint("TOPLEFT", ui.editor, "TOPLEFT", 10, -48)
    ui.chance:SetSize(285, 18)
    ui.chance:SetMinMaxValues(0, 100)
    ui.chance:SetValueStep(1)
    ui.chance:SetObeyStepOnDrag(true)
    _G[ui.chance:GetName() .. "Low"]:SetText("0%")
    _G[ui.chance:GetName() .. "High"]:SetText("100%")
    ui.chance:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText("Chance: " .. value .. "%")
        if not ui.updating and selectedKey then
            EnsureDB()
            local cfg = db.instances[selectedKey]
            if cfg then cfg.chance = value end
        end
    end)

    ui.cooldown = CreateFrame("Slider", "RoarForeverCooldownSlider", ui.editor, "OptionsSliderTemplate")
    ui.cooldown:SetPoint("TOPLEFT", ui.editor, "TOPLEFT", 10, -103)
    ui.cooldown:SetSize(285, 18)
    ui.cooldown:SetMinMaxValues(0, 120)
    ui.cooldown:SetValueStep(1)
    ui.cooldown:SetObeyStepOnDrag(true)
    _G[ui.cooldown:GetName() .. "Low"]:SetText("0s")
    _G[ui.cooldown:GetName() .. "High"]:SetText("120s")
    ui.cooldown:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText("Cooldown: " .. value .. " sec")
        if not ui.updating and selectedKey then
            EnsureDB()
            local cfg = db.instances[selectedKey]
            if cfg then cfg.cooldown = value end
        end
    end)

    local emoteTitle = ui.editor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emoteTitle:SetPoint("TOPLEFT", ui.editor, "TOPLEFT", 0, -153)
    emoteTitle:SetText("Emotes (one is chosen at random)")

    ui.emoteScroll = CreateFrame("ScrollFrame", nil, ui.editor, "UIPanelScrollFrameTemplate")
    ui.emoteScroll:SetPoint("TOPLEFT", ui.editor, "TOPLEFT", 0, -174)
    ui.emoteScroll:SetSize(315, 190)

    ui.emoteChild = CreateFrame("Frame", nil, ui.emoteScroll)
    ui.emoteChild:SetSize(290, 1)
    ui.emoteScroll:SetScrollChild(ui.emoteChild)
    ui.emoteChecks = {}

    function ui:RefreshInstances()
        local keys = SortedInstanceKeys()

        for i, key in ipairs(keys) do
            local button = self.instanceButtons[i]
            if not button then
                button = CreateFrame("Button", nil, self.instanceChild, "UIPanelButtonTemplate")
                button:SetSize(178, 24)
                button:SetScript("OnClick", function(btn)
                    selectedKey = btn.abilityKey
                    self:Refresh()
                end)
                self.instanceButtons[i] = button
            end

            button:SetPoint("TOPLEFT", self.instanceChild, "TOPLEFT", 0, -((i - 1) * 27))
            button.abilityKey = key
            button:SetText(db.instances[key].name or key)
            button:Show()

            if key == selectedKey then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end
        end

        for i = #keys + 1, #self.instanceButtons do
            self.instanceButtons[i]:Hide()
        end

        self.instanceChild:SetHeight(math.max(1, #keys * 27))
    end

    function ui:RefreshEmotes(cfg)
        for i, token in ipairs(knownEmotes) do
            local check = self.emoteChecks[i]
            if not check then
                check = CreateCheckbox(self.emoteChild, "", 0, 0)
                check:SetScript("OnClick", function(btn)
                    if not selectedKey then return end
                    EnsureDB()
                    local current = db.instances[selectedKey]
                    if not current then return end
                    current.emotes[btn.token] = btn:GetChecked() and true or nil
                end)
                self.emoteChecks[i] = check
            end

            check:SetPoint("TOPLEFT", self.emoteChild, "TOPLEFT", 0, -((i - 1) * 24))
            check.token = token
            check.label:SetText(EmoteLabel(token))
            check:SetChecked(cfg.emotes[token] and true or false)
            check:Show()
        end

        for i = #knownEmotes + 1, #self.emoteChecks do
            self.emoteChecks[i]:Hide()
        end

        self.emoteChild:SetHeight(math.max(1, #knownEmotes * 24))
    end

    function ui:Refresh()
        EnsureDB()
        self.enabled:SetChecked(db.actionEmotesEnabled)
        self:RefreshInstances()

        local cfg = selectedKey and db.instances[selectedKey]
        if not cfg then
            self.editor:Hide()
            self.remove:Disable()
            return
        end

        self.remove:Enable()
        self.editor:Show()
        self.editorTitle:SetText(cfg.name or selectedKey)

        self.updating = true
        self.chance:SetValue(tonumber(cfg.chance) or DEFAULT_CHANCE)
        self.cooldown:SetValue(tonumber(cfg.cooldown) or DEFAULT_COOLDOWN)
        self.updating = false

        self:RefreshEmotes(cfg)
    end

    ui:SetScript("OnShow", function(self)
        EnsureDB()
        RefreshKnownAbilities()
        RefreshKnownEmotes()
        self:Refresh()
    end)

    return ui
end

function RoarForever_OpenConfig()
    local frame = CreateUI()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

function RoarForever_ActionStatus()
    EnsureDB()
    local count = 0
    for _ in pairs(db.instances) do count = count + 1 end
    return db.actionEmotesEnabled, count
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" and spellID then
            TryAbilityEmote(spellID)
        end
    elseif event == "SPELLS_CHANGED" then
        if ui and ui:IsShown() then
            RefreshKnownAbilities()
            ui:Refresh()
        end
    end
end)

eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("SPELLS_CHANGED")
