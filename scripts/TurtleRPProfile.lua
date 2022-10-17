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

function TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, frame, stringToShow, overrideHide)
  local frameHidden = false
  if characterInfo["keyM"] == nil or overrideHide == true then
    frame:Hide()
    frameHidden = true
  else
    if stringToShow ~= nil and stringToShow ~= "" then
      frame:Show()
      frame:SetText(stringToShow)
      local currentHeight = frame:GetHeight()
      if frame:GetStringWidth() > 265 and floor(currentHeight + 0.5) ~= 30 then
        frame:SetHeight(30)
      end
      if frame:GetStringWidth() < 265 and floor(currentHeight + 0.5) == 30 then
        frame:SetHeight(10)
      end
    else
      frame:Hide()
      frameHidden = true
    end
  end
  if lastFrame ~= nil then
    if frameHidden then
      frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
      return lastFrame
    else
      frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
    end
  end
  return frame
end

function TurtleRP.buildGeneral(playerName)
  TurtleRP.currentlyViewedPlayer = playerName

  TurtleRP.SetNameAndIcon(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  local raceClassString = ""
  if characterInfo["keyM"] ~= nil then
    local classColor = characterInfo['class_color'] and characterInfo['class_color'] or TurtleRPClassData[characterInfo["class"]][4]
    raceClassString = characterInfo["race"] .. "|cff" .. classColor .. " " .. characterInfo["class"]
  end

  local lastFrame = nil
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_TargetRaceClass, raceClassString)
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_ICOOC, characterInfo["currently_ic"] == "1" and "|cff40AF6FIC" or "|cffD3681EOOC")
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_ICInfo, "|cffCC9900IC Info" .. TurtleRP.getPronounsText(characterInfo["ic_pronouns"], "|cffffcc80"), characterInfo["ic_info"] == nil or characterInfo["ic_info"] == "")
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_ICInfoText, characterInfo["ic_info"])
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_OOCInfo, "|cffCC9900OOC Info" .. TurtleRP.getPronounsText(characterInfo["ooc_pronouns"], "|cffffcc80"), characterInfo["ooc_info"] == nil or characterInfo["ooc_info"] == "")
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_OOCInfoText, characterInfo["ooc_info"])

  TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", lastFrame, "BOTTOMLEFT", 0, -10)

  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Experience, TurtleRPDropdownOptions["experience"][characterInfo["experience"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Walkups, TurtleRPDropdownOptions["walkups"][characterInfo["walkups"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Injury, TurtleRPDropdownOptions["injury"][characterInfo["injury"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Romance, TurtleRPDropdownOptions["romance"][characterInfo["romance"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Death, TurtleRPDropdownOptions["death"][characterInfo["death"]])

  TurtleRP_CharacterDetails_General_AtAGlance1:Hide()
  TurtleRP_CharacterDetails_General_AtAGlance2:Hide()
  TurtleRP_CharacterDetails_General_AtAGlance3:Hide()
  if characterInfo["keyT"] ~= nil then
    if characterInfo['atAGlance1Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance1Icon"]
      TurtleRP_CharacterDetails_General_AtAGlance1_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_CharacterDetails_General_AtAGlance1_TextPanel_TitleText:SetText(characterInfo["atAGlance1Title"])
      TurtleRP_CharacterDetails_General_AtAGlance1_TextPanel_Text:SetText(characterInfo["atAGlance1"])
      TurtleRP_CharacterDetails_General_AtAGlance1:Show()
      TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -40)
    end

    if characterInfo['atAGlance2Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance2Icon"]
      TurtleRP_CharacterDetails_General_AtAGlance2_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_CharacterDetails_General_AtAGlance2_TextPanel_TitleText:SetText(characterInfo["atAGlance2Title"])
      TurtleRP_CharacterDetails_General_AtAGlance2_TextPanel_Text:SetText(characterInfo["atAGlance2"])
      TurtleRP_CharacterDetails_General_AtAGlance2:Show()
      TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -40)
    end

    if characterInfo['atAGlance3Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance3Icon"]
      TurtleRP_CharacterDetails_General_AtAGlance3_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_CharacterDetails_General_AtAGlance3_TextPanel_TitleText:SetText(characterInfo["atAGlance3Title"])
      TurtleRP_CharacterDetails_General_AtAGlance3_TextPanel_Text:SetText(characterInfo["atAGlance3"])
      TurtleRP_CharacterDetails_General_AtAGlance3:Show()
      TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -40)
    end

  end

  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab1-Selected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")

  TurtleRP_CharacterDetails_General:Show()
end

function TurtleRP.buildDescription(playerName)
  TurtleRP.currentlyViewedPlayer = playerName

  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP_CharacterDetails_General:Hide()
  TurtleRP_CharacterDetails_Notes:Hide()

  TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("")
  TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText("")

  if characterInfo["keyD"] ~= nil then

    TurtleRP.SetNameAndIcon(playerName)

    local replacedLineBreaks = gsub(characterInfo["description"], "@N", "%\n")
    if string.find(characterInfo['description'], "<p>") then
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body>" .. replacedLineBreaks .. "<br /><br /><br /></body></html>")
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText("")
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetHeight(1000)
    else
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("")
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText(replacedLineBreaks)
      local stringHeight = TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:GetHeight()
      TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder:SetHeight(stringHeight * 3)
    end

  end

  TurtleRP_CharacterDetails_DescriptionScrollBox:Show()
  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
end

function TurtleRP.buildNotes(playerName)
  TurtleRP.currentlyViewedPlayer = playerName

  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP.SetNameAndIcon(playerName)

  if TurtleRPCharacterInfo['character_notes'][TurtleRP.currentlyViewedPlayer] ~= nil then
    TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesInput:SetText(TurtleRPCharacterInfo['character_notes'][TurtleRP.currentlyViewedPlayer])
  else
    TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesInput:SetText("")
  end

  TurtleRP_CharacterDetails_Notes:Show()

  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab1-Selected")
end

function TurtleRP.SetNameAndIcon(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  if characterInfo["keyM"] ~= nil then
    TurtleRP_CharacterDetails_TargetName:SetText(characterInfo['full_name'])
    local icon = characterInfo['icon']
    if icon and TurtleRPIcons[tonumber(icon)] then
      TurtleRP_CharacterDetails_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon)])
      TurtleRP_CharacterDetails_TargetName:SetPoint("TOPLEFT", 65, -52)
      TurtleRP_CharacterDetails_Icon:Show()
    else
      TurtleRP_CharacterDetails_TargetName:SetPoint("TOPLEFT", 25, -52)
      TurtleRP_CharacterDetails_Icon:Hide()
    end
  else
    TurtleRP_CharacterDetails_Icon:Hide()
    TurtleRP_CharacterDetails_TargetName:SetPoint("TOPLEFT", 25, -52)
    TurtleRP_CharacterDetails_TargetName:SetText("No character info saved.")
    TurtleRP_CharacterDetails_General_TargetRaceClass:SetText("Try fetching, then re-opening this window, if the player is online.")
  end
end
