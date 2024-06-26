-- Variable to control whether frames are movable
local isMovable = false

-- Create a frame for the main addon window
local frame = CreateFrame("Frame", "BlueFrogFrame", UIParent)
frame:SetSize(200, 100)
frame:SetPoint("CENTER")
frame:SetMovable(true)  -- Allow frame to be moved
frame:EnableMouse(true)  -- Enable mouse interaction
frame:RegisterForDrag("LeftButton")  -- Register left mouse button for dragging
frame:SetScript("OnDragStart", frame.StartMoving)  -- Allow dragging on mouse down
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)  -- Stop dragging on mouse up

-- Create a toggle button inside the main frame
local toggleButton = CreateFrame("Button", "BlueFrogToggleButton", frame, "UIPanelButtonTemplate")
toggleButton:SetSize(80, 22)
toggleButton:SetPoint("TOP", frame, "BOTTOM", 0, -5)
toggleButton:SetText("BFCT")  -- Button text
toggleButton:SetMovable(true)  -- Allow button to be moved
toggleButton:EnableMouse(true)  -- Enable mouse interaction
toggleButton:RegisterForDrag("LeftButton")  -- Register left mouse button for dragging
toggleButton:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()  -- Start moving button on shift + left click
    end
end)
toggleButton:SetScript("OnDragStop", toggleButton.StopMovingOrSizing)  -- Stop moving button on release

-- Create a scrolling message frame for displaying damage information
local damageText = CreateFrame("ScrollingMessageFrame", "BlueFrogDamageText", UIParent)
damageText:SetSize(250, 200)
damageText:SetPoint("LEFT", UIParent, "CENTER", -300, 0)
damageText:SetFontObject(GameFontNormalLarge)
damageText:SetFading(true)
damageText:SetFadeDuration(1)
damageText:SetTimeVisible(3)
damageText:SetMaxLines(20)
damageText:SetMovable(true)  -- Allow frame to be moved
damageText:EnableMouse(true)  -- Enable mouse interaction
damageText:RegisterForDrag("LeftButton")  -- Register left mouse button for dragging
damageText:SetScript("OnDragStart", function(self)
    if isMovable then
        self:StartMoving()  -- Start moving frame on left click
    end
end)
damageText:SetScript("OnDragStop", damageText.StopMovingOrSizing)  -- Stop moving frame on release

-- Create a scrolling message frame for displaying healing information
local healingText = CreateFrame("ScrollingMessageFrame", "BlueFrogHealingText", UIParent)
healingText:SetSize(250, 200)
healingText:SetPoint("RIGHT", UIParent, "CENTER", 300, 0)
healingText:SetFontObject(GameFontNormalLarge)
healingText:SetFading(true)
healingText:SetFadeDuration(1)
healingText:SetTimeVisible(3)
healingText:SetMaxLines(20)
healingText:SetMovable(true)  -- Allow frame to be moved
healingText:EnableMouse(true)  -- Enable mouse interaction
healingText:RegisterForDrag("LeftButton")  -- Register left mouse button for dragging
healingText:SetScript("OnDragStart", function(self)
    if isMovable then
        self:StartMoving()  -- Start moving frame on left click
    end
end)
healingText:SetScript("OnDragStop", healingText.StopMovingOrSizing)  -- Stop moving frame on release

-- Create a scrolling message frame for displaying damage taken information
local damageTakenText = CreateFrame("ScrollingMessageFrame", "BlueFrogDamageTakenText", UIParent)
damageTakenText:SetSize(250, 200)
damageTakenText:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 50, 50)
damageTakenText:SetFontObject(GameFontNormalLarge)
damageTakenText:SetFading(true)
damageTakenText:SetFadeDuration(1)
damageTakenText:SetTimeVisible(3)
damageTakenText:SetMaxLines(20)
damageTakenText:SetMovable(true)  -- Allow frame to be moved
damageTakenText:EnableMouse(true)  -- Enable mouse interaction
damageTakenText:RegisterForDrag("LeftButton")  -- Register left mouse button for dragging
damageTakenText:SetScript("OnDragStart", function(self)
    if isMovable then
        self:StartMoving()  -- Start moving frame on left click
    end
end)
damageTakenText:SetScript("OnDragStop", damageTakenText.StopMovingOrSizing)  -- Stop moving frame on release

-- Create background frames using BackdropTemplate for each scrolling message frame
local damageTextBg = CreateFrame("Frame", nil, damageText, BackdropTemplateMixin and "BackdropTemplate")
damageTextBg:SetAllPoints(damageText)
damageTextBg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
damageTextBg:SetBackdropColor(0, 0, 0, 0.5)
damageTextBg:Hide()  -- Initially hide background frame

local healingTextBg = CreateFrame("Frame", nil, healingText, BackdropTemplateMixin and "BackdropTemplate")
healingTextBg:SetAllPoints(healingText)
healingTextBg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
healingTextBg:SetBackdropColor(0, 0, 0, 0.5)
healingTextBg:Hide()  -- Initially hide background frame

local damageTakenTextBg = CreateFrame("Frame", nil, damageTakenText, BackdropTemplateMixin and "BackdropTemplate")
damageTakenTextBg:SetAllPoints(damageTakenText)
damageTakenTextBg:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
damageTakenTextBg:SetBackdropColor(0, 0, 0, 0.5)
damageTakenTextBg:Hide()  -- Initially hide background frame

-- Set toggleButton's functionality to lock/unlock frames and show/hide background frames
toggleButton:SetScript("OnClick", function()
    isMovable = not isMovable
    if isMovable then
        toggleButton:SetText("Lock ")  -- Change button text to indicate locked state
        damageTextBg:Show()  -- Show damage text background frame
        healingTextBg:Show()  -- Show healing text background frame
        damageTakenTextBg:Show()  -- Show damage taken text background frame
    else
        toggleButton:SetText("BFCT")  -- Reset button text to default
        damageText:StopMovingOrSizing()  -- Stop moving damage text frame
        healingText:StopMovingOrSizing()  -- Stop moving healing text frame
        damageTakenText:StopMovingOrSizing()  -- Stop moving damage taken text frame
        damageTextBg:Hide()  -- Hide damage text background frame
        healingTextBg:Hide()  -- Hide healing text background frame
        damageTakenTextBg:Hide()  -- Hide damage taken text background frame
    end
end)

-- Function to display damage text with optional spell icon
local function displayDamageText(text, r, g, b, spellId)
    local icon = GetSpellTexture(spellId) or ""
    damageText:AddMessage("|T" .. icon .. ":20:20:0:0:64:64:5:59:5:59|t " .. text, 1, 1, 0)  -- Yellow color for damage text
end

-- Function to display healing text with optional spell icon
local function displayHealingText(text, r, g, b, spellId)
    local icon = GetSpellTexture(spellId) or ""
    healingText:AddMessage("|T" .. icon .. ":20:20:0:0:64:64:5:59:5:59|t " .. text, 0, 1, 0)  -- Green color for healing text
end

-- Function to display damage taken text with optional spell icon
local function displayDamageTakenText(text, r, g, b, spellId)
    local icon = GetSpellTexture(spellId) or ""
    damageTakenText:AddMessage("|T" .. icon .. ":20:20:0:0:64:64:5:59:5:59|t " .. text, 1, 0, 0)  -- Red color for damage taken text
end


-- Event handler to listen for combat log events
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventHandler:SetScript("OnEvent", function(self, event, ...)
    local timestamp, subEvent, _, sourceGUID, _, sourceName, _, destGUID, destName, _, _, spellId, spellName, _, amount = Combat

    -- Retrieve current combat log event information
    local timestamp, subEvent, _, sourceGUID, _, sourceName, _, destGUID, destName, _, _, spellId, spellName, _, amount = CombatLogGetCurrentEventInfo()

    -- Check for damage events
    if subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SWING_DAMAGE" then
        -- Damage dealt
        if sourceGUID == UnitGUID("player") then
            displayDamageText("" .. amount, 1, 0, 0, spellId)  -- Red color for damage dealt by player
        elseif destGUID == UnitGUID("player") then
            displayDamageTakenText("" .. amount, 1, 0, 0, spellId)  -- Red color for damage taken by player
        end
    elseif subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then
        -- Healing events
        if sourceGUID == UnitGUID("player") then
            displayHealingText("" .. amount, 0, 1, 0, spellId)  -- Green color for healing done by player
        elseif destGUID == UnitGUID("player") then
            displayHealingText("" .. amount, 0, 1, 0, spellId)  -- Green color for healing received by player
        end
    end
end)

-- Print a message on successful addon load
print("|cFF00FF00BlueFrog successfully loaded!|r")
