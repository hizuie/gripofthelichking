_G.GotLK_Pouch = {}
local GotLK_Pouch = _G.GotLK_Pouch

local trackedIcons = {
    ["Honor Points"] = {
        Alliance = "Interface\\Icons\\achievement_pvp_a_16",
        Horde = "Interface\\Icons\\achievement_pvp_h_16"
    },
    ["Arena Points"] = {
        Alliance = "Interface\\Icons\\Arena_RatedBattleground",
        Horde = "Interface\\Icons\\Arena_RatedBattleground"
    },
}

local minimapIcon = "Interface\\Icons\\inv_misc_bag_19"

local state = {
    radius = 80,
    rounding = 10,
    dragging = false,
    lastClickTime = 0,
    doubleClickThreshold = 0.4
}

local shapeRules = {
    ROUND = {true, true, true, true}, SQUARE = {false, false, false, false},
    ["CORNER-TOPLEFT"] = {true, false, false, false},
    ["CORNER-TOPRIGHT"] = {false, false, true, false},
    ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"] = {false, false, false, true},
    ["SIDE-LEFT"] = {true, true, false, false},
    ["SIDE-RIGHT"] = {false, false, true, true},
    ["SIDE-TOP"] = {true, false, true, false},
    ["SIDE-BOTTOM"] = {false, true, false, true},
    ["TRICORNER-TOPLEFT"] = {true, true, true, false},
    ["TRICORNER-TOPRIGHT"] = {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {false, true, true, true},
}

function GotLK_Pouch:Enable()
    if not self.button then self:CreateIcon() end
    if self.button then self.button:Show() end
    self.enabled = true
end

function GotLK_Pouch:Disable()
    if self.button then self.button:Hide() end
    self.enabled = false
end

function GotLK_Pouch:Reposition()
    if not self.enabled or not self.button then return end
    local angle = math.rad(GotLK_PouchDB.angle or 192)
    local x, y = math.cos(angle), math.sin(angle)
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quad = 1
    if x < 0 then quad = quad + 1 end
    if y > 0 then quad = quad + 2 end
    if not shapeRules[shape][quad] then
        local d = math.sqrt(2 * (state.radius)^2) - state.rounding
        x = math.max(-state.radius, math.min(x * d, state.radius))
        y = math.max(-state.radius, math.min(y * d, state.radius))
    else
        x = x * state.radius
        y = y * state.radius
    end
    self.button:SetPoint("CENTER", Minimap, "CENTER", x, y - 1)
    self:UpdateMsgFramePosition()
end

function GotLK_Pouch:BeginDrag()
    if not self.enabled then return end
    state.dragging = true
    this:LockHighlight()
end

function GotLK_Pouch:EndDrag()
    if not self.enabled then return end
    state.dragging = false
    this:UnlockHighlight()
end

function GotLK_Pouch:DragUpdate()
    if not self.enabled or not state.dragging then return end
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scaleM = MinimapCluster:GetScale()
    local scaleUI = UIParent:GetEffectiveScale()
    local dx = (cx / scaleUI) - (mx * scaleM)
    local dy = (cy / scaleUI) - (my * scaleM)
    local angle = math.deg(math.atan2(dy, dx))
    if angle < 0 then angle = angle + 360 end
    GotLK_PouchDB.angle = angle
    self:Reposition()
end

function GotLK_Pouch:ShowTooltip()
    if not self.enabled then return end
    GameTooltip:SetOwner(self.button, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", self.button, "BOTTOM", 0, 3)
    GameTooltip:ClearLines()
    if not GotLK_PouchDB.hideMoney then
        local moneyText = GetCoinTextureString(GetMoney(), 13)
        local g = math.floor(GetMoney() / 10000)
        local s = math.floor((GetMoney() % 10000) / 100)
        local icon = "Interface\\Icons\\INV_Misc_Coin_01"
        if g == 0 and s > 0 then
            icon = "Interface\\Icons\\INV_Misc_Coin_03"
        elseif g == 0 and s == 0 then
            icon = "Interface\\Icons\\INV_Misc_Coin_05"
        end
        local iconString = GotLK_PouchDB.hideIcons and "" or ("|T" .. icon .. ":16:16:0:0|t  ")
        GameTooltip:AddLine(iconString .. moneyText, 250, 125, 50)
    end
    if GotLK_PouchDB.showAchievementPoints then
        local points = GetTotalAchievementPoints and GetTotalAchievementPoints() or 0
        local apIcon = GotLK_PouchDB.hideIcons and "" or "|TInterface\\Icons\\Achievement_Level_80:17:17:0:0|t  "
        GameTooltip:AddLine(apIcon .. points .. " Achievement Points", 1, 1, 1)
    end
    for i = 1, GetCurrencyListSize() do
        local name, isHeader, _, _, _, count = GetCurrencyListInfo(i)
        if count and count > 0 and not isHeader and GotLK_PouchDB.enabledCurrencies[name] then
            local iconEntry = trackedIcons[name]
            local icon = type(iconEntry) == "table" and iconEntry[UnitFactionGroup("player")] or iconEntry
            icon = icon or GotLK_PouchDB.icon or minimapIcon
            local display = GotLK_PouchDB.hideIcons and "" or ("|T" .. icon .. ":17:17:0:0|t  ")
            GameTooltip:AddLine(display .. count .. " " .. name, 1, 1, 1)
        end
    end
    GameTooltip:Show()
    if self.text and not GotLK_PouchDB.hidePouchTitle then self.text:Show() else if self.text then self.text:Hide() end end
    self:UpdateMsgFramePosition()
end

function GotLK_Pouch:HideTooltip()
    if GameTooltip:IsShown() then GameTooltip:Hide() end
    if self.text then self.text:Hide() end
    self:UpdateMsgFramePosition()
end

function GotLK_Pouch:HandleClick()
    if not self.enabled then return end
    ToggleCharacter("TokenFrame")
end

function GotLK_Pouch:SetDraggable(enabled)
    local btn = self.minimapButton
    if not btn then return end
    if enabled then
        btn:RegisterForDrag("LeftButton")
        btn:SetScript("OnDragStart", function() GotLK_Pouch:BeginDrag() end)
        btn:SetScript("OnDragStop", function() GotLK_Pouch:EndDrag() end)
        btn:SetScript("OnUpdate", function() GotLK_Pouch:DragUpdate() end)
    else
        btn:RegisterForDrag()
        btn:SetScript("OnDragStart", nil)
        btn:SetScript("OnDragStop", nil)
        btn:SetScript("OnUpdate", nil)
    end
end

function GotLK_Pouch:CreateIcon()
    if self.button then return end
    local holder = CreateFrame("Frame", "GotLKCurrencyMinimap", Minimap)
    holder:SetSize(33, 35)
    holder:SetFrameStrata("LOW")
    holder:SetPoint("CENTER")
    holder:EnableMouse(true)
    local btn = CreateFrame("Button", nil, holder)
    btn:SetAllPoints()
    btn:SetHighlightTexture("Interface\\Minimap\\UI-MoneyButton-Hilight")
    btn:SetScript("OnEnter", function() GotLK_Pouch:ShowTooltip() end)
    btn:SetScript("OnLeave", function() GotLK_Pouch:HideTooltip() end)
    btn:SetScript("OnClick", function() GotLK_Pouch:HandleClick() end)
    self.minimapButton = btn
    self.button = holder
    self:SetDraggable(GotLK_PouchDB.draggable)
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 2)
    icon:SetTexture(GotLK_PouchDB.icon or minimapIcon)
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(55, 55)
    border:SetPoint("TOPLEFT")
    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("RIGHT", holder, "LEFT", -1, 3)
    text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    text:SetTextColor(1, 0.82, 0)
    text:SetText("Pouch")
    text:Hide()
    self.text = text
    if C_Timer and C_Timer.After then C_Timer.After(0, function() GotLK_Pouch:Reposition() end) else GotLK_Pouch:Reposition() end
end

function GotLK_Pouch:ToggleCurrency(name)
    if not self.enabled then return end
    if not name or type(name) ~= "string" then return end
    GotLK_PouchDB.enabledCurrencies[name] = not GotLK_PouchDB.enabledCurrencies[name]
    local newState = GotLK_PouchDB.enabledCurrencies[name]
    print("|cffffff00" .. (newState and "Tracking:" or "Stopped Tracking:") .. "|r " .. name)
    if GameTooltip:IsOwned(GotLK_Pouch.button) then GotLK_Pouch:ShowTooltip() end
end

function GotLK_Pouch:Init()
    GotLK_PouchDB = GotLK_PouchDB or {}
    GotLK_PouchDB.angle = GotLK_PouchDB.angle or 192
    GotLK_PouchDB.enabledCurrencies = GotLK_PouchDB.enabledCurrencies or {}
    if GotLK_PouchDB.enabled == nil then GotLK_PouchDB.enabled = true end
    if GotLK_PouchDB.draggable == nil then GotLK_PouchDB.draggable = false end
    if GotLK_PouchDB.showNotifications == nil then GotLK_PouchDB.showNotifications = true end
    self.iconPath = GotLK_PouchDB.icon or minimapIcon
    if GotLK_PouchDB.enabled then self:Enable() else self:Disable() end
end

hooksecurefunc("TokenFrame_Update", function()
    if not GotLK_PouchDB or not GotLK_PouchDB.enabled then return end
    local buttons = TokenFrameContainer and TokenFrameContainer.buttons
    if not buttons then return end
    for _, button in ipairs(buttons) do
        if button.isHeader or not button.name then
            if button.GotLK_PouchToggle then button.GotLK_PouchToggle:Hide() end
            if button.GotLK_PouchIcon then button.GotLK_PouchIcon:Hide() end
        else
            local currencyName = button.name:GetText()
            if not currencyName then return end
            if not button.GotLK_PouchIcon then
                local icon = button:CreateTexture(nil, "ARTWORK")
                icon:SetSize(12, 11)
                icon:SetPoint("LEFT", button, "LEFT", 200, 0)
                icon:SetTexture(GotLK_PouchDB.icon or minimapIcon)
                button.GotLK_PouchIcon = icon
            end
            button.GotLK_PouchIcon:SetTexture(GotLK_PouchDB.icon or minimapIcon)
            if GotLK_PouchDB.hideIcons then
                button.GotLK_PouchIcon:Hide()
            else
                button.GotLK_PouchIcon:Show()
            end
            if not button.GotLK_PouchToggle then
                local toggle = CreateFrame("CheckButton", nil, button, "UICheckButtonTemplate")
                toggle:SetSize(18, 18)
                toggle:SetPoint("LEFT", button.GotLK_PouchIcon, "RIGHT", -28, 0)
                toggle:SetScript("OnClick", function(self)
                    GotLK_Pouch:ToggleCurrency(currencyName)
                    self:SetChecked(GotLK_PouchDB.enabledCurrencies[currencyName])
                end)
                toggle:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Track in Pouch.")
                    GameTooltip:Show()
                end)
                toggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
                button.GotLK_PouchToggle = toggle
            end
            local isTracked = GotLK_PouchDB.enabledCurrencies[currencyName]
            button.GotLK_PouchToggle:SetChecked(isTracked)
            button.GotLK_PouchToggle:Show()
        end
    end
end)

GotLK_PouchDB = GotLK_PouchDB or {}
if GotLK_PouchDB.showNotifications == nil then GotLK_PouchDB.showNotifications = true end

local _pouchState = { lastMoney = nil, lastCurrencies = {}, lastAP = nil }
local wipeTbl = wipe or function(t) for k in pairs(t) do t[k]=nil end end

local function MoneyToCoinTexture(copperAbs)
    local g = math.floor(copperAbs / 10000)
    local s = math.floor((copperAbs % 10000) / 100)
    local c = copperAbs % 100
    local t = ""
    if g > 0 then t = t .. g .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t " end
    if s > 0 or (g > 0 and c > 0) then t = t .. s .. "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t " end
    t = t .. c .. "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
    return t
end

local function IconForCurrency(name)
    local entry = trackedIcons and trackedIcons[name]
    local icon = nil
    if type(entry) == "table" then icon = entry[UnitFactionGroup("player")] else icon = entry end
    return icon or (GotLK_PouchDB and GotLK_PouchDB.icon) or minimapIcon
end

function GotLK_Pouch:AcquireMsgFrame()
    if self.msgFrame then return self.msgFrame end
    local holder = self.button or Minimap
    local f = CreateFrame("Frame", nil, holder)
    f:SetSize(260, 20)
    f:SetFrameStrata("TOOLTIP")
    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetJustifyH("RIGHT")
    if self.text and self.text.GetFont then
        local path, size, flags = self.text:GetFont()
        f.text:SetFont(path or "Fonts\\FRIZQT__.TTF", size or 12, flags or "OUTLINE")
    else
        f.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    end
    f.text:SetAllPoints(f)
    f:Hide()
    f.elapsed = 0
    f.visibleFor = 3.0
    f.fadeFor = 1.5
    self.msgFrame = f
    self.currentKey = nil
    self.currentDelta = 0
    self.currentIsMoney = false
    self.currentIcon = nil
    self:UpdateMsgFramePosition()
    return f
end

function GotLK_Pouch:UpdateMsgFrameFont()
    if not self.msgFrame or not self.text then return end
    local path, size, flags = self.text:GetFont()
    if path then self.msgFrame.text:SetFont(path, size, flags) end
end

function GotLK_Pouch:UpdateMsgFramePosition()
    if not self.msgFrame or not self.button then return end
    self.msgFrame:ClearAllPoints()
    if self.text and self.text:IsShown() then
        self.msgFrame:SetPoint("RIGHT", self.text, "LEFT", -6, 0)
    else
        self.msgFrame:SetPoint("RIGHT", self.button, "LEFT", -6, 0)
    end
    self:UpdateMsgFrameFont()
end

function GotLK_Pouch:FormatCurrentText()
    local amt = math.abs(self.currentDelta)
    local isGain = self.currentDelta > 0
    local sign = isGain and "+" or "-"
    if self.currentIsMoney then
        return sign .. " " .. MoneyToCoinTexture(amt), (isGain and 0 or 1), (isGain and 1 or 0.1), (isGain and 0 or 0.1)
    else
        local prefix = self.currentIcon and ("|T" .. self.currentIcon .. ":16:16:0:0|t ") or ""
        return sign .. " " .. prefix .. tostring(amt), (isGain and 0 or 1), (isGain and 1 or 0.1), (isGain and 0 or 0.1)
    end
end

function GotLK_Pouch:RefreshMessage()
    if not self.msgFrame then return end
    local txt, r, g, b = self:FormatCurrentText()
    self.msgFrame.text:SetText(txt)
    self.msgFrame.text:SetTextColor(r, g, b)
    self.msgFrame.elapsed = 0
    self.msgFrame:Show()
    self.msgFrame:SetAlpha(1)
    self.msgFrame:SetScript("OnUpdate", function(selfFrame, dt)
        selfFrame.elapsed = selfFrame.elapsed + dt
        if selfFrame.elapsed >= (selfFrame.visibleFor + selfFrame.fadeFor) then
            selfFrame:SetScript("OnUpdate", nil)
            selfFrame:Hide()
            GotLK_Pouch.currentKey = nil
            GotLK_Pouch.currentDelta = 0
            GotLK_Pouch.currentIsMoney = false
            GotLK_Pouch.currentIcon = nil
            return
        end
        if selfFrame.elapsed > selfFrame.visibleFor then
            local k = (selfFrame.elapsed - selfFrame.visibleFor) / selfFrame.fadeFor
            selfFrame:SetAlpha(1 - math.min(1, k))
        else
            selfFrame:SetAlpha(1)
        end
    end)
end

function GotLK_Pouch:PushChange(key, delta, isMoney, iconPath)
    if not self.enabled or not GotLK_PouchDB.showNotifications or GotLK_PouchDB.hideNotifications then return end
    local f = self:AcquireMsgFrame()
    self:UpdateMsgFramePosition()
    local canAggregate = self.currentKey and self.currentKey == key and f:IsShown() and f:GetAlpha() > 0
    if canAggregate then
        local sameSign = (self.currentDelta > 0 and delta > 0) or (self.currentDelta < 0 and delta < 0)
        if sameSign then
            self.currentDelta = self.currentDelta + delta
            self.currentIsMoney = isMoney
            self.currentIcon = isMoney and nil or iconPath
            self:RefreshMessage()
        else
            self.currentKey = key
            self.currentDelta = delta
            self.currentIsMoney = isMoney
            self.currentIcon = isMoney and nil or iconPath
            self:RefreshMessage()
        end
    else
        self.currentKey = key
        self.currentDelta = delta
        self.currentIsMoney = isMoney
        self.currentIcon = isMoney and nil or iconPath
        self:RefreshMessage()
    end
end

function GotLK_Pouch:CheckMoney()
    if not self.enabled or GotLK_PouchDB.hideMoney then return end
    local now = GetMoney()
    if _pouchState.lastMoney == nil then _pouchState.lastMoney = now return end
    local delta = now - _pouchState.lastMoney
    if delta ~= 0 then
        self:PushChange("MONEY", delta, true, nil)
        _pouchState.lastMoney = now
    end
end

function GotLK_Pouch:CheckCurrencies()
    if not self.enabled then return end
    for i = 1, GetCurrencyListSize() do
        local name, isHeader, _, _, _, count = GetCurrencyListInfo(i)
        if name and not isHeader and count then
            if GotLK_PouchDB.enabledCurrencies and GotLK_PouchDB.enabledCurrencies[name] then
                local last = _pouchState.lastCurrencies[name] or count
                local delta = count - last
                if delta ~= 0 then
                    local icon = IconForCurrency(name)
                    self:PushChange(name, delta, false, icon)
                end
                _pouchState.lastCurrencies[name] = count
            else
                _pouchState.lastCurrencies[name] = count
            end
        end
    end
end

function GotLK_Pouch:CheckAchievementPoints()
    if not self.enabled or not GotLK_PouchDB.showAchievementPoints then return end
    local getAP = GetTotalAchievementPoints
    if not getAP then return end
    local now = getAP() or 0
    if _pouchState.lastAP == nil then _pouchState.lastAP = now return end
    local delta = now - _pouchState.lastAP
    if delta ~= 0 then
        self:PushChange("ACHIEVEMENT_POINTS", delta, false, "Interface\\Icons\\Achievement_Level_80")
        _pouchState.lastAP = now
    end
end

local GotLK_Pouch_Events = CreateFrame("Frame")
GotLK_Pouch_Events:RegisterEvent("PLAYER_ENTERING_WORLD")
GotLK_Pouch_Events:RegisterEvent("PLAYER_MONEY")
GotLK_Pouch_Events:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
GotLK_Pouch_Events:RegisterEvent("ACHIEVEMENT_EARNED")
GotLK_Pouch_Events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        _pouchState.lastMoney = GetMoney()
        _pouchState.lastAP = GetTotalAchievementPoints and GetTotalAchievementPoints() or nil
        wipeTbl(_pouchState.lastCurrencies)
        for i = 1, GetCurrencyListSize() do
            local name, isHeader, _, _, _, count = GetCurrencyListInfo(i)
            if name and not isHeader and count then _pouchState.lastCurrencies[name] = count end
        end
        return
    end
    if event == "PLAYER_MONEY" then
        GotLK_Pouch:CheckMoney()
        return
    end
    if event == "CURRENCY_DISPLAY_UPDATE" then
        GotLK_Pouch:CheckCurrencies()
        return
    end
    if event == "ACHIEVEMENT_EARNED" then
        GotLK_Pouch:CheckAchievementPoints()
        return
    end
end)

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function() GotLK_Pouch:Init() end)

local saver = CreateFrame("Frame")
saver:RegisterEvent("PLAYER_LOGOUT")
saver:SetScript("OnEvent", function()
    GotLK_PouchDB.enabled = GotLK_Pouch and GotLK_Pouch.enabled or false
end)
