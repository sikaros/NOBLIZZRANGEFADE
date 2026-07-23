-- NoBlizzRangeFade | Fixes.lua  
-- VERSION: 1.1.2
-- Prevents raid and party frames from fading when units are out of range

local addonName, ns = ...

local overlayByFrame = setmetatable({}, { __mode = "k" })
local compactRaidFrameCount = 0

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

local function ApplyRangeIndicator(frame, unit)
    local overlay = GetRangeOverlay(frame)
    if not overlay then
        return
    end

    local ok, inRange, checkedRange = pcall(UnitInRange, unit)
    if not ok then
        pcall(function()
            overlay.rangeGate:SetAlpha(0)
        end)
        return
    end

    local applied = pcall(function()
        overlay.rangeGate:SetAlphaFromBoolean(checkedRange, 1, 0)
        overlay.texture:SetAlphaFromBoolean(inRange, 0, 0.40)
    end)

    if not applied then
        pcall(function()
            overlay.rangeGate:SetAlpha(0)
        end)
    end
end

-- Disable range display and force alpha on all frames
local function DisableRangeDisplay()
    -- Party frames
    for i = 1, 5 do
        pcall(function()
            local frame = _G["CompactPartyFrameMember" .. i]
            if frame and type(frame) == "table" then
                local ok, unit = pcall(function() return frame.unit end)
                if ok and unit then
                    pcall(function()
                        if frame.optionTable then
                            frame.optionTable.displayRangeDisplay = false
                            frame.optionTable.fadeOutOfRange = false
                        end
                        frame:SetAlpha(1)
                        ApplyRangeIndicator(frame, unit)
                    end)
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
                    pcall(function()
                        if frame.optionTable then
                            frame.optionTable.displayRangeDisplay = false
                            frame.optionTable.fadeOutOfRange = false
                        end
                        frame:SetAlpha(1)
                        ApplyRangeIndicator(frame, unit)
                    end)
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
                                pcall(function()
                                    if frame.optionTable then
                                        frame.optionTable.displayRangeDisplay = false
                                        frame.optionTable.fadeOutOfRange = false
                                    end
                                    frame:SetAlpha(1)
                                    ApplyRangeIndicator(frame, unit)
                                end)
                            end
                        end
                    end)
                end
            end
        end)
    end
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
rosterFrame:SetScript("OnEvent", function()
    C_Timer.After(0.5, function()
        DisableRangeDisplay()
    end)
end)

-- Public API
ns.FixAllFrames = DisableRangeDisplay

ns.SetupHooks = function()
    DisableRangeDisplay()
    print("|cff00ff00[NoBlizzRangeFade]|r Active - frames will not fade when out of range")
end
