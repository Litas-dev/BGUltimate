-- =========================
-- BG ULTIMATE ADDON (v6)
-- =========================

local f = CreateFrame("Frame")

-- EVENTS
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
f:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")

-- =========================
-- STATE
-- =========================
local tracker = {
    sessionHonor = 0,
    inAV = false,
}

local triggered = false

-- =========================
-- CONFIG
-- =========================
local COUNTDOWN_DELAY = 19
local COUNTDOWN_LENGTH = 10

-- =========================
-- SOUND SYSTEM (RESTORED)
-- =========================
local function playCountdown()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\10.ogg", "Master")
end

local function playIntro()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\intro.ogg", "Master")
end

-- =========================
-- AV CHECK
-- =========================
local function IsInAlteracValley()
    return GetRealZoneText() == "Alterac Valley"
end

-- =========================
-- PARSE HONOR
-- =========================
local function ParseHonorGain(msg)
    if not msg then return 0 end
    local val = msg:match("(%d+)")
    return tonumber(val) or 0
end

-- =========================
-- UI
-- =========================
local frame = CreateFrame("Frame", "BGAVTrackerFrame", UIParent, "BackdropTemplate")
frame:SetSize(320, 150)
frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -24, -220)

frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
})

frame:SetBackdropColor(0,0,0,0.75)
frame:SetBackdropBorderColor(0.7,0.7,0.7,0.9)

-- TITLE
local title = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOPLEFT",10,-10)
title:SetText("ALTERAC VALLEY • PERFORMANCE")
title:SetTextColor(1,0.85,0.2)

-- SESSION
local sessionText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
sessionText:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-10)

-- THIS WEEK
local weekText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
weekText:SetPoint("TOPLEFT",sessionText,"BOTTOMLEFT",0,-8)

-- LAST WEEK
local lastWeekText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
lastWeekText:SetPoint("TOPLEFT",weekText,"BOTTOMLEFT",0,-6)

-- STANDING
local standingText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
standingText:SetPoint("TOPLEFT",lastWeekText,"BOTTOMLEFT",0,-6)

frame:Hide()

-- =========================
-- UPDATE UI
-- =========================
local function UpdateUI()
    if not tracker.inAV then
        frame:Hide()
        return
    end

    frame:Show()

    sessionText:SetText("|cffFFD24CSession Honor:|r " .. tracker.sessionHonor)

    local thisWeekHonor, lastWeekHonor, lastWeekStanding = GetPVPLastWeekStats()

    weekText:SetText("|cff00ff98This Week:|r " .. (thisWeekHonor or 0))
    lastWeekText:SetText("|cff8888ffLast Week Honor:|r " .. (lastWeekHonor or 0))

    if lastWeekStanding and lastWeekStanding > 0 then
        standingText:SetText("|cffffd200Standing:|r #" .. lastWeekStanding)
    else
        standingText:SetText("|cff9d9d9dStanding:|r N/A")
    end
end

-- =========================
-- EVENTS
-- =========================
f:SetScript("OnEvent", function(self, event, msg)

    -- ENTER / ZONE CHANGE
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        tracker.inAV = IsInAlteracValley()
        triggered = false
        UpdateUI()
        return
    end

    -- HONOR TRACK
    if event == "CHAT_MSG_COMBAT_HONOR_GAIN" and tracker.inAV then
        tracker.sessionHonor = tracker.sessionHonor + ParseHonorGain(msg)
        UpdateUI()
        return
    end

    -- SOUND TRIGGER (RESTORED)
    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" and msg then
        -- safer match (avoid random "30")
        if not triggered and string.find(msg, "30 seconds") then
            triggered = true

            C_Timer.After(COUNTDOWN_DELAY, function()
                playCountdown()

                C_Timer.After(COUNTDOWN_LENGTH, function()
                    playIntro()
                end)
            end)
        end
    end
end)
