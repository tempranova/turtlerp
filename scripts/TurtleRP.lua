--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

-----
-- Global storage (not saved)
-----
TurtleRP.TestMode = 0

-- Dev
TurtleRP.currentVersion = "1.0.0"
-- Chat
TurtleRP.channelName = "TTRP"
TurtleRP.channelIndex = 0
TurtleRP.timeBetweenPings = 30
TurtleRP.currentlyRequestedData = nil
TurtleRP.disableMessageSending = nil
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

    local TurtleRPSettingsTemplate = {}
    TurtleRPSettingsTemplate["bgs"] = "off"
    TurtleRPSettingsTemplate["tray"] = "1"
    TurtleRPSettingsTemplate["name_size"] = "1"
    TurtleRPSettingsTemplate["minimap_icon_size"] = "0"
    TurtleRPSettingsTemplate["hide_minimap_icon"] = "1"


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

    -- For adding additional settings after plugin is in use
    if TurtleRPSettings ~= nil then
      for i, field in pairs(TurtleRPSettingsTemplate) do
        if TurtleRPSettings[i] == nil then
          TurtleRPSettings[i] = TurtleRPSettingsTemplate[i]
        end
      end
    end

    -- Intro message
    TurtleRP.log("Welcome, " .. TurtleRPCharacterInfo["full_name"] .. ", to TurtleRP.")
    TurtleRP.log("Type |ccfFF0000/ttrp |ccfFFFFFFto open the addon.")

    if GetRealmName() == "Turtle WoW" and UnitLevel("player") < 5 and UnitLevel("player") ~= 0 then
      TurtleRP.log("|ccfFF0000Sorry, but due to Turtle WoW restrictions you can't access other player's TurtleRP profiles until level 5.")
    end

    TurtleRP.communication_prep()
    TurtleRP.send_ping_message()

    TurtleRP.populate_interface_user_data()

    TurtleRP.tooltip_events()
    TurtleRP.mouseover_and_target_events()
    TurtleRP.communication_events()

    TurtleRP.emote_events()


    -- Set Version number
    TurtleRP_AdminSB_Content7_VersionText:SetText(TurtleRP.currentVersion)

    -- SLash commands
    SLASH_TURTLERP1 = "/ttrp";
    function SlashCmdList.TURTLERP(msg)
      TurtleRP.OpenAdmin()
    end

  end
end

TurtleRP_Parent:SetScript("OnEvent", TurtleRP.OnEvent)

-----
-- Interface interaction for communication and display
-----
function TurtleRP.mouseover_and_target_events()

  -- Player target
  local TurtleRPTargetFrame = CreateFrame("Frame")
  TurtleRPTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  TurtleRPTargetFrame:SetScript("OnEvent",
  	function(self, event, ...)
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        if (UnitIsPlayer("target")) then
          if UnitName("target") == UnitName("player") then
            TurtleRP.buildTargetFrame(UnitName("player"))
          else
            TurtleRP_Target:Hide()
            TurtleRP.sendRequestForData("T", UnitName("target"))
          end
        else
          TurtleRP_Target:Hide()
        end
      end
  	end
  )

  -- Other player mouseover
  local TurtleRPMouseoverFrame = CreateFrame("Frame")
  TurtleRPMouseoverFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  TurtleRPMouseoverFrame:RegisterEvent("CURSOR_UPDATE")
  TurtleRPMouseoverFrame:SetScript("OnEvent",function(self, event)
      -- Ensuring defaults are in place
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        if (UnitIsPlayer("mouseover")) then
          TurtleRP.sendRequestForData("M", UnitName("mouseover"))
        end
      end
  end)

  -- Self target mouseover frame (preview of self mouseover)
  TurtleRP.targetFrame:EnableMouse()
  local defaultTargetFrameFunction = TurtleRP.targetFrame:GetScript("OnEnter")
  TurtleRP.targetFrame:SetScript("OnEnter",
    function()
      defaultTargetFrameFunction()
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        if(UnitName("target") == UnitName("player")) then
          TurtleRP.buildTooltip(UnitName("player"), "target")
        end
      end
    end
  )
end

-----
-- Handling custom emotes
-----
function TurtleRP.emote_events()

  local TurtleLastEmote = {}
  local TurtleLastSender = {}
  local beginningQuoteFlag = {}

  local oldChatFrame_OnEvent = ChatFrame_OnEvent
  function ChatFrame_OnEvent(event)
    local savedEvent = event
    if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
      local type = strsub(event, 10);

      if ( type == "SYSTEM") then
        if arg1 == "You are now AFK: Away from Keyboard" then
          TurtleRP.disableMessageSending = true
        end
        if arg1 == "You are no longer AFK." then
          TurtleRP.disableMessageSending = nil
        end
      end

      if ( type == "EMOTE" ) then
        if beginningQuoteFlag[this:GetID()] == nil then
          beginningQuoteFlag[this:GetID()] = 0
        end
        if TurtleLastSender[this:GetID()] and TurtleLastSender[this:GetID()] == arg2 then
          if string.find(TurtleLastEmote[this:GetID()], '"') then
            local splitArrayQuotes = string.split(TurtleLastEmote[this:GetID()], '"')
            local numberOfQuotes = getn(splitArrayQuotes) + 1
            if (numberOfQuotes - math.floor(numberOfQuotes/2)*2) ~= 0 then -- an odd number of quotes!
              if beginningQuoteFlag[this:GetID()] == 1 then
                beginningQuoteFlag[this:GetID()] = 0
              else
                beginningQuoteFlag[this:GetID()] = 1
              end
            end
          end
        end
        TurtleLastEmote[this:GetID()] = arg1
        TurtleLastSender[this:GetID()] = arg2
        savedEvent = "TURTLE_TAKEOVER"
        local nameString = arg2
        local splitArray = string.split(arg1, '"')
        local firstChunk = splitArray[1]
        local firstChars = strsub(firstChunk, 1, 3)
        if firstChars == "|| " then
          nameString = ""
          firstChunk = strsub(firstChunk, 4)
        end
        local newString = beginningQuoteFlag[this:GetID()] == 1 and (" |cffFFFFFF" .. firstChunk) or firstChunk
        if getn(splitArray) > 1 then
          for i in splitArray do
            if i ~= 1 then
              if (i - math.floor(i/2)*2) == 0 then -- this is even
                local colorChange = beginningQuoteFlag[this:GetID()] == 1 and "|cffFF7E40" or "|cffFFFFFF"
                local colorRevert = beginningQuoteFlag[this:GetID()] == 1 and "|cffFFFFFF" or "|cffFF7E40"
                local finalQuoteToAdd = splitArray[i + 1] and '"' or ''
                newString = newString .. colorChange .. '"' .. splitArray[i] .. finalQuoteToAdd .. colorRevert
              else
                newString = newString .. splitArray[i]
              end
            end
          end
        end
        local body = format(TEXT(getglobal("CHAT_"..type.."_GET")) .. newString, "|cffFF7E40" .. nameString)
        if nameString == "" then
          body = "|cffFF7E40" .. newString
        end

        this:AddMessage(body)
      end
    end
    oldChatFrame_OnEvent(savedEvent)
  end

end

-----
-- Building interfaces to display data
-----
function TurtleRP.SetNameFrameWidths(playerName)
  if TurtleRPCharacters[playerName] then
    local fullName = TurtleRPCharacters[playerName]["full_name"]
    TurtleRP_Target_TargetName:SetText(fullName)
    local stringWidth = TurtleRP_Target_TargetName:GetStringWidth()
    if stringWidth < 100 then
      stringWidth = 100
    end
    TurtleRP_Target:SetWidth(tonumber(stringWidth) + 40)

    TurtleRP_Description_TargetName:SetText(TurtleRP_Target_TargetName:GetText())
    local stringWidth = TurtleRP_Description_TargetName:GetStringWidth()
    if (stringWidth + 40) > 350 then
      TurtleRP_Description:SetWidth(tonumber(stringWidth) + 40)
      TurtleRP_Description_DescriptionScrollBox:SetWidth(tonumber(stringWidth) - 40)
      TurtleRP_Description:SetPoint("TOP", UIParent, 0, -100)
    end
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

    TurtleRP.SetNameFrameWidths(playerName)

    TurtleRP_Target:Show()
  end
end

function TurtleRP.buildDescription(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  if characterInfo["keyD"] ~= nil then

    TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body><h1>Hi</h1></body></html>")
    if string.find(characterInfo['description'], "<p>") then
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body>" .. characterInfo['description'] .. "</body></html>")
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText("")
    else
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("")
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText(characterInfo['description'])
    end

    TurtleRP.SetNameFrameWidths(playerName)
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

  TurtleRP_AdminSB_Content6_PVPButton:SetChecked(TurtleRPSettings["bgs"] == "on" and true or false)
  TurtleRP_AdminSB_Content6_NameButton:SetChecked(TurtleRPSettings["name_size"] == "1" and true or false)

  if TurtleRPCharacterInfo["currently_ic"] == "1" then
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(true)
    TurtleRP_IconTray_ICModeButton2:Show()
  else
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(false)
    TurtleRP_IconTray_ICModeButton:Show()
  end

  if TurtleRPSettings["tray"] == "1" then
    TurtleRP_AdminSB_Content6_TrayButton:SetChecked(true)
    TurtleRP_IconTray:Show()
  end

  if TurtleRPSettings["minimap_icon_size"] == "1" then
    TurtleRP_AdminSB_Content6_MinimapButton:SetChecked(true)
    TurtleRP_MinimapIcon_OpenAdmin:SetScale(1.25)
  end

  if TurtleRPSettings["hide_minimap_icon"] == "1" then
    TurtleRP_AdminSB_Content6_HideMinimapButton:SetChecked(true)
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

----
-- Directory Manager
----
function TurtleRP.Directory_ScrollBar_Update()
  -- if TurtleRP.iconFrames == nil then
  --   TurtleRP.iconFrames = TurtleRP.makeIconFrames()
  -- end
  -- local totalDirectoryChars = 0
  -- for i, v in TurtleRPCharacters do
  --   totalDirectoryChars = totalDirectoryChars + 1
  -- end
  -- TurtleRP.log(totalDirectoryChars)
  -- FauxScrollFrame_Update(TurtleRP_AdminSB_Content5_DirectoryScrollBox, totalDirectoryChars, 20, 25)
  -- local currentLine = FauxScrollFrame_GetOffset(TurtleRP_AdminSB_Content5_DirectoryScrollBox)
  -- TurtleRP.renderDirectory((currentLine * 5))
end

function TurtleRP.makeDirectoryFrames()
end

function TurtleRP.renderDirectory(directoryOffset)
  -- TurtleRP.log(directoryOffset)
  -- local remadeArray = {}
  -- local currentArrayNumber = 1
  -- for i, v in TurtleRPCharacters do
  --   remadeArray[currentArrayNumber] = v
  --   currentArrayNumber = currentArrayNumber + 1
  -- end
  -- for i=directoryOffset, directoryOffset+20 do
  --   for i, v in TurtleRPCharacters do
  --     local directoryNameFrame = CreateFrame("Frame",  "TurtleRP_AdminSB_Content5_DirectoryScrollBox_DirectoryHolder_Listing_DirectoryName" .. i, TurtleRP_AdminSB_Content5_DirectoryScrollBox_DirectoryHolder, "TurtleRP_Directory_Listing")
  --     getglobal("TurtleRP_AdminSB_Content5_DirectoryScrollBox_DirectoryHolder_Listing_DirectoryName" .. i .. "_NameText"):SetText(i)
  --     getglobal("TurtleRP_AdminSB_Content5_DirectoryScrollBox_DirectoryHolder_Listing_DirectoryName" .. i):SetPoint("TOPLEFT", TurtleRP_AdminSB_Content5, "TOPLEFT", 0, framesCreated * -25)
  --     framesCreated = framesCreated + 1
  --   end
  -- end
  -- local framesCreated = 0
end

-----
-- Icon Selector
-----
function TurtleRP.create_icon_selector()
  TurtleRP_IconSelector:Show()
  TurtleRP_IconSelector:SetFrameStrata("high")
  TurtleRP_IconSelector_FilterSearchInput:SetFrameStrata("high")
  TurtleRP_IconSelector_ScrollBox:SetFrameStrata("high")
  if TurtleRP.iconFrames == nil then
    TurtleRP.iconFrames = TurtleRP.makeIconFrames()
  end
  TurtleRP.iconSelectorFilter = ""
  TurtleRP_IconSelector_FilterSearchInput:SetText("")
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_IconSelector_ScrollBox)
  TurtleRP.renderIcons((currentLine * 5))
end

function TurtleRP.Icon_ScrollBar_Update()
  FauxScrollFrame_Update(TurtleRP_IconSelector_ScrollBox, 450, 250, 25)
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_IconSelector_ScrollBox)
  TurtleRP.renderIcons((currentLine * 5))
end

function TurtleRP.makeIconFrames()
  local IconFrames = {}
  local numberOnRow = 0
  local currentRow = 0
  for i=1,20 do
    local thisIconFrame = CreateFrame("Button", "TurtleRPIcon_" .. i, TurtleRP_IconSelector_ScrollBox)
    thisIconFrame:SetWidth(25)
    thisIconFrame:SetHeight(25)
    thisIconFrame:SetPoint("TOPLEFT", TurtleRP_IconSelector_ScrollBox, numberOnRow * 25, currentRow * -25)
    thisIconFrame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    thisIconFrame:SetText(i)
    thisIconFrame:SetFont("Fonts\\FRIZQT__.ttf", 0)
    thisIconFrame:SetScript("OnClick", function()
      local thisIconIndex = thisIconFrame:GetText()
      TurtleRPCharacterInfo[TurtleRP.currentIconSelector] = thisIconIndex
      TurtleRP.save_general()
      TurtleRP.save_at_a_glance()
      TurtleRP_IconSelector:Hide()
    end)
    IconFrames[i] = thisIconFrame
    numberOnRow = numberOnRow + 1
    if (i - math.floor(i/5)*5) == 0 then
      currentRow = currentRow + 1
      numberOnRow = 0
    end
  end
  return IconFrames
end

function TurtleRP.renderIcons(iconOffset)
  if TurtleRP.iconFrames ~= nil then
    local filteredIcons = {}
    local numberAdded = 0
    for i, iconName in ipairs(TurtleRPIcons) do
      if TurtleRP.iconSelectorFilter ~= "" then
        if TurtleRPIcons[i + iconOffset] ~= nil then
          if string.find(string.lower(TurtleRPIcons[i + iconOffset]), string.lower(TurtleRP.iconSelectorFilter)) then
            filteredIcons[numberAdded + 1] = i + iconOffset
            numberAdded = numberAdded + 1
          end
        end
      else
        filteredIcons[numberAdded + 1] = i + iconOffset
        numberAdded = numberAdded + 1
      end
    end
    for i, iconFrame in ipairs(TurtleRP.iconFrames) do
      if filteredIcons[i + iconOffset] ~= nil and TurtleRPIcons[filteredIcons[i + iconOffset]] ~= nil then
        iconFrame:SetText(filteredIcons[i + iconOffset])
        iconFrame:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[filteredIcons[i + iconOffset]] })
      else
        iconFrame:SetBackdrop(nil)
      end
    end
  end
end

-----
-- Interface helpers
-----
function TurtleRP.escapeFocusFromChatbox()
  local existingWorldFrameFunctions = WorldFrame:GetScript("OnMouseDown")
  WorldFrame:SetScript("OnMouseDown", function()
    if TurtleRP.editingChatBox then
      TurtleRP_ChatBox_TextScrollBox_TextInput:ClearFocus()
      TurtleRP.editingChatBox = false
    end
    if existingWorldFrameFunctions then
      existingWorldFrameFunctions()
    end
  end)
end

function TurtleRP.IconTrayMover(actionType, frame)
  if actionType == "mousedown" then
    local newLeft = frame:GetLeft()
    local newTop = frame:GetTop()
    TurtleRP.movingIconTray = newLeft * newTop
  else
    local newLeft = frame:GetLeft()
    local newTop = frame:GetTop()
    if TurtleRP.movingIconTray ~= (newLeft * newTop) then
      TurtleRP.movingIconTray = true
    else
      TurtleRP.movingIconTray = nil
    end
  end
end


function TurtleRP.BindFrameToWorldFrame(frame)
	local scale = UIParent:GetEffectiveScale();
	frame:SetParent(WorldFrame);
	frame:SetScale(scale);
end

function TurtleRP.BindFrameToUIParent(frame)
	frame:SetParent(UIParent);
	frame:SetScale(1);
end

function TurtleRP.EnableRPMode()
	TurtleRP.BindFrameToWorldFrame(GameTooltip);
	TurtleRP.BindFrameToWorldFrame(ChatFrameEditBox);
	TurtleRP.BindFrameToWorldFrame(ChatFrameMenuButton);
	TurtleRP.BindFrameToWorldFrame(ChatMenu);
	TurtleRP.BindFrameToWorldFrame(EmoteMenu);
	TurtleRP.BindFrameToWorldFrame(LanguageMenu);
	TurtleRP.BindFrameToWorldFrame(VoiceMacroMenu);
	--TurtleRP.BindFrameToWorldFrame(TurtleRPInfobox);
	for i = 1, 7 do
    TurtleRP.BindFrameToWorldFrame(TurtleRP_IconTray)
    TurtleRP.BindFrameToWorldFrame(TurtleRP_ChatBox)
		TurtleRP.BindFrameToWorldFrame(getglobal("ChatFrame" .. i));
		TurtleRP.BindFrameToWorldFrame(getglobal("ChatFrame" .. i .. "Tab"));
		TurtleRP.BindFrameToWorldFrame(getglobal("ChatFrame" .. i .. "TabDockRegion"));
	end
	TurtleRP.RPMode = 1;
	CloseAllWindows();
	UIParent:Hide();
end

function TurtleRP.DisableRPMode()
	TurtleRP.BindFrameToUIParent(GameTooltip);
	GameTooltip:SetFrameStrata("TOOLTIP");
	TurtleRP.BindFrameToUIParent(ChatFrameEditBox);
	ChatFrameEditBox:SetFrameStrata("DIALOG");
	TurtleRP.BindFrameToUIParent(ChatFrameMenuButton);
	ChatFrameMenuButton:SetFrameStrata("DIALOG");
	TurtleRP.BindFrameToUIParent(ChatMenu);
	ChatMenu:SetFrameStrata("DIALOG");
	TurtleRP.BindFrameToUIParent(EmoteMenu);
	EmoteMenu:SetFrameStrata("DIALOG");
	TurtleRP.BindFrameToUIParent(LanguageMenu);
	LanguageMenu:SetFrameStrata("DIALOG");
	TurtleRP.BindFrameToUIParent(VoiceMacroMenu);
	VoiceMacroMenu:SetFrameStrata("DIALOG");
	--TurtleRP.BindFrameToUIParent(TurtleRPInfobox);
	for i = 1, 7 do
    TurtleRP.BindFrameToUIParent(TurtleRP_IconTray)
    TurtleRP.BindFrameToUIParent(TurtleRP_ChatBox)
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i));
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i .. "Tab"));
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i .. "TabDockRegion"));
	end
	TurtleRP.RPMode = 0;
	UIParent:Show();
end

function TurtleRP.OpenAdmin()
  UIPanelWindows["TurtleRP_AdminSB"] = { area = "left", pushable = 0 }

  ShowUIPanel(TurtleRP_AdminSB)

  TurtleRP_AdminSB_Tab1:SetNormalTexture("Interface\\Icons\\Spell_Nature_MoonGlow")
  TurtleRP_AdminSB_Tab1.tooltip = "Profile"
  TurtleRP_AdminSB_Tab1:Show()

  TurtleRP_AdminSB_Tab2:SetNormalTexture("Interface\\Icons\\INV_Misc_Head_Human_02")
  TurtleRP_AdminSB_Tab2.tooltip = "At A Glance"
  TurtleRP_AdminSB_Tab2:Show()

  TurtleRP_AdminSB_Tab3:SetNormalTexture("Interface\\Icons\\INV_Misc_StoneTablet_11")
  TurtleRP_AdminSB_Tab3.tooltip = "Description"
  TurtleRP_AdminSB_Tab3:Show()

  TurtleRP_AdminSB_Tab4:SetNormalTexture("Interface\\Icons\\INV_Letter_03")
  TurtleRP_AdminSB_Tab4.tooltip = "Notes"
  TurtleRP_AdminSB_Tab4:Show()

  -- TurtleRP_AdminSB_Tab5:SetNormalTexture("Interface\\Icons\\Spell_Holy_InnerFire")
  -- TurtleRP_AdminSB_Tab5.tooltip = "Directory"
  -- TurtleRP_AdminSB_Tab5:Show()

  TurtleRP_AdminSB_Tab6:SetNormalTexture("Interface\\Icons\\Trade_Engineering")
  TurtleRP_AdminSB_Tab6.tooltip = "Settings"
  TurtleRP_AdminSB_Tab6:Show()

  TurtleRP_AdminSB_Tab7:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
  TurtleRP_AdminSB_Tab7.tooltip = "About / Help"
  TurtleRP_AdminSB_Tab7:Show()

  TurtleRP.OnAdminTabClick(1)
end

function TurtleRP.OnAdminTabClick(id)
  for i=1, 7 do
    if i ~= id then
      getglobal("TurtleRP_AdminSB_Tab"..i):SetChecked(0)
      getglobal("TurtleRP_AdminSB_Content"..i):Hide()
    else
      getglobal("TurtleRP_AdminSB_Tab"..i):SetChecked(1)
      getglobal("TurtleRP_AdminSB_Content"..i):Show()
    end
  end
end

function TurtleRP.showColorPicker(r, g, b, a, changedCallback)
 ColorPickerFrame:SetColorRGB(r, g, b);
 ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
 ColorPickerFrame.previousValues = {r,g,b,a};
 ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
 ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
 ColorPickerFrame:Show();
end

function TurtleRP.colorPickerCallback(restore)
  local newR, newG, newB, newA;
  if restore then
    newR, newG, newB, newA = unpack(restore);
  else
    newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
  end

  local r, g, b, a = newR, newG, newB, newA;
  local hex = TurtleRP.rgb2hex(r, g, b)
  TurtleRP_AdminSB_Content1_ClassColorButton:SetBackdropColor(r, g, b)
  TurtleRPCharacterInfo['class_color'] = hex
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
  if string.find(data, '~') then
    _ERRORMESSAGE('Please do not use the character "~" in your text. Thanks!')
  else
    return data
  end
end

function TurtleRP.DrunkEncode(text)
	text = string.gsub(text, "s", "°");
	text = string.gsub(text, "S", "§");
	return text;
end

function TurtleRP.DrunkDecode(text)
  local DrunkSuffix = string.gsub(SLURRED_SPEECH, "%%s(.+)", "%1$"); -- remove "%s" from the localized " ...hic!" text;
	text = string.gsub(text, "°", "s");
	text = string.gsub(text, "§", "S");
	text = string.gsub(text, DrunkSuffix, ""); -- likely only needed if decoding an entire message
	return text;
end

function TurtleRP.log(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end
