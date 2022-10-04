--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

StaticPopupDialogs["CONFIRM_QUOTATION"] = {
  text = TEXT('You typed an emote with a unclosed quotation ("). This could result in the chat being formatted wrong.');
  button1 = TEXT("Send"),
  button2 = TEXT("Don't Send"),
  OnShow = function()
    TurtleRP.errorOpen = true
    TurtleRP.sendWithError = nil
  end,
  OnHide = function()
    TurtleRP.errorOpen = nil
  end,
  OnAccept = function()
    TurtleRP.sendWithError = true
    if TurtleRP.sendingLongForm then
      TurtleRP.SendLongFormMessage("EMOTE", TurtleRP.errorMessage)
    else
      ChatThrottleLib:SendChatMessage("NORMAL", "TTRP", TurtleRP.errorMessage, "EMOTE")
    end
  end,
  timeout = 0,
  whileDead = 0,
  interruptCinematic = 1,
  notClosableByLogout = 0
};

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
        if TurtleRP.sendingLongForm == nil and TurtleRP.sendWithError == nil then
          if string.find(arg1, '"') then
            local splitArrayQuotes = string.split(arg1, '"')
            local numberOfQuotes = getn(splitArrayQuotes) + 1
            if (numberOfQuotes - math.floor(numberOfQuotes/2)*2) ~= 0 then -- an odd number of quotes!
              TurtleRP.errorMessage = arg1
              StaticPopup_Show("CONFIRM_QUOTATION");
              return
            end
          end
        end
        TurtleRP.sendWithError = nil -- it's already made it through the check, so reset errors
        TurtleRP.errorMessage = nil
        if TurtleRP.errorOpen == nil or TurtleRP.sendingLongForm == true then
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
    end
    oldChatFrame_OnEvent(savedEvent)
  end

end

function TurtleRP.SendLongFormMessage(type, message)
  local splitMessage = string.split(message, " ")
  local currentCharCount = 0
  local currentMessageString = ""
  local emotePrefix = ""
  if type == "Emote" then
    TurtleRP.sendingLongForm = true
    if TurtleRP.sendWithError == nil then
      if string.find(message, '"') then
        local splitArrayQuotes = string.split(message, '"')
        local numberOfQuotes = getn(splitArrayQuotes) + 1
        if (numberOfQuotes - math.floor(numberOfQuotes/2)*2) ~= 0 then -- an odd number of quotes!
          TurtleRP.errorMessage = message
          StaticPopup_Show("CONFIRM_QUOTATION");
          return
        end
      end
    end
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
  TurtleRP_ChatBox_TextScrollBox_TextInput:SetText("")
  TurtleRP.sendingLongForm = nil
end
