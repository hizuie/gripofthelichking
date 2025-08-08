local GotLK_FrameVisible = false

function GotLK_InitCharacterPanel()
    CharacterAttributesFrame:Hide()
    CharacterModelFrame:SetHeight(300)
    GotLKStatsPanel:Hide()
end

function GotLK_ToggleStatsPanel()
    GotLK_FrameVisible = not GotLK_FrameVisible
    if GotLK_FrameVisible then
        GotLKStatsPanel:Show()
    else
        GotLKStatsPanel:Hide()
    end
end
