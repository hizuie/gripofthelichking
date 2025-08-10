local pendingUpdate = false
local retryFrame = CreateFrame("Frame")

function GotLK_GetAverageItemLevelFull()
    local total, count = 0, 0
    for slot = 1, 17 do
        if slot ~= 4 then
            local itemLink = GetInventoryItemLink("player", slot)
            if itemLink then
                local _, _, _, itemLevel = GetItemInfo(itemLink)
                if itemLevel then
                    total = total + itemLevel
                    count = count + 1
                end
            end
        end
    end
    return (count > 0) and string.format("%.0f", total / count) or "0"
end

function GotLK_GetAverageItemLevelShort()
    local total, count = 0, 0
    for slot = 1, 17 do
        if slot ~= 4 then
            local itemLink = GetInventoryItemLink("player", slot)
            if itemLink then
                local _, _, _, itemLevel = GetItemInfo(itemLink)
                if itemLevel then
                    total = total + itemLevel
                    count = count + 1
                end
            end
        end
    end
    if count == 0 then return "0" end
    local avg = total / count
    return (avg >= 1000) and string.format("%.1fk", avg / 1000) or string.format("%.0f", avg)
end

function GotLK_GetAverageItemQuality()
    local total, count = 0, 0
    for slot = 1, 17 do
        if slot ~= 4 then
            local itemLink = GetInventoryItemLink("player", slot)
            if itemLink then
                local _, _, quality = GetItemInfo(itemLink)
                if quality then
                    total = total + quality
                    count = count + 1
                end
            end
        end
    end
    return (count > 0) and math.floor((total / count) + 0.5) or nil
end

function GotLK_CalculateGearScore()
    local Scale = 1.8618
    local GS_Formula = {
        A = {
            [4] = { A = 91.45, B = 0.65 },
            [3] = { A = 81.375, B = 0.8125 },
            [2] = { A = 73.0, B = 1.0 }
        },
        B = {
            [4] = { A = 26.0, B = 1.2 },
            [3] = { A = 0.75, B = 1.8 },
            [2] = { A = 8.0, B = 2.0 },
            [1] = { A = 0.0, B = 2.25 }
        }
    }
    local GS_ItemTypes = {
        ["INVTYPE_HEAD"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_NECK"] = { SlotMOD = 0.5625, Enchantable = false },
        ["INVTYPE_SHOULDER"] = { SlotMOD = 0.75, Enchantable = true },
        ["INVTYPE_CLOAK"] = { SlotMOD = 0.5625, Enchantable = true },
        ["INVTYPE_CHEST"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_ROBE"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_WRIST"] = { SlotMOD = 0.5625, Enchantable = true },
        ["INVTYPE_HAND"] = { SlotMOD = 0.75, Enchantable = true },
        ["INVTYPE_WAIST"] = { SlotMOD = 0.75, Enchantable = false },
        ["INVTYPE_LEGS"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_FEET"] = { SlotMOD = 0.75, Enchantable = true },
        ["INVTYPE_FINGER"] = { SlotMOD = 0.5625, Enchantable = false },
        ["INVTYPE_TRINKET"] = { SlotMOD = 0.5625, Enchantable = false },
        ["INVTYPE_2HWEAPON"] = { SlotMOD = 2.0, Enchantable = true },
        ["INVTYPE_WEAPON"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_WEAPONMAINHAND"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_WEAPONOFFHAND"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_SHIELD"] = { SlotMOD = 1.0, Enchantable = true },
        ["INVTYPE_HOLDABLE"] = { SlotMOD = 1.0, Enchantable = false },
        ["INVTYPE_RANGED"] = { SlotMOD = 0.3164, Enchantable = true },
        ["INVTYPE_RANGEDRIGHT"] = { SlotMOD = 0.3164, Enchantable = false },
        ["INVTYPE_THROWN"] = { SlotMOD = 0.3164, Enchantable = false },
        ["INVTYPE_RELIC"] = { SlotMOD = 0.3164, Enchantable = false }
    }
    local totalGS = 0
    for slot = 1, 18 do
        if slot ~= 4 then
            local link = GetInventoryItemLink("player", slot)
            if link then
                local _, _, rarity, ilvl, _, _, _, _, slotType = GetItemInfo(link)
                if not ilvl or not rarity or not slotType then
                    pendingUpdate = true
                    retryFrame:Show()
                    return 0
                end
                if rarity == 5 then rarity = 4 end
                local qualityScale = 1.0
                if rarity == 5 then qualityScale = 1.3 end
                if rarity == 1 or rarity == 0 then
                    qualityScale = 0.005
                    rarity = 2
                end
                local typeData = GS_ItemTypes[slotType]
                if typeData and rarity >= 2 and rarity <= 4 then
                    local formula = (ilvl > 120) and GS_Formula.A[rarity] or GS_Formula.B[rarity]
                    local base = (ilvl - formula.A) / formula.B * typeData.SlotMOD * Scale * qualityScale
                    local rawScore = math.floor(base)
                    local enchantMod = 1.0
                    if typeData.Enchantable then
                        local _, _, itemString = string.find(link, "^|c%x+|H(.+)|h%[.*%]")
                        if itemString then
                            local parts = { strsplit(":", itemString) }
                            local enchantID = tonumber(parts[3]) or 0
                            if enchantID == 0 then
                                enchantMod = 1 + ((-2 * typeData.SlotMOD) / 100)
                            end
                        end
                    end
                    local finalScore = math.floor(rawScore * enchantMod)
                    totalGS = totalGS + math.max(0, finalScore)
                end
            end
        end
    end
    return math.floor(totalGS)
end

function GotLK_FormatGearScore(score)
    return (score >= 1000) and string.format("%.1fk", score / 1000) or tostring(score)
end

function GotLK_UpdateGearScoreDisplay(frame)
    local text = _G[frame:GetName() .. "Text"]
    if text then
        if not text:GetFont() then
            text:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
        end
        local gs = GotLK_CalculateGearScore()
        text:SetText(GotLK_FormatGearScore(gs))
        text:SetTextColor(1, 1, 1)
    end
end

function GotLK_ShowGearScoreTooltip(self)
    self:SetFrameStrata("HIGH")
    local gs = GotLK_CalculateGearScore()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Overall Gear Score " .. tostring(gs), 1, 1, 1)
    GameTooltip:AddLine("Displays a numerical representation of your gear's overall strength. Based on item level and slot weight.", 1.0, 0.82, 0.0, true)
    GameTooltip:Show()
end

function GotLK_UpdateAvgItemLevelDisplay(frame)
    local incomplete = false
    for slot = 1, 17 do
        if slot ~= 4 then
            local itemLink = GetInventoryItemLink("player", slot)
            if itemLink then
                local _, _, _, itemLevel = GetItemInfo(itemLink)
                if not itemLevel then
                    incomplete = true
                    break
                end
            end
        end
    end
    if incomplete then
        pendingUpdate = true
        retryFrame:Show()
        return
    end
    local text = _G[frame:GetName() .. "Text"]
    if text then
        if not text:GetFont() then
            text:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
        end
        text:SetText(GotLK_GetAverageItemLevelShort())
        text:SetTextColor(1, 1, 1)
    end
    if GotLK_AvgItemLevelIcon and GameTooltip then
        local tooltipLevel = GameTooltip:GetFrameLevel()
        GotLK_AvgItemLevelIcon:SetFrameStrata("HIGH")
        GotLK_AvgItemLevelIcon:SetFrameLevel(tooltipLevel - 1)
    end
    if GameTooltip:IsOwned(frame) then
        GotLK_ShowTooltip(frame)
    end
end

function GotLK_ShowTooltip(self)
    self:SetFrameStrata("HIGH")
    local avgLevel = GotLK_GetAverageItemLevelFull()
    local avgQuality = GotLK_GetAverageItemQuality()
    local qualityNames = {
        [0] = "Poor",
        [1] = "Common",
        [2] = "Uncommon",
        [3] = "Rare",
        [4] = "Epic",
        [5] = "Legendary"
    }
    local qualityHexColors = {
        [0] = "FF9D9D9D",
        [1] = "FFFFFFFF",
        [2] = "FF1EFF00",
        [3] = "FF0070DD",
        [4] = "FFA335EE",
        [5] = "FFFF8000"
    }
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Avg. Item Level " .. avgLevel, 1, 1, 1)
    GameTooltip:AddLine("Represents the average level of all\nthe currently equipped items.", 1.0, 0.82, 0.0)
    if avgQuality and qualityNames[avgQuality] and qualityHexColors[avgQuality] then
        local qualityColor = "|c" .. qualityHexColors[avgQuality]
        local qualityText = qualityColor .. qualityNames[avgQuality] .. "|r"
        GameTooltip:AddLine("Avg. quality: " .. qualityText, 1.0, 0.82, 0.0)
    end
    GameTooltip:Show()
end

function GotLK_CalculateDurability()
    local current, max = 0, 0
    for slot = 1, 17 do
        if slot ~= 4 then
            local cur, maxDur = GetInventoryItemDurability(slot)
            if cur and maxDur and maxDur > 0 then
                current = current + cur
                max = max + maxDur
            end
        end
    end
    return (max > 0) and math.floor((current / max) * 100 + 0.5) or 100
end

function GotLK_UpdateDurabilityDisplay(frame)
    local text = _G[frame:GetName() .. "Text"]
    if text then
        if not text:GetFont() then
            text:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
        end
        local percent = GotLK_CalculateDurability()
        text:SetText(percent .. "%")
        text:SetTextColor(1, 1, 1)
    end
end

function GotLK_ShowDurabilityTooltip(self)
    self:SetFrameStrata("HIGH")
    local percent = GotLK_CalculateDurability()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Item Durability " .. percent .. "%", 1, 1, 1)
    GameTooltip:AddLine("Represents the total durability\nof your equipped items.", 1.0, 0.82, 0.0, true)
    GameTooltip:Show()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
f:SetScript("OnEvent", function(self, event)
    if event == "GET_ITEM_INFO_RECEIVED" then
        if pendingUpdate and GotLK_AvgItemLevelIcon then
            GotLK_UpdateAvgItemLevelDisplay(GotLK_AvgItemLevelIcon)
            GotLK_UpdateGearScoreDisplay(GotLK_GearScoreIcon)
            GotLK_UpdateDurabilityDisplay(GotLK_DurabilityIcon)
            pendingUpdate = false
        end
    else
        if GotLK_AvgItemLevelIcon then GotLK_UpdateAvgItemLevelDisplay(GotLK_AvgItemLevelIcon) end
        if GotLK_GearScoreIcon then GotLK_UpdateGearScoreDisplay(GotLK_GearScoreIcon) end
        if GotLK_DurabilityIcon then GotLK_UpdateDurabilityDisplay(GotLK_DurabilityIcon) end
    end
end)

_G.GotLK_CharacterEventFrame = f

retryFrame:Hide()
retryFrame:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.5 then
        self.timer = 0
        if pendingUpdate and GotLK_AvgItemLevelIcon then
            GotLK_UpdateAvgItemLevelDisplay(GotLK_AvgItemLevelIcon)
            GotLK_UpdateGearScoreDisplay(GotLK_GearScoreIcon)
            GotLK_UpdateDurabilityDisplay(GotLK_DurabilityIcon)
        end
    end
end)

_G.GotLK_Character = _G.GotLK_Character or {}
local Character = _G.GotLK_Character

function Character:Enable()
    GotLK_CharacterDB = GotLK_CharacterDB or {}
    GotLK_CharacterDB.enabled = true
    if _G.GotLKFrame then _G.GotLKFrame:Show() end
    if _G.GotLK_AvgItemLevelIcon then _G.GotLK_AvgItemLevelIcon:Show() end
    if _G.GotLK_GearScoreIcon then _G.GotLK_GearScoreIcon:Show() end
    if _G.GotLK_DurabilityIcon then _G.GotLK_DurabilityIcon:Show() end
    if _G.GotLKButtonToggle then _G.GotLKButtonToggle:Show() end
    if _G.GotLK_CharacterEventFrame then
        local ef = _G.GotLK_CharacterEventFrame
        ef:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        ef:RegisterEvent("UNIT_INVENTORY_CHANGED")
        ef:RegisterEvent("PLAYER_ENTERING_WORLD")
        ef:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    end
end

function Character:Disable()
    GotLK_CharacterDB = GotLK_CharacterDB or {}
    GotLK_CharacterDB.enabled = false
    if _G.GotLKFrame then _G.GotLKFrame:Hide() end
    if _G.GotLK_AvgItemLevelIcon then _G.GotLK_AvgItemLevelIcon:Hide() end
    if _G.GotLK_GearScoreIcon then _G.GotLK_GearScoreIcon:Hide() end
    if _G.GotLK_DurabilityIcon then _G.GotLK_DurabilityIcon:Hide() end
    if _G.GotLKButtonToggle then _G.GotLKButtonToggle:Hide() end
    if _G.GotLK_CharacterEventFrame then
        _G.GotLK_CharacterEventFrame:UnregisterAllEvents()
    end
end

