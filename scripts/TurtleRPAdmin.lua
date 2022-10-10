--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

-----
-- Interface helpers
-----

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

  TurtleRP_AdminSB_Tab5:SetNormalTexture("Interface\\Icons\\Trade_Engineering")
  TurtleRP_AdminSB_Tab5.tooltip = "Settings"
  TurtleRP_AdminSB_Tab5:Show()

  TurtleRP_AdminSB_Tab6:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
  TurtleRP_AdminSB_Tab6.tooltip = "About / Help"
  TurtleRP_AdminSB_Tab6:Show()

  TurtleRP_AdminSB_Content1_Tab2:Hide()

  TurtleRP_AdminSB_SpellBookFrameTabButton1:SetText("Basic Info")
  TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
  TurtleRP_AdminSB_SpellBookFrameTabButton1.bookType = "profile"
  TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
  TurtleRP_AdminSB_SpellBookFrameTabButton2:SetText("RP Style")
  TurtleRP_AdminSB_SpellBookFrameTabButton2.bookType = "rp_style"

  TurtleRP.OnAdminTabClick(1)

end

function TurtleRP.OnAdminTabClick(id)
  for i=1, 6 do
    if i ~= id then
      getglobal("TurtleRP_AdminSB_Tab"..i):SetChecked(0)
      getglobal("TurtleRP_AdminSB_Content"..i):Hide()
    else
      getglobal("TurtleRP_AdminSB_Tab"..i):SetChecked(1)
      getglobal("TurtleRP_AdminSB_Content"..i):Show()
    end
  end
  if id == 1 then
    TurtleRP_AdminSB_SpellBookFrameTabButton1:Show()
    TurtleRP_AdminSB_SpellBookFrameTabButton2:Show()
  else
    TurtleRP_AdminSB_SpellBookFrameTabButton1:Hide()
    TurtleRP_AdminSB_SpellBookFrameTabButton2:Hide()
  end
end

function TurtleRP.OnBottomTabAdminClick(bookType)
  if bookType == "profile" then
    TurtleRP_AdminSB_Content1:Show()
    TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
    TurtleRP_AdminSB_Content1_Tab2:Hide()
    TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\SpellBook\\UI-SpellBook-Tab-Unselected")
  end

  if bookType == "rp_style" then
    TurtleRP_AdminSB_Content1:Hide()
    TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\SpellBook\\UI-SpellBook-Tab-Unselected")
    TurtleRP_AdminSB_Content1_Tab2:Show()
    TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
    TurtleRP.SetInitialDropdowns()
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
-- Dropdown RP Style selectors
-----
function TurtleRP.InitializeRPStyleDropdown(frame, items)
  UIDropDownMenu_Initialize(frame, function()
    local frameName = frame:GetName()
    for i, v in items do
      local info = {}
      info.text = v
      info.value = i
      info.arg1 = v
      info.checked = false
      info.menuList = i
      info.hasArrow = false
      info.func = function(text)
        getglobal(frameName .. "_Text"):SetText(text)
        UIDropDownMenu_SetSelectedName(frame, text)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info)
    end
  end)
end

function TurtleRP.SetInitialDropdowns()
  local dropdownsToSet = {}
  dropdownsToSet["experience"] = TurtleRP_AdminSB_Content1_Tab2_ExperienceDropdown
  dropdownsToSet["walkups"] = TurtleRP_AdminSB_Content1_Tab2_WalkupsDropdown
  dropdownsToSet["injury"] = TurtleRP_AdminSB_Content1_Tab2_InjuryDropdown
  dropdownsToSet["romance"] = TurtleRP_AdminSB_Content1_Tab2_RomanceDropdown
  dropdownsToSet["death"] = TurtleRP_AdminSB_Content1_Tab2_DeathDropdown

  for i, v in dropdownsToSet do
    if TurtleRPCharacters[UnitName("player")][i] ~= "0" then
      local thisValue = TurtleRPCharacters[UnitName("player")][i]
      getglobal(v:GetName() .. "_Text"):SetText(TurtleRPDropdownOptions[i][thisValue])
      UIDropDownMenu_SetSelectedID(v, thisValue)
    end
  end
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
