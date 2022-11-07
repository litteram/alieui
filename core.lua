local A, ns = ...
ns.db = {}
ns.L = {}
local L = ns.L

local shadowTex = "Interface\\AddOns\\".. A .."\\media\\shadow_border"

function L.copyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[L.copyTable(orig_key)] = L.copyTable(orig_value)
        end
        setmetatable(copy, L.copyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function L:RegisterCallback(event, callback, ...)
    if callback == nil then print("callback for "..event.." is nil!") end
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        function self.eventFrame:OnEvent(event, ...)
            for callback, args in next, self.callbacks[event] do
                callback(args, event, ...)
            end
        end
        self.eventFrame:SetScript("OnEvent", self.eventFrame.OnEvent)
    end
    if not self.eventFrame.callbacks then self.eventFrame.callbacks = {} end
    if not self.eventFrame.callbacks[event] then self.eventFrame.callbacks[event] = {} end

    self.eventFrame.callbacks[event][callback] = {...}
    self.eventFrame:RegisterEvent(event)
end

function L:CallElementFunction(element, func, ...)
    if element and func and element[func] then
        element[func](element, ...)
    end
end


function L:ShadowedBorder(anchor)
  local frame = anchor.GetTexture and anchor:GetParent() or anchor

  local BACKDROP_OFFSET = 3
  local BACKDROP_INSET  = 2

  local backdrop = CreateFrame('Frame', nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  backdrop:SetFrameStrata('BACKGROUND')
  backdrop:SetFrameLevel(0)
  backdrop:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -BACKDROP_OFFSET, BACKDROP_OFFSET)
  backdrop:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', BACKDROP_OFFSET, -BACKDROP_OFFSET)
  backdrop:SetBackdrop({
      bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
      insets = {left = BACKDROP_INSET, right = BACKDROP_INSET, top = BACKDROP_INSET, bottom = BACKDROP_INSET}
  })
  backdrop:SetBackdropColor(0, 0, 0, 0.6)
  anchor.shadowedBackdrop = backdrop

  local SHADOW_OFFSET   = 5
  local SHADOW_EDGESIZE = 5

  local shadow = CreateFrame('Frame', nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  shadow:SetFrameStrata('BACKGROUND')
  shadow:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -SHADOW_OFFSET, SHADOW_OFFSET)
  shadow:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', SHADOW_OFFSET, -SHADOW_OFFSET)
  shadow:SetBackdrop({
      edgeFile = shadowTex, edgeSize = SHADOW_EDGESIZE,
  })
  shadow:SetBackdropBorderColor(0, 0, 0, 0.6)
  anchor.shadowedShadow = shadow

end

function L:RegisterAlphaAnimation(frame)
  frame.alphaAnimation = frame:CreateAnimationGroup()
  frame.alphaAnimation.alpha = frame.alphaAnimation:CreateAnimation("Alpha")
  frame.alphaAnimation.alpha:SetDuration(0.2)
  frame.alphaAnimation.alpha:SetSmoothing("OUT")
  function frame:PlayAlpha(toAlpha, startDelay)
    local delay = startDelay or 0.0
    local enableMouse = toAlpha ~= 0 and true or false

    if self.EnableMouse and not InCombatLockdown() then
      self:EnableMouse(enableMouse)
    end
    self.alphaAnimation.alpha:SetStartDelay(delay)
    self.alphaAnimation.alpha:SetFromAlpha(self:GetAlpha())
    self.alphaAnimation.alpha:SetToAlpha(toAlpha)
    self.alphaAnimation:SetToFinalAlpha(toAlpha)
    self.alphaAnimation:Play()
  end
  function frame:PlayReveal()
    self:PlayAlpha(1, 0.0)
  end
  function frame:PlayHide()
    self:PlayAlpha(0, 0.5)
  end
end

function L:PlayerIsTank()
  local assignedRole = UnitGroupRolesAssigned("player")
  if (assignedRole == "NONE") then
    local spec = GetSpecialization()
    return spec and GetSpecializationRole(spec) == "TANK"
  end

  return assignedRole == "TANK"
end

function L:CommaValue(number)  -- credit http://richard.warburton.it
  if not number then return end

  local left ,num, right = string.match(number,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function deepExists(t, ...)
  for _, k in ipairs{...} do
    t = t[k]
    if t == nil then
      return nil
    end
  end
  return t
end


SLASH_RELOADUI1 = '/rl'
SlashCmdList.RELOADUI = ReloadUI
