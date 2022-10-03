--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

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
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i));
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i .. "Tab"));
		TurtleRP.BindFrameToUIParent(getglobal("ChatFrame" .. i .. "TabDockRegion"));
	end
	TurtleRP.RPMode = 0;
	UIParent:Show();
end
