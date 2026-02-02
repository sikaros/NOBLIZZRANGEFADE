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