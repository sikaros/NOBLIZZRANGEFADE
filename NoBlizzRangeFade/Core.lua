-- NoBlizzRangeFade | Core.lua
-- Addon initialization and namespace setup
-- VERSION: 1.1.4

local addonName, ns = ...

ns.ADDON_NAME  = addonName
ns.VERSION     = "1.1.4"

-- Settings with defaults
ns.settings = {
    alpha = 1.0  -- Default: fully visible
}

-- Simple logging (only when debug enabled)
ns.debug = false

ns.log = function(msg)
    if ns.debug then
        print("|cff00ffff[NBR]|r " .. tostring(msg))
    end
end

-- Save settings to disk
local function SaveSettings()
    NoBlizzRangeFadeDB = NoBlizzRangeFadeDB or {}
    NoBlizzRangeFadeDB.alpha = ns.settings.alpha
end

-- Load settings from disk
local function LoadSettings()
    NoBlizzRangeFadeDB = NoBlizzRangeFadeDB or {}
    local a = tonumber(NoBlizzRangeFadeDB.alpha) or 1.0
    -- Clamp to the safe range so a stored value cannot hide the frames.
    if a < 0.3 then a = 0.3 elseif a > 1.0 then a = 1.0 end
    ns.settings.alpha = a
    ns.log("Loaded alpha: " .. ns.settings.alpha)
end

-- Slash commands
SLASH_NORANGEFADE1 = "/norangefade"

SlashCmdList["NORANGEFADE"] = function(args)
    args = args:lower():match("^%s*(.-)%s*$")

    -- Check for alpha command first
    local alphaValue = args:match("^alpha%s+([%d%.]+)$")
    if alphaValue then
        local value = tonumber(alphaValue)
        if not value then
            print("|cffff0000[NoBlizzRangeFade]|r Invalid number. Usage: /norangefade alpha 0.75")
            return
        end
        if value < 0.3 or value > 1.0 then
            print("|cffff0000[NoBlizzRangeFade]|r Alpha must be between 0.3 and 1.0")
            return
        end

        ns.settings.alpha = value
        SaveSettings()

        -- Apply immediately to all frames
        if ns.ResetRangeState then
            ns.ResetRangeState()
        end
        if ns.FixAllFrames then
            ns.FixAllFrames()
        end

        print("|cff00ff00[NoBlizzRangeFade]|r Alpha set to: " .. string.format("%.2f", value))
        return
    end

    -- Test command to check current frame alphas
    if args == "test" then
        print("|cff00ff00[NoBlizzRangeFade]|r Frame Alpha Check:")
        print("  Current setting: alpha=" .. string.format("%.2f", ns.settings.alpha))
        for i = 1, 5 do
            pcall(function()
                local f = _G["CompactPartyFrameMember" .. i]
                if f then
                    local alpha = f:GetAlpha()
                    print("  CompactPartyFrameMember" .. i .. ": alpha=" .. string.format("%.2f", alpha))
                end
            end)
        end
        return
    end

    if args == "debug" then
        ns.debug = not ns.debug
        print("|cff00ff00[NoBlizzRangeFade]|r Debug: " .. (ns.debug and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif args == "status" then
        print("|cff00ff00[NoBlizzRangeFade]|r v" .. ns.VERSION)
        print("  Alpha: " .. string.format("%.2f", ns.settings.alpha))
        print("  Debug: " .. (ns.debug and "ON" or "OFF"))
    else
        print("|cff00ff00[NoBlizzRangeFade]|r Commands:")
        print("  /norangefade status - Show version and status")
        print("  /norangefade alpha <0.3-1.0> - Set out-of-range alpha (1.0 = never fade)")
        print("  /norangefade test - Check current frame alphas")
        print("  /norangefade debug  - Toggle debug logging")
        print("Example: /norangefade alpha 0.45")
    end
end

-- Initialization
local Init = CreateFrame("Frame")

Init:RegisterEvent("ADDON_LOADED")

Init:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= addonName then return end

        LoadSettings()

        if ns.SetupHooks then
            ns.SetupHooks()
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)
