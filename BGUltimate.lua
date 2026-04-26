-- =========================
-- BG ULTIMATE ADDON (CLEAN UI v2)
-- =========================

local f = CreateFrame("Frame")

-- EVENTS
f:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
f:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

local triggered = false

-- =========================
-- CONFIG
-- =========================
local COUNTDOWN_DELAY = 19
local COUNTDOWN_LENGTH = 10
local AV_ZERO_HK_THRESHOLD_SECONDS = 900

-- =========================
-- SOUNDS
-- =========================
local function playCountdown()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\10.ogg", "Master")
end

local function playIntro()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\intro.ogg", "Master")
end

-- =========================
-- AV TRACKER STATE
-- =========================
local tracker = {
    honorEarned = 0,
    avTimerStartedAt = nil,
    flaggedPlayers = {},
    inAV = false,
}

local trackerTicker = nil

local function IsInAlteracValley()
    return GetRealZoneText() == "Alterac Valley"
end

local function ResetTracker()
    tracker.honorEarned = 0
    tracker.avTimerStartedAt = nil
    wipe(tracker.flaggedPlayers)
end

local function EnsureAVTicker()
    if trackerTicker then
        return
    end

    trackerTicker = C_Timer.NewTicker(10, function()
        if not tracker.inAV then
            return
        end

        if not tracker.avTimerStartedAt then
            return
        end

        local elapsed = GetTime() - tracker.avTimerStartedAt
        if elapsed < AV_ZERO_HK_THRESHOLD_SECONDS then
            return
        end

        RequestBattlefieldScoreData()
    end)
end

-- =========================
-- AV TRACKER UI
-- =========================
local avTrackerFrame = CreateFrame("Frame", "BGAVTrackerFrame", UIParent)
avTrackerFrame:SetSize(220, 64)
avTrackerFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -24, -220)
avTrackerFrame:SetMovable(true)
avTrackerFrame:EnableMouse(true)
avTrackerFrame:RegisterForDrag("LeftButton")
avTrackerFrame:SetScript("OnDragStart", avTrackerFrame.StartMoving)
avTrackerFrame:SetScript("OnDragStop", avTrackerFrame.StopMovingOrSizing)
if avTrackerFrame.SetBackdrop then
    avTrackerFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    avTrackerFrame:SetBackdropColor(0, 0, 0, 0.7)
    avTrackerFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0.9)
end
avTrackerFrame:Hide()

local avTitle = avTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
avTitle:SetPoint("TOPLEFT", avTrackerFrame, "TOPLEFT", 10, -10)
avTitle:SetText("AV Tracker")

local honorText = avTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
honorText:SetPoint("TOPLEFT", avTitle, "BOTTOMLEFT", 0, -8)
honorText:SetJustifyH("LEFT")
honorText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
honorText:SetTextColor(1, 0.82, 0)
honorText:SetShadowOffset(1, -1)
honorText:SetText("|cffFFD24CHonor Earned:|r 0")

local suspectsText = avTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
suspectsText:SetPoint("TOPLEFT", honorText, "BOTTOMLEFT", 0, -8)
suspectsText:SetWidth(196)
suspectsText:SetJustifyH("LEFT")
suspectsText:SetJustifyV("TOP")
suspectsText:SetText("")

local function UpdateTrackerUI()
    if tracker.inAV then
        avTrackerFrame:Show()
    else
        avTrackerFrame:Hide()
        return
    end

    honorText:SetText(string.format("|cffFFD24CHonor Earned:|r %d", tracker.honorEarned))

    local names = {}
    for name, _ in pairs(tracker.flaggedPlayers) do
        table.insert(names, name)
    end

    table.sort(names)

    local elapsed = 0
    if tracker.avTimerStartedAt then
        elapsed = GetTime() - tracker.avTimerStartedAt
    end

    if elapsed < AV_ZERO_HK_THRESHOLD_SECONDS or #names == 0 then
        suspectsText:SetText("")
        avTrackerFrame:SetHeight(64)
    else
        suspectsText:SetText("|cffff6b6bSuspicious (0 HK after 15m):|r " .. table.concat(names, ", "))
        avTrackerFrame:SetHeight(120)
    end
end

local function UpdateAVState()
    tracker.inAV = IsInAlteracValley()

    if not tracker.inAV then
        ResetTracker()
    end

    UpdateTrackerUI()
end

local function ParseHonorGain(msg)
    if not msg then
        return 0
    end

    local honorValue = msg:match("([%d]+)")
    if honorValue then
        return tonumber(honorValue) or 0
    end

    return 0
end

-- =========================
-- PANEL (BLIZZARD STYLE)
-- =========================
local panel = CreateFrame("Frame", "BGPanelFrame", UIParent, "UIPanelDialogTemplate")
panel:SetSize(420, 320)
panel:SetPoint("CENTER")
panel:Hide()

table.insert(UISpecialFrames, "BGPanelFrame")

-- Proper title placement (no overlap)
local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", panel, "TOP", 0, -28)
title:SetText("Battlegrounds")
title:SetTextColor(1, 0.82, 0)

-- =========================
-- BUTTON CREATOR (TOP ANCHORED)
-- =========================
local function CreateButton(text, index, cmd)
    local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    b:SetSize(240, 32)

    -- Proper spacing from top
    b:SetPoint("TOP", panel, "TOP", 0, -70 - (index * 45))

    b:SetText(text)

    -- Font
    b:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    b:GetFontString():SetTextColor(1, 0.82, 0)

    -- Hover glow
    local glow = b:CreateTexture(nil, "HIGHLIGHT")
    glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    glow:SetBlendMode("ADD")
    glow:SetAllPoints()

    -- Click
    b:SetScript("OnClick", function()
        SendChatMessage(cmd, "SAY")
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        panel:Hide()
    end)
end

-- BUTTONS (clean spacing)
CreateButton("Warsong Gulch", 0, ".go warsong")
CreateButton("Arathi Basin", 1, ".go arathi")
CreateButton("Alterac Valley", 2, ".go alterac")

-- =========================
-- MAIN BUTTON (BOTTOM RIGHT)
-- =========================
local bgBtn = CreateFrame("Button", "BGLFGButton", UIParent)
bgBtn:SetSize(36, 36)
bgBtn:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -90, 40)
bgBtn:SetFrameStrata("HIGH")

-- background
local btnBG = bgBtn:CreateTexture(nil, "BACKGROUND")
btnBG:SetAllPoints()
btnBG:SetTexture("Interface\\Buttons\\UI-Quickslot2")

-- icon
local icon = bgBtn:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\Icons\\INV_Sword_27")
icon:SetSize(20, 20)
icon:SetPoint("CENTER")

-- border
local border = bgBtn:CreateTexture(nil, "OVERLAY")
border:SetAllPoints()
border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
border:SetBlendMode("ADD")
border:SetAlpha(0.8)

-- hover
local highlight = bgBtn:CreateTexture(nil, "HIGHLIGHT")
highlight:SetAllPoints()
highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
highlight:SetBlendMode("ADD")

-- click
bgBtn:SetScript("OnClick", function()
    if panel:IsShown() then
        panel:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    else
        panel:Show()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end
end)

-- tooltip
bgBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Battlegrounds")
    GameTooltip:AddLine("Ready for battle", 1, 0.8, 0)
    GameTooltip:Show()
end)

bgBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

bgBtn:Show()

-- =========================
-- PULSE EFFECT
-- =========================
local pulse = bgBtn:CreateAnimationGroup()

local fade1 = pulse:CreateAnimation("Alpha")
fade1:SetFromAlpha(0.5)
fade1:SetToAlpha(1)
fade1:SetDuration(0.8)
fade1:SetOrder(1)

local fade2 = pulse:CreateAnimation("Alpha")
fade2:SetFromAlpha(1)
fade2:SetToAlpha(0.5)
fade2:SetDuration(0.8)
fade2:SetOrder(2)

pulse:SetLooping("REPEAT")
pulse:Play()

EnsureAVTicker()

-- =========================
-- BG COUNTDOWN + TRACKER EVENTS
-- =========================
f:SetScript("OnEvent", function(self, event, msg)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        triggered = false
        UpdateAVState()
        return
    end

    if event == "CHAT_MSG_COMBAT_HONOR_GAIN" and tracker.inAV then
        tracker.honorEarned = tracker.honorEarned + ParseHonorGain(msg)
        UpdateTrackerUI()
        return
    end

    if event == "UPDATE_BATTLEFIELD_SCORE" and tracker.inAV and tracker.avTimerStartedAt then
        local elapsed = GetTime() - tracker.avTimerStartedAt
        if elapsed >= AV_ZERO_HK_THRESHOLD_SECONDS then
            for i = 1, GetNumBattlefieldScores() do
                local name, _, honorableKills = GetBattlefieldScore(i)
                if name and honorableKills == 0 and not string.find(name, "*", 1, true) then
                    tracker.flaggedPlayers[name] = true
                end
            end
            UpdateTrackerUI()
        end
        return
    end

    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" and msg then
        if not triggered and string.find(msg, "30") then
            triggered = true

            if tracker.inAV then
                tracker.avTimerStartedAt = GetTime() + COUNTDOWN_DELAY
                UpdateTrackerUI()
            end

            C_Timer.After(COUNTDOWN_DELAY, function()
                playCountdown()

                C_Timer.After(COUNTDOWN_LENGTH, function()
                    playIntro()
                end)
            end)
        end
    end
end)
