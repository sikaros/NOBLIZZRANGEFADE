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
    
    -- Raid frames
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
## Interface: 120000
## Title: NoBlizzRangeFade
## Author: YourName
## Version: 0..3.7
## Notes: DIAGNOSTIC MODE - Hooks all possible fade functions to find what Midnight uses. Watch debug logs.
## OptionalDeps: 
## SavedVariables: NoBlizzRangeFadeDB

# --- Core must always load first ---
Core.lua

# --- Hooks and fixes ---
Fixes.lua

-- NoBlizzRangeFade | Core.lua
-- Addon initialization and namespace setup
-- VERSION: 1.0.0 STABLE

local addonName, ns = ...

ns.ADDON_NAME  = addonName
ns.VERSION     = "1.0.0"

-- Simple logging (only when debug enabled)
ns.debug = false

ns.log = function(msg)
    if ns.debug then
        print("|cff00ffff[NBR]|r " .. tostring(msg))
    end
end

-- Slash commands
SLASH_NORANGEFADE1 = "/norangefade"

SlashCmdList["NORANGEFADE"] = function(args)
    args = args:lower():match("^%s*(.-)%s*$")
    if args == "debug" then
        ns.debug = not ns.debug
        print("|cff00ff00[NoBlizzRangeFade]|r Debug: " .. (ns.debug and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif args == "status" then
        print("|cff00ff00[NoBlizzRangeFade]|r v" .. ns.VERSION .. " | Debug: " .. (ns.debug and "ON" or "OFF"))
    else
        print("|cff00ff00[NoBlizzRangeFade]|r Commands:")
        print("  /norangefade status - Show version and status")
        print("  /norangefade debug  - Toggle debug logging")
    end
end

-- Initialization
local Init = CreateFrame("Frame")

Init:RegisterEvent("ADDON_LOADED")
Init:RegisterEvent("PLAYER_ENTERING_WORLD")

Init:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= addonName then return end

        if ns.SetupHooks then
            ns.SetupHooks()
        end

        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_ENTERING_WORLD" then
        if ns.FixAllFrames then
            ns.FixAllFrames()
        end
    end
end)
