local function AddOpt_OnClick(self, info)
    local button = info.button
    local name = info.name or UnitName(info.unit)
    if button == "AddFriend" then
        AddFriend(name)
    elseif button == "GuildInvite" then
        GuildInvite(name)
    end
end

local function IsFriend(name)
    ShowFriends()
    for i = 1, GetNumFriends() do
        if GetFriendInfo(i) == name then
            return true
        end
    end
    return false
end

local function IsGuildMember(name)
    GuildRoster()
    for i = 1, GetNumGuildMembers() do
        if GetGuildRosterInfo(i) == name then
            return true
        end
    end
    return false
end

local function AddOptionsToDropdown(dropdownMenu, which, unit, name)
    if InCombatLockdown() then return end
    if UIDROPDOWNMENU_MENU_LEVEL > 1 then return end

    -- SAFELY check if unit exists before calling UnitGUID
    if unit and UnitExists(unit) and UnitGUID(unit) == UnitGUID("player") then
        return
    end

    local info = UIDropDownMenu_CreateInfo()

    if not IsFriend(name) then
        info.text = "Add Friend"
        info.value = "AddFriend"
        info.func = AddOpt_OnClick
        info.notCheckable = true
        info.arg1 = { button = "AddFriend", name = name, unit = unit }
        UIDropDownMenu_AddButton(info)
    end

    if IsInGuild() and CanGuildInvite() and not IsGuildMember(name) then
        info.text = "Invite to Guild"
        info.value = "GuildInvite"
        info.func = AddOpt_OnClick
        info.notCheckable = true
        info.arg1 = { button = "GuildInvite", name = name, unit = unit }
        UIDropDownMenu_AddButton(info)
    end
end

-- Main frame and events
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Hook right-click dropdown and rename buttons
        hooksecurefunc("UnitPopup_ShowMenu", function(dropdownMenu, which, unit, name)
            AddOptionsToDropdown(dropdownMenu, which, unit, name)

            local level = UIDROPDOWNMENU_MENU_LEVEL or 1
            local listFrame = _G["DropDownList" .. level]
            if not listFrame then return end

            for i = 1, listFrame.numButtons do
                local button = _G["DropDownList" .. level .. "Button" .. i]
                if button and button.value == "INVITE" then
                    button:SetText("Invite to Party")
                elseif button and button.value == "DUEL" then
                    button:SetText("Request Duel")
                end
            end
        end)
    end
end)
