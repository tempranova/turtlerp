--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp

-- Communication system
--- Notes :
--- ALL information send via the chat channel is stored by ALL players;
---  every player updates their unique key anytime a new message is sent out

-- Request types
M Mouseover
T Target
D Description

-- Data responses
MR
TR
DR

-- Player1 sends out a request for information.
  - If they have no key for that player: "<request type>:<Player2>~NO_KEY"
  - If they have a key for that player: "<request type>:<Player2>~<unique key>"
  - In the meantime, Player1 displays whatever they have stored locally
-- Player2 is listening, recieves the request
  - If the key matches their local key, they send nothing back
  - If the key doesn't match, they send a response: "<data type>:<Player2>~<unique key>~<DATA>"

]]

----
-- Player communication
----

local lastRequestType = nil
local lastPlayerName = nil
local timeOfLastSend = time()

-- This function often runs too early
function TurtleRP.communication_prep()
  if UnitLevel("player") > 4 then
    TurtleRP.ttrpChatSend("A")
  end

  local TurtleRPChannelJoinDelay = CreateFrame("Frame")
  TurtleRPChannelJoinDelay:Hide()
  TurtleRPChannelJoinDelay:SetScript("OnShow", function()
      this.startTime = GetTime()
  end)
  TurtleRPChannelJoinDelay:SetScript("OnHide", function()
      TurtleRP.checkTTRPChannel()
  end)
  TurtleRPChannelJoinDelay:SetScript("OnUpdate", function()
    local plus = 15 --seconds
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then
        TurtleRPChannelJoinDelay:Hide()
    end
  end)
  TurtleRPChannelJoinDelay:Show()
end

function TurtleRP.send_ping_message()
  if UnitLevel("player") > 4 then
    TurtleRP.ttrpChatSend("P")
  end

  local TurtleRPChannelPingDelay = CreateFrame("Frame")
  TurtleRPChannelPingDelay:Hide()
  TurtleRPChannelPingDelay:SetScript("OnShow", function()
      this.startTime = GetTime()
  end)
  TurtleRPChannelPingDelay:SetScript("OnHide", function()
      TurtleRPChannelPingDelay:Show()
  end)
  TurtleRPChannelPingDelay:SetScript("OnUpdate", function()
    local plus = TurtleRP.timeBetweenPings --seconds
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then
      if TurtleRP.disableMessageSending == nil then
        if UnitLevel("player") > 4 then
          TurtleRP.ttrpChatSend("P")
        end
      end
      TurtleRPChannelPingDelay:Hide()
    end
  end)
  TurtleRPChannelPingDelay:Show()
end


function TurtleRP.checkTTRPChannel()
  local lastVal = 0
  local chanList = { GetChannelList() }
  for _, value in next, chanList do
      if value == TurtleRP.channelName then
          TurtleRP.channelIndex = lastVal
          break
      end
      lastVal = value
  end
  if TurtleRP.channelIndex == 0 then
    JoinChannelByName(TurtleRP.channelName)
    if UnitLevel("player") > 4 then
      TurtleRP.ttrpChatSend("A")
    end
  else
    if UnitLevel("player") > 4 then
      TurtleRP.ttrpChatSend("A")
    end
  end
end

function TurtleRP.communication_events()

  TurtleRP_Target_DescriptionButton:SetScript("OnClick", function()
    if UnitName("target") == UnitName("player") then
      TurtleRP.buildDescription(UnitName("player"))
    else
      TurtleRP.sendRequestForData("D", UnitName("target"))
    end
    TurtleRP_Description:Show()
  end)

  local CheckMessages = CreateFrame("Frame")
  CheckMessages:RegisterEvent("CHAT_MSG_CHANNEL")
  CheckMessages:SetScript("OnEvent", function()
    if event == "CHAT_MSG_CHANNEL" then
      if arg9 == TurtleRP.channelName then
        TurtleRP.checkChatMessage(arg1, arg2)
      end
    end
  end)

end

function TurtleRP.sendRequestForData(requestType, playerName)
  if timeOfLastSend < (time() - 2) or lastRequestType ~= requestType then
    timeOfLastSend = time()
    lastRequestType = requestType
    lastPlayerName = playerName
    if TurtleRPQueryablePlayers[playerName] ~= nil or TurtleRPCharacters[playerName] ~= nil then
      if TurtleRPCharacters[playerName] ~= nil and TurtleRPCharacters[playerName]['key' .. requestType] ~= nil then
        local currentKey = TurtleRPCharacters[playerName]['key' .. requestType]
        TurtleRP.ttrpChatSend(requestType .. ':' .. playerName .. '~' .. currentKey)
        TurtleRP.displayData(requestType, playerName)
      else
        TurtleRP.ttrpChatSend(requestType .. ':' .. playerName .. '~NO_KEY')
      end
    end
  end
end

function TurtleRP.checkChatMessage(msg, playerName)
  -- If it's requesting data from me
  if msg == "A" then
    TurtleRPQueryablePlayers[playerName] = time()
  end
  if msg == "P" then
    TurtleRPQueryablePlayers[playerName] = time()
  end
  if string.find(msg, ':') then
    local colonStart, colonEnd = string.find(msg, ':')
    local dataPrefix = string.sub(msg, 1, colonEnd - 1)
    local tildeStart, tildeEnd = string.find(msg, '~')
    if tildeStart then
      local playerName = string.sub(msg, colonEnd + 1, tildeEnd - 1)
      if playerName == UnitName("player") then
        if TurtleRP.checkUniqueKey(dataPrefix, msg) ~= true then
          TurtleRP.sendData(dataPrefix)
        end
      else
        TurtleRP.recieveAndStoreData(dataPrefix, playerName, msg)
      end
    end
  else
end
end

function TurtleRP.checkUniqueKey(dataPrefix, msg)
  local keyValid = false
  local dataFromString = TurtleRP.getDataFromString(msg)
  local keyData = dataFromString[2]
  if keyData ~= "NO_KEY" then
    if keyData == TurtleRPCharacterInfo["key" .. dataPrefix] then
      keyValid = true
    end
  end
  return keyValid
end

function TurtleRP.getDataFromString(msg)
  local beginningOfData = strfind(msg, "~")
  local dataSlice = strsub(arg1, beginningOfData)
  local splitArray = string.split(dataSlice, "~")
  return splitArray
end

function sendChunks(dataPrefix, stringChunks)
  local totalToSend = table.getn(stringChunks)
  for i in stringChunks do
    TurtleRP.ttrpChatSend(dataPrefix .. 'R:' .. UnitName("player") .. "~" .. TurtleRPCharacterInfo["key" .. dataPrefix] .. '~' .. i .. '~' .. totalToSend .. '~' .. stringChunks[i])
  end
end

function TurtleRP.sendData(dataPrefix)
  local stringChunks = TurtleRP.splitByChunk(TurtleRP.buildDataStringToSend(dataPrefix), 230)
  if dataPrefix == "M" or dataPrefix == "T" or dataPrefix == "D" then
    sendChunks(dataPrefix, stringChunks)
  end
end

function TurtleRP.buildDataStringToSend(dataPrefix)
  local dataToBuild = TurtleRP.dataKeys(dataPrefix)
  local stringToSend = ""
  for i, dataRef in ipairs(dataToBuild) do
    if i ~= 1 then -- don't send key again
      local thisData = TurtleRPCharacterInfo[dataRef]
      if dataRef == 'description' then
        thisData = gsub(TurtleRPCharacterInfo["description"], "%\n", "@N")
        if thisData == "" then
          thisData = " "
        end
      end
      local frontDelimiter = i == 2 and "" or "~"
      stringToSend = stringToSend .. frontDelimiter .. thisData
    end
  end
  return stringToSend
end

function TurtleRP.dataKeys(dataPrefix)
  local dataKeys = {}
  if dataPrefix == "M" or dataPrefix == "MR" then
    dataKeys = { "keyM", "icon", "full_name", "race", "class", "class_color", "ooc_info", "ic_info", "currently_ic", "ooc_pronouns", "ic_pronouns" }
  end
  if dataPrefix == "T" or dataPrefix == "TR" then
    dataKeys = { "keyT", "atAGlance1", "atAGlance1Title", "atAGlance1Icon", "atAGlance2", "atAGlance2Title", "atAGlance2Icon", "atAGlance3", "atAGlance3Title", "atAGlance3Icon" }
  end
  if dataPrefix == "D" or dataPrefix == "DR" then
    dataKeys = { "keyD", "description" }
  end
  return dataKeys
end

function TurtleRP.storeChunkedData(dataPrefix, playerName, stringData)
  local readyToProcess = false
  if stringData[3] == "1" then -- if this is the first message
    TurtleRPCharacters[playerName]["temp" .. dataPrefix] = ""
  end
  if stringData[3] == stringData[4] then -- if this is the last message
    readyToProcess = true
  end
  -- Process into temp holder
  local totalReceived = table.getn(stringData)
  local justDataString = ""
  if TurtleRPCharacters[playerName]["temp" .. dataPrefix] == "" then
    justDataString = stringData[2] .. "~" -- adding key back
  end
  for i=5, totalReceived do
    justDataString = justDataString .. stringData[i] .. (i == totalReceived and "" or "~")
  end
  TurtleRPCharacters[playerName]["temp" .. dataPrefix] = TurtleRPCharacters[playerName]["temp" .. dataPrefix] .. justDataString

  return readyToProcess
end

function processAndStoreData(dataPrefix, playerName)
  local splitString = string.split(TurtleRPCharacters[playerName]["temp" .. dataPrefix], "~")
  local dataToSave = TurtleRP.dataKeys(dataPrefix)
  for i, dataRef in ipairs(dataToSave) do
    if splitString[i] ~= nil then
      TurtleRPCharacters[playerName][dataRef] = splitString[i]
    else
      TurtleRPCharacters[playerName][dataRef] = ""
    end
  end
end

function TurtleRP.recieveAndStoreData(dataPrefix, playerName, msg)
  local stringData = TurtleRP.getDataFromString(msg) -- 1 is username, 2 is key, 3 is i, 4 is total
  if TurtleRPCharacters[playerName] == nil then
    TurtleRPCharacters[playerName] = {}
  end
  if dataPrefix == "MR" then
    local readyToProcess = TurtleRP.storeChunkedData(dataPrefix, playerName, stringData)
    if readyToProcess then
      processAndStoreData(dataPrefix, playerName)
      TurtleRP.displayData(dataPrefix, playerName)
      if playerName == UnitName("target") or playerName == UnitName("mouseover") then
        TurtleRP.SetNameFrameWidths(playerName)
      end
    end
  end
  if dataPrefix == "TR" then
    local readyToProcess = TurtleRP.storeChunkedData(dataPrefix, playerName, stringData)
    if readyToProcess then
      processAndStoreData(dataPrefix, playerName)
      TurtleRP.displayData(dataPrefix, playerName)
    end
  end
  if dataPrefix == "DR" then
    local readyToProcess = TurtleRP.storeChunkedData(dataPrefix, playerName, stringData)
    if readyToProcess then
      processAndStoreData(dataPrefix, playerName)
      TurtleRP.displayData(dataPrefix, playerName)
    end
  end
end

function TurtleRP.displayData(dataPrefix, playerName)
  if playerName == UnitName("mouseover") and (dataPrefix == "M" or dataPrefix == "MR") then
    TurtleRP.buildTooltip(playerName, "mouseover")
  end
  if playerName == UnitName("target") and (dataPrefix == "T" or dataPrefix == "TR") then
    TurtleRP.buildTargetFrame(playerName)
  end
  if playerName == UnitName("target") and (dataPrefix == "D" or dataPrefix == "DR") then
    TurtleRP.buildDescription(playerName)
  end
  -- Directory exceptions
  if playerName == TurtleRP.showTooltip and (dataPrefix == "M" or dataPrefix == "MR") then
    TurtleRP.buildTooltip(playerName, nil) -- Missing some data
  end
  if playerName == TurtleRP.showTarget and (dataPrefix == "T" or dataPrefix == "TR") then
    TurtleRP.buildTargetFrame(playerName)
    TurtleRP.showTarget = nil
  end
  if playerName == TurtleRP.showDescription and (dataPrefix == "D" or dataPrefix == "DR") then
    TurtleRP.buildDescription(playerName)
    TurtleRP_Target:Hide()
    TurtleRP_Description:Show()
    TurtleRP.showDescription = nil
  end
end

function TurtleRP.SendLongFormMessage(type, message)
  local splitMessage = string.split(message, " ")
  local currentCharCount = 0
  local currentMessageString = ""
  local emotePrefix = ""
  if type == "Emote" then
    emotePrefix = "|| "
  end
  for i, v in splitMessage do
    local stringLength = strlen(v)
    local sendMessage = false
    currentCharCount = currentCharCount + stringLength
    if splitMessage[i + 1] then
      if (strlen(splitMessage[i + 1]) + currentCharCount) > 200 then
        sendMessage = true
      end
    else
      sendMessage = true
    end
    local extraSpace = currentMessageString == "" and (emotePrefix .. "") or " "
    currentMessageString = currentMessageString .. extraSpace .. v
    if sendMessage then
      ChatThrottleLib:SendChatMessage("NORMAL", "TTRP", currentMessageString, type)
      currentMessageString = ""
      currentCharCount = 0
    end
  end
end

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

function TurtleRP.ttrpChatSend(message)
  ChatThrottleLib:SendChatMessage("NORMAL", TurtleRP.channelName, message, "CHANNEL", nil, GetChannelName(TurtleRP.channelName))
end
