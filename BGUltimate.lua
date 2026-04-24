
-- BG ULTIMATE ADDON 

local f = CreateFrame("Frame")

-- EVENTS
f:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

local triggered = false


-- CONFIG

local COUNTDOWN_DELAY = 19
local COUNTDOWN_LENGTH = 10


-- SOUNDS

local function playCountdown()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\10.ogg", "Master")
end

local function playIntro()
    PlaySoundFile("Interface\\AddOns\\BGUltimate\\sounds\\intro.ogg", "Master")
end


-- PANEL 

local panel = CreateFrame("Frame", "BGPanelFrame", UIParent)
panel:SetSize(420, 300)
panel:SetPoint("CENTER")
panel:Hide()

table.insert(UISpecialFrames, "BGPanelFrame")

-- DARK BACKGROUND
panel.bg = panel:CreateTexture(nil, "BACKGROUND")
panel.bg:SetAllPoints()
panel.bg:SetColorTexture(0.05, 0.05, 0.05, 0.95)

-- GRADIENT
panel.gradient = panel:CreateTexture(nil, "ARTWORK")
panel.gradient:SetAllPoints()
panel.gradient:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
panel.gradient:SetGradientAlpha("VERTICAL",
    0,0,0,0.2,
    0,0,0,0.8
)

-- BORDER (thin gold)
panel.border = CreateFrame("Frame", nil, panel, "BackdropTemplate")
panel.border:SetAllPoints()
panel.border:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
})
panel.border:SetBackdropBorderColor(0.8, 0.6, 0, 0.8)

-- TITLE
local title = panel:CreateFontString(nil, "OVERLAY")
title:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
title:SetPoint("TOP", 0, -15)
title:SetText("Battleground Finder")
title:SetTextColor(1, 0.82, 0)

-- BUTTONS

local function CreateButton(text, y, cmd)
    local b = CreateFrame("Button", nil, panel)
    b:SetSize(260, 40)
    b:SetPoint("TOP", 0, y)

    -- background
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.05, 0.05, 0.9)

    -- hover
    local hover = b:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(1, 0, 0, 0.15)

    -- text
    local txt = b:CreateFontString(nil, "OVERLAY")
    txt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    txt:SetPoint("CENTER")
    txt:SetText(text)
    txt:SetTextColor(1, 0.8, 0)

    -- click
    b:SetScript("OnClick", function()
    SendChatMessage(cmd, "SAY")
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    panel:Hide()
    end)
end

CreateButton("Warsong Gulch", -70, ".go warsong")
CreateButton("Arathi Basin", -120, ".go arathi")
CreateButton("Alterac Valley", -170, ".go alterac")

-- MAIN BUTTON 

local bgBtn = CreateFrame("Button", "BGLFGButton", UIParent)
bgBtn:SetSize(36, 36)
bgBtn:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -90, 40)

bgBtn:SetFrameStrata("HIGH")
bgBtn:SetFrameLevel(10)

-- background
local bg = bgBtn:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\Buttons\\UI-Quickslot2")

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
    GameTooltip:SetText("Battleground Finder")
    GameTooltip:AddLine("Ready for battle", 1, 0.8, 0)
    GameTooltip:Show()
end)

bgBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

bgBtn:Show()

-- PULSE EFFECT

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

-- BG COUNTDOWN
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