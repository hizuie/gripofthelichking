local function IsEquippableItem(itemLink)
    local _, _, _, _, _, itemType, _, _, equipSlot = GetItemInfo(itemLink)
    return equipSlot ~= "" and (itemType == "Armor" or itemType == "Weapon")
end

local GS_Formula = {
    A = {
        [4] = { A = 91.45,  B = 0.65 },
        [3] = { A = 81.375, B = 0.8125 },
        [2] = { A = 73.0,   B = 1.0 }
    },
    B = {
        [4] = { A = 26.0,  B = 1.2 },
        [3] = { A = 0.75,  B = 1.8 },
        [2] = { A = 8.0,   B = 2.0 },
        [1] = { A = 0.0,   B = 2.25 }
    }
}

local GS_ItemTypes = {
    INVTYPE_HEAD           = { m = 1.0,    e = true  },
    INVTYPE_NECK           = { m = 0.5625, e = false },
    INVTYPE_SHOULDER       = { m = 0.75,   e = true  },
    INVTYPE_CLOAK          = { m = 0.5625, e = true  },
    INVTYPE_CHEST          = { m = 1.0,    e = true  },
    INVTYPE_ROBE           = { m = 1.0,    e = true  },
    INVTYPE_WRIST          = { m = 0.5625, e = true  },
    INVTYPE_HAND           = { m = 0.75,   e = true  },
    INVTYPE_WAIST          = { m = 0.75,   e = false },
    INVTYPE_LEGS           = { m = 1.0,    e = true  },
    INVTYPE_FEET           = { m = 0.75,   e = true  },
    INVTYPE_FINGER         = { m = 0.5625, e = false },
    INVTYPE_TRINKET        = { m = 0.5625, e = false },
    INVTYPE_2HWEAPON       = { m = 2.0,    e = true  },
    INVTYPE_WEAPON         = { m = 1.0,    e = true  },
    INVTYPE_WEAPONMAINHAND = { m = 1.0,    e = true  },
    INVTYPE_WEAPONOFFHAND  = { m = 1.0,    e = true  },
    INVTYPE_SHIELD         = { m = 1.0,    e = true  },
    INVTYPE_HOLDABLE       = { m = 1.0,    e = false },
    INVTYPE_RANGED         = { m = 0.3164, e = true  },
    INVTYPE_RANGEDRIGHT    = { m = 0.3164, e = false },
    INVTYPE_THROWN         = { m = 0.3164, e = false },
    INVTYPE_RELIC          = { m = 0.3164, e = false }
}

local function CalculateItemGearScore(itemLink)
    local _, _, rarity, ilvl, _, _, _, _, slot = GetItemInfo(itemLink)
    local data = GS_ItemTypes[slot]
    if not (rarity and ilvl and data and rarity >= 2) then return nil end
    if rarity == 5 then rarity = 4 end
    local scale = 1.8618
    local formula = (ilvl > 120) and GS_Formula.A[rarity] or GS_Formula.B[rarity]
    local base = (ilvl - formula.A) / formula.B * data.m * scale
    local raw = math.floor(base)
    local enchantMod = 1.0
    if data.e then
        local _, _, s = string.find(itemLink, "^|c%x+|H(.+)|h")
        if s then
            local parts = { strsplit(":", s) }
            if tonumber(parts[3]) == 0 then
                enchantMod = 1 - (2 * data.m / 100)
            end
        end
    end
    return math.floor(math.max(0, raw * enchantMod))
end

local function AddGearScoreToTooltip(tooltip)
    local _, link = tooltip:GetItem()
    if not link or not IsEquippableItem(link) then return end

    -- remove Blizzard Item Level line
    for i = 1, tooltip:NumLines() do
        local left = _G[tooltip:GetName() .. "TextLeft" .. i]
        if left and left:GetText() and left:GetText():find("Item Level") then
            left:SetText(nil)
            local right = _G[tooltip:GetName() .. "TextRight" .. i]
            if right then right:SetText(nil) end
        end
    end

    local gs = CalculateItemGearScore(link)
    if not gs then return end
    local _, _, _, ilvl = GetItemInfo(link)

    local gsIcon   = "|TInterface\\Icons\\Inv_helmet_03:14:14:2:-2|t"
    local ilvlIcon = "|TInterface\\Icons\\Inv_helmet_54:14:14:2:-1|t"

    tooltip:AddLine(
        gsIcon .. " Gear Score " .. gs .. "  " ..
        ilvlIcon .. " Item Level " .. ilvl,
        0.9, 0.9, 0.9
    )
end

GameTooltip:HookScript("OnTooltipSetItem", AddGearScoreToTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", AddGearScoreToTooltip)

