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
-- Directory Manager
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
  TurtleRP_DirectoryFrame_Directory_Total:SetText(totalDirectoryChars .. " profiles (" .. totalDirectoryOnline .. " online)")

  FauxScrollFrame_Update(TurtleRP_DirectoryFrame_Directory_ScrollFrame, totalDirectoryChars, 17, 16)
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_DirectoryFrame_Directory_ScrollFrame)
  TurtleRP.renderDirectory(currentLine)
end

function TurtleRP.renderDirectory(directoryOffset)
  local remadeArray = {}
  local currentArrayNumber = 1
  for i, v in TurtleRPCharacters do
    if TurtleRPCharacters[i] and TurtleRPCharacters[i]['full_name'] ~= nil then
      remadeArray[currentArrayNumber] = v
      remadeArray[currentArrayNumber]['player_name'] = i
      remadeArray[currentArrayNumber]['status'] = "Offline"
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
      getglobal(thisFrameName .. 'Variable'):SetText(thisCharacter['full_name'])
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

function TurtleRP.OpenDirectoryListing(frame)
  TurtleRP_Directory_DetailsFrame:SetPoint("LEFT", frame, "RIGHT", 30, 0)
  TurtleRP_Directory_DetailsFrame:Show()
end
