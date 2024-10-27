-- BlueFrog Addon v2.0 

--  settings
local BlueFrogSettings = (function()
    local instance = nil
    local defaultSettings = {
        fadeDuration = 3,
        timeVisible = 5,
        maxLines = 20,
        fontSize = 12,
        fontColor = {1, 1, 1},  -- White
        frameHeight = 200,
    }

    local function createInstance()
        return defaultSettings
    end

    return {
        getInstance = function()
            if instance == nil then
                instance = createInstance()
            end
            return instance
        end
    }
end)()

-- frame creation
local function MessageFrameFactory(frameType, point, relativePoint, xOffset, yOffset)
    local settings = BlueFrogSettings.getInstance()
    local frame = CreateFrame("ScrollingMessageFrame", frameType, UIParent, "BackdropTemplate")

    frame:SetSize(250, settings.frameHeight)
    frame:SetPoint(point, UIParent, relativePoint, xOffset, yOffset)
    local font, _, flags = GameFontNormalLarge:GetFont()
    frame:SetFont(font, settings.fontSize, flags)
    frame:SetTextColor(unpack(settings.fontColor))
    frame:SetFading(true)
    frame:SetFadeDuration(settings.fadeDuration)
    frame:SetTimeVisible(settings.timeVisible)
    frame:SetMaxLines(settings.maxLines)
    frame:SetInsertMode("BOTTOM")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if isMovable then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    return frame
end

-- Create frames for different types of messages
local frames = {
    damageText = MessageFrameFactory("BlueFrogDamageText", "LEFT", "CENTER", -300, 0),
    healingText = MessageFrameFactory("BlueFrogHealingText", "RIGHT", "CENTER", 300, 0),
    damageTakenText = MessageFrameFactory("BlueFrogDamageTakenText", "BOTTOMLEFT", "BOTTOMLEFT", 50, 50),
}

-- Handling combat log events and notifying observers
local CombatEventObserver = {}

function CombatEventObserver.notify(eventType, sourceGUID, destGUID, spellId, amount, critical)
    if eventType == "damage" then
        frames.damageText:AddMessage(amount .. (critical and " CRIT!" or ""), 1, 0, 0, spellId)
    elseif eventType == "healing" then
        frames.healingText:AddMessage(amount .. (critical and " CRIT!" or ""), 0, 1, 0, spellId)
    elseif eventType == "damageTaken" then
        frames.damageTakenText:AddMessage(amount .. (critical and " CRIT!" or ""), 1, 0, 0, spellId)
    end
end

-- Event handling
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventHandler:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId, spellName, _, amount, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

    local eventType = nil
    if subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SWING_DAMAGE" then
        eventType = sourceGUID == UnitGUID("player") and "damage" or "damageTaken"
    elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then
        eventType = "healing"
    end

    if eventType and amount then
        CombatEventObserver.notify(eventType, sourceGUID, destGUID, spellId, amount, critical)
    end
end)

-- control frame lock/unlock behavior
local LockUnlockStrategy = {}

function LockUnlockStrategy.lockFrames(isLocked)
    local bgAlpha = isLocked and 0.5 or 0
    for _, frame in pairs(frames) do
        frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
        frame:SetBackdropColor(0, 0, 0, bgAlpha)
    end
end

-- toggle lock/unlock
local function ToggleCommand()
    isMovable = not isMovable
    LockUnlockStrategy.lockFrames(isMovable)
    return isMovable and "Lock Frames" or "Unlock Frames"
end

-- Toggle Button
local function CreateToggleButton(frame)
    local button = CreateFrame("Button", "BlueFrogToggleButton", frame, "UIPanelButtonTemplate")
    button:SetSize(80, 22)
    button:SetPoint("TOP", frame, "BOTTOM", 0, -5)
    button:SetText("Unlock Frames")
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function()
        button:SetText(ToggleCommand())
    end)
    return button
end

local toggleButton = CreateToggleButton(frames.damageText) -- Attach to one of the frames

-- Options Panel with settings
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "BlueFrogOptionsPanel", UIParent)
    panel.name = "BlueFrog"
    InterfaceOptions_AddCategory(panel)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BlueFrog Options")

    -- Use sliders to update settings
    local function CreateSlider(name, parent, label, minVal, maxVal, step, currentVal, callback)
        local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(step)
        slider:SetWidth(180)
        slider:SetValue(currentVal)
        slider:SetScript("OnValueChanged", callback)
        _G[slider:GetName() .. 'Low']:SetText(tostring(minVal))
        _G[slider:GetName() .. 'High']:SetText(tostring(maxVal))
        _G[slider:GetName() .. 'Text']:SetText(label .. ": " .. slider:GetValue())
        return slider
    end

    local settings = BlueFrogSettings.getInstance()

    local fadeSlider = CreateSlider("BlueFrogFadeSlider", panel, "Fade Duration", 1, 10, 1, settings.fadeDuration, function(self, value)
        settings.fadeDuration = value
        for _, frame in pairs(frames) do frame:SetFadeDuration(value) end
    end)
    fadeSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -30)

    local textSizeSlider = CreateSlider("BlueFrogTextSizeSlider", panel, "Text Size", 10, 20, 1, settings.fontSize, function(self, value)
        settings.fontSize = value
        for _, frame in pairs(frames) do
            local font, _, flags = GameFontNormalLarge:GetFont()
            frame:SetFont(font, value, flags)
        end
    end)
    textSizeSlider:SetPoint("TOPLEFT", fadeSlider, "BOTTOMLEFT", 0, -50)

    local heightSlider = CreateSlider("BlueFrogHeightSlider", panel, "Frame Height", 100, 400, 10, settings.frameHeight, function(self, value)
        settings.frameHeight = value
        for _, frame in pairs(frames) do frame:SetHeight(value) end
    end)
    heightSlider:SetPoint("TOPLEFT", textSizeSlider, "BOTTOMLEFT", 0, -50)
end

CreateOptionsPanel()

print("|cFF00FF00BlueFrog successfully loaded!|r")
