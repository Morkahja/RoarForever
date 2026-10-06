local _, RF = ...
local L = RF.locale.ui
local panel

local function Checkbox(parent, label, x, y, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check:SetPoint("TOPLEFT", x, y)
    local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 4, 0)
    text:SetText(label)
    check:SetScript("OnClick", function(self) onClick(self:GetChecked() and true or false) end)
    return check
end

local function BuildPanel()
    panel = CreateFrame("Frame", "RoarForeverOptions", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(540, 550)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel.TitleText:SetText("Roar Forever")
    panel:Hide()
    table.insert(UISpecialFrames, "RoarForeverOptions")

    panel.master = Checkbox(panel, L.enabled, 18, -34, RF.SetAddonEnabled)
    panel.announce = Checkbox(panel, L.announce, 18, -65, function(enabled)
        RF.SettingsDB().announceTrain = enabled
    end)
    local note = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", 22, -100)
    note:SetWidth(488)
    note:SetJustifyH("LEFT")
    note:SetText(L.note)

    local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", 24, -145)
    heading:SetText(L.emote)
    local previewHeading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewHeading:SetPoint("TOPRIGHT", -53, -145)
    previewHeading:SetText(L.listen)

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -167)
    scroll:SetPoint("BOTTOMRIGHT", -40, 20)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(476, #RF.order * 31)
    scroll:SetScrollChild(content)
    panel.rows = {}
    for index, emote in ipairs(RF.order) do
        local key = emote
        local check = Checkbox(content, RF.locale.labels[key], 0, -(index - 1) * 31, function(enabled)
            RF.SettingsDB().emotes[key] = enabled
        end)
        panel.rows[key] = check
        local speaker = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        speaker:SetSize(32, 25)
        speaker:SetPoint("TOPRIGHT", -4, -(index - 1) * 31)
        local icon = speaker:CreateTexture(nil, "ARTWORK")
        icon:SetSize(18, 18)
        icon:SetPoint("CENTER")
        icon:SetTexture("Interface\\Common\\VoiceChat-Speaker")
        speaker:SetScript("OnClick", function()
            if not RF.Preview(key) then print("Roar Forever: " .. L.failed) end
        end)
        speaker:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L.preview, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        speaker:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    panel:SetScript("OnShow", function(self)
        self.master:SetChecked(RF.AddonEnabled())
        self.announce:SetChecked(RF.SettingsDB().announceTrain ~= false)
        for emote, check in pairs(self.rows) do check:SetChecked(RF.EmoteEnabled(emote)) end
    end)
end

function RF.OpenOptions()
    if not panel then BuildPanel() end
    if panel:IsShown() then panel:Hide() else panel:Show() end
end
