#ttery Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
# from libqtile.utils import guess_terminal

import psutil
from socket import gethostname

import os
import subprocess

mod = "mod4"
terminal = "alacritty"
browser = "qutebrowser"
browser1 = "firefox"


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod, "shift"], "i", lazy.to_screen(0), desc="Move focus to monitor 0"),
    Key([mod, "shift"], "o", lazy.to_screen(1), desc="Move focus to monitor 1"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "s", lazy.spawn("flameshot gui"), desc="Flameshot"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "c", lazy.spawn(f"qtile run-cmd --float {terminal}"), desc="Launch floating terminal"),
    Key([mod], "b", lazy.spawn(browser), desc="Launch browser"),
    Key([mod], "g", lazy.spawn(browser1), desc="Launch secondary browser"),

    # Toggle between different layouts as defined below
    Key([mod], "m", lazy.next_layout(), desc="Toggle between layouts"),
    # Key([mod], "m", lazy.group.setlayout("max"), desc="Toggle one window focus"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "x", lazy.window.toggle_minimize(), desc="Minimize current window"),
    Key([mod, "shift"], "x", lazy.group.unminimize_all(), desc="Unminimizes all windows" ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Key([mod], "space", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "space", lazy.spawn("dmenu_run"), desc="Spawn a command using a prompt widget"),
    Key([mod], "p", lazy.spawn("passmenu"), desc="Spawn a command using a prompt widget"),
    Key([mod], "s", lazy.spawn("flameshot gui"), desc="Flameshot"),

    # Volume control
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset Master 10%+"), desc="Raise volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset Master 10%-"), desc="Lower volume"),
    Key([], "XF86AudioMute", lazy.spawn("amixer sset Master toggle"), desc="Toggle volume"),

    # Keyboard layout shenanigans
    Key([mod], "u", lazy.spawn("setxkbmap -layout us -option ctrl:nocaps"), desc="Enable us keyboard layout"),
    Key([mod, "shift"], "u", lazy.spawn("setxkbmap -layout no -option ctrl:nocaps"), desc="Enable no keyboard layout"),

    # Meme
    Key([mod], "a", lazy.spawn('firefox "https://youtu.be/dQw4w9WgXcQ?si=c9d29RirqWIJoDp"'), lazy.spawn('amixer sset Master unmute && amixer sset Master 100%')),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


# Groups will currently break if named
groups = [Group(str(i+1)) for i in range(9)]

for i in groups:
    keys.extend(
        [
            # mod1 + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            Key(
                [mod, "control"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )


# def to_next_group(qtile):
#     i = qtile.groups.index(qtile.current_group)
#     lazy.group[i+1]

# Some custom group keybindings
# keys.extend([
#     Key(
#         [mod, "o"],
#         lazy.group[qtile.groups.index(qtile.current_group)+1].toscreen(),
#         desc="Switch to next group",
#     ),
#     Key(
#         [mod, "i"],
#         lazy.group[qtile.groups.index(qtile.current_group)-1].toscreen(),
#         desc="Switch to previous group",
#     ),
# ])

keys.extend([
    # Jump between groups
    Key([mod], "o", lazy.screen.next_group()),
    Key([mod], "i", lazy.screen.prev_group()),
    # Throw windows between groups
    # TODO
])

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=3),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]


colors = [
    "#1e1e1e",  # Background color
    "#ff0000",  # Red
    "#ffa500",  # Orange
    "#ffff00",  # Yellow
    "#00ff00",  # Green
    "#0080ff",  # Blue
    "#800099",  # Indigo
    "#ee82ee",  # Violet
    "#111111",  # Text colors for widgets in rainbow
]


widget_defaults = dict(
    font="mononoki nerd font",
    fontsize=14,
    padding=3,
    background=colors[0],
)
extension_defaults = widget_defaults.copy()

def dynamic_battery_icon():
    bat = psutil.sensors_battery()
    bat_icons = [
        "",
        "",
        "",
        "",
        "",
    ]
    if bat.percent < 10:
        return bat_icons[0]
    elif bat.percent < 45:
        return bat_icons[1]
    elif bat.percent < 60:
        return bat_icons[2]
    elif bat.percent < 90:
        return bat_icons[3]
    return bat_icons[4]



Sep = widget.Sep(
    padding=10,
    linewidth=0,
)


WindowName = widget.WindowName()

Wlan = widget.Wlan(
    interface='wlp1s0',
    format='| {essid} {percent:2.0%}',
    # background=colors[1],
    # foreground=colors[8],
)

Net = widget.Net(
    format='| {down:.0f}{down_suffix} ↓↑ {up:.0f}{up_suffix}',
    # background=colors[2],
    # foreground=colors[8],
)

CPU = widget.CPU(
    format='|  {freq_current}GHz {load_percent}%',
    # background=colors[3],
    # foreground=colors[8],
)

Memory = widget.Memory(
    # background=colors[4],
    # foreground=colors[8],
    format="| 󰆚 {MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}",
)

Volume = widget.Volume(
    # background=colors[5],
    # foreground=colors[8],
    fmt='| Vol: {}',
)

if gethostname() == 'hausdorff':
    Battery = widget.Sep(
        padding = 0,
        linewidth = 0,
    )
else:
    Battery = widget.Battery(
        format=f"| {dynamic_battery_icon()}  "+"{percent:2.0%}",
        show_short_text=False,
        charge_char="Charging 󰂄",
        full_char="| Full",
        update_interval=60,
        # background=colors[6],
        # foreground=colors[8],
    )


Clock = widget.Clock(
    # background=colors[7],
    # foreground=colors[8],
    format="| %A, %B %d, %H:%M",
)


screens = [
    Screen(
        top=bar.Bar(
            [
                Sep,
                widget.GroupBox(
                    highlight_method='block',
                    this_current_screen_border=colors[7],
                    rounded=False,
                ),
                WindowName,
                Wlan,
                Net,
                CPU,
                Memory,
                Volume,
                Battery,
                Clock,
            ],
            24,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),

    Screen(
        top=bar.Bar(
            [
                Sep,
                widget.GroupBox(
                    highlight_method='block',
                    this_current_screen_border=colors[7],
                    rounded=False,
                ),
                WindowName,
                Wlan,
                Net,
                CPU,
                Memory,
                Volume,
                Battery,
                Clock,
            ],
            24,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),

]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"


if gethostname() == 'hilbert':
    @hook.subscribe.startup_once
    def autostart():
        home = os.path.expanduser('/usr/local/bin/background')
        subprocess.Popen([home])
