--updated to show larger resizeable frames for damage and healing,
--dmg and healing are showen faster, fixed bug for nill dmg,
--on MoP Remix dubble bronze patch,
-- added cusom options for text scrolling, height x width and icons
-- added user interface options pannel
--fixed healing frames that prevented user interface from showing
-- addon now works for MoP remix and retail 

-- Main addon frame setup
local frame = CreateFrame("Frame", "BlueFrogFrame", UIParent)
frame:SetSize(200, 100)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Storage for addon settings
BlueFrogSettings = BlueFrogSettings or {
    fadeDuration = 3,
    timeVisible = 5,
    maxLines = 20,
    fontSize = 12,
    fontColor = {1, 1, 1},  -- Default to white
    frameHeight = 200,
}

-- Function to create the message frame
local function CreateMessageFrame(name, point, relativePoint, xOffset, yOffset)
    local frame = CreateFrame("ScrollingMessageFrame", name, UIParent, "BackdropTemplate")
    frame:SetSize(250, BlueFrogSettings.frameHeight)
    frame:SetPoint(point, UIParent, relativePoint, xOffset, yOffset)
    local font, _, flags = GameFontNormalLarge:GetFont()
    frame:SetFont(font, BlueFrogSettings.fontSize, flags)
    frame:SetTextColor(unpack(BlueFrogSettings.fontColor))
    frame:SetFading(true)
    frame:SetFadeDuration(BlueFrogSettings.fadeDuration)
    frame:SetTimeVisible(BlueFrogSettings.timeVisible)
    frame:SetMaxLines(BlueFrogSettings.maxLines)
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

-- Create damage, healing, and damage taken frames
local damageText = CreateMessageFrame("BlueFrogDamageText", "LEFT", "CENTER", -300, 0)
local healingText = CreateMessageFrame("BlueFrogHealingText", "RIGHT", "CENTER", 300, 0)
local damageTakenText = CreateMessageFrame("BlueFrogDamageTakenText", "BOTTOMLEFT", "BOTTOMLEFT", 50, 50)

-- Toggle button to lock and unlock frames
local toggleButton = CreateFrame("Button", "BlueFrogToggleButton", frame, "UIPanelButtonTemplate")
toggleButton:SetSize(80, 22)
toggleButton:SetPoint("TOP", frame, "BOTTOM", 0, -5)
toggleButton:SetText("Unlock Frames")
toggleButton:SetMovable(true)
toggleButton:EnableMouse(true)
toggleButton:RegisterForDrag("LeftButton")
toggleButton:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()
    end
end)
toggleButton:SetScript("OnDragStop", toggleButton.StopMovingOrSizing)
toggleButton:SetScript("OnClick", function()
    isMovable = not isMovable
    toggleButton:SetText(isMovable and "Lock Frames" or "Unlock Frames")
    
    -- Set background based on lock state
    local bgAlpha = isMovable and 0.5 or 0
    damageText:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
    damageText:SetBackdropColor(0, 0, 0, bgAlpha)
    healingText:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
    healingText:SetBackdropColor(0, 0, 0, bgAlpha)
    damageTakenText:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
    damageTakenText:SetBackdropColor(0, 0, 0, bgAlpha)
end)

-- Generic function to display text
local function displayText(frame, text, r, g, b, spellId)
    local icon = GetSpellTexture(spellId) or ""
    frame:AddMessage("|T" .. icon .. ":20:20:0:0:64:64:5:59:5:59|t " .. text, r, g, b)
end

-- Event handler for combat log
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventHandler:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId, spellName, _, amount, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SWING_DAMAGE" then
        if amount then
            if sourceGUID == UnitGUID("player") then
                displayText(damageText, amount .. (critical and " CRIT!" or ""), 1, 0, 0, spellId)
            elseif destGUID == UnitGUID("player") then
                displayText(damageTakenText, amount .. (critical and " CRIT!" or ""), 1, 0, 0, spellId)
            end
        end
    elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then
        if amount and sourceGUID == UnitGUID("player") then
            displayText(healingText, amount .. (critical and " CRIT!" or ""), 0, 1, 0, spellId)
        end
    end
end)

-- Interface options for customization
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "BlueFrogOptionsPanel", UIParent)
    panel.name = "BlueFrog"
    InterfaceOptions_AddCategory(panel)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BlueFrog Options")

    -- Fade Duration Slider
    local fadeSlider = CreateFrame("Slider", "BlueFrogFadeSlider", panel, "OptionsSliderTemplate")
    fadeSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -30)
    fadeSlider:SetMinMaxValues(1, 10)
    fadeSlider:SetValueStep(1)
    fadeSlider:SetObeyStepOnDrag(true)
    fadeSlider:SetWidth(180)
    fadeSlider:SetValue(BlueFrogSettings.fadeDuration)
    fadeSlider:SetScript("OnValueChanged", function(self, value)
        BlueFrogSettings.fadeDuration = value
        damageText:SetFadeDuration(value)
        healingText:SetFadeDuration(value)
        damageTakenText:SetFadeDuration(value)
    end)
    _G[fadeSlider:GetName() .. 'Low']:SetText('1 sec')
    _G[fadeSlider:GetName() .. 'High']:SetText('10 sec')
    _G[fadeSlider:GetName() .. 'Text']:SetText('Fade Duration: ' .. fadeSlider:GetValue() .. ' sec')

    -- Text Size Slider
    local textSizeSlider = CreateFrame("Slider", "BlueFrogTextSizeSlider", panel, "OptionsSliderTemplate")
    textSizeSlider:SetPoint("TOPLEFT", fadeSlider, "BOTTOMLEFT", 0, -50)
    textSizeSlider:SetMinMaxValues(10, 20)
    textSizeSlider:SetValueStep(1)
    textSizeSlider:SetObeyStepOnDrag(true)
    textSizeSlider:SetWidth(180)
    textSizeSlider:SetValue(BlueFrogSettings.fontSize)
    textSizeSlider:SetScript("OnValueChanged", function(self, value)
        BlueFrogSettings.fontSize = value
        local font, _, flags = GameFontNormalLarge:GetFont()
        damageText:SetFont(font, value, flags)
        healingText:SetFont(font, value, flags)
        damageTakenText:SetFont(font, value, flags)
    end)
    _G[textSizeSlider:GetName() .. 'Low']:SetText('10 pt')
    _G[textSizeSlider:GetName() .. 'High']:SetText('20 pt')
    _G[textSizeSlider:GetName() .. 'Text']:SetText('Text Size: ' .. textSizeSlider:GetValue() .. ' pt')

    -- Frame Height Slider
    local heightSlider = CreateFrame("Slider", "BlueFrogHeightSlider", panel, "OptionsSliderTemplate")
    heightSlider:SetPoint("TOPLEFT", textSizeSlider, "BOTTOMLEFT", 0, -50)
    heightSlider:SetMinMaxValues(100, 400)
    heightSlider:SetValueStep(10)
    heightSlider:SetObeyStepOnDrag(true)
    heightSlider:SetWidth(180)
    heightSlider:SetValue(BlueFrogSettings.frameHeight)
    heightSlider:SetScript("OnValueChanged", function(self, value)
        BlueFrogSettings.frameHeight = value
        damageText:SetHeight(value)
        healingText:SetHeight(value)
        damageTakenText:SetHeight(value)
    end)
    _G[heightSlider:GetName() .. 'Low']:SetText('100 px')
    _G[heightSlider:GetName() .. 'High']:SetText('400 px')
    _G[heightSlider:GetName() .. 'Text']:SetText('Frame Height: ' .. heightSlider:GetValue() .. ' px')
end

CreateOptionsPanel()

print("|cFF00FF00BlueFrog successfully loaded!|r")
