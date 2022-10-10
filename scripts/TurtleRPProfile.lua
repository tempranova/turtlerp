--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

function TurtleRP.OpenProfile(openTo)
  TurtleRP_CharacterDetails_FrameTabButton1.bookType = "general"
  TurtleRP_CharacterDetails_FrameTabButton2.bookType = "description"
  TurtleRP_CharacterDetails_FrameTabButton3.bookType = "notes"

  UIPanelWindows["TurtleRP_CharacterDetails"] = { area = "left", pushable = 6 }
  ShowUIPanel(TurtleRP_CharacterDetails)

  TurtleRP.OnBottomTabProfileClick(openTo)
end

function TurtleRP.OnBottomTabProfileClick(bookType)
  TurtleRP_CharacterDetails_General:Hide()
  TurtleRP_CharacterDetails_DescriptionScrollBox:Hide()
  TurtleRP_CharacterDetails_Notes:Hide()

  if bookType == "general" then
    TurtleRP.buildGeneral(TurtleRP.currentlyViewedPlayer)
  end

  if bookType == "description" then
    TurtleRP.buildDescription(TurtleRP.currentlyViewedPlayer)
  end

  if bookType == "notes" then
    TurtleRP.buildNotes(TurtleRP.currentlyViewedPlayer)
  end
end

function TurtleRP.buildGeneral(playerName)
  TurtleRP.currentlyViewedPlayer = playerName

  TurtleRP.SetNameAndIcon(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  local classColor = TurtleRPClassData[characterInfo["class"]][4]
  TurtleRP_CharacterDetails_General_TargetRaceClass:SetText(characterInfo["race"] .. "|cff" .. classColor .. " " .. characterInfo["class"])
  TurtleRP_CharacterDetails_General_ICOOC:SetText(characterInfo["currently_ic"] == "1" and "|cff40AF6FCurrently IC" or "|cffD3681ECurrently OOC")
  TurtleRP_CharacterDetails_General_ICInfo:SetText("|cffCC9900IC Info" .. TurtleRP.getPronounsText(characterInfo["ic_pronouns"], "|cffffcc80"))
  TurtleRP_CharacterDetails_General_ICInfoText:SetText(characterInfo["ic_info"])
  TurtleRP_CharacterDetails_General_OOCInfo:SetText("|cffCC9900OOC Info" .. TurtleRP.getPronounsText(characterInfo["ooc_pronouns"], "|cffffcc80"))
  TurtleRP_CharacterDetails_General_OOCInfoText:SetText(characterInfo["ooc_info"])
  TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -10)

  TurtleRP_CharacterDetails_General_Experience:SetText(TurtleRPDropdownOptions["experience"][characterInfo["experience"]])
  TurtleRP_CharacterDetails_General_Walkups:SetText(TurtleRPDropdownOptions["walkups"][characterInfo["walkups"]])
  TurtleRP_CharacterDetails_General_Injury:SetText(TurtleRPDropdownOptions["injury"][characterInfo["injury"]])
  TurtleRP_CharacterDetails_General_Romance:SetText(TurtleRPDropdownOptions["romance"][characterInfo["romance"]])
  TurtleRP_CharacterDetails_General_Death:SetText(TurtleRPDropdownOptions["death"][characterInfo["death"]])

  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab1-Selected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")

  TurtleRP_CharacterDetails_General:Show()
end

function TurtleRP.buildDescription(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  if characterInfo["keyD"] ~= nil then
    TurtleRP.currentlyViewedPlayer = playerName

    TurtleRP.SetNameAndIcon(playerName)

    TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body><h1>Hi</h1></body></html>")
    local replacedLineBreaks = gsub(characterInfo["description"], "@N", "%\n")
    if string.find(characterInfo['description'], "<p>") then
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body>" .. replacedLineBreaks .. "<br /><br /><br /></body></html>")
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText("")
    else
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("")
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText(replacedLineBreaks)
    end

    local stringHeight = TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:GetHeight()
    TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder:SetHeight(stringHeight * 2)
    TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetHeight(stringHeight * 2)

    TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
    TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
    TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")

    TurtleRP_CharacterDetails_DescriptionScrollBox:Show()
  end
end

function TurtleRP.buildNotes(playerName)
  TurtleRP.currentlyViewedPlayer = playerName

  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP.SetNameAndIcon(playerName)
  TurtleRP_CharacterDetails_Notes:Show()

  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab1-Selected")
end

function TurtleRP.SetNameAndIcon(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP_CharacterDetails_TargetName:SetText(characterInfo['full_name'])
  local icon = characterInfo['icon']
  if TurtleRPIcons[tonumber(icon)] then
    TurtleRP_CharacterDetails_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon)])
  end
end
