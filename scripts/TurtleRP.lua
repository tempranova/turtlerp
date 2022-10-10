--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

-----
-- Global storage (not saved)
-----
TurtleRP.TestMode = 0

-- Dev
TurtleRP.currentVersion = "1.1.0"
TurtleRP.latestVersion = TurtleRP.currentVersion
-- Chat
TurtleRP.channelName = "TTRPTEST"
TurtleRP.channelIndex = 0
TurtleRP.timeBetweenPings = 30
TurtleRP.currentlyRequestedData = nil
TurtleRP.disableMessageSending = nil
TurtleRP.sendingLongForm = nil
TurtleRP.errorMessage = nil
TurtleRP.sendWithError = nil
-- Interface
TurtleRP.iconFrames = nil
TurtleRP.directoryFrames = nil
TurtleRP.iconSelectorCreated = nil
TurtleRP.currentIconSelector = nil
TurtleRP.iconSelectorFilter = ""
TurtleRP.RPMode = 0
TurtleRP.movingIconTray = nil
TurtleRP.movingMinimapButton = nil
TurtleRP.editingChatBox = nil
TurtleRP.currentChatType = nil
TurtleRP.targetFrame = TargetFrame
TurtleRP.gameTooltip = GameTooltip
TurtleRP.shaguEnabled = nil
-- Directory
TurtleRP.currentlyViewedPlayer = nil
TurtleRP.locationFrames = {}
TurtleRP.showTooltip = nil
TurtleRP.showTarget = nil
TurtleRP.showDescription = nil
TurtleRP.secondColumn = "Character Name"
TurtleRP.sortByKey = nil
TurtleRP.sortByOrder = 0
TurtleRP.searchTerm = ""
-- Accounting for PFUI, Go Shagu Go
if pfUI ~= nil and pfUI.uf ~= nil and pfUI.uf.target ~= nil then
  TurtleRP.targetFrame = pfUI.uf.target
  TurtleRP.shaguEnabled = true
end

-----
-- Addon load event
-----
local TurtleRP_Parent = CreateFrame("Frame")
TurtleRP_Parent:RegisterEvent("ADDON_LOADED")
TurtleRP_Parent:RegisterEvent("PLAYER_LOGOUT")

function TurtleRP:OnEvent()
  if event == "ADDON_LOADED" and arg1 == "TurtleRP" then

    -- Reset for testing
    -- TurtleRPCharacterInfo = nil
    -- TurtleRPCharacters = nil
    -- TurtleRPSettings = nil

    local TurtleRPCharacterInfoTemplate = {}

    TurtleRPCharacterInfoTemplate["keyM"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["icon"] = ""
    TurtleRPCharacterInfoTemplate["full_name"] = UnitName("player")
    TurtleRPCharacterInfoTemplate["race"] = UnitRace("player")
    TurtleRPCharacterInfoTemplate["class"] = UnitClass("player")
    TurtleRPCharacterInfoTemplate["class_color"] = TurtleRPClassData[UnitClass("player")][4]
    TurtleRPCharacterInfoTemplate["ic_info"] = ""
    TurtleRPCharacterInfoTemplate["ooc_info"] = ""
    TurtleRPCharacterInfoTemplate["ic_pronouns"] = ""
    TurtleRPCharacterInfoTemplate["ooc_pronouns"] = ""
    TurtleRPCharacterInfoTemplate["currently_ic"] = "1"

    TurtleRPCharacterInfoTemplate["notes"] = ""

    TurtleRPCharacterInfoTemplate["keyT"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["atAGlance1"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance1Title"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance1Icon"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance2"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance2Title"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance2Icon"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance3"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance3Title"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance3Icon"] = ""
    TurtleRPCharacterInfoTemplate["newfieldtest"] = ""

    TurtleRPCharacterInfoTemplate["keyD"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["description"] = ""

    TurtleRPCharacterInfoTemplate["keyS"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["experience"] = "0"
    TurtleRPCharacterInfoTemplate["walkups"] = "0"
    TurtleRPCharacterInfoTemplate["injury"] = "0"
    TurtleRPCharacterInfoTemplate["romance"] = "0"
    TurtleRPCharacterInfoTemplate["death"] = "0"

    TurtleRPCharacterInfoTemplate["character_notes"] = {}

    local TurtleRPSettingsTemplate = {}
    TurtleRPSettingsTemplate["bgs"] = "off"
    TurtleRPSettingsTemplate["tray"] = "1"
    TurtleRPSettingsTemplate["name_size"] = "1"
    TurtleRPSettingsTemplate["minimap_icon_size"] = "0"
    TurtleRPSettingsTemplate["hide_minimap_icon"] = "1"
    TurtleRPSettingsTemplate["share_location"] = "1"


    -- Global character defaults setup
    if TurtleRPCharacterInfo == nil then
      TurtleRPCharacterInfo = TurtleRPCharacterInfoTemplate
    end
    if TurtleRPCharacters == nil then
      TurtleRPCharacters = {}
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    end
    if TurtleRPSettings == nil then
      TurtleRPSettings = TurtleRPSettingsTemplate
    end
    if TurtleRPQueryablePlayers == nil then
      TurtleRPQueryablePlayers = {}
    end

    -- For adding additional fields after plugin is in use
    if TurtleRPCharacterInfo ~= nil then
      for i, field in pairs(TurtleRPCharacterInfoTemplate) do
        if TurtleRPCharacterInfo[i] == nil then
          TurtleRPCharacterInfo[i] = TurtleRPCharacterInfoTemplate[i]
        end
      end
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    end

    -- TurtleRPCharacters["A°hkir"] = TurtleRPCharacters["Ashkir"]

    -- For adding additional settings after plugin is in use
    if TurtleRPSettings ~= nil then
      for i, field in pairs(TurtleRPSettingsTemplate) do
        if TurtleRPSettings[i] == nil then
          TurtleRPSettings[i] = TurtleRPSettingsTemplate[i]
        end
      end
    end

    -- Intro message
    TurtleRP.log("Welcome, |cff8C48AB" .. TurtleRPCharacterInfo["full_name"] .. "|ccfFFFFFF, to TurtleRP.")
    TurtleRP.log("Type |cff8C48AB/ttrp |ccfFFFFFFto open the addon.")

    if GetRealmName() == "Turtle WoW" and UnitLevel("player") < 5 and UnitLevel("player") ~= 0 then
      TurtleRP.log("|cff8C48ABSorry, but due to Turtle WoW restrictions you can't access other player's TurtleRP profiles until level 5.")
    end

    TurtleRP.communication_prep()
    TurtleRP.send_ping_message()

    TurtleRP.populate_interface_user_data()

    TurtleRP.tooltip_events()
    TurtleRP.mouseover_and_target_events()
    TurtleRP.communication_events()
    TurtleRP.display_nearby_players()

    TurtleRP.emote_events()

    -- Set Version number
    TurtleRP_AdminSB_Content6_VersionText:SetText(TurtleRP.currentVersion)

    -- SLash commands
    SLASH_TURTLERP1 = "/ttrp";
    function SlashCmdList.TURTLERP(msg)
      if msg == "dir" or msg == "directory" then
        TurtleRP.OpenDirectory()
      else
        TurtleRP.OpenAdmin()
      end
    end

  end
end

TurtleRP_Parent:SetScript("OnEvent", TurtleRP.OnEvent)

-----
-- Building interfaces to display data
-----
function TurtleRP.SetTargetNameFrameWidths(playerName)
  if TurtleRPCharacters[playerName] then
    local fullName = TurtleRPCharacters[playerName]["full_name"]
    TurtleRP_Target_TargetName:SetText(fullName)
    local stringWidth = TurtleRP_Target_TargetName:GetStringWidth()
    if stringWidth < 100 then
      stringWidth = 100
    end
    TurtleRP_Target:SetWidth(tonumber(stringWidth) + 40)
  end
end

function TurtleRP.buildTargetFrame(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP_Target:Hide()
  if characterInfo["keyT"] ~= nil then

    TurtleRP_Target_AtAGlance1:Hide()
    if characterInfo['atAGlance1Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance1Icon"]
      TurtleRP_Target_AtAGlance1_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance1_TextPanel_TitleText:SetText(characterInfo["atAGlance1Title"])
      TurtleRP_Target_AtAGlance1_TextPanel_Text:SetText(characterInfo["atAGlance1"])
      TurtleRP_Target_AtAGlance1:Show()
    end

    TurtleRP_Target_AtAGlance2:Hide()
    if characterInfo['atAGlance2Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance2Icon"]
      TurtleRP_Target_AtAGlance2_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance2_TextPanel_TitleText:SetText(characterInfo["atAGlance2Title"])
      TurtleRP_Target_AtAGlance2_TextPanel_Text:SetText(characterInfo["atAGlance2"])
      TurtleRP_Target_AtAGlance2:Show()
    end

    TurtleRP_Target_AtAGlance3:Hide()
    if characterInfo['atAGlance3Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance3Icon"]
      TurtleRP_Target_AtAGlance3_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance3_TextPanel_TitleText:SetText(characterInfo["atAGlance3Title"])
      TurtleRP_Target_AtAGlance3_TextPanel_Text:SetText(characterInfo["atAGlance3"])
      TurtleRP_Target_AtAGlance3:Show()
    end

    TurtleRP.SetTargetNameFrameWidths(playerName)

    TurtleRP_Target:Show()
  end
end

-----
-- Populate data
-----
function TurtleRP.populate_interface_user_data()
  TurtleRP_AdminSB_Content1_NameInput:SetText(TurtleRPCharacterInfo["full_name"])
  TurtleRP_AdminSB_Content1_RaceInput:SetText(TurtleRPCharacterInfo["race"])
  TurtleRP_AdminSB_Content1_ClassInput:SetText(TurtleRPCharacterInfo["class"])
  local r, g, b = TurtleRP.hex2rgb(TurtleRPCharacterInfo['class_color'])
  TurtleRP_AdminSB_Content1_ClassColorButton:SetBackdropColor(r, g, b)
  TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:SetText(TurtleRPCharacterInfo["ic_info"])
  TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:SetText(TurtleRPCharacterInfo["ooc_info"])
  TurtleRP_AdminSB_Content1_ICPronounsInput:SetText(TurtleRPCharacterInfo["ic_pronouns"])
  TurtleRP_AdminSB_Content1_OOCPronounsInput:SetText(TurtleRPCharacterInfo["ooc_pronouns"])
  TurtleRP.setCharacterIcon()
  TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:SetText(TurtleRPCharacterInfo["atAGlance1"])
  TurtleRP_AdminSB_Content2_AAG1TitleInput:SetText(TurtleRPCharacterInfo["atAGlance1Title"])
  TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:SetText(TurtleRPCharacterInfo["atAGlance2"])
  TurtleRP_AdminSB_Content2_AAG2TitleInput:SetText(TurtleRPCharacterInfo["atAGlance2Title"])
  TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:SetText(TurtleRPCharacterInfo["atAGlance3"])
  TurtleRP_AdminSB_Content2_AAG3TitleInput:SetText(TurtleRPCharacterInfo["atAGlance3Title"])
  TurtleRP.setAtAGlanceIcons()
  TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:SetText(TurtleRPCharacterInfo["description"])
  TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:SetText(TurtleRPCharacterInfo["notes"])

  TurtleRP_AdminSB_Content5_PVPButton:SetChecked(TurtleRPSettings["bgs"] == "on" and true or false)
  TurtleRP_AdminSB_Content5_NameButton:SetChecked(TurtleRPSettings["name_size"] == "1" and true or false)

  if TurtleRPCharacterInfo["currently_ic"] == "1" then
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(true)
    TurtleRP_IconTray_ICModeButton2:Show()
  else
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(false)
    TurtleRP_IconTray_ICModeButton:Show()
  end

  if TurtleRPSettings["tray"] == "1" then
    TurtleRP_AdminSB_Content5_TrayButton:SetChecked(true)
    TurtleRP_IconTray:Show()
  end

  if TurtleRPSettings["minimap_icon_size"] == "1" then
    TurtleRP_AdminSB_Content5_MinimapButton:SetChecked(true)
    TurtleRP_MinimapIcon_OpenAdmin:SetScale(1.25)
  end

  if TurtleRPSettings["hide_minimap_icon"] == "1" then
    TurtleRP_AdminSB_Content5_HideMinimapButton:SetChecked(true)
    TurtleRP_MinimapIcon:Hide()
  end

  if TurtleRPSettings["share_location"] == "1" then
    TurtleRP_AdminSB_Content5_ShareLocationButton:SetChecked(true)
    TurtleRP_MinimapIcon:Hide()
  end

end

function TurtleRP.setCharacterIcon()
  if TurtleRPCharacterInfo["icon"] ~= "" then
    local iconIndex = TurtleRPCharacterInfo["icon"]
    TurtleRP_AdminSB_Content1_IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_AdminSB_Content1_IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
end

function TurtleRP.setAtAGlanceIcons()
  if TurtleRPCharacters[UnitName("player")]["atAGlance1Icon"] ~= "" then
    local iconIndex = TurtleRPCharacters[UnitName("player")]["atAGlance1Icon"]
    TurtleRP_AdminSB_Content2_AAG1IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_AdminSB_Content2_AAG1IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
  if TurtleRPCharacters[UnitName("player")]["atAGlance2Icon"] ~= "" then
    local iconIndex = TurtleRPCharacters[UnitName("player")]["atAGlance2Icon"]
    TurtleRP_AdminSB_Content2_AAG2IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_AdminSB_Content2_AAG2IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
  if TurtleRPCharacters[UnitName("player")]["atAGlance3Icon"] ~= "" then
    local iconIndex = TurtleRPCharacters[UnitName("player")]["atAGlance3Icon"]
    TurtleRP_AdminSB_Content2_AAG3IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_AdminSB_Content2_AAG3IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
end

-----
-- Saving
-----
function TurtleRP.change_ic_status()
  if TurtleRPCharacterInfo["currently_ic"] ~= "1" then
    TurtleRPCharacterInfo["currently_ic"] = "1"
    TurtleRP_IconTray_ICModeButton2:Show()
    TurtleRP_IconTray_ICModeButton:Hide()
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(true)
  else
    TurtleRPCharacterInfo["currently_ic"] = "0"
    TurtleRP_IconTray_ICModeButton:Show()
    TurtleRP_IconTray_ICModeButton2:Hide()
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(false)
  end
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.save_general()
end

function TurtleRP.save_general()
  TurtleRPCharacterInfo['keyM'] = TurtleRP.randomchars()
  local full_name = TurtleRP_AdminSB_Content1_NameInput:GetText()
  TurtleRP_AdminSB_Content1_NameInput:ClearFocus()
  TurtleRPCharacterInfo["full_name"] = TurtleRP.validateBeforeSaving(full_name)
  local race = TurtleRP_AdminSB_Content1_RaceInput:GetText()
  TurtleRP_AdminSB_Content1_RaceInput:ClearFocus()
  TurtleRPCharacterInfo["race"] = TurtleRP.validateBeforeSaving(race)
  local class = TurtleRP_AdminSB_Content1_ClassInput:GetText()
  TurtleRP_AdminSB_Content1_ClassInput:ClearFocus()
  TurtleRPCharacterInfo["class"] = TurtleRP.validateBeforeSaving(class)
  local ic_info = TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:GetText()
  TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:ClearFocus()
  TurtleRPCharacterInfo["ic_info"] = TurtleRP.validateBeforeSaving(ic_info)
  local ooc_info = TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:GetText()
  TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:ClearFocus()
  TurtleRPCharacterInfo["ooc_info"] = TurtleRP.validateBeforeSaving(ooc_info)
  local ic_pronouns = TurtleRP_AdminSB_Content1_ICPronounsInput:GetText()
  TurtleRP_AdminSB_Content1_ICPronounsInput:ClearFocus()
  TurtleRPCharacterInfo["ic_pronouns"] = TurtleRP.validateBeforeSaving(ic_pronouns)
  local ooc_pronouns = TurtleRP_AdminSB_Content1_OOCPronounsInput:GetText()
  TurtleRP_AdminSB_Content1_OOCPronounsInput:ClearFocus()
  TurtleRPCharacterInfo["ooc_pronouns"] = TurtleRP.validateBeforeSaving(ooc_pronouns)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setCharacterIcon()
end
function TurtleRP.save_style()
  TurtleRPCharacterInfo['keyS'] = TurtleRP.randomchars()
  local experience = UIDropDownMenu_GetSelectedID(TurtleRP_AdminSB_Content1_Tab2_ExperienceDropdown)
  TurtleRPCharacterInfo["experience"] = experience ~= nil and experience or 0
  local walkups = UIDropDownMenu_GetSelectedID(TurtleRP_AdminSB_Content1_Tab2_WalkupsDropdown)
  TurtleRPCharacterInfo["walkups"] = walkups ~= nil and walkups or 0
  local injury = UIDropDownMenu_GetSelectedID(TurtleRP_AdminSB_Content1_Tab2_InjuryDropdown)
  TurtleRPCharacterInfo["injury"] = injury ~= nil and injury or 0
  local romance = UIDropDownMenu_GetSelectedID(TurtleRP_AdminSB_Content1_Tab2_RomanceDropdown)
  TurtleRPCharacterInfo["romance"] = romance ~= nil and romance or 0
  local death = UIDropDownMenu_GetSelectedID(TurtleRP_AdminSB_Content1_Tab2_DeathDropdown)
  TurtleRPCharacterInfo["death"] = death ~= nil and death or 0
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
end
function TurtleRP.save_at_a_glance()
  TurtleRPCharacterInfo['keyT'] = TurtleRP.randomchars()
  local aag1Text = TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1"] = TurtleRP.validateBeforeSaving(aag1Text)
  local aag1TitleText = TurtleRP_AdminSB_Content2_AAG1TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG1TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1Title"] = TurtleRP.validateBeforeSaving(aag1TitleText)
  local aag2Text = TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2"] = TurtleRP.validateBeforeSaving(aag2Text)
  local aag2TitleText = TurtleRP_AdminSB_Content2_AAG2TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG2TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2Title"] = TurtleRP.validateBeforeSaving(aag2TitleText)
  local aag3Text = TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3"] = TurtleRP.validateBeforeSaving(aag3Text)
  local aag3TitleText = TurtleRP_AdminSB_Content2_AAG3TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG3TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3Title"] = TurtleRP.validateBeforeSaving(aag3TitleText)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setAtAGlanceIcons()
end
function TurtleRP.save_description()
  TurtleRPCharacterInfo['keyD'] = TurtleRP.randomchars()
  local description = TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:GetText()
  TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:ClearFocus()
  TurtleRPCharacterInfo["description"] = TurtleRP.validateBeforeSaving(description)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
end
function TurtleRP.save_notes()
  local notes = TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:GetText()
  TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:ClearFocus()
  TurtleRPCharacterInfo["notes"] = notes
end
function TurtleRP.save_character_notes()
  local notes = TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesInput:GetText()
  TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesInput:ClearFocus()
  TurtleRPCharacterInfo["character_notes"][TurtleRP.currentlyViewedPlayer] = notes
end

-----
-- Utility
-----
function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end

function TurtleRP.randomchars()
	local res = ""
	for i = 1, 5 do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function TurtleRP.hex2rgb(hex)
  return tonumber(strsub(hex, 1, 2), 16)/255, tonumber(strsub(hex, 3, 4), 16)/255, tonumber(strsub(hex, 5, 6), 16)/255
end

function TurtleRP.rgb2hex(r, g, b)
	return string.format("%02x%02x%02x",
		math.floor(r*255),
		math.floor(g*255),
		math.floor(b*255))
end

function TurtleRP.validateBeforeSaving(data)
  if string.find(data, '~') or string.find(data, '°') or string.find(data, '§') then
    _ERRORMESSAGE('Please do not use the characters "~", "°", or "§" in your text. Thanks!')
  else
    return data
  end
end

function TurtleRP.cleanDirectory()
  for i, v in TurtleRPCharacters do
    if string.find(i, '°') or string.find(i, '§') then
      local fixedName = TurtleRP.DrunkDecode(i)
      TurtleRPCharacters[fixedName] = TurtleRPCharacters[i]
      TurtleRPCharacters[i] = nil
    end
  end
end

function TurtleRP.log(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end
