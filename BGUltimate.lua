-- =========================
-- BG ULTIMATE ADDON (v7 FULL)
-- =========================

local f = CreateFrame("Frame")

-- EVENTS
f:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
f:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

-- =========================
-- CONFIG
-- =========================
local COUNTDOWN_DELAY = 19
local COUNTDOWN_LENGTH = 10
local AV_ZERO_HK_THRESHOLD_SECONDS = 900

-- =========================
-- STATE
-- =========================
local triggered = false

local tracker = {
    sessionHonor = 0,
    honorEarned = 0,
    avTimerStartedAt = nil,
    flaggedPlayers = {},
    inAV = false,
}

local trackerTicker = nil

-- =========================
-- SOUND SYSTEM
-- =========================
local function playCountdown()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\10.ogg", "Master")
end

local function playIntro()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\intro.ogg", "Master")
end

-- =========================
-- HELPERS
-- =========================
local function IsInAlteracValley()
    return GetRealZoneText() == "Alterac Valley"
end

local function ResetTracker()
    tracker.honorEarned = 0
    tracker.sessionHonor = 0
    tracker.avTimerStartedAt = nil
    wipe(tracker.flaggedPlayers)
end

local function ParseHonorGain(msg)
    if not msg then return 0 end
    local v = msg:match("(%d+)")
    return tonumber(v) or 0
end

-- =========================
-- AV TICKER (SCAN LOOP)
-- =========================
local function EnsureAVTicker()
    if trackerTicker then return end

    trackerTicker = C_Timer.NewTicker(10, function()
        if not tracker.inAV then return end
        if not tracker.avTimerStartedAt then return end

        local elapsed = GetTime() - tracker.avTimerStartedAt
        if elapsed < AV_ZERO_HK_THRESHOLD_SECONDS then return end

        RequestBattlefieldScoreData()
    end)
end

-- =========================
-- UI (MAIN PANEL)
-- =========================
local frame = CreateFrame("Frame", "BGAVTrackerFrame", UIParent, "BackdropTemplate")
frame:SetSize(320, 180)
frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -24, -220)

frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
})

frame:SetBackdropColor(0,0,0,0.75)
frame:SetBackdropBorderColor(0.7,0.7,0.7,0.9)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- TITLE
local title = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOPLEFT",10,-10)
title:SetText("ALTERAC VALLEY • OPERATIONS")
title:SetTextColor(1,0.85,0.2)

-- SESSION
local sessionText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
sessionText:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-10)

-- WEEK
local weekText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
weekText:SetPoint("TOPLEFT",sessionText,"BOTTOMLEFT",0,-6)

-- LAST WEEK
local lastWeekText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
lastWeekText:SetPoint("TOPLEFT",weekText,"BOTTOMLEFT",0,-4)

-- STANDING
local standingText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
standingText:SetPoint("TOPLEFT",lastWeekText,"BOTTOMLEFT",0,-4)

-- SUSPECTS
local suspectsText = frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
suspectsText:SetPoint("TOPLEFT",standingText,"BOTTOMLEFT",0,-8)
suspectsText:SetWidth(300)
suspectsText:SetJustifyH("LEFT")
suspectsText:SetJustifyV("TOP")

frame:Hide()

-- =========================
-- UI UPDATE
-- =========================
local function UpdateUI()
    if not tracker.inAV then
        frame:Hide()
        return
    end

    frame:Show()

    sessionText:SetText("|cffFFD24CSession Honor:|r " .. tracker.sessionHonor)

    local thisWeek, lastWeek, standing = GetPVPLastWeekStats()

    weekText:SetText("|cff00ff98This Week:|r " .. (thisWeek or 0))
    lastWeekText:SetText("|cff8888ffLast Week:|r " .. (lastWeek or 0))

    if standing and standing > 0 then
        standingText:SetText("|cffffd200Standing:|r #" .. standing)
    else
        standingText:SetText("|cff9d9d9dStanding:|r N/A")
    end

    -- suspects
    local names = {}
    for n in pairs(tracker.flaggedPlayers) do table.insert(names,n) end
    table.sort(names)

    if #names == 0 then
        suspectsText:SetText("|cff9d9d9dStatus: No inactive players detected")
    else
        local txt = "|cffff5555Low Activity Players:|r\n"
        for i=1,#names do
            txt = txt .. "• " .. names[i] .. "\n"
        end
        suspectsText:SetText(txt)
    end
end

-- =========================
-- BG PANEL BUTTON
-- =========================
local panel = CreateFrame("Frame","BGPanelFrame",UIParent,"UIPanelDialogTemplate")
panel:SetSize(420,320)
panel:SetPoint("CENTER")
panel:Hide()
table.insert(UISpecialFrames,"BGPanelFrame")

local function CreateButton(text,index,cmd)
    local b = CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    b:SetSize(240,32)
    b:SetPoint("TOP",panel,"TOP",0,-70-(index*45))
    b:SetText(text)

    b:SetScript("OnClick",function()
        SendChatMessage(cmd,"SAY")
        panel:Hide()
    end)
end

CreateButton("Warsong Gulch",0,".go warsong")
CreateButton("Arathi Basin",1,".go arathi")
CreateButton("Alterac Valley",2,".go alterac")

local btn = CreateFrame("Button",nil,UIParent)
btn:SetSize(36,36)
btn:SetPoint("BOTTOMRIGHT",-90,40)

local icon = btn:CreateTexture(nil,"ARTWORK")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\INV_Sword_27")

btn:SetScript("OnClick",function()
    if panel:IsShown() then panel:Hide() else panel:Show() end
end)

-- =========================
-- EVENTS
-- =========================
f:SetScript("OnEvent",function(self,event,msg)

    if event=="PLAYER_ENTERING_WORLD" or event=="ZONE_CHANGED_NEW_AREA" then
        tracker.inAV = IsInAlteracValley()
        triggered = false
        if not tracker.inAV then ResetTracker() end
        UpdateUI()
        return
    end

    if event=="CHAT_MSG_COMBAT_HONOR_GAIN" and tracker.inAV then
        local g = ParseHonorGain(msg)
        tracker.sessionHonor = tracker.sessionHonor + g
        tracker.honorEarned = tracker.honorEarned + g
        UpdateUI()
        return
    end

    if event=="UPDATE_BATTLEFIELD_SCORE" and tracker.inAV and tracker.avTimerStartedAt then
        local elapsed = GetTime() - tracker.avTimerStartedAt
        if elapsed >= AV_ZERO_HK_THRESHOLD_SECONDS then
            for i=1,GetNumBattlefieldScores() do
                local name,_,hk = GetBattlefieldScore(i)
                if name and hk==0 then
                    tracker.flaggedPlayers[name]=true
                end
            end
            UpdateUI()
        end
        return
    end

    -- SOUND + TIMER START
    if event=="CHAT_MSG_BG_SYSTEM_NEUTRAL" and msg then
        if not triggered and string.find(msg,"30 seconds") then
            triggered = true

            if tracker.inAV then
                tracker.avTimerStartedAt = GetTime() + COUNTDOWN_DELAY
            end

            C_Timer.After(COUNTDOWN_DELAY,function()
                playCountdown()
                C_Timer.After(COUNTDOWN_LENGTH,playIntro)
            end)
        end
    end
end)

EnsureAVTicker()
