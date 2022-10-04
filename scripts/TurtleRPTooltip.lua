--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp

-- Need to account for all different possibilities for tooltip :)
-- Pvp, guilded, other unexpected things?
-- Not clearing and remaking (status bar), but instead overwriting existing lines
-- Using the "GetText() == nil" as a test for a line's existence
-- Not worrying about multiple overwrites? Could this cause lag? Are there overwrites occuring (only when rapidly mousing out and in again)

--]]

function TurtleRP.tooltip_events()
  -- Get defaults
  local tooltipDefaults = {}
	for i = 1, 11 do
    local lfontName, lfontHeight, lflag = getglobal("GameTooltipTextLeft" .. i):GetFont()
    tooltipDefaults["tooltipFontLeft" .. i .. "Name"] = lfontName
    tooltipDefaults["tooltipFontLeft" .. i .. "Height"] = lfontHeight
    tooltipDefaults["tooltipFontLeft" .. i .. "Flag"] = lflag
    local rfontName, rfontHeight, rflag = getglobal("GameTooltipTextRight" .. i):GetFont()
    tooltipDefaults["tooltipFontRight" .. i .. "Name"] = rfontName
    tooltipDefaults["tooltipFontRight" .. i .. "Height"] = rfontHeight
    tooltipDefaults["tooltipFontRight" .. i .. "Flag"] = rflag
  end
  -- Custom scripts
  local defaultTooltipClearedScript = TurtleRP.gameTooltip:GetScript("OnTooltipCleared")
  TurtleRP.gameTooltip:SetScript("OnTooltipCleared", function()
    for i = 1, 11 do
      getglobal("GameTooltipTextLeft" .. i):SetFont(tooltipDefaults["tooltipFontLeft" .. i .. "Name"], tooltipDefaults["tooltipFontLeft" .. i .. "Height"], tooltipDefaults["tooltipFontLeft" .. i .. "Flag"])
      getglobal("GameTooltipTextRight" .. i):SetFont(tooltipDefaults["tooltipFontRight" .. i .. "Name"], tooltipDefaults["tooltipFontRight" .. i .. "Height"], tooltipDefaults["tooltipFontRight" .. i .. "Flag"])
    end
    TurtleRP_Tooltip_Icon:Hide()
    if defaultTooltipShowScript then
      defaultTooltipClearedScript()
    end
  end)
  local defaultTooltipShowScript = TurtleRP.gameTooltip:GetScript("OnShow")
  TurtleRP.gameTooltip:SetScript("OnShow", function()
    if UnitIsPlayer("mouseover") then
      TurtleRP.buildTooltip(UnitName("mouseover"), "mouseover")
    end
    if defaultTooltipShowScript then
      defaultTooltipShowScript()
    end
  end)
  local defaultTooltipHideScript = TurtleRP.gameTooltip:GetScript("OnHide")
  TurtleRP.gameTooltip:SetScript("OnHide", function()
    -- Set defaults
    for i = 1, 11 do
      getglobal("GameTooltipTextLeft" .. i):SetFont(tooltipDefaults["tooltipFontLeft" .. i .. "Name"], tooltipDefaults["tooltipFontLeft" .. i .. "Height"], tooltipDefaults["tooltipFontLeft" .. i .. "Flag"])
      getglobal("GameTooltipTextRight" .. i):SetFont(tooltipDefaults["tooltipFontRight" .. i .. "Name"], tooltipDefaults["tooltipFontRight" .. i .. "Height"], tooltipDefaults["tooltipFontRight" .. i .. "Flag"])
    end
    defaultTooltipHideScript()
    TurtleRP_Tooltip_Icon:Hide()
  end)
end

function TurtleRP.getStatusText(currently_ic, ICOn, ICOff, whiteColor)
  local statusText = ""
  if currently_ic ~= nil then
    if currently_ic == "1" then
      statusText = " (" .. ICOn .. "IC" .. whiteColor .. ")"
    else
      statusText = " (" .. ICOff .. "OOC" .. whiteColor .. ")"
    end
  end
  return statusText
end

function TurtleRP.getPronounsText(pronouns, pronounColor)
  local pronounText = ""
  if pronouns ~= nil and pronouns ~= "" then
    pronounText = pronounColor .. " (" .. pronouns .. ")"
  end
  return pronounText
end

function TurtleRP.printICandOOC(info, headerText, blankLine, l)
  local n = l
  if info ~= nil and info ~= "" then
    n = n + 1
    if getglobal("GameTooltipTextLeft"..n):GetText() == nil then
      TurtleRP.gameTooltip:AddLine(blankLine)
    else
      getglobal("GameTooltipTextLeft"..n):SetText(blankLine)
    end

    n = n + 1
    if getglobal("GameTooltipTextLeft"..n):GetText() == nil then
      TurtleRP.gameTooltip:AddLine(headerText, 1, 0.6, 0, true)
    else
      getglobal("GameTooltipTextLeft"..n):SetText(headerText)
    end

    n = n + 1
    if getglobal("GameTooltipTextLeft"..n):GetText() == nil then
      TurtleRP.gameTooltip:AddLine(info, 0.8, 0.8, 0.8, true)
    else
      getglobal("GameTooltipTextLeft"..n):SetText(info)
    end
    getglobal("GameTooltipTextLeft"..n):SetFont("Fonts\\FRIZQT__.ttf", 10)
  end
  return n
end

function TurtleRP.buildTooltip(playerName, targetType)
  -- Prepping character from database
  local characterInfo = TurtleRPCharacters[playerName]
  local locallyRetrievable = nil
  if characterInfo and characterInfo["keyM"] then
    locallyRetrievable = true
  end

  if targetType == nil then
    GameTooltip_SetDefaultAnchor(TurtleRP.gameTooltip, UIParent)
  end

  -- Getting details for character
  local fullName        = locallyRetrievable and characterInfo["full_name"] or UnitName(targetType)
  local race            = locallyRetrievable and characterInfo["race"] or UnitRace(targetType)
  local class           = locallyRetrievable and characterInfo["class"] or UnitClass(targetType)
  local class_color     = locallyRetrievable and characterInfo['class_color'] or TurtleRPClassData[class][4]
  local guildName       = nil
  local guildRank       = nil
  local queriedLevel    = ""
  local icon            = locallyRetrievable and characterInfo['icon'] or nil
  local currently_ic    = locallyRetrievable and characterInfo['currently_ic'] or nil
  local ic_info         = locallyRetrievable and characterInfo['ic_info'] or nil
  local ic_pronouns     = locallyRetrievable and characterInfo['ic_pronouns'] or nil
  local ooc_info        = locallyRetrievable and characterInfo['ooc_info'] or nil
  local ooc_pronouns    = locallyRetrievable and characterInfo['ooc_pronouns'] or nil
  if targetType ~= nil then
    guildName, guildRank= GetGuildInfo(targetType)
    queriedLevel = UnitLevel(targetType)
  end

  -- Color variables
  local colorPrefix       = "|cff"
  local thisClassColor    = colorPrefix .. class_color -- Hex code
  local guildColor        = colorPrefix .. "FFD700"
  local whiteColor        = colorPrefix .. "FFFFFF"
  local ICOn              = colorPrefix .. "40AF6F"
  local ICOff             = colorPrefix .. "D3681E"
  local pronounColor      = colorPrefix .. "ffcc80"

  -- Formatting variables
  -- local titleExtraSpaces    = (icon ~= nil and icon ~= "") and "" or ""
  -- local guildExtraSpaces    = (icon ~= nil and icon ~= "") and "" or ""
  local titleExtraSpaces    = (icon ~= nil and icon ~= "") and "         " or ""
  local guildExtraSpaces    = (icon ~= nil and icon ~= "") and "           " or ""
  if TurtleRP.shaguEnabled then
    guildExtraSpaces        = (icon ~= nil and icon ~= "") and "               " or ""
  end
  local blankLine           = " "
  local statusText          = TurtleRP.getStatusText(currently_ic, ICOn, ICOff, whiteColor)
  local level               = queriedLevel == -1 and "??" or queriedLevel
  local levelAndStatusText  = "Level " .. level .. statusText
  local raceAndClassText    = whiteColor .. race .. " " .. thisClassColor .. class
  local ICandPronounsText   = "IC Info" .. TurtleRP.getPronounsText(ic_pronouns, pronounColor)
  local OOCandPronounsText  = "OOC Info" .. TurtleRP.getPronounsText(ooc_pronouns, pronounColor)

  -- Modify tooltip
  local l = 1
  if getglobal("GameTooltipTextLeft1"):GetText() == nil then
    TurtleRP.gameTooltip:AddLine(thisClassColor .. titleExtraSpaces .. fullName)
  end
  if TurtleRPSettings["name_size"] == "1" then
    getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 18)
  else
    getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 15)
  end
  getglobal("GameTooltipTextLeft"..l):SetText(thisClassColor .. titleExtraSpaces .. fullName)

  l = l + 1
  if guildName then
    getglobal("GameTooltipTextLeft"..l):SetText(guildColor .. guildExtraSpaces .. "<" .. guildRank .. " of " .. guildName .. ">")
    l = l + 1
  else
    getglobal("GameTooltipTextLeft"..l):SetText(blankLine)
    if guildExtraSpaces ~= "" then -- if there is an icon, but no guild, add another line
      l = l + 1
      TurtleRP.gameTooltip:AddLine(blankLine)
    end
  end

  if getglobal("GameTooltipTextLeft3"):GetText() == nil then
    TurtleRP.gameTooltip:AddLine(blankLine)
  else
    if guildName ~= nil then
      if string.find(getglobal("GameTooltipTextLeft3"):GetText(), guildName) then
        getglobal("GameTooltipTextLeft3"):SetText("")
      end
    end
  end

  l = l + 1
  if getglobal("GameTooltipTextLeft"..l):GetText() == nil then
    TurtleRP.gameTooltip:AddDoubleLine(raceAndClassText, levelAndStatusText)
  else
    getglobal("GameTooltipTextLeft"..l):SetText(raceAndClassText)
    getglobal("GameTooltipTextRight"..l):Show()
    getglobal("GameTooltipTextRight"..l):SetText(levelAndStatusText)
  end

  -- Stuff only available for TTRP folks
  if locallyRetrievable then

    l = TurtleRP.printICandOOC(ic_info, ICandPronounsText, blankLine, l)
    l = TurtleRP.printICandOOC(ooc_info, OOCandPronounsText, blankLine, l)

    if icon ~= nil and icon ~= "" then
      TurtleRP_Tooltip_Icon:SetPoint("TOPLEFT", GameTooltipTextLeft1, "TOPLEFT")
      TurtleRP_Tooltip_Icon:SetFrameStrata("tooltip")
      TurtleRP_Tooltip_Icon:SetFrameLevel(99)
      TurtleRP_Tooltip_Icon_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon)])
      TurtleRP_Tooltip_Icon:Show()

      -- getglobal("GameTooltipTextLeft1"):SetPoint("TOPLEFT", GameTooltip, "TOPLEFT", 50, -5)
      -- getglobal("GameTooltipTextLeft2"):SetPoint("TOPLEFT", GameTooltipTextLeft1, "BOTTOMLEFT", 0, -5)
      -- getglobal("GameTooltipTextLeft3"):SetPoint("TOPLEFT", GameTooltipTextLeft2, "BOTTOMLEFT", -40, -10)

    else
      TurtleRP_Tooltip_Icon:Hide()
    end

  end

  -- Resizes tooltip to fit
  TurtleRP.gameTooltip:Show()

end
