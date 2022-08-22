local windline = require('windline')
local helper = require('windline.helpers')
local utils = require('windline.utils')
local sep = helper.separators
local animation = require('wlanimation')
local efffects = require('wlanimation.effects')
local HSL = require('wlanimation.utils')

local state = _G.WindLine.state

local lsp_comps = require('windline.components.lsp')
local lsp_progress = require('windline.components.lsp_progress')
local git_comps = require('windline.components.git')
local b_components = require('windline.components.basic')
local lsp_p = require('core.status')

local hl_list = {
    Black = { 'white', 'black' },
    Inactive = { 'InactiveFg', 'InactiveBg' },
    Active = { 'ActiveFg', 'ActiveBg' },
}
local basic = {}

basic.divider = { '%=', '' }
basic.space = { ' ', '' }
basic.line_col = { [[ %3l:%-2c ]], hl_list.Black }
basic.progress = { [[%3p%% ]], hl_list.Black }
basic.bg = { ' ', 'StatusLine' }
basic.file_name_inactive = { '%f', hl_list.Inactive }
basic.line_col_inactive = { [[ %3l:%-2c ]], hl_list.Inactive }
basic.progress_inactive = { [[%3p%% ]], hl_list.Inactive }

utils.change_mode_name({
    ['n'] = { ' NORMAL', 'Normal' },
    ['no'] = { ' O-PENDING', 'Visual' },
    ['nov'] = { ' O-PENDING', 'Visual' },
    ['noV'] = { ' O-PENDING', 'Visual' },
    ['no'] = { ' O-PENDING', 'Visual' },
    ['niI'] = { ' NORMAL', 'Normal' },
    ['niR'] = { ' NORMAL', 'Normal' },
    ['niV'] = { ' NORMAL', 'Normal' },
    ['v'] = { ' VISUAL', 'Visual' },
    ['V'] = { ' V-LINE', 'Visual' },
    [''] = { ' V-BLOCK', 'Visual' },
    ['s'] = { ' SELECT', 'Visual' },
    ['S'] = { ' S-LINE', 'Visual' },
    [''] = { ' S-BLOCK', 'Visual' },
    ['i'] = { ' INSERT', 'Insert' },
    ['ic'] = { ' INSERT', 'Insert' },
    ['ix'] = { ' INSERT', 'Insert' },
    ['R'] = { ' REPLACE', 'Replace' },
    ['Rc'] = { ' REPLACE', 'Replace' },
    ['Rv'] = { 'V-REPLACE', 'Normal' },
    ['Rx'] = { ' REPLACE', 'Normal' },
    ['c'] = { ' COMMAND', 'Command' },
    ['cv'] = { ' COMMAND', 'Command' },
    ['ce'] = { ' COMMAND', 'Command' },
    ['r'] = { ' REPLACE', 'Replace' },
    ['rm'] = { ' MORE', 'Normal' },
    ['r?'] = { ' CONFIRM', 'Normal' },
    ['!'] = { ' SHELL', 'Normal' },
    ['t'] = { ' TERMINAL', 'Command' },
})

basic.vi_mode = {
    name = 'vi_mode',
    hl_colors = {
        Normal = { 'white', 'black' },
        Insert = { 'black', 'red' },
        Visual = { 'black', 'green' },
        Replace = { 'black', 'cyan' },
        Command = { 'black', 'yellow' },
    },
    text = function()
        return ' ' .. state.mode[1] .. ' '
    end,
    hl = function()
        return state.mode[2]
    end,
}

basic.vi_mode_sep = {
    name = 'vi_mode_sep',
    hl_colors = {
        Normal = { 'black', 'FilenameBg' },
        Insert = { 'red', 'FilenameBg' },
        Visual = { 'green', 'FilenameBg' },
        Replace = { 'cyan', 'FilenameBg' },
        Command = { 'yellow', 'FilenameBg' },
    },
    text = function()
        return sep.right_rounded
    end,
    hl = function()
        return state.mode[2]
    end,
}

basic.file_name = {
    text = function()
        local name = vim.fn.expand('%:p:t')
        if name == '' then
            name = '[No Name]'
        end
        return name .. ' '
    end,
    hl_colors = { 'FilenameFg', 'FilenameBg' },
}

basic.lsp_diagnos = {
    name = 'diagnostic',
    hl_colors = {
        red = { 'red', 'black_light' },
        yellow = { 'yellow', 'black_light' },
        blue = { 'blue', 'black_light' },
    },
    width = 90,
    text = function(bufnr)
        if lsp_comps.check_lsp(bufnr) then
            return {
                { lsp_comps.lsp_error({ format = '   %s ' }), 'red' },
                { lsp_comps.lsp_warning({ format = '   %s ' }), 'yellow' },
                { lsp_comps.lsp_hint({ format = '  %s ' }), 'blue' },
            }
        end
        return ''
    end,
}

basic.lsp_name = {
    width = 100,
    hl_colors = {
        green = { 'green', 'black_light' },
        blue = { 'blue', 'black_light' },
    },
    name = 'lsp_name',
    text = function(bufnr)
        if lsp_comps.check_lsp(bufnr) then
            return {
                { lsp_p.provider.lsp_client_names(true), 'blue' },
           }
        end
        return ''
    end,
}

basic.git = {
    name = 'git',
    width = 90,
    hl_colors = {
        green = { 'green', 'black_light' },
        red = { 'red', 'black_light' },
        blue = { 'blue', 'black_light' },
    },
    text = function(bufnr)
        if git_comps.is_git(bufnr) then
            return {
                { git_comps.diff_added({ format = '  %s' }), 'green' },
                { git_comps.diff_removed({ format = '  %s' }), 'red' },
                { git_comps.diff_changed({ format = ' 柳%s' }), 'blue' },
            }
        end
        return ''
    end,
}

basic.right = {
    hl_colors = {
        Normal = { 'white', 'black_light' },
        Insert = { 'black', 'red' },
        Visual = { 'black', 'green' },
        Replace = { 'black', 'cyan' },
        Command = { 'black', 'yellow' },
    },
    text = function()
        return {
            { ' ', state.mode[2] },
            { b_components.progress },
            { ' ' },
            { b_components.line_col },
        }
    end,
}

basic.right_sep = {
    name = 'right_sep',
    hl_colors = {
        Normal = { 'black_light', 'black' },
        Insert = { 'red', 'black' },
        Visual = { 'green', 'black' },
        Replace = { 'cyan', 'black' },
        Command = { 'yellow', 'black' },
    },
    text = function()
        return sep.left_rounded
    end,
    hl = function()
        return state.mode[2]
    end,
}

basic.treesitter = {
    name = 'treesitter',
    hl_colors = {
        green = { 'green', 'black' },
    },
    text = function()
        return {
            { lsp_p.provider.treesitter_status, 'green' },
            { ' ' },
            { b_components.file_type( { icon = true } ) },
            { ' ' },
        }
    end,
    hl = function()
        return state.mode[2]
    end,
}

local is_run = false

local status_color = ''
local change_color = function()
    local hl_colors = {
        Normal = { 'white', 'black' },
        Insert = { 'black', 'red' },
        Visual = { 'black', 'green' },
        Replace = { 'black', 'cyan' },
        Command = { 'black', 'yellow' },
    }

    local green_shades, purple_shades = HSL.rgb_to_hsl('#ffb0ff'):shades(10,8)

    if state.mode[2] ~= nil then
        purple_shades = HSL.rgb_to_hsl(utils.get_color(WindLine.state.colors, hl_colors[state.mode[2]][2])):shades(10,8)
    end

    local anim_colors = purple_shades

    if status_color == 'blue' then
        anim_colors = green_shades
        status_color = 'yellow'
    else
        status_color = 'blue'
    end

    if is_run then
        animation.stop_all()
        is_run = false
    end
    is_run = true

    animation.stop_all()
    animation.animation({
        data = {
            { 'waveleft1', efffects.list_color(anim_colors, 6) },
            { 'waveleft2', efffects.list_color(anim_colors, 5) },
            { 'waveleft3', efffects.list_color(anim_colors, 4) },
            { 'waveleft4', efffects.list_color(anim_colors, 3) },
            { 'waveleft5', efffects.list_color(anim_colors, 2) },
        },
        timeout = nil,
        delay = 200,
        interval = 150,
    })

    animation.animation({
        data = {
            { 'waveright1', efffects.list_color(anim_colors, 2) },
            { 'waveright2', efffects.list_color(anim_colors, 3) },
            { 'waveright3', efffects.list_color(anim_colors, 4) },
            { 'waveright4', efffects.list_color(anim_colors, 5) },
            { 'waveright5', efffects.list_color(anim_colors, 6) },
        },
        timeout = nil,
        delay = 200,
        interval = 150,
    })
end

local wave_left = {
    text = function()
        return {
            { sep.right_filled .. ' ', { 'black_light', 'waveleft1' } },
            { sep.right_filled .. ' ', { 'waveleft1', 'waveleft2' } },
            { sep.right_filled .. ' ', { 'waveleft2', 'waveleft3' } },
            { sep.right_filled .. ' ', { 'waveleft3', 'waveleft4' } },
            { sep.right_filled .. ' ', { 'waveleft4', 'waveleft5' } },
            { sep.right_filled .. ' ', { 'waveleft5', 'wavedefault' } },
        }
    end,
    click = change_color,
}

local wave_right = {
    text = function()
        return {
            { ' ' .. sep.left_filled, { 'waveright1', 'wavedefault' } },
            { ' ' .. sep.left_filled, { 'waveright2', 'waveright1' } },
            { ' ' .. sep.left_filled, { 'waveright3', 'waveright2' } },
            { ' ' .. sep.left_filled, { 'waveright4', 'waveright3' } },
            { ' ' .. sep.left_filled, { 'waveright5', 'waveright4' } },
            { ' ' .. sep.left_filled, { 'black', 'waveright5' } },
        }
    end,
    click = change_color,
}

local default = {
    filetypes = { 'default' },
    active = {
        basic.vi_mode,
        basic.vi_mode_sep,
        { ' ', '' },
        basic.file_name,
        { b_components.file_size() },
        wave_left,
        { ' ', { 'FilenameBg', 'black' } },
        basic.divider,
        { sep.left_filled, { 'black_light', 'black' } },
        basic.lsp_diagnos,
        basic.lsp_name,
        basic.git,
        { git_comps.git_branch({ icon = '  ' }), { 'green', 'black_light' }, 90 },
        { lsp_progress.lsp_progress() },
        { sep.right_filled, { 'black_light', 'black' } },
        basic.divider,
        wave_right,
        basic.treesitter,
        basic.right_sep,
        basic.right,
    },
    inactive = {
        basic.file_name_inactive,
        basic.divider,
        basic.divider,
        basic.right,
    },
}

windline.setup({
    colors_name = function(colors)
        colors.FilenameFg = colors.white
        colors.FilenameBg = colors.black_light

        colors.wavedefault = colors.black
        colors.waveleft1 = colors.wavedefault
        colors.waveleft2 = colors.wavedefault
        colors.waveleft3 = colors.wavedefault
        colors.waveleft4 = colors.wavedefault
        colors.waveleft5 = colors.wavedefault

        colors.waveright1 = colors.wavedefault
        colors.waveright2 = colors.wavedefault
        colors.waveright3 = colors.wavedefault
        colors.waveright4 = colors.wavedefault
        colors.waveright5 = colors.wavedefault
        return colors
    end,
    statuslines = {
        default,
    },
})

local function anim_toggle()
    local timer = vim.loop.new_timer()
    timer:start(
        0,
        4000,
        vim.schedule_wrap(function()
            change_color()
        end)
    )
end

anim_toggle()
