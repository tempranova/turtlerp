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
  GameTooltip:SetScript("OnShow", function()
    if UnitIsPlayer("mouseover") then
      TurtleRP.buildTooltip(UnitName("mouseover"), "mouseover")
    end
  end)
  GameTooltip:SetScript("OnHide", function()
    TurtleRP_Tooltip_Icon:Hide()
    if TurtleRPStatusBarFrame ~= nil then
      TurtleRPStatusBarFrame:Hide()
    end
    getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 15)
  end)
end

function TurtleRP.getStatusText(currently_ic, ICOn, ICOff, whiteColor)
  local statusText = ""
  if currently_ic ~= nil then
    if currently_ic == 'on' then
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
      GameTooltip:AddLine(blankLine)
    else
      getglobal("GameTooltipTextLeft"..n):SetText(blankLine)
    end

    n = n + 1
    if getglobal("GameTooltipTextLeft"..n):GetText() == nil then
      GameTooltip:AddLine(headerText, 1, 0.6, 0, true)
    else
      getglobal("GameTooltipTextLeft"..n):SetText(headerText)
    end

    n = n + 1
    if getglobal("GameTooltipTextLeft"..n):GetText() == nil then
      GameTooltip:AddLine(info, 0.8, 0.8, 0.8, true)
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

  -- Getting details for character
  local fullName        = locallyRetrievable and TurtleRP.getFullName(characterInfo['title'], characterInfo['first_name'], characterInfo['last_name']) or UnitName(targetType)
  local race            = UnitRace(targetType)
  local class           = UnitClass(targetType)
  local guildName       = GetGuildInfo(targetType)
  local level           = UnitLevel(targetType)
  local icon            = locallyRetrievable and characterInfo['icon'] or nil
  local currently_ic    = locallyRetrievable and characterInfo['currently_ic'] or nil
  local ic_info         = locallyRetrievable and characterInfo['ic_info'] or nil
  local ic_pronouns     = locallyRetrievable and characterInfo['ic_pronouns'] or nil
  local ooc_info        = locallyRetrievable and characterInfo['ooc_info'] or nil
  local ooc_pronouns    = locallyRetrievable and characterInfo['ooc_pronouns'] or nil

  -- Color variables
  local colorPrefix       = "|cff"
  local thisClassColor    = colorPrefix .. TurtleRPClassData[class][4] -- Hex code
  local guildColor        = colorPrefix .. "FFD700"
  local whiteColor        = colorPrefix .. "FFFFFF"
  local ICOn              = colorPrefix .. "40AF6F"
  local ICOff             = colorPrefix .. "D3681E"
  local pronounColor      = colorPrefix .. "ffcc80"

  -- Formatting variables
  local titleExtraSpaces    = (icon ~= nil and icon ~= "") and "         " or ""
  local guildExtraSpaces    = (icon ~= nil and icon ~= "") and "           " or ""
  local blankLine           = " "
  local statusText          = TurtleRP.getStatusText(currently_ic, ICOn, ICOff, whiteColor)
  local levelAndStatusText  = "Level " .. level .. statusText
  local raceAndClassText    = race .. " " .. thisClassColor .. class
  local ICandPronounsText   = "IC Info" .. TurtleRP.getPronounsText(ic_pronouns, pronounColor)
  local OOCandPronounsText  = "OOC Info" .. TurtleRP.getPronounsText(ooc_pronouns, pronounColor)

  -- Modify tooltip
  local l = 1
  getglobal("GameTooltipTextLeft1"):SetFont("Fonts\\FRIZQT__.ttf", 18)
  getglobal("GameTooltipTextLeft"..l):SetText(thisClassColor .. titleExtraSpaces .. fullName)

  l = l + 1
  if guildName then
    getglobal("GameTooltipTextLeft"..l):SetText(guildColor .. guildExtraSpaces .. "<" .. guildName .. ">")
    l = l + 1
  else
    getglobal("GameTooltipTextLeft"..l):SetText(blankLine)
    if guildExtraSpaces ~= "" then -- if there is an icon, but no guild, add another line
      l = l + 1
      GameTooltip:AddLine(blankLine)
    end
  end

  if getglobal("GameTooltipTextLeft3"):GetText() == nil then
    GameTooltip:AddLine(blankLine)
  end

  l = l + 1
  if getglobal("GameTooltipTextLeft"..l):GetText() == nil then
    GameTooltip:AddDoubleLine(raceAndClassText, levelAndStatusText)
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
      TurtleRP_Tooltip_Icon:SetPoint("TOPLEFT", "GameTooltipTextLeft1", "TOPLEFT")
      TurtleRP_Tooltip_Icon:SetFrameStrata("tooltip")
      TurtleRP_Tooltip_Icon:SetFrameLevel(99)
      TurtleRP_Tooltip_Icon_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon)])
      TurtleRP_Tooltip_Icon:Show()
    else
      TurtleRP_Tooltip_Icon:Hide()
    end

  end

  -- Resizes tooltip to fit
  GameTooltip:Show()

end
