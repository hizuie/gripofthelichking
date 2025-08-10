local ADDON_NAME = ...
local PREFIX = "GOTLKVER"  

local MY_VERSION = GetAddOnMetadata(ADDON_NAME, "Version") or "0.0.0"

local function VersionNumber(v)
    local clean = string.match(v, "^%d+%.%d+%.?%d*") or "0.0.0"
    local a, b, c = string.match(clean, "(%d+)%.(%d+)%.?(%d*)")
    a, b, c = tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
    return a * 10000 + b * 100 + c
end

local MY_NUM = VersionNumber(MY_VERSION)

local function PickChannel()
    if GetNumRaidMembers and GetNumRaidMembers() > 0 then return "RAID" end
    if GetNumPartyMembers and GetNumPartyMembers() > 0 then return "PARTY" end
    if IsInGuild and IsInGuild() then return "GUILD" end
    return nil
end

local function PrintNormal(msg)
    local c = NORMAL_FONT_COLOR or { r = 1.0, g = 0.82, b = 0 }
    (DEFAULT_CHAT_FRAME or ChatFrame1):AddMessage(msg, c.r, c.g, c.b)
end

local function MaybeAnnounceNewer(vstr, from)
    local other = VersionNumber(vstr)
    if other > MY_NUM then
        PrintNormal("Update available for Grip of the Lich King (at github.com/hizuie/gripofthelichking/releases)")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        local chan = PickChannel()
        if chan then
            SendAddonMessage(PREFIX, "REQ", chan)
            SendAddonMessage(PREFIX, "VER:" .. MY_VERSION, chan)
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, dist, sender = ...
        if prefix ~= PREFIX then return end
        if msg == "REQ" then
            local chan = dist
            SendAddonMessage(PREFIX, "VER:" .. MY_VERSION, chan)
        else
            local their = string.match(msg, "^VER:(.+)")
            if their then
                MaybeAnnounceNewer(their, sender)
            end
        end
    end
end)
