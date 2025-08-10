GotLK_CharacterDB = GotLK_CharacterDB or {}
local function CharacterEnabled() return GotLK_CharacterDB.enabled ~= false end

function GotLK_OnLoad()
    if not CharacterEnabled() then
        if GotLKFrame then GotLKFrame:Hide() end
        return
    end
    CharacterAttributesFrame:Hide()
    CharacterModelFrame:SetHeight(300)
    PaperDollFrame_UpdateStats = GotLK_UpdateStats
end

function GotLK_UpdateStats()
    if not CharacterEnabled() then return end
    GotLK_DisplayStats()
end

function GotLK_DisplayStats()
    if not CharacterEnabled() then
        if GotLKFrame then GotLKFrame:Hide() end
        return
    end
    local statStr = GotLKFrameStat1
    local statAgi = GotLKFrameStat2
    local statSta = GotLKFrameStat3
    local statInt = GotLKFrameStat4
    local statSpi = GotLKFrameStat5

    local meleeDmg = GotLKFrameStatMeleeDamage
    local meleeSpd = GotLKFrameStatMeleeSpeed
    local meleePwr = GotLKFrameStatMeleePower
    local meleeHit = GotLKFrameStatMeleeHit
    local meleeCrt = GotLKFrameStatMeleeCrit
    local meleeExp = GotLKFrameStatMeleeExpert

    local rngDmg = GotLKFrameStatRangeDamage
    local rngSpd = GotLKFrameStatRangeSpeed
    local rngPwr = GotLKFrameStatRangePower
    local rngHit = GotLKFrameStatRangeHit
    local rngCrt = GotLKFrameStatRangeCrit

    local splDmg = GotLKFrameStatSpellDamage
    local splHeal = GotLKFrameStatSpellHeal
    local splHit = GotLKFrameStatSpellHit
    local splCrt = GotLKFrameStatSpellCrit
    local splHst = GotLKFrameStatSpellHaste
    local splReg = GotLKFrameStatSpellRegen

    local armorVal = GotLKFrameStatArmor
    local defVal = GotLKFrameStatDefense
    local dodgeVal = GotLKFrameStatDodge
    local parryVal = GotLKFrameStatParry
    local blockVal = GotLKFrameStatBlock
    local resilVal = GotLKFrameStatResil

    PaperDollFrame_SetStat(statStr, 1)
    PaperDollFrame_SetStat(statAgi, 2)
    PaperDollFrame_SetStat(statSta, 3)
    PaperDollFrame_SetStat(statInt, 4)
    PaperDollFrame_SetStat(statSpi, 5)

    PaperDollFrame_SetDamage(meleeDmg)
    meleeDmg:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
    PaperDollFrame_SetAttackSpeed(meleeSpd)
    PaperDollFrame_SetAttackPower(meleePwr)
    PaperDollFrame_SetRating(meleeHit, CR_HIT_MELEE)
    PaperDollFrame_SetMeleeCritChance(meleeCrt)
    PaperDollFrame_SetExpertise(meleeExp)

    PaperDollFrame_SetRangedDamage(rngDmg)
    rngDmg:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
    PaperDollFrame_SetRangedAttackSpeed(rngSpd)
    PaperDollFrame_SetRangedAttackPower(rngPwr)
    PaperDollFrame_SetRating(rngHit, CR_HIT_RANGED)
    PaperDollFrame_SetRangedCritChance(rngCrt)

    PaperDollFrame_SetSpellBonusDamage(splDmg)
    splDmg:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
    PaperDollFrame_SetSpellBonusHealing(splHeal)
    PaperDollFrame_SetRating(splHit, CR_HIT_SPELL)
    PaperDollFrame_SetSpellCritChance(splCrt)
    splCrt:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
    PaperDollFrame_SetSpellHaste(splHst)
    PaperDollFrame_SetManaRegen(splReg)

    PaperDollFrame_SetArmor(armorVal)
    PaperDollFrame_SetDefense(defVal)
    PaperDollFrame_SetDodge(dodgeVal)
    PaperDollFrame_SetParry(parryVal)
    PaperDollFrame_SetBlock(blockVal)
    PaperDollFrame_SetResilience(resilVal)
end

local gotLK_ShowPanel = true

function GotLK_TogglePanel_OnClick()
    if not CharacterEnabled() then
        if GotLKFrame then GotLKFrame:Hide() end
        return
    end
    gotLK_ShowPanel = not gotLK_ShowPanel
    if gotLK_ShowPanel then
        GotLKFrame:Show()
    else
        GotLKFrame:Hide()
    end
end

GotLK_CharacterStats = {}
function GotLK_CharacterStats.Enable()
    if GotLKFrame then GotLKFrame:Show() end
end
function GotLK_CharacterStats.Disable()
    if GotLKFrame then GotLKFrame:Hide() end
end
