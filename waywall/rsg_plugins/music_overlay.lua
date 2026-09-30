local cfg = {
    overlay = true,
    wall_only = true,
    look = {
        X = 70,
        Y = 900,
        color = '#FFFFFF',
        size = 3,
        max_len = 30,
    },
    previous = "F10",
    play_pause = "F11",
    next = "F12",
}

return {
    url = "https://github.com/arjuncgore/ww_music_overlay",
    config = function(config)
        require("music_overlay.init").setup(config, cfg)
    end,
    name = "music_overlay",
    update_on_load = false,
}
