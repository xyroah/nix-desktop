local cfg = {
    username = "xvpy",
    look = {
        X = 1530,
        Y = 1030,
        color = '#FFFFFF',
        bold = true,
        size = 3
    },

    info = {
        { tag = "Nethers",           enabled = true,  key = "nether" },
        { tag = "Bastions",          enabled = false,  key = "bastion" },
        { tag = "Fortresses",        enabled = false,  key = "fortress" },
        { tag = "First Structures",  enabled = false, key = "first_structure" },
        { tag = "Second Structures", enabled = false, key = "second_structure" },
        { tag = "First Portals",     enabled = false, key = "first_portal" },
        { tag = "Strongholds",       enabled = false, key = "stronghold" },
        { tag = "End Enters",        enabled = false, key = "end" },
        { tag = "Completions",       enabled = false, key = "finish" },
    },

}

return {
    url = "https://github.com/arjuncgore/ww_paceman_overlay",
    config = function(config)
        require("paceman_overlay.init").setup(config, cfg)
    end,
    dependencies = {
        {
            url = "https://github.com/arjuncgore/ww_requests",
            name = "ww_requests",
        }
    },
    name = "paceman_overlay",
    update_on_load = false,
}
