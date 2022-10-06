--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

function TurtleRP.OpenDirectory()
  UIPanelWindows["TurtleRP_DirectoryFrame"] = { area = "left", pushable = 0 }
  ShowUIPanel(TurtleRP_DirectoryFrame)
  TurtleRP.Directory_ScrollBar_Update()
end

----
-- Map Directory Display
----
function TurtleRP.display_nearby_players()
  local onlinePlayers = TurtleRP.get_players_online()
  local createdFrames = 1
  for i, v in onlinePlayers do
    if i ~= UnitName("player") then
      if TurtleRPCharacters[i] and TurtleRPCharacters[i]['zone'] == GetZoneText() then
        if TurtleRPCharacters[i]['zoneX'] and TurtleRPCharacters[i]['zoneY'] then
          if TurtleRPCharacters[i]['zoneX'] ~= "false" and TurtleRPCharacters[i]['zoneY'] ~= "false" then
            local zoneX = tonumber(TurtleRPCharacters[i]['zoneX'])
            local zoneY = tonumber(TurtleRPCharacters[i]['zoneY'])
            local playerPositionFrame = getglobal("TurtleRP_MapPlayerPosition_" .. createdFrames)
            if playerPositionFrame == nil then
              playerPositionFrame = CreateFrame("Button", "TurtleRP_MapPlayerPosition_" .. createdFrames, WorldMapDetailFrame, "TurtleRP_WorldMapUnitTemplate")
              TurtleRP.locationFrames[getn(TurtleRP.locationFrames) + 1] = { playerPositionFrame }
            end
            local mapWidth = WorldMapDetailFrame:GetWidth()
            local mapLeft = WorldMapDetailFrame:GetLeft()
            local mapHeight = WorldMapDetailFrame:GetHeight()
            local mapLeft = WorldMapDetailFrame:GetLeft()
            playerPositionFrame.full_name = TurtleRPCharacters[i]['full_name']
            playerPositionFrame:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", zoneX * mapWidth, zoneY * mapHeight * -1)
            playerPositionFrame:Show()
            createdFrames = createdFrames + 1
          else
            if getglobal("TurtleRP_MapPlayerPosition_" .. createdFrames) then
              getglobal("TurtleRP_MapPlayerPosition_" .. createdFrames):Hide()
            end
            createdFrames = createdFrames + 1
          end
        end
      end
    end
  end
end

----
-- Directory Scroll Manager
----
function TurtleRP.Directory_ScrollBar_Update()
  local totalDirectoryChars = 0
  local totalDirectoryOnline = 0
  for i, v in TurtleRPCharacters do
    if TurtleRPQueryablePlayers[i] then
      totalDirectoryChars = totalDirectoryChars + 1
      if type(TurtleRPQueryablePlayers[i]) == "number" then
        if TurtleRPQueryablePlayers[i] > (time() - 65) then
          totalDirectoryOnline = totalDirectoryOnline + 1
        end
      end
    end
  end
  TurtleRP_DirectoryFrame_Directory_Total:SetText(totalDirectoryChars .. " adventurers found (" .. totalDirectoryOnline .. " online)")

  FauxScrollFrame_Update(TurtleRP_DirectoryFrame_Directory_ScrollFrame, totalDirectoryChars * 1.5, 17, 16)
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_DirectoryFrame_Directory_ScrollFrame)
  TurtleRP.renderDirectory(currentLine)
end

function TurtleRP.renderDirectory(directoryOffset)
  local remadeArray = {}
  local currentArrayNumber = 1
  for i, v in TurtleRPCharacters do
    if TurtleRPCharacters[i] then
      if TurtleRPCharacters[i]['full_name'] == nil then
        TurtleRPCharacters[i]['full_name'] = ""
      end
      local resultShown = true
      if TurtleRP.searchTerm ~= "" then
        if string.find(string.lower(i), string.lower(TurtleRP.searchTerm)) == nil and string.find(string.lower(v['full_name']), string.lower(TurtleRP.searchTerm)) == nil then
          resultShown = false
        end
      end
      if resultShown then
        remadeArray[currentArrayNumber] = v
        remadeArray[currentArrayNumber]['player_name'] = i
        remadeArray[currentArrayNumber]['status'] = "Offline"
        remadeArray[currentArrayNumber]['zone'] = v['zone'] and v['zone'] or ""
        if TurtleRPQueryablePlayers[i] then
          if type(TurtleRPQueryablePlayers[i]) == "number" then
            if TurtleRPQueryablePlayers[i] > (time() - 65) then
              remadeArray[currentArrayNumber]['status'] = "Online"
            end
          end
        end
        currentArrayNumber = currentArrayNumber + 1
      end
    end
  end

  if TurtleRP.sortByKey ~= nil then
    if TurtleRP.sortByOrder == 1 then
      table.sort(remadeArray, function(a, b) return a[TurtleRP.sortByKey] > b[TurtleRP.sortByKey] end)
    else
      table.sort(remadeArray, function(a, b) return a[TurtleRP.sortByKey] < b[TurtleRP.sortByKey] end)
    end
  end

  local currentFrameNumber = 1
  if directoryOffset == 0 then
    directoryOffset = directoryOffset + 1
  end
  for i=directoryOffset, directoryOffset+16 do
    local thisFrameName = "TurtleRP_DirectoryFrame_Directory_Button" .. currentFrameNumber
    getglobal(thisFrameName):Hide()
    if remadeArray[i] then
      local thisCharacter = remadeArray[i]
      getglobal(thisFrameName):Show()
      getglobal(thisFrameName .. "Name"):SetText(thisCharacter['player_name'])
      getglobal(thisFrameName .. 'Variable'):SetText(TurtleRP.secondColumn == "Character Name" and thisCharacter['full_name'] or thisCharacter['zone'])
      getglobal(thisFrameName .. '_StatusOffline'):Show()
      getglobal(thisFrameName .. '_StatusOnline'):Hide()
      if thisCharacter['status'] == "Online" then
        getglobal(thisFrameName .. '_StatusOffline'):Hide()
        getglobal(thisFrameName .. '_StatusOnline'):Show()
      end
    end
    currentFrameNumber = currentFrameNumber + 1
  end
end

function TurtleRP.get_players_online()
  local onlinePlayers = {}
  for i, v in TurtleRPCharacters do
    if TurtleRPQueryablePlayers[i] then
      if type(TurtleRPQueryablePlayers[i]) == "number" then
        if TurtleRPQueryablePlayers[i] > (time() - 65) then
          onlinePlayers[i] = v
        end
      end
    end
  end
  return onlinePlayers
end

function TurtleRP.OpenDirectoryListing(frame)
  TurtleRP_Directory_DetailsFrame:SetPoint("LEFT", frame, "RIGHT", 30, 0)
  TurtleRP_Directory_DetailsFrame:Show()
end

function TurtleRP.Directory_FrameDropDown_Initialize()
  local info;
  local buttonTexts = { "Character Name", "Zone" }
  for i=1, getn(buttonTexts), 1 do
    info = {};
    info.text = buttonTexts[i];
    info.func = TurtleRP.Directory_FrameDropDown_OnClick;
    UIDropDownMenu_AddButton(info);
  end
end

function TurtleRP.Directory_FrameDropDown_OnClick()
  UIDropDownMenu_SetSelectedID(TurtleRP_Directory_FrameDropDown, this:GetID());
  TurtleRP.secondColumn = this:GetText()
  TurtleRP.Directory_ScrollBar_Update(0)
end
