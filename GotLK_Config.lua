local GotLK_VERSION = "1.0.0"
local GotLK_AUTHOR = "@Hizuie"

local topLevel = CreateFrame("Frame", "GotLKConfigCategory", UIParent)
topLevel.name = "Grip of the Lich King"
InterfaceOptions_AddCategory(topLevel)

local overviewPanel = CreateFrame("Frame", "GotLKOverviewPanel", UIParent)
overviewPanel.name = "Overview"
overviewPanel.parent = topLevel.name
InterfaceOptions_AddCategory(overviewPanel)

local pouchPanel = CreateFrame("Frame", "GotLKPouchPanel", UIParent)
pouchPanel.name = "Pouch"
pouchPanel.parent = topLevel.name
InterfaceOptions_AddCategory(pouchPanel)

local function SetPouchPanelEnabled(enabled)
    local alpha = enabled and 1 or 0.4
    local function SetDisabledRecursive(frame, disable)
        if frame.SetEnabled then frame:SetEnabled(not disable) end
        if frame:IsObjectType("Button") or frame:IsObjectType("CheckButton") then frame:EnableMouse(not disable) end
        local regions = { frame:GetRegions() }
        for _, r in ipairs(regions) do if r.SetAlpha then r:SetAlpha(alpha) end end
        local children = { frame:GetChildren() }
        for _, child in ipairs(children) do SetDisabledRecursive(child, disable) end
    end
    SetDisabledRecursive(pouchPanel, not enabled)
end

local title = overviewPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Grip of the Lich King")

local intro = overviewPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
intro:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
intro:SetWidth(560)
intro:SetJustifyH("LEFT")
intro:SetJustifyV("TOP")
intro:SetText(
"Grip of the Lich King is a set of |cff00ff99quality-of-life|r improvements and subtle\n" ..
"features designed to blend naturally into the |cffffff00World of Warcraft|r experience.\n" ..
"Every addition is crafted to feel like a seamless extension of the game.\n\n" ..
"As for the name? Just a playful nod to the iconic |cff66ccffWrath of the Lich King|r\n" ..
"expansion."
)

local separator = overviewPanel:CreateTexture(nil, "ARTWORK")
separator:SetTexture(1, 1, 1, 0.25)
separator:SetSize(370, 1)
separator:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -16)

local sectionTitle = overviewPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
sectionTitle:SetPoint("TOPLEFT", separator, "BOTTOMLEFT", 0, -10)
sectionTitle:SetText("Control Panel")

local subText = overviewPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subText:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -12)
subText:SetText("These options let you enable or disable individual modules.")

local pouchEnableCheckbox = CreateFrame("CheckButton", "GotLKPouchEnableCheckbox", overviewPanel, "InterfaceOptionsCheckButtonTemplate")
pouchEnableCheckbox:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 0, -8)
pouchEnableCheckbox.text = pouchEnableCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
pouchEnableCheckbox.text:SetPoint("LEFT", pouchEnableCheckbox, "RIGHT", 4, 1)
pouchEnableCheckbox.text:SetText("Pouch")

local pouchTitle = pouchPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
pouchTitle:SetPoint("TOPLEFT", 16, -16)
pouchTitle:SetText("Pouch")

local pouchStatus = pouchPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
pouchStatus:SetPoint("TOPRIGHT", pouchTitle, "TOPRIGHT", 340, 0)
pouchStatus:SetJustifyH("RIGHT")
pouchStatus:SetText("Disabled")
pouchStatus:SetTextColor(1, 0, 0)
pouchStatus:Hide()

local pouchDesc = pouchPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
pouchDesc:SetPoint("TOPLEFT", pouchTitle, "BOTTOMLEFT", 0, -8)
pouchDesc:SetWidth(560)
pouchDesc:SetJustifyH("LEFT")
pouchDesc:SetText("These options allow you to change the way the Pouch looks or behaves.")

local pouchIconDropdown = CreateFrame("Frame", "GotLKPouchIconDropdown", pouchPanel, "UIDropDownMenuTemplate")
pouchIconDropdown:SetPoint("TOPLEFT", pouchDesc, "BOTTOMLEFT", -15, -12)

local pouchIconOptions = {
    { text = "Borean Brown Pouch", value = "Interface\\Icons\\inv_misc_bag_19" },
    { text = "Fel Green Pouch", value = "Interface\\Icons\\inv_misc_bag_20" },
    { text = "Blood Red Pouch", value = "Interface\\Icons\\inv_misc_bag_22" },
    { text = "Void Purple Pouch", value = "Interface\\Icons\\inv_misc_bag_21" },
}

local function UpdatePouchIcon(texturePath)
    GotLK_PouchDB = GotLK_PouchDB or {}
    GotLK_PouchDB.icon = texturePath
    if GotLK_Pouch and GotLK_Pouch.minimapButton then
        local textures = { GotLK_Pouch.minimapButton:GetRegions() }
        for _, t in ipairs(textures) do
            if t:GetObjectType() == "Texture" and t:GetTexture() == GotLK_Pouch.iconPath then
                t:SetTexture(texturePath)
                break
            end
        end
    end
    GotLK_Pouch.iconPath = texturePath
    for _, opt in ipairs(pouchIconOptions) do
        if opt.value == texturePath then
            UIDropDownMenu_SetText(pouchIconDropdown, opt.text)
            break
        end
    end
    if TokenFrame_Update then TokenFrame_Update() end
end

UIDropDownMenu_Initialize(pouchIconDropdown, function(self, level)
    for _, opt in ipairs(pouchIconOptions) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = opt.text
        info.value = opt.value
        info.func = function()
            UIDropDownMenu_SetSelectedValue(pouchIconDropdown, opt.value)
            UpdatePouchIcon(opt.value)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

GotLK_PouchDB = GotLK_PouchDB or {}
local defaultIcon = GotLK_PouchDB.icon or "Interface\\Icons\\inv_misc_bag_19"
UIDropDownMenu_SetSelectedValue(pouchIconDropdown, defaultIcon)
UIDropDownMenu_SetWidth(pouchIconDropdown, 125)
UpdatePouchIcon(defaultIcon)

_G["GotLKPouchIconDropdownButton"]:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Choose a pouch icon.")
    GameTooltip:Show()
end)

_G["GotLKPouchIconDropdownButton"]:HookScript("OnLeave", function()
    GameTooltip:Hide()
end)

local draggableCheckbox = CreateFrame("CheckButton", "GotLKPouchDraggableCheckbox", pouchPanel, "InterfaceOptionsCheckButtonTemplate")
draggableCheckbox:SetPoint("TOPLEFT", pouchIconDropdown, "BOTTOMLEFT", 15, -12)
draggableCheckbox.text = draggableCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
draggableCheckbox.text:SetPoint("LEFT", draggableCheckbox, "RIGHT", 4, 1)
draggableCheckbox.text:SetText("Draggable")

local resetButton = CreateFrame("Button", nil, pouchPanel, "UIPanelButtonTemplate")
resetButton:SetSize(105, 22)
resetButton:SetPoint("LEFT", draggableCheckbox.text, "RIGHT", 20, 0)
resetButton:SetText("Reset Position")
resetButton:SetScript("OnClick", function()
    GotLK_PouchDB = GotLK_PouchDB or {}
    GotLK_PouchDB.angle = 192
    if GotLK_Pouch then GotLK_Pouch:Reposition() end
end)

local advancedTitle = pouchPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
advancedTitle:SetPoint("TOPLEFT", draggableCheckbox, "BOTTOMLEFT", 0, -24)
advancedTitle:SetText("Advanced Options")

local hideMoneyCheckbox = CreateFrame("CheckButton", "GotLKPouchHideMoneyCheckbox", pouchPanel, "InterfaceOptionsCheckButtonTemplate")
hideMoneyCheckbox:SetPoint("TOPLEFT", advancedTitle, "BOTTOMLEFT", 0, -8)
hideMoneyCheckbox.text = hideMoneyCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
hideMoneyCheckbox.text:SetPoint("LEFT", hideMoneyCheckbox, "RIGHT", 4, 1)
hideMoneyCheckbox.text:SetText("Hide Money")
hideMoneyCheckbox:SetScript("OnClick", function(self)
    GotLK_PouchDB.hideMoney = self:GetChecked()
    if GotLK_Pouch and GameTooltip:IsOwned(GotLK_Pouch.button) then
        GotLK_Pouch:ShowTooltip()
    end
end)

local hidePouchTitleCheckbox = CreateFrame("CheckButton", "GotLKPouchHidePouchTitleCheckbox", pouchPanel, "InterfaceOptionsCheckButtonTemplate")
hidePouchTitleCheckbox:SetPoint("TOPLEFT", hideMoneyCheckbox, "BOTTOMLEFT", 0, -8)
hidePouchTitleCheckbox.text = hidePouchTitleCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
hidePouchTitleCheckbox.text:SetPoint("LEFT", hidePouchTitleCheckbox, "RIGHT", 4, 1)
hidePouchTitleCheckbox.text:SetText("Hide Pouch Title")
hidePouchTitleCheckbox:SetScript("OnClick", function(self)
    GotLK_PouchDB.hidePouchTitle = self:GetChecked()
    if GotLK_Pouch and GameTooltip:IsOwned(GotLK_Pouch.button) then
        GotLK_Pouch:ShowTooltip()
    end
end)

local hideIconsCheckbox = CreateFrame("CheckButton", "GotLKPouchHideCurrencyIconsCheckbox", pouchPanel, "InterfaceOptionsCheckButtonTemplate")
hideIconsCheckbox:SetPoint("TOPLEFT", hidePouchTitleCheckbox, "BOTTOMLEFT", 0, -8)
hideIconsCheckbox.text = hideIconsCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
hideIconsCheckbox.text:SetPoint("LEFT", hideIconsCheckbox, "RIGHT", 4, 1)
hideIconsCheckbox.text:SetText("Hide Currency Icons")
hideIconsCheckbox:SetScript("OnClick", function(self)
    GotLK_PouchDB.hideIcons = self:GetChecked()
    if GotLK_Pouch and GameTooltip:IsOwned(GotLK_Pouch.button) then
        GotLK_Pouch:ShowTooltip()
    end
    if TokenFrame_Update then TokenFrame_Update() end
end)

local miscTitle = pouchPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
miscTitle:SetPoint("TOPLEFT", hideIconsCheckbox, "BOTTOMLEFT", 0, -24)
miscTitle:SetText("Miscellaneous")

local showAPCheckbox = CreateFrame("CheckButton", "GotLKPouchShowAchievementPointsCheckbox", pouchPanel, "InterfaceOptionsCheckButtonTemplate")
showAPCheckbox:SetPoint("TOPLEFT", miscTitle, "BOTTOMLEFT", 0, -8)
showAPCheckbox.text = showAPCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
showAPCheckbox.text:SetPoint("LEFT", showAPCheckbox, "RIGHT", 4, 1)
showAPCheckbox.text:SetText("Show Achievement Points")
showAPCheckbox:SetScript("OnClick", function(self)
    GotLK_PouchDB.showAchievementPoints = self:GetChecked()
    if GotLK_Pouch and GameTooltip:IsOwned(GotLK_Pouch.button) then
        GotLK_Pouch:ShowTooltip()
    end
end)

pouchEnableCheckbox:SetScript("OnClick", function(self)
    GotLK_PouchDB = GotLK_PouchDB or {}
    local checked = self:GetChecked()
    GotLK_PouchDB.enabled = checked
    if GotLK_Pouch then
        if checked then GotLK_Pouch:Enable() else GotLK_Pouch:Disable() end
    end
    SetPouchPanelEnabled(checked)
    if checked then
        pouchTitle:SetTextColor(1, 0.82, 0)
        pouchStatus:Hide()
    else
        pouchTitle:SetTextColor(0.5, 0.5, 0.5)
        pouchStatus:Show()
    end
    if TokenFrame_Update then TokenFrame_Update() end
end)

draggableCheckbox:SetScript("OnClick", function(self)
    GotLK_PouchDB = GotLK_PouchDB or {}
    GotLK_PouchDB.draggable = self:GetChecked()
    if GotLK_Pouch and GotLK_Pouch.minimapButton then
        GotLK_Pouch:SetDraggable(self:GetChecked())
    end
end)

pouchPanel:SetScript("OnShow", function()
    GotLK_PouchDB = GotLK_PouchDB or {}
    draggableCheckbox:SetChecked(GotLK_PouchDB.draggable or false)
    hideMoneyCheckbox:SetChecked(GotLK_PouchDB.hideMoney or false)
    hidePouchTitleCheckbox:SetChecked(GotLK_PouchDB.hidePouchTitle or false)
    hideIconsCheckbox:SetChecked(GotLK_PouchDB.hideIcons or false)
    showAPCheckbox:SetChecked(GotLK_PouchDB.showAchievementPoints or false)
    SetPouchPanelEnabled(GotLK_PouchDB.enabled)
    if GotLK_PouchDB.enabled then
        pouchTitle:SetTextColor(1, 0.82, 0)
        pouchStatus:Hide()
    else
        pouchTitle:SetTextColor(0.5, 0.5, 0.5)
        pouchStatus:Show()
    end
    local selected = GotLK_PouchDB.icon or "Interface\\Icons\\inv_misc_bag_19"
    UIDropDownMenu_SetSelectedValue(pouchIconDropdown, selected)
    UpdatePouchIcon(selected)
end)

overviewPanel:SetScript("OnShow", function()
    GotLK_PouchDB = GotLK_PouchDB or {}
    pouchEnableCheckbox:SetChecked(GotLK_PouchDB.enabled)
end)

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    GotLK_PouchDB = GotLK_PouchDB or {}
    if GotLK_Pouch then
        if GotLK_PouchDB.enabled then GotLK_Pouch:Enable() else GotLK_Pouch:Disable() end
        GotLK_Pouch:SetDraggable(GotLK_PouchDB.draggable or false)
        if GotLK_PouchDB.icon then UpdatePouchIcon(GotLK_PouchDB.icon) end
    end
end)

topLevel:SetScript("OnShow", function()
    InterfaceOptionsFrame_OpenToCategory(GotLKOverviewPanel)
end)

local function AddFooter(panel)
    local versionSeparator = panel:CreateTexture(nil, "ARTWORK")
    versionSeparator:SetTexture(1, 1, 1, 0.25)
    versionSeparator:SetSize(380, 1)
    versionSeparator:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 36)
    local versionText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    versionText:SetPoint("TOPLEFT", versionSeparator, "BOTTOMLEFT", 0, -8)
    versionText:SetJustifyH("LEFT")
    versionText:SetText("|cffa0a0a0Version " .. GotLK_VERSION .. "|r")
end

AddFooter(overviewPanel)
AddFooter(pouchPanel)
