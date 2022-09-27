--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

-----
-- Global storage (not saved)
-----
TurtleRP = {}
TurtleRP.currentlyRequestedData = nil
TurtleRP.iconFrames = nil
TurtleRP.iconSelectorCreated = nil
TurtleRP.currentIconSelector = nil
TurtleRP.iconSelectorFilter = ""
TurtleRP.RPMode = 0
TurtleRP.TestMode = 0

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
    TurtleRPCharacterInfoTemplate["title"] = ""
    TurtleRPCharacterInfoTemplate["first_name"] = UnitName("player")
    TurtleRPCharacterInfoTemplate["last_name"] = ""
    TurtleRPCharacterInfoTemplate["ic_info"] = ""
    TurtleRPCharacterInfoTemplate["ooc_info"] = ""
    TurtleRPCharacterInfoTemplate["ic_pronouns"] = ""
    TurtleRPCharacterInfoTemplate["ooc_pronouns"] = ""
    TurtleRPCharacterInfoTemplate["currently_ic"] = "on"

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

    -- Global character defaults setup
    if TurtleRPCharacterInfo == nil then
      TurtleRPCharacterInfo = TurtleRPCharacterInfoTemplate
    end
    if TurtleRPCharacters == nil then
      TurtleRPCharacters = {}
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    end
    if TurtleRPSettings == nil then
      TurtleRPSettings = {}
      TurtleRPSettings["bgs"] = "off"
    end
    if TurtleRPQueryablePlayers == nil then
      TurtleRPQueryablePlayers = {}
    end

    -- For adding additional fields after plugin is in use
    if TurtleRPCharacterInfo ~= nil then
      for i, field in pairs(TurtleRPCharacterInfoTemplate) do
        if TurtleRPCharacterInfo[i] == nil then
          TurtleRPCharacterInfo[i] = ""
        end
      end
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    end

    -- Intro message
    TurtleRP.log("Welcome, " .. TurtleRP.getFullName(TurtleRPCharacterInfo["title"], TurtleRPCharacterInfo["first_name"], TurtleRPCharacterInfo["last_name"]) .. ", to TurtleRP.")
    TurtleRP.log("Type |ccfFF0000/ttrp |ccfFFFFFFto open the addon.")

    if GetRealmName() == "Turtle WoW" and UnitLevel("player") < 5 and UnitLevel("player") ~= 0 then
      TurtleRP.log("|ccfFF0000Sorry, but due to Turtle WoW restrictions you can't access other player's TurtleRP profiles until level 5.")
    end

    TurtleRP.communication_prep()

    TurtleRP.populate_interface_user_data()

    TurtleRP.tooltip_events()
    TurtleRP.mouseover_and_target_events()
    TurtleRP.communication_events()

    -- TurtleRP_HTML_Renderer:SetText('<html><body><h1>Heading1</h1><h2>Heading2</h2><h3>Heading3</h3><p>A paragraph</p></body></html>')

    -- SLash commands
    SLASH_TURTLERP1 = "/ttrp";
    function SlashCmdList.TURTLERP(msg)
      TurtleRP_Admin:Show()
      TurtleRP_Description:Hide()
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
      getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 15)
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        if (UnitIsPlayer("mouseover")) then
          getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 18)
          TurtleRP.sendRequestForData("M", UnitName("mouseover"))
        end
      end
  end)

  -- Self target mouseover frame (preview of self mouseover)
  TargetFrame:EnableMouse()
  local defaultTargetFrameFunction = TargetFrame:GetScript("OnEnter")
  TargetFrame:SetScript("OnEnter",
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
-- Building interfaces to display data
-----
function TurtleRP.buildTargetFrame(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP_Target:Hide()
  if characterInfo["keyT"] ~= nil then
    local fullName = TurtleRP.getFullName(characterInfo['title'], characterInfo['first_name'], characterInfo['last_name'])
    TurtleRP_Target_TargetName:SetText(fullName)
    local stringWidth = TurtleRP_Target_TargetName:GetStringWidth()
    if stringWidth < 100 then
      stringWidth = 100
    end
    TurtleRP_Target:SetWidth(tonumber(stringWidth) + 40)

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

    TurtleRP_Target:Show()
  end
end

function TurtleRP.buildDescription(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  if characterInfo["keyD"] ~= nil then
    TurtleRP_Description_TargetName:SetText(TurtleRP_Target_TargetName:GetText())
    local stringWidth = TurtleRP_Description_TargetName:GetStringWidth()
    if (stringWidth + 40) > 350 then
      TurtleRP_Target:SetWidth(tonumber(stringWidth) + 40)
    end
    -- TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body><h1>Hi</h1></body></html>")
    if string.find(characterInfo['description'], "<p>") then
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("<html><body>" .. characterInfo['description'] .. "</body></html>")
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText("")
    else
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML:SetText("")
      TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription:SetText(characterInfo['description'])
    end
  end
end

-----
-- Populate data
-----
function TurtleRP.populate_interface_user_data()
  TurtleRP_Admin_General_TitleInput:SetText(TurtleRPCharacterInfo["title"])
  TurtleRP_Admin_General_FirstNameInput:SetText(TurtleRPCharacterInfo["first_name"])
  TurtleRP_Admin_General_LastNameInput:SetText(TurtleRPCharacterInfo["last_name"])
  TurtleRP_Admin_General_ICScrollBox_ICInfoInput:SetText(TurtleRPCharacterInfo["ic_info"])
  TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:SetText(TurtleRPCharacterInfo["ooc_info"])
  TurtleRP_Admin_General_ICPronounsInput:SetText(TurtleRPCharacterInfo["ic_pronouns"])
  TurtleRP_Admin_General_OOCPronounsInput:SetText(TurtleRPCharacterInfo["ooc_pronouns"])
  TurtleRP.setCharacterIcon()
  TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:SetText(TurtleRPCharacterInfo["atAGlance1"])
  TurtleRP_Admin_AtAGlance_AAG1TitleInput:SetText(TurtleRPCharacterInfo["atAGlance1Title"])
  TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:SetText(TurtleRPCharacterInfo["atAGlance2"])
  TurtleRP_Admin_AtAGlance_AAG2TitleInput:SetText(TurtleRPCharacterInfo["atAGlance2Title"])
  TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:SetText(TurtleRPCharacterInfo["atAGlance3"])
  TurtleRP_Admin_AtAGlance_AAG3TitleInput:SetText(TurtleRPCharacterInfo["atAGlance3Title"])
  TurtleRP.setAtAGlanceIcons()
  TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:SetText(TurtleRPCharacterInfo["description"])
  TurtleRP_Admin_Notes_NotesScrollBox_NotesInput:SetText(TurtleRPCharacterInfo["notes"])

  TurtleRP_Admin_Settings_PVPButton:SetChecked(TurtleRPSettings["bgs"] == "on" and true or false)
  TurtleRP_Admin_General_ICButton:SetChecked(TurtleRPCharacterInfo["currently_ic"] == "on" and true or false)
end

function TurtleRP.setCharacterIcon()
  if TurtleRPCharacterInfo["icon"] ~= "" then
    local iconIndex = TurtleRPCharacterInfo["icon"]
    TurtleRP_Admin_General_IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_Admin_General_IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
end

function TurtleRP.setAtAGlanceIcons()
  if TurtleRPCharacters[UnitName("player")]["atAGlance1Icon"] ~= "" then
    local iconIndex = TurtleRPCharacters[UnitName("player")]["atAGlance1Icon"]
    TurtleRP_Admin_AtAGlance_AAG1IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_Admin_AtAGlance_AAG1IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
  if TurtleRPCharacters[UnitName("player")]["atAGlance2Icon"] ~= "" then
    local iconIndex = TurtleRPCharacters[UnitName("player")]["atAGlance2Icon"]
    TurtleRP_Admin_AtAGlance_AAG2IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_Admin_AtAGlance_AAG2IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
  if TurtleRPCharacters[UnitName("player")]["atAGlance3Icon"] ~= "" then
    local iconIndex = TurtleRPCharacters[UnitName("player")]["atAGlance3Icon"]
    TurtleRP_Admin_AtAGlance_AAG3IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_Admin_AtAGlance_AAG3IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
end

-----
-- Saving
-----
function TurtleRP.save_general()
  TurtleRPCharacterInfo['keyM'] = TurtleRP.randomchars()
  local title = TurtleRP_Admin_General_TitleInput:GetText()
  TurtleRP_Admin_General_TitleInput:ClearFocus()
  TurtleRPCharacterInfo["title"] = TurtleRP.validateBeforeSaving(title)
  local first_name = TurtleRP_Admin_General_FirstNameInput:GetText()
  TurtleRP_Admin_General_FirstNameInput:ClearFocus()
  TurtleRPCharacterInfo["first_name"] = TurtleRP.validateBeforeSaving(first_name)
  local last_name = TurtleRP_Admin_General_LastNameInput:GetText()
  TurtleRP_Admin_General_LastNameInput:ClearFocus()
  TurtleRPCharacterInfo["last_name"] = TurtleRP.validateBeforeSaving(last_name)
  local ic_info = TurtleRP_Admin_General_ICScrollBox_ICInfoInput:GetText()
  TurtleRP_Admin_General_ICScrollBox_ICInfoInput:ClearFocus()
  TurtleRPCharacterInfo["ic_info"] = TurtleRP.validateBeforeSaving(ic_info)
  local ooc_info = TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:GetText()
  TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:ClearFocus()
  TurtleRPCharacterInfo["ooc_info"] = TurtleRP.validateBeforeSaving(ooc_info)
  local ic_pronouns = TurtleRP_Admin_General_ICPronounsInput:GetText()
  TurtleRP_Admin_General_ICPronounsInput:ClearFocus()
  TurtleRPCharacterInfo["ic_pronouns"] = TurtleRP.validateBeforeSaving(ic_pronouns)
  local ooc_pronouns = TurtleRP_Admin_General_OOCPronounsInput:GetText()
  TurtleRP_Admin_General_OOCPronounsInput:ClearFocus()
  TurtleRPCharacterInfo["ooc_pronouns"] = TurtleRP.validateBeforeSaving(ooc_pronouns)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setCharacterIcon()
end
function TurtleRP.save_at_a_glance()
  TurtleRPCharacterInfo['keyT'] = TurtleRP.randomchars()
  local aag1Text = TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:GetText()
  TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1"] = TurtleRP.validateBeforeSaving(aag1Text)
  local aag1TitleText = TurtleRP_Admin_AtAGlance_AAG1TitleInput:GetText()
  TurtleRP_Admin_AtAGlance_AAG1TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1Title"] = TurtleRP.validateBeforeSaving(aag1TitleText)
  local aag2Text = TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:GetText()
  TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2"] = TurtleRP.validateBeforeSaving(aag2Text)
  local aag2TitleText = TurtleRP_Admin_AtAGlance_AAG2TitleInput:GetText()
  TurtleRP_Admin_AtAGlance_AAG2TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2Title"] = TurtleRP.validateBeforeSaving(aag2TitleText)
  local aag3Text = TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:GetText()
  TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3"] = TurtleRP.validateBeforeSaving(aag3Text)
  local aag3TitleText = TurtleRP_Admin_AtAGlance_AAG3TitleInput:GetText()
  TurtleRP_Admin_AtAGlance_AAG3TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3Title"] = TurtleRP.validateBeforeSaving(aag3TitleText)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setAtAGlanceIcons()
end
function TurtleRP.save_description()
  TurtleRPCharacterInfo['keyD'] = TurtleRP.randomchars()
  local description = TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:GetText()
  TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:ClearFocus()
  TurtleRPCharacterInfo["description"] = TurtleRP.validateBeforeSaving(description)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
end
function TurtleRP.save_notes()
  local notes = TurtleRP_Admin_Notes_NotesScrollBox_NotesInput:GetText()
  TurtleRP_Admin_Notes_NotesScrollBox_NotesInput:ClearFocus()
  TurtleRPCharacterInfo["notes"] = notes
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

function MyModScrollBar_Update()
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
function TurtleRP.ToggleRPMode()
	if (TurtleRP.RPMode == 0) then
		TurtleRP.EnableRPMode();
	else
		TurtleRP.DisableRPMode();
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
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i));
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i .. "Tab"));
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i .. "TabDockRegion"));
	end
	TurtleRP.RPMode = 0;
	UIParent:Show();
end

function TurtleRP.showHidePanels(panelName)
  TurtleRP_Admin_General:Hide()
  TurtleRP_Admin_AtAGlance:Hide()
  TurtleRP_Admin_Description:Hide()
  TurtleRP_Admin_Notes:Hide()
  TurtleRP_Admin_Settings:Hide()
  panelName:Show()
end

-----
-- Utility
-----
function TurtleRP.splitByChunk(text, chunkSize)
    local splitLength = 200
    local sz = math.ceil(strlen(text) / splitLength)
    local loopNumber = 0
    local chunksToReturn = {}
    while loopNumber < sz do
      local startAt = (loopNumber * splitLength)
      chunksToReturn[loopNumber + 1] = strsub(text, startAt, startAt + splitLength - 1)
      loopNumber = loopNumber + 1
    end
    return chunksToReturn
end

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

function TurtleRP.getFullName(title, first_name, last_name)
  local fullName = first_name
  if title ~= "" then
    fullName = title .. " " .. fullName
  end
  if last_name ~= "" then
   fullName = fullName .. " " .. last_name
  end
  return fullName
end

function TurtleRP.randomchars()
	local res = ""
	for i = 1, 5 do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function TurtleRP.validateBeforeSaving(data)
  if string.find(data, '&&') then
    _ERRORMESSAGE('Please do not use the characters "&&" together in your text. Thanks!')
  else
    return data
  end
end

function TurtleRP.log(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end
