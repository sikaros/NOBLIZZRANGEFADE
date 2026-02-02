-- NoBlizzRangeFade | Fixes.lua  
-- VERSION: 1.0.0 STABLE
-- Prevents raid and party frames from fading when units are out of range

local addonName, ns = ...

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
                        end
                        frame:SetAlpha(1)
                    end)
                end
            end
        end)
    end
    
    -- Raid frames (RaidGroupButton pattern)
    for i = 1, 40 do
        pcall(function()
            local frame = _G["RaidGroupButton" .. i]
            if frame and type(frame) == "table" then
                local ok, unit = pcall(function() return frame.unit end)
                if ok and unit then
                    pcall(function()
                        if frame.optionTable then
                            frame.optionTable.displayRangeDisplay = false
                        end
                        frame:SetAlpha(1)
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
                                    end
                                    frame:SetAlpha(1)
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
