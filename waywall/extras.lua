local waywall = require("waywall")
local helpers = require("waywall.helpers")
return function(config)
-- Add any extra code here
local binds = {
    decrement = "*-leftarrow", -- [
    increment = "*-rightarrow", -- ]
    undo = "*-end", -- ;
    redo = "*-page_down", -- '
    reset = "*-page_up", -- \
}

for action, bind in pairs(binds) do
    config.actions[bind] = function()
        waywall.exec("ninjabrain-bot-xwayland " .. action)
    end
end

    -- END
end
