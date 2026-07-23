-- NoBlizzRangeFade | Fixes.lua  
-- VERSION: 1.1.4
-- Prevents raid and party frames from fading when units are out of range

local addonName, ns = ...

local overlayByFrame = setmetatable({}, { __mode = "k" })
local compactRaidFrameCount = 0
local worldReady = false
local worldEntryGeneration = 0
local readyAfterCombatGeneration
local editModeActive = false
local editModeGeneration = 0

local function DiscoverCompactRaidFrames()
    while true do
        local nextIndex = compactRaidFrameCount + 1
        local ok, frame = pcall(function()
            return _G["CompactRaidFrame" .. nextIndex]
        end)

        if not ok or not frame or type(frame) ~= "table" then
            return
        end

        compactRaidFrameCount = nextIndex
    end
end

local function GetRangeOverlay(frame)
    local overlay = overlayByFrame[frame]
    if overlay then
        return overlay
    end

    if InCombatLockdown and InCombatLockdown() then
        return nil
    end

    local ok, createdOverlay = pcall(function()
        local rangeGate = CreateFrame("Frame", nil, frame)
        rangeGate:SetAllPoints(frame)
        rangeGate:SetAlpha(0)

        local texture = rangeGate:CreateTexture(nil, "OVERLAY", nil, 7)
        texture:SetAllPoints(rangeGate)
        texture:SetColorTexture(0.35, 0.35, 0.35, 1)
        texture:SetAlpha(0)

        rangeGate:Show()
        texture:Show()

        return {
            rangeGate = rangeGate,
            texture = texture,
        }
    end)

    if ok and createdOverlay then
        overlayByFrame[frame] = createdOverlay
        return createdOverlay
    end

    return nil
end

-- Grey overlay strength applied to a frame when its unit is out of range.
local OUT_OF_RANGE_OVERLAY_ALPHA = 0.40

local function HideRangeIndicators()
    for frame, overlay in pairs(overlayByFrame) do
        pcall(function()
            overlay.rangeGate:SetAlpha(0)
        end)
    end
end

-- Edit Mode uses simulated preview units. We must leave those alone.
-- The EditMode.Enter/Exit callbacks below set editModeActive, but we do not
-- trust those event names to fire, so we also poll the manager frame directly.
local function IsEditModeOpen()
    if editModeActive then
        return true
    end
    local f = EditModeManagerFrame
    if type(f) == "table" then
        local ok, shown = pcall(function() return f:IsShown() end)
        if ok and shown then
            return true
        end
    end
    return false
end

-- Refresh one frame's alpha and range overlay.
-- Frame alpha is 1.0 in range. Out of range it uses the user alpha setting
-- (default 1.0 = never fade); players who want fading can lower it.
-- We branch with SetAlphaFromBoolean, so we never compare secret range values.
-- Do not write frame.optionTable here. Blizzard reads that table during
-- compact-frame refresh, and addon writes can taint protected health math.
local function ApplyFrame(frame, unit)
    local overlay = GetRangeOverlay(frame)

    local ok, inRange, checkedRange = pcall(UnitInRange, unit)
    if not ok then
        -- Range restricted. Keep the frame fully visible and hide the overlay.
        pcall(function() frame:SetAlpha(1) end)
        if overlay then
            pcall(function() overlay.rangeGate:SetAlpha(0) end)
        end
        return
    end

    local outAlpha = 1.0
    if type(ns.settings) == "table" and type(ns.settings.alpha) == "number" then
        outAlpha = ns.settings.alpha
    end

    local applied = pcall(function()
        frame:SetAlphaFromBoolean(inRange, 1, outAlpha)
        if overlay then
            overlay.rangeGate:SetAlphaFromBoolean(checkedRange, 1, 0)
            overlay.texture:SetAlphaFromBoolean(inRange, 0, OUT_OF_RANGE_OVERLAY_ALPHA)
        end
    end)

    if not applied then
        -- Safe fallback: stay visible, hide the overlay.
        pcall(function() frame:SetAlpha(1) end)
        if overlay then
            pcall(function() overlay.rangeGate:SetAlpha(0) end)
        end
    end
end

-- Keep default group frames visible and update our range overlay.
local function DisableRangeDisplay()
    -- Blizzard restores Edit Mode layouts while PLAYER_ENTERING_WORLD is
    -- running. Do not touch compact frames until that work has settled.
    if not worldReady then
        return
    end

    -- Never touch frames while Edit Mode is open. Clear our overlays so the
    -- simulated previews stay under Blizzard's control.
    if IsEditModeOpen() then
        HideRangeIndicators()
        return
    end

    -- Party frames
    for i = 1, 5 do
        pcall(function()
            local frame = _G["CompactPartyFrameMember" .. i]
            if frame and type(frame) == "table" then
                local ok, unit = pcall(function() return frame.unit end)
                if ok and unit then
                    pcall(function() ApplyFrame(frame, unit) end)
                end
            end
        end)
    end

    -- Raid frames use a contiguous creation counter, not a member index.
    DiscoverCompactRaidFrames()
    for i = 1, compactRaidFrameCount do
        pcall(function()
            local frame = _G["CompactRaidFrame" .. i]
            if frame and type(frame) == "table" then
                local ok, unit = pcall(function() return frame.unit end)
                if ok and unit then
                    pcall(function() ApplyFrame(frame, unit) end)
                end
            end
        end)
    end

    -- Raid frames (CompactRaidGroup pattern)
    for group = 1, 8 do
        pcall(function()
            local raidGroup = _G["CompactRaidGroup" .. group]
            if raidGroup and raidGroup.memberUnitFrames then
                for member = 1, 5 do
                    pcall(function()
                        local frame = raidGroup.memberUnitFrames[member]
                        if frame and type(frame) == "table" then
                            local ok, unit = pcall(function() return frame.unit end)
                            if ok and unit then
                                pcall(function() ApplyFrame(frame, unit) end)
                            end
                        end
                    end)
                end
            end
        end)
    end
end

-- Edit Mode uses simulated party and raid units. Leave those previews entirely
-- under Blizzard's control, then resume after the saved layout has settled.
if EventRegistry and type(EventRegistry) == "table" then
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        editModeGeneration = editModeGeneration + 1
        editModeActive = true
        HideRangeIndicators()
    end)

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        local generation = editModeGeneration
        C_Timer.After(0.5, function()
            if generation ~= editModeGeneration then
                return
            end

            editModeActive = false
            DisableRangeDisplay()
        end)
    end)
end

-- Continuous update loop (10 times per second)
local updateFrame = CreateFrame("Frame")
local elapsed = 0

updateFrame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.1 then
        elapsed = 0
        DisableRangeDisplay()
    end
end)

-- Re-apply on roster changes
local rosterFrame = CreateFrame("Frame")
rosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
rosterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
rosterFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
rosterFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        worldEntryGeneration = worldEntryGeneration + 1
        local generation = worldEntryGeneration
        worldReady = false
        readyAfterCombatGeneration = nil

        C_Timer.After(1, function()
            if generation ~= worldEntryGeneration then
                return
            end

            if InCombatLockdown and InCombatLockdown() then
                readyAfterCombatGeneration = generation
                return
            end

            worldReady = true
            DisableRangeDisplay()
        end)
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        if readyAfterCombatGeneration == worldEntryGeneration then
            readyAfterCombatGeneration = nil
            worldReady = true
            DisableRangeDisplay()
        end
        return
    end

    C_Timer.After(0.5, function()
        DisableRangeDisplay()
    end)
end)

-- Public API
ns.FixAllFrames = DisableRangeDisplay

-- Clear overlays so a settings change (for example a new alpha) redraws cleanly
-- on the next update pass. Called by the alpha slash command.
ns.ResetRangeState = HideRangeIndicators

ns.SetupHooks = function()
    DisableRangeDisplay()
    print("|cff00ff00[NoBlizzRangeFade]|r Active - frames will not fade when out of range")
end
