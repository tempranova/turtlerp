--[[ To Do

BUGS
-- Need to test all iffy characters -- if any bad ones cause an error, it'll error EVERYONE

NEXT UP

-- Selector for main tooltip icon
-- Allow to "deselect" and icon and delete it

-- Passing through HTML for the Description, adding some "Advanced" instructions on click
----- (link to HTML instructions, and a link to lists of images and names of images they can use in the text)
-- Allowing custom class text and custom class color

]]

-----
-- Global storage (not saved)
-----
TurtleRP = {}
TurtleRP.currentlyRequestedData = nil
TurtleRP.iconFrames = {}
TurtleRP.currentTooltip = nil
TurtleRP.currentIconSelector = nil

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

    -- Global character defaults setup
    if TurtleRPCharacterInfo == nil then
      TurtleRPCharacterInfo = {}

      TurtleRPCharacterInfo["keyM"] = randomchars()
      TurtleRPCharacterInfo["icon"] = ""
      TurtleRPCharacterInfo["title"] = ""
      TurtleRPCharacterInfo["first_name"] = UnitName("player")
      TurtleRPCharacterInfo["last_name"] = ""
      TurtleRPCharacterInfo["ic_info"] = ""
      TurtleRPCharacterInfo["ooc_info"] = ""
      TurtleRPCharacterInfo["currently_ic"] = "on"

      TurtleRPCharacterInfo["keyT"] = randomchars()
      TurtleRPCharacterInfo["atAGlance1"] = ""
      TurtleRPCharacterInfo["atAGlance1Icon"] = ""
      TurtleRPCharacterInfo["atAGlance2"] = ""
      TurtleRPCharacterInfo["atAGlance2Icon"] = ""
      TurtleRPCharacterInfo["atAGlance3"] = ""
      TurtleRPCharacterInfo["atAGlance3Icon"] = ""

      TurtleRPCharacterInfo["keyD"] = randomchars()
      TurtleRPCharacterInfo["description"] = ""
    end
    if TurtleRPCharacters == nil then
      TurtleRPCharacters = {}
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    end
    if TurtleRPSettings == nil then
      TurtleRPSettings = {}
      TurtleRPSettings["bgs"] = "off"
    end

    -- Intro message
    log("Welcome, " .. getFullName(TurtleRPCharacterInfo["title"], TurtleRPCharacterInfo["first_name"], TurtleRPCharacterInfo["last_name"]) .. ", to TurtleRP.")
    log("Share your story by typing /ttrp to open the menu.")

    if GetRealmName() == "Turtle WoW" and UnitLevel("player") < 5 and UnitLevel("player") ~= 0 then
      log("|ccfFF0000Sorry, but due to Turtle WoW restrictions you can't access other player's TurtleRP profiles until level 5.")
    end

    communication_prep()

    populate_interface_user_data()
    interface_tweaks()

    interface_events()
    interface_frame_events()
    communication_events()
    save_events()

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
function interface_frame_events()

  -- Player target
  local TurtleRPTargetFrame = CreateFrame("Frame")
  TurtleRPTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  TurtleRPTargetFrame:SetScript("OnEvent",
  	function(self, event, ...)
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        if (UnitIsPlayer("target")) then
          if UnitName("target") == UnitName("player") then
            buildTargetFrame(UnitName("player"))
          else
            sendRequestForData("T", UnitName("target"))
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
  TurtleRPMouseoverFrame:SetScript("OnEvent",
  	function(self, event, ...)
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        -- Ensuring defaults are in place
        getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 15)
        if (UnitIsPlayer("mouseover")) then
          sendRequestForData("M", UnitName("mouseover"))
        end
      end
  	end
  )

  -- Self target mouseover frame (preview of self mouseover)
  TargetFrame:EnableMouse()
  local defaultTargetFrameFunction = TargetFrame:GetScript("OnEnter")
  TargetFrame:SetScript("OnEnter",
    function()
      defaultTargetFrameFunction()
      if (IsInInstance() == "pvp" and TurtleRPSettings["bgs"] == "off") or IsInInstance() ~= "pvp" then
        if(UnitName("target") == UnitName("player")) then
          buildTooltip(UnitName("player"), "target")
        end
      end
    end
  )
end

function buildTooltip(playerName, targetType)
  local characterInfo = TurtleRPCharacters[playerName]
  if TurtleRPCharacters[playerName]["keyM"] ~= nil and TurtleRP.currentTooltip == nil then
    TurtleRP.currentTooltip = playerName
    local fullName = getFullName(characterInfo['title'], characterInfo['first_name'], characterInfo['last_name'])
    local race = UnitRace(targetType)
    local class = UnitClass(targetType)
    local guildName = GetGuildInfo(targetType)
    local level = UnitLevel(targetType)

    local currentLineNumber = 1
    local titleExtraSpaces = characterInfo['icon'] ~= "" and "         " or ""
    getglobal("GameTooltipTextLeft1"):SetText(titleExtraSpaces .. fullName, 0.53, 0.53, 0.93)
    local thisClassColor = TurtleRPClassData[class]
    getglobal("GameTooltipTextLeft1"):SetTextColor(thisClassColor[1], thisClassColor[2], thisClassColor[3])
    getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 18)

    currentLineNumber = currentLineNumber + 1
    local guildExtraSpaces = characterInfo['icon'] ~= "" and "           " or ""
    getglobal("GameTooltipTextLeft2"):SetText(guildExtraSpaces .. "<" .. guildName .. ">")
    getglobal("GameTooltipTextLeft2"):SetTextColor(0.83, 0.62, 0.09)

    currentLineNumber = currentLineNumber + 1
    GameTooltip:AddLine(" ")

    currentLineNumber = currentLineNumber + 1
    getglobal("GameTooltipTextRight2"):SetText()
    local statusText = characterInfo['currently_ic'] == "on" and "|cff40AF6FIC" or "|cffD3681EOOC"
    local levelAndStatusText = "Level " .. level .. " (" .. statusText .. "|cffFFFFFF)"
    GameTooltip:AddDoubleLine(race .. " |cff" .. thisClassColor[4] .. class, levelAndStatusText, 1, 1, 1, 1, 1, 1)
    if characterInfo['ic_info'] ~= "" then

      currentLineNumber = currentLineNumber + 1
      GameTooltip:AddLine(" ")

      currentLineNumber = currentLineNumber + 1
      GameTooltip:AddLine("IC Info", 1, 0.6, 0, true)

      currentLineNumber = currentLineNumber + 1
      GameTooltip:AddLine(characterInfo['ic_info'], 0.8, 0.8, 0.8, true)
      getglobal("GameTooltipTextLeft" .. currentLineNumber):SetFont("Fonts\\FRIZQT__.ttf", 10)
    end
    if characterInfo['ooc_info'] ~= "" then

      currentLineNumber = currentLineNumber + 1
      GameTooltip:AddLine(" ")

      currentLineNumber = currentLineNumber + 1
      GameTooltip:AddLine("OOC Info", 1, 0.6, 0, true)

      currentLineNumber = currentLineNumber + 1
      GameTooltip:AddLine(characterInfo['ooc_info'], 0.8, 0.8, 0.8, true)
      getglobal("GameTooltipTextLeft" .. currentLineNumber):SetFont("Fonts\\FRIZQT__.ttf", 10)
    end
    GameTooltip:Show()

    if characterInfo['icon'] ~= "" then
      TurtleRP_Tooltip_Icon:SetPoint("TOPLEFT", "GameTooltipTextLeft1", "TOPLEFT")
      TurtleRP_Tooltip_Icon:SetFrameStrata("tooltip")
      TurtleRP_Tooltip_Icon:SetFrameLevel(99)
      local iconIndex = characterInfo["icon"]
      TurtleRP_Tooltip_Icon_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Tooltip_Icon:Show()
    end
  end
end

function buildTargetFrame(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  if characterInfo["keyT"] ~= nil then
    local fullName = getFullName(characterInfo['title'], characterInfo['first_name'], characterInfo['last_name'])
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
      TurtleRP_Target_AtAGlance1_TextPanel_Text:SetText(characterInfo["atAGlance1"])
      TurtleRP_Target_AtAGlance1_TextPanel_Text:SetFont("Fonts\\FRIZQT__.ttf", 10)
      TurtleRP_Target_AtAGlance1:Show()
    end

    TurtleRP_Target_AtAGlance2:Hide()
    if characterInfo['atAGlance2Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance2Icon"]
      TurtleRP_Target_AtAGlance2_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance2_TextPanel_Text:SetText(characterInfo["atAGlance2"])
      TurtleRP_Target_AtAGlance2_TextPanel_Text:SetFont("Fonts\\FRIZQT__.ttf", 10)
      TurtleRP_Target_AtAGlance2:Show()
    end

    TurtleRP_Target_AtAGlance3:Hide()
    if characterInfo['atAGlance3Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance3Icon"]
      TurtleRP_Target_AtAGlance3_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance3_TextPanel_Text:SetText(characterInfo["atAGlance3"])
      TurtleRP_Target_AtAGlance3_TextPanel_Text:SetFont("Fonts\\FRIZQT__.ttf", 10)
      TurtleRP_Target_AtAGlance3:Show()
    end

    TurtleRP_Target:Show()
  end
end

function buildDescription(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  if characterInfo["keyD"] ~= nil then
    TurtleRP_Description_TargetName:SetText(TurtleRP_Target_TargetName:GetText())
    local stringWidth = TurtleRP_Description_TargetName:GetStringWidth()
    if (stringWidth + 40) > 350 then
      TurtleRP_Target:SetWidth(tonumber(stringWidth) + 40)
    end
    TurtleRP_Description_DescriptionScrollBox_DescriptionHolder_TargetDescription:SetText(characterInfo['description'])
    TurtleRP_Description:Show()
    TurtleRP_Admin:Hide()
  end
end

-----
-- Setup
-----
function populate_interface_user_data()
  TurtleRP_Admin_General_TitleInput:SetText(TurtleRPCharacterInfo["title"])
  TurtleRP_Admin_General_FirstNameInput:SetText(TurtleRPCharacterInfo["first_name"])
  TurtleRP_Admin_General_LastNameInput:SetText(TurtleRPCharacterInfo["last_name"])
  TurtleRP_Admin_General_ICScrollBox_ICInfoInput:SetText(TurtleRPCharacterInfo["ic_info"])
  TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:SetText(TurtleRPCharacterInfo["ooc_info"])
  setCharacterIcon()
  TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:SetText(TurtleRPCharacterInfo["atAGlance1"])
  TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:SetText(TurtleRPCharacterInfo["atAGlance1"])
  TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:SetText(TurtleRPCharacterInfo["atAGlance2"])
  TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:SetText(TurtleRPCharacterInfo["atAGlance3"])
  setAtAGlanceIcons()
  TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:SetText(TurtleRPCharacterInfo["description"])

  TurtleRP_Admin_Settings_PVPButton:SetChecked(TurtleRPSettings["bgs"] == "on" and true or false)
  TurtleRP_Admin_General_ICButton:SetChecked(TurtleRPCharacterInfo["currently_ic"] == "on" and true or false)
end

function interface_tweaks()
  TurtleRP_Admin_General_SaveButton:SetFont("Fonts\\FRIZQT__.ttf", 10)
  TurtleRP_Admin_Description_SaveButton:SetFont("Fonts\\FRIZQT__.ttf", 10)
  TurtleRP_Admin_AtAGlance_SaveButton:SetFont("Fonts\\FRIZQT__.ttf", 10)
  TurtleRP_Target_DescriptionButton:SetFont("Fonts\\FRIZQT__.ttf", 10)

  TurtleRP_Admin_General_TitleInput:SetMaxLetters(20)
  TurtleRP_Admin_General_FirstNameInput:SetMaxLetters(20)
  TurtleRP_Admin_General_LastNameInput:SetMaxLetters(20)
  TurtleRP_Admin_General_ICScrollBox_ICInfoInput:SetMaxLetters(100)
  TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:SetMaxLetters(100)
  TurtleRP_Admin_General_ICScrollBox_ICInfoInput:SetMultiLine(true)
  TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:SetMultiLine(true)
  TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:SetMultiLine(true)
  TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:SetMaxLetters(75)
  TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:SetMultiLine(true)
  TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:SetMaxLetters(75)
  TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:SetMultiLine(true)
  TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:SetMaxLetters(75)
  TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:SetMultiLine(true)
  TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:SetMultiLine(true)
end

function interface_events()
  function showHidePanels(panelName)
    TurtleRP_Admin_General:Hide()
    TurtleRP_Admin_AtAGlance:Hide()
    TurtleRP_Admin_Description:Hide()
    TurtleRP_Admin_Settings:Hide()
    panelName:Show()
  end
  TurtleRP_Admin_GeneralButton:SetScript("OnClick", function(self, arg1)
    showHidePanels(TurtleRP_Admin_General)
  end)
  TurtleRP_Admin_AtAGlanceButton:SetScript("OnClick", function(self, arg1)
    showHidePanels(TurtleRP_Admin_AtAGlance)
  end)
  TurtleRP_Admin_DescriptionButton:SetScript("OnClick", function(self, arg1)
    showHidePanels(TurtleRP_Admin_Description)
  end)
  TurtleRP_Admin_SettingsButton:SetScript("OnClick", function(self, arg1)
    showHidePanels(TurtleRP_Admin_Settings)
  end)
  TurtleRP_Admin_General_ICButton:SetScript("OnClick", function()
    if TurtleRPCharacterInfo["currently_ic"] == "off" then
      TurtleRPCharacterInfo["currently_ic"] = "on"
    else
      TurtleRPCharacterInfo["currently_ic"] = "off"
    end
    TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  end)
  TurtleRP_Admin_General_IconButton:SetScript("OnClick", function()
    TurtleRP.currentIconSelector = 'icon'
    create_icon_selector()
  end)
  TurtleRP_Admin_General_CancelIconButton:SetScript("OnClick", function()
    TurtleRPCharacterInfo['icon'] = ""
    save_general()
  end)
  TurtleRP_Admin_AtAGlance_AAG1IconButton:SetScript("OnClick", function()
    TurtleRP.currentIconSelector = 'atAGlance1Icon'
    create_icon_selector()
  end)
  TurtleRP_Admin_AtAGlance_CancelAAG1IconButton:SetScript("OnClick", function()
    TurtleRPCharacterInfo['atAGlance1Icon'] = ""
    save_at_a_glance()
  end)
  TurtleRP_Admin_AtAGlance_AAG2IconButton:SetScript("OnClick", function()
    TurtleRP.currentIconSelector = 'atAGlance2Icon'
    create_icon_selector()
  end)
  TurtleRP_Admin_AtAGlance_CancelAAG2IconButton:SetScript("OnClick", function()
    TurtleRPCharacterInfo['atAGlance2Icon'] = ""
    save_at_a_glance()
  end)
  TurtleRP_Admin_AtAGlance_AAG3IconButton:SetScript("OnClick", function()
    TurtleRP.currentIconSelector = 'atAGlance3Icon'
    create_icon_selector()
  end)
  TurtleRP_Admin_AtAGlance_CancelAAG3IconButton:SetScript("OnClick", function()
    TurtleRPCharacterInfo['atAGlance3Icon'] = ""
    save_at_a_glance()
  end)
  TurtleRP_Admin_Settings_PVPButton:SetScript("OnClick", function()
    if TurtleRPSettings["bgs"] == "off" then
      TurtleRPSettings["bgs"] = "on"
    else
      TurtleRPSettings["bgs"] = "off"
    end
  end)
  TurtleRP_Admin:SetScript("OnMouseDown", function()
    TurtleRP_Admin:StartMoving()
  end)
  TurtleRP_Admin:SetScript("OnMouseUp", function()
    TurtleRP_Admin:StopMovingOrSizing()
  end)
  TurtleRP_Target:SetScript("OnMouseDown", function()
    TurtleRP_Target:StartMoving()
  end)
  TurtleRP_Target:SetScript("OnMouseUp", function()
    TurtleRP_Target:StopMovingOrSizing()
  end)
  TurtleRP_Description:SetScript("OnMouseDown", function()
    TurtleRP_Description:StartMoving()
  end)
  TurtleRP_Description:SetScript("OnMouseUp", function()
    TurtleRP_Description:StopMovingOrSizing()
  end)
  TurtleRP_MinimapIcon_OpenAdmin:SetScript("OnMouseDown", function()
    TurtleRP_MinimapIcon:StartMoving()
  end)
  TurtleRP_MinimapIcon_OpenAdmin:SetScript("OnMouseUp", function()
    TurtleRP_MinimapIcon:StopMovingOrSizing()
  end)
  GameTooltip:SetScript("OnHide", function()
    TurtleRP_Tooltip_Icon:Hide()
    TurtleRP.currentTooltip = nil
  end)
  TurtleRP_MinimapIcon_OpenAdmin:SetScript("OnClick", function()
    TurtleRP_Admin:Show()
  end)
  TurtleRP_Target_AtAGlance1:SetScript("OnEnter", function()
    TurtleRP_Target_AtAGlance1_TextPanel:Show()
  end)
  TurtleRP_Target_AtAGlance1:SetScript("OnLeave", function()
    TurtleRP_Target_AtAGlance1_TextPanel:Hide()
  end)
  TurtleRP_Target_AtAGlance2:SetScript("OnEnter", function()
    TurtleRP_Target_AtAGlance2_TextPanel:Show()
  end)
  TurtleRP_Target_AtAGlance2:SetScript("OnLeave", function()
    TurtleRP_Target_AtAGlance2_TextPanel:Hide()
  end)
  TurtleRP_Target_AtAGlance3:SetScript("OnEnter", function()
    TurtleRP_Target_AtAGlance3_TextPanel:Show()
  end)
  TurtleRP_Target_AtAGlance3:SetScript("OnLeave", function()
    TurtleRP_Target_AtAGlance3_TextPanel:Hide()
  end)
end

function save_events()
  function save_general()
    TurtleRPCharacterInfo['keyM'] = randomchars()
    local title = TurtleRP_Admin_General_TitleInput:GetText()
    TurtleRP_Admin_General_TitleInput:ClearFocus()
    TurtleRPCharacterInfo["title"] = title
    local first_name = TurtleRP_Admin_General_FirstNameInput:GetText()
    TurtleRP_Admin_General_FirstNameInput:ClearFocus()
    TurtleRPCharacterInfo["first_name"] = first_name
    local last_name = TurtleRP_Admin_General_LastNameInput:GetText()
    TurtleRP_Admin_General_LastNameInput:ClearFocus()
    TurtleRPCharacterInfo["last_name"] = last_name
    local ic_info = TurtleRP_Admin_General_ICScrollBox_ICInfoInput:GetText()
    TurtleRP_Admin_General_ICScrollBox_ICInfoInput:ClearFocus()
    TurtleRPCharacterInfo["ic_info"] = ic_info
    local ooc_info = TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:GetText()
    TurtleRP_Admin_General_OOCScrollBox_OOCInfoInput:ClearFocus()
    TurtleRPCharacterInfo["ooc_info"] = ooc_info
    TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    setCharacterIcon()
  end
  function save_at_a_glance()
    TurtleRPCharacterInfo['keyT'] = randomchars()
    local aag1Text = TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:GetText()
    TurtleRP_Admin_AtAGlance_AtAGlance1ScrollBox_AAG1Input:ClearFocus()
    TurtleRPCharacterInfo["atAGlance1"] = aag1Text
    local aag2Text = TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:GetText()
    TurtleRP_Admin_AtAGlance_AtAGlance2ScrollBox_AAG2Input:ClearFocus()
    TurtleRPCharacterInfo["atAGlance2"] = aag2Text
    local aag3Text = TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:GetText()
    TurtleRP_Admin_AtAGlance_AtAGlance3ScrollBox_AAG3Input:ClearFocus()
    TurtleRPCharacterInfo["atAGlance3"] = aag3Text
    TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    setAtAGlanceIcons()
  end
  function save_description()
    TurtleRPCharacterInfo['keyD'] = randomchars()
    local description = TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:GetText()
    TurtleRP_Admin_Description_DescriptionScrollBox_DescriptionInput:ClearFocus()
    TurtleRPCharacterInfo["description"] = description
    TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  end
  TurtleRP_Admin_General_SaveButton:SetScript("OnClick", function(self, arg1)
    save_general()
  end)
  TurtleRP_Admin_AtAGlance_SaveButton:SetScript("OnClick", function(self, arg1)
    save_at_a_glance()
  end)
  TurtleRP_Admin_Description_SaveButton:SetScript("OnClick", function(self, arg1)
    save_description()
    TurtleRPCharacterInfo['descriptionUniqueKey'] = randomchars()
  end)
end

function setCharacterIcon()
  if TurtleRPCharacterInfo["icon"] ~= "" then
    local iconIndex = TurtleRPCharacterInfo["icon"]
    TurtleRP_Admin_General_IconButton:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)] })
  else
    TurtleRP_Admin_General_IconButton:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-EmptySlot-White" })
  end
end

function setAtAGlanceIcons()
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

function create_icon_selector()
  TurtleRP_IconSelector:Show()
  TurtleRP_IconSelector:SetFrameStrata("tooltip")
  TurtleRP_IconSelector:SetFrameLevel(99)
  TurtleRP.iconFrames = makeIconFrames()
  renderIcons(0)
end

function MyModScrollBar_Update()
  FauxScrollFrame_Update(TurtleRP_IconSelector_ScrollBox, 500, 250, 25)
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_IconSelector_ScrollBox)
  renderIcons((currentLine * 5))
end

function makeIconFrames()
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
      save_general()
      save_at_a_glance()
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

function renderIcons(iconOffset)
  if TurtleRP.iconFrames ~= nil then
    for i, iconFrame in ipairs(TurtleRP.iconFrames) do
      iconFrame:SetText(i + iconOffset)
      iconFrame:SetBackdrop({ bgFile = "Interface\\Icons\\" .. TurtleRPIcons[i + iconOffset] })
    end
  end
end

-----
-- Helper / Utility
-----
function splitByChunk(text, chunkSize)
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

function getFullName(title, first_name, last_name)
  local fullName = first_name
  if title ~= "" then
    fullName = title .. " " .. fullName
  end
  if last_name ~= "" then
   fullName = fullName .. " " .. last_name
  end
  return fullName
end

-- function setGeneralDataToInterface(msg)
--   local beginningOfData = strfind(msg, "&&")
--   local dataSlice = strsub(arg1, beginningOfData)
--   local splitArray = string.split(dataSlice, "&&")
--   local title = splitArray[2]
--   local first_name = splitArray[3]
--   local last_name = splitArray[4]
--   local ic_info = splitArray[5]
--   local ooc_info = splitArray[6]
--   local currently_ic = splitArray[7]
--   if TurtleRP.currentPlayerRequestedMouseover == UnitName("mouseover") then
--     local race = UnitRace("mouseover")
--     local class = UnitClass("mouseover")
--     local guildName = GetGuildInfo("mouseover")
--     local level = UnitLevel("mouseover")
--     buildTooltip(title, first_name, last_name, race, class, guildName, level, ic_info, ooc_info, currently_ic)
--   end
--   if TurtleRP.currentPlayerRequestedMouseover == UnitName("target") then
--     buildTargetFrame(title, first_name, last_name)
--   end
--   TurtleRP.currentPlayerRequestedMouseover = nil
-- end
--
-- function setDescriptionDataToInterface(msg)
--   if TurtleRP.currentPlayerRequestedTarget == UnitName("target") then
--     local beginningOfData = strfind(msg, "&&")
--     local dataSlice = strsub(arg1, beginningOfData)
--     local splitArray = string.split(dataSlice, "&&")
--     local index = splitArray[2]
--     local total = splitArray[3]
--     local text = splitArray[4]
--     if(TurtleRP.currentDescriptionCount == tonumber(index)) then
--       TurtleRP.currentDescriptionCount = TurtleRP.currentDescriptionCount + 1
--       TurtleRP.currentDescription = TurtleRP.currentDescription .. text
--     end
--     local reconstitutedDescriptionWithLineBreaks = gsub(TurtleRP.currentDescription, "@N", "%\n")
--     buildDescription(reconstitutedDescriptionWithLineBreaks)
--     if (TurtleRP.currentDescriptionCount - 1) == tonumber(total) then
--       TurtleRP.currentPlayerRequestedTarget = nil
--     end
--   end
-- end

function randomchars()
	local res = ""
	for i = 1, 5 do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function log(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end
