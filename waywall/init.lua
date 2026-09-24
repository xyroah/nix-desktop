-- ==== CONFIG ====
local xkb_layout = "mc"

local tall_sens = 1
local normal_sens = 25

local keys = {
    thin           = "*-f3",
    wide           = "*-V",
    tall           = "*-Alt_L",

    toggle_ninbot  = "*-control_R",
    fullscreen     = "Shift-O",
    launch_paceman = "Shift-P",

    toggle_rebinds = "F9",
    -- delete_worlds  = "End",

}


-- ==== THEMES ====
THEME = 2

THEMES = {
    {
        description = "Spiderverse",
        colors = {
            border_color  = "#4A5759",
            pie1_color    = "#e41c26",
            pie2_color    = "#008080",
            pie3_color    = "#FFFFFF",
            text_color    = "#FFFFFF",
            text_bg_color = "#000000"
        },
        measuring_overlay = os.getenv("HOME") .. "/.config/waywall/resources/spiderverse/measuring_overlay.png",
        background = os.getenv("HOME") .. "/.config/waywall/resources/spiderverse/background.png",
    },
    {
        description = "Street",
        colors = {
            border_color  = "#4A5759",
            pie1_color    = "#2A383D",
            pie2_color    = "#4A6068",
            pie3_color    = "#7F969F",
            text_color    = "#FFFFFF",
            text_bg_color = "#000000"
        },
        measuring_overlay = os.getenv("HOME") .. "/.config/waywall/resources/street/measuring_overlay.png",
        background = os.getenv("HOME") .. "/.config/waywall/resources/street/background.png",
    },
}

local colors = THEMES[THEME].colors
local overlay_path = THEMES[THEME].measuring_overlay
local background_path = THEMES[THEME].background

-- ==== PATHS ====
local home = os.getenv("HOME") .. "/"
local config_folder = home .. ".config/waywall/"

-- local background_path = config_folder .. "resources/background.png"
local tall_overlay_path = config_folder .. "resources/overlay_tall.png"
local wide_overlay_path = config_folder .. "resources/overlay_wide.png"
local thin_overlay_path = config_folder .. "resources/overlay_thin.png"
-- local overlay_path = config_folder .. "resources/measuring_overlay.png"

local pacem_path = config_folder .. "jars/paceman-tracker-0.7.1.jar"
local nb_path = config_folder .. "jars/Ninjabrain-Bot-1.5.2.jar"


-- ==== IMPORTS ====
local waywall = require("waywall")
local helpers = require("waywall.helpers")
local remaps = require("remaps")


-- ==== HELPERS ====
local thin_active = false
local remaps_active = true
local remaps_text = nil
local read_file = function(name)
    local file = io.open(config_folder .. name, "r")
    if file then
        local data = file:read("*a")
        file:close()
        return data
    else
        print("Error: File \"" .. name .. "\" not found.")
        return
    end
end
local is_ninb_running = function()
    -- local handle = io.popen("pgrep -f 'Ninjabrain.*jar'")
    local handle = io.popen("pgrep -f 'ninjabrain-bot'")
    if handle then
        local result = handle:read("*l")
        handle:close()
        return result ~= nil
    else
        print("Error: Command failed.")
        return
    end
end
local is_pacem_running = function()
    local handle = io.popen("pgrep -f 'paceman..*'")
    if handle then
        local result = handle:read("*l")
        handle:close()
        return result ~= nil
    else
        print("Error: Command failed.")
        return
    end
end

local hex_to_vec = function(var, hex)
    hex = hex:match("^%s*(.-)%s*$")
    hex = hex:gsub("^#", "")
    hex = hex:lower()

    local hex_segs = {}
    for pair in hex:gmatch("%x%x") do
        table.insert(hex_segs, pair)
    end
    if #hex_segs == 3 then
        table.insert(hex_segs, "ff")
    end

    local r = tonumber(hex_segs[1], 16) / 255
    local g = tonumber(hex_segs[2], 16) / 255
    local b = tonumber(hex_segs[3], 16) / 255
    local a = tonumber(hex_segs[4], 16) / 255

    return "const vec4 " .. var .. " = vec4(" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. ");"
end


local compile_colors = function(colors)
    local output = "precision highp float;\n\n"

    for name, hex in pairs(colors) do
        output = output .. hex_to_vec(name, hex) .. "\n\n"
    end

    return output
end


-- ==== MAIN CONFIG ====
local config = {
    input = {
        layout = xkb_layout,
        repeat_rate = 190,
        repeat_delay = 180,

        remaps = remaps.enabled,
        sensitivity = normal_sens,
        confine_pointer = true,
    },
    theme = {
        -- background = "#AA0000",
        background_png = background_path,

        ninb_anchor = {
            position = "topright",
            x = 0,
            y = 0
        },
        ninb_opacity = 0.9,
    },
    experimental = {
        debug = false,
        jit = false,
        tearing = true,
        scene_add_text = true,
    },
    shaders = {
        ["pie_chart"] = {
            vertex   = read_file("shaders/general.vert"),
            fragment = compile_colors(colors) .. read_file("shaders/pie_chart.frag"),
        },
        ["pie_border"] = {
            vertex   = read_file("shaders/general.vert"),
            fragment = compile_colors(colors) .. read_file("shaders/pie_border.frag"),
        },
        ["text"] = {
            vertex   = read_file("shaders/general.vert"),
            fragment = compile_colors(colors) .. read_file("shaders/text.frag"),
        },
        ["text_bg"] = {
            vertex   = read_file("shaders/general.vert"),
            fragment = compile_colors(colors) .. read_file("shaders/text_bg.frag"),
        },
        ["borders"] = {
            vertex   = read_file("shaders/general.vert"),
            fragment = compile_colors(colors) .. read_file("shaders/borders.frag"),
        },
    },
}


-- ==== MIRRORS ====
helpers.res_mirror( -- thin e_counter
    {
        src = { x = 1, y = 28, w = 49, h = 18 },
        dst = { x = 1340, y = 300, w = 49 * 5, h = 18 * 5 },
        depth = 2,
        shader = "text",
    },
    340, 1080
)
helpers.res_mirror( -- thin e_counter_bg
    {
        src = { x = 1, y = 28, w = 49, h = 18 },
        dst = { x = 1345, y = 305, w = 49 * 5, h = 18 * 5 },
        depth = 1,
        shader = "text_bg",
    },
    340, 1080
)
helpers.res_mirror( -- tall e_counter
    {
        src = { x = 1, y = 28, w = 49, h = 18 },
        dst = { x = 1340, y = 300, w = 49 * 5, h = 18 * 5 },
        depth = 2,
        shader = "text",
    },
    384, 16384
)
helpers.res_mirror( -- tall e_counter_bg
    {
        src = { x = 1, y = 28, w = 49, h = 18 },
        dst = { x = 1345, y = 305, w = 49 * 5, h = 18 * 5 },
        depth = 1,
        shader = "text_bg",
    },
    384, 16384
)
helpers.res_mirror( -- thin pie
    {
        src = { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = 1250, y = 500, w = 420, h = 423 },
        depth = 2,
        shader = "pie_chart",
    },
    340, 1080
)
helpers.res_mirror( -- thin pie border
    {
        src = { x = 0, y = 674, w = 340, h = 178 },
        dst = { x = 1245, y = 495, w = 430, h = 433 },
        depth = 1,
        shader = "pie_border",
    },
    340, 1080
)
helpers.res_mirror( -- tall pie
    {
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = 1250, y = 500, w = 420, h = 423 },
        depth = 2,
        shader = "pie_chart",
    },
    384, 16384
)
helpers.res_mirror( -- tall pie border
    {
        src = { x = 44, y = 15978, w = 340, h = 178 },
        dst = { x = 1245, y = 495, w = 430, h = 433 },
        depth = 1,
        shader = "pie_border",
    },
    384, 16384
)
helpers.res_mirror( -- thin percentages
    {
        src = { x = 247, y = 859, w = 33, h = 25 },
        dst = { x = 1300, y = 850, w = 33 * 6, h = 25 * 6 },
        depth = 2,
        shader = "text",
    },
    340, 1080
)
helpers.res_mirror( -- thin percentages_bg
    {
        src = { x = 247, y = 859, w = 33, h = 25 },
        dst = { x = 1306, y = 856, w = 33 * 6, h = 25 * 6 },
        depth = 1,
        shader = "text_bg",
    },
    340, 1080
)
helpers.res_mirror( -- tall percentages
    {
        src = { x = 291, y = 16163, w = 33, h = 25 },
        dst = { x = 1300, y = 850, w = 33 * 6, h = 25 * 6 },
        depth = 2,
        shader = "text",
    },
    384, 16384
)
helpers.res_mirror( -- tall percentages_bg
    {
        src = { x = 291, y = 16163, w = 33, h = 25 },
        dst = { x = 1306, y = 856, w = 33 * 6, h = 25 * 6 },
        depth = 1,
        shader = "text_bg",
    },
    384, 16384
)
helpers.res_mirror( -- Eye Measure
    {
        src = { x = 177, y = 7902, w = 30, h = 580 },
        dst = { x = 30, y = 340, w = 700, h = 400 },
        depth = 2,
    },
    384, 16384
)
--helpers.res_mirror( -- chunk coords
--{
--src = { x = 0, y = 436, w = 1080, h = 36 },
--dst = { x = 0, y = 436, w = 1080, h = 36 },
--depth = 2,
--color_key = { input = "#DDDDDD", output = "#de0000" }
--},
--0, 0
--)


for i = 0, 3, 1 do
    helpers.res_mirror( -- mob_spawner
        {
            src = { x = 1827, y = 859 + 8 * i, w = 33, h = 9 },
            dst = { x = 1618, y = 720, w = 33 * 8, h = 9 * 8 },
            depth = 3,
            color_key = { input = "#4de1ca", output = "#FFFFFF" }
        },
        0, 0
    )
    helpers.res_mirror( -- mob_spawner
        {
            src = { x = 1827, y = 859 + 8 * i, w = 33, h = 9 },
            dst = { x = 1618 + 8, y = 720 + 8, w = 33 * 8, h = 9 * 8 },
            depth = 2,
            color_key = { input = "#4de1ca", output = "#000000" }
        },
        0, 0
    )
end


-- ==== IMAGES ====
helpers.res_image( -- Measuring Overlay
    overlay_path,
    {
        dst = { x = 30, y = 340, w = 700, h = 400 },
        depth = 3,
    },
    384, 16384
)
helpers.res_image( -- Thin Overlay
    thin_overlay_path,
    {
        dst = { x = 0, y = 0, w = 1920, h = 1080 },
        depth = 3,
        shader = "borders",
    },
    340, 1080
)
helpers.res_image( -- Wide Overlay
    wide_overlay_path,
    {
        dst = { x = 0, y = 0, w = 1920, h = 1080 },
        depth = 3,
        shader = "borders",
    },
    1920, 300
)
helpers.res_image( -- Tall Overlay
    tall_overlay_path,
    {
        dst = { x = 0, y = 0, w = 1920, h = 1080 },
        depth = 3,
        shader = "borders",
    },
    384, 16384
)

-- ==== RESOLUTIONS ====
local resolutions = {
    thin = function()
        if remaps_active then
            if not waywall.get_key("F3") then
                helpers.ingame_only(helpers.toggle_res(340, 1080))()
                local act_width, act_height = waywall.active_res()
                if act_width == 340 and act_height == 1080 then
                    thin_active = true
                else
                    thin_active = false
                end
            else
                return false
            end
        else
            return false
        end
    end,
    wide = function()
        if remaps_active then
            if not waywall.get_key("F3") then
                helpers.ingame_only(helpers.toggle_res(1920, 300))()
                thin_active = false
            else
                return false
            end
        else
            return false
        end
    end,
    tall = function()
        if remaps_active then
            if not waywall.get_key("F3") then
                if thin_active then
                    helpers.toggle_res(340, 1080)()
                    helpers.toggle_res(384, 16384)()
                else
                    helpers.toggle_res(384, 16384, tall_sens)()
                end
                thin_active = false
            else
                return false
            end
        else
            return false
        end
    end,
}


-- ==== CONFIG ACTIONS ====
config.actions = {
    [keys.thin] = resolutions.thin,
    [keys.wide] = resolutions.wide,
    [keys.tall] = resolutions.tall,

    [keys.fullscreen] = waywall.toggle_fullscreen,

    [keys.toggle_ninbot] = function()
        if not waywall.get_key("F3") then
            if not is_ninb_running() then
                -- waywall.exec("java -Dawt.useSystemAAFontSettings=on -jar " .. nb_path)
                waywall.exec("ninjabrain-bot")
                waywall.show_floating(true)
            else
                helpers.toggle_floating()
            end
        else
            return false
        end
    end,

    ["*-C"] = function()
        if waywall.get_key("F3") then
            waywall.show_floating(true)
        end
        return false
    end,

    [keys.launch_paceman] = function()
        if not is_pacem_running() then
            waywall.exec("java -jar " .. pacem_path .. " --nogui")
        end
    end,

    [keys.toggle_rebinds] = function()
        if remaps_text then
            remaps_text:close(); remaps_text = nil
        end
        if remaps_active then
            remaps_active = false
            waywall.set_remaps(remaps.disabled)
            waywall.set_keymap({ layout = "us" })
            remaps_text = waywall.text("Rebinds OFF", { x = 20, y = 10, color = "#FFFFFF", size = 3 })
        else
            remaps_active = true
            waywall.set_remaps(remaps.enabled)
            waywall.set_keymap({ layout = xkb_layout })
        end
    end,

}
require("extras")(config)
return config
