local cfg = {
    fast_reset = "T",
    main_reset = "P",
    thin_res = { w = 340, h = 1080 }
}

return {
    url = "https://github.com/arjuncgore/ww_rsg_utils",
    config = function(config)
        require("rsg_utils.init").setup(config, cfg)
    end,
    name = "rsg_utils",
    update_on_load = true,
}
