local A, ns = ...
local L = ns.L


local function init()
    if ns.db.fade_bags then
        L:CreateFrameFader(MicroButtonAndBagsBar)
    end

    if ns.db.fade_experience_bar then
        L:CreateFrameFader(StatusTrackingBarManager)
    end

    if ns.db.fade_objective_tracker then
        L:CreateFrameFader()
    end

end
L:RegisterCallback('PLAYER_ENTERING_WORLD', init)
