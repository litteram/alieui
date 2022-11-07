local A, ns = ...
local db = ns.db

db.fade_actionbars = false
db.fade_bags = true
db.fade_experience_bar = true

local sizes = {
  large  = { width = 155, height = 26, power = 4, },
  medium = { width = 135, height = 12, power = 3, },
  small  = { width = 56,  height = 7, },
  mini   = { width = 40,  height = 12, },
}

db.unitframes = {
  hidePlayerFrameOoc = false,
  emulatePersonalResourceDisplay = false,
  outofcombat_alpha = 0.1,

  texture = "Interface\\AddOns\\".. A .."\\media\\bar",
  classIconSpacing = 4,

  enabled = {
    arena        = true,
    focus        = true,
    focustarget  = true,
    maintank     = true,
    party        = false,
    pet          = true,
    player       = true,
    raid         = false,
    target       = true,
    targettarget = true,
  },

  sizes = {
    player       = sizes.large,
    target       = sizes.large,
    targettarget = sizes.medium,
    pet          = sizes.mini,
    focus        = sizes.medium,
    focustarget  = sizes.mini,
    party        = sizes.mini,
    maintank     = sizes.medium,
  },
  -- Positions
  positions  = {
    player       = { "RIGHT", UIParent, "CENTER", -250, -160},
    target       = { "LEFT", UIParent, "CENTER", 250, -160},
    targettarget = { "TOPLEFT", "oUF_aLieTarget", "TOPRIGHT", 7, 0 },
    focus        = { "TOPLEFT", "oUF_aLiePlayer", "TOPRIGHT", 56, -100 },
    focustarget  = { "TOPLEFT", "oUF_aLieFocus", "TOPRIGHT", 7, 0 },
    pet          = { "TOPLEFT", "oUF_aLiePlayer", "TOPRIGHT", 5, 0 },
    party        = { "BOTTOMRIGHT", "oUF_aLiePlayer", "TOPLEFT", -350, 150 },
    maintank     = { "BOTTOMRIGHT", "oUF_aLiePlayer", "TOPLEFT", -350, 150 },
  },
  buffs = {
    -- Unholy DK
    ["Sudden Doom"] = true,
    ["Dark Succor"] = true,

    -- Arms Warrior
    ["Victorious"] = true,
    ["Sharpen Blade"] = true,
    ["Crushing Assault"] = true,

    -- Fury Warrior
    ["Enraged Regeneration"] = true,
    ["Whirlwind"] = true,
    ["Barbarian"] = true,
    ["Battle Trance"] = true,

    -- Arcane Mage
    ["Clearcasting"] = true,
    ["Rule of Threes"] = true,
    ["Displacement Beacon"] = true,
    ["Presence of Mind"] = true,

    -- Fire Mage
    ["Heating Up"] = true,
    ["Hot Streak!"] = true
  },
  debuffs = {
    ["Forberance"] = true,
  },
  auras = {
    player   = { "buff", 24 },
    target   = { "debuff", 18 },
    pet      = { "aura", 16 },
    focus    = { "aura", 16 },
    arena    = { "debuff", 30 },
    maintank = { "debuff", 30 },
  }
}
