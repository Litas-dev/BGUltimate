-- =========================
-- BG ULTIMATE ADDON (CLEAN UI v2)
-- =========================

local f = CreateFrame("Frame")

-- EVENTS
f:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

local triggered = false

-- =========================
-- CONFIG
-- =========================
local COUNTDOWN_DELAY = 19
local COUNTDOWN_LENGTH = 10

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

-- =========================
-- BG COUNTDOWN
-- =========================
f:SetScript("OnEvent", function(self, event, msg)

    if event == "PLAYER_ENTERING_WORLD" then
        triggered = false
    end

    if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" and msg then
        if not triggered and string.find(msg, "30") then
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
