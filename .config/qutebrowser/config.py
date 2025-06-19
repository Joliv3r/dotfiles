# Config found https://gitlab.com/farlusiva/dotfiles/-/blob/master/qutebrowser/.config/qutebrowser/

config.load_autoconfig(False)
# Get the version. Maybe a hack.
import qutebrowser
qutebrowser_version = qutebrowser.__version_info__

# Colours
c_text = "#aaaaaa"
c_black = "#161616"
c_dgrey = "#2a2a2a"
c_background = "#202020"

font = "12pt mononoki"


if qutebrowser_version >= (2, 0, 0):
	config.load_autoconfig(False)

# Tabs
c.colors.tabs.selected.odd.fg = "#dddddd"
c.colors.tabs.selected.even.fg = "#dddddd"
c.colors.tabs.selected.odd.bg = "#555555"
c.colors.tabs.selected.even.bg = "#555555"
c.colors.tabs.even.bg = c_black
c.colors.tabs.odd.bg = c_black
c.colors.tabs.even.fg = "grey"
c.colors.tabs.odd.fg = "grey"
# Softer colours for the indicator
c.colors.tabs.indicator.start = "#003300"
c.colors.tabs.indicator.stop  = "#009900"
c.colors.tabs.indicator.error = "#aa0000"

# Try to do darkmode globally
# TODO: Some websites (wikipedia, packages.nixos.org) use images as part of
# their light time. This can be fixed with a policy.images = "always", but this
# breaks more than it fixes.
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = "lightness-cielab" # default
# Example from settings.asciidoc
if qutebrowser_version >= (3, 1, 0):
	c.colors.webpage.darkmode.threshold.foreground = 150
else:
	c.colors.webpage.darkmode.threshold.text = 150
c.colors.webpage.darkmode.threshold.background = 205

# Remove unwanted pointer behaviour
# c.tabs.close_mouse_button_on_bar = "ignore"
# c.tabs.close_mouse_button = "none"
# c.tabs.mousewheel_switching= False

# Other tab settings
# c.tabs.indicator.width = 1 # less prominent indicator
# c.tabs.favicons.show = "never"

# Hints
c.colors.hints.fg = "#ffffff"
c.colors.hints.match.fg = "#ffffff"
c.colors.hints.bg = "#ff0000"
c.hints.border = "0px solid #ff0000"

# The statusbar, completion and messages
c.colors.statusbar.normal.bg = c_background
c.colors.statusbar.normal.fg = c_text
c.colors.statusbar.command.bg = c_background
c.colors.statusbar.command.fg = c_text
c.colors.statusbar.passthrough.bg = "#003153"
c.colors.statusbar.url.success.https.fg = "#00dd00"
c.colors.statusbar.url.hover.fg = "#00cccc"
c.colors.completion.fg = c_text
c.colors.completion.even.bg = "#202020"
c.colors.completion.odd.bg = "#2d2d2d"
c.colors.messages.info.fg = c_text
c.colors.messages.info.bg = c_background
c.colors.messages.error.bg = "#cc0000"


# Settings
c.hints.mode = "letter"
c.hints.auto_follow_timeout = 200 # Nifty!
c.tabs.background = True
c.tabs.last_close = "close"
c.completion.height = "40%"
c.completion.open_categories = ["quickmarks", "bookmarks", "history"]
c.statusbar.widgets = ["keypress", "url", "scroll", "history", "progress"]
c.content.pdfjs = True
# MPV_FLAGS = "--force-window=immediate --ytdl-raw-options=format='bestvideo[height<=1080]+bestaudio/best[height<=1080]'"
# (Don't have youtube-dl do anything above 1080p)


# Fonts
c.fonts.hints = "10pt mononoki"
c.fonts.completion.category = "bold " + font
c.fonts.debug_console = font
c.fonts.downloads = font
c.fonts.keyhint = font
c.fonts.messages.error = font
c.fonts.messages.info = font
c.fonts.messages.warning = font
c.fonts.prompts = font
c.fonts.statusbar = font
c.fonts.completion.entry = font

if qutebrowser_version >= (1, 13, 0):
	# c.fonts.tabs was removed in 1.13.0.
	# See https://github.com/qutebrowser/qutebrowser/releases/tag/v1.13.0
	c.fonts.tabs.selected = font
	c.fonts.tabs.unselected = font
else:
	# The old way, which works on (non-ancient) versions <= 1.12
	c.fonts.tabs = font

# Avoid #ffffff when possible
c.url.start_pages = c.url.default_page
c.colors.webpage.bg = c_background


# TODO: Make work with qtile
# c.editor.command = ["sh", "-c", "bspc rule -a qute-edit --one-shot state=pseudo_tiled;"
# + "st -c qute-edit -e vim -f {file} -c 'normal {line}G{column0}l' -c 'nnoremap <CR> ZZ'"]
c.editor.command = ["qtile", "run-cmd", "--float", "alacritty", "-e", "nvim", "{file}", "-c", "normal {line}G{column0}1"]

# Binds for modes other than normal mode (John-Aslak style)
# config.bind("<Shift-Esc>", "mode-enter normal", mode="passthrough")
# config.bind("<Insert>", "mode-enter normal", mode="passthrough")
# config.bind("<Ctrl+n>", "completion-item-focus --history next", mode="command")
# config.bind("<Ctrl+p>", "completion-item-focus --history prev", mode="command")
# config.bind("<Ctrl+w>", "rl-backward-kill-word", mode="command")
# config.bind("<Ctrl+i>", "cmd-edit", mode="command")
# config.bind("<Ctrl+w>", "rl-backward-kill-word", mode="prompt")

# MAY BE IMPORTANT
# Remove tabs, see github.com/qutebrowser/qutebrowser/issues/4579,
# but not in insert mode
# for cur_mode in ["hint", "passthrough", "caret", "register"]:
# 	config.bind("<Tab>", "nop", mode=cur_mode)

c.bindings.commands["normal"] = {

	"<Tab>":"nop", # Not None!
	"gf":None,
	"c":None,
	"M":None,
	"<Ctrl-h>":None,
	"<Ctrl-w>":None,
	"<Ctrl-t>":None,
	"<Alt-m>":None,
	"<Ctrl-m>":"tab-mute",
	"d":"cmd-repeat 1 tab-close", # requires qute >=1.5.0
	"u":"cmd-repeat 1 undo",
	"<Ctrl-n>":"tab-next",
	"<Ctrl-p>":"tab-prev",
	"gt":"tab-next",
	"gT":"tab-prev",
	"<Shift-Esc>":"mode-enter passthrough",
	"<Insert>":"mode-enter passthrough",
	"<":"tab-move -",
	">":"tab-move +",
	# "<Ctrl-i>":"open-editor",
	"t":"cmd-set-text -s :open -t ",
	"O":"cmd-set-text :open {url:pretty}",
	"T":"cmd-set-text :open -t {url:pretty}",
	# ",v":"spawn --userscript view_in_mpv " + MPV_FLAGS,
	# ";v":"hint links spawn mpv {hint-url} " + MPV_FLAGS,
	"b":"tab-select",

	# Make hjkl always scroll
	"j":"scroll-page 0 0.05",
	"k":"scroll-page 0 -0.05",
	"h":"scroll-page -0.05 0",
	"l":"scroll-page 0.05 0",

	# Remove some pesky default keybinds
	"J":"nop",
	"K":"nop",

	# Make "m" be marks like in vim and pdf readers, overriding quickmarks.
	# As of writing this, "set_mark" only works when at a 100% zoom:
	# https://github.com/qutebrowser/qutebrowser/issues/4013
	"m":"mode-enter set_mark",
	"'":"mode-enter jump_mark",
	"M":"quickmark-save",

	# Moved from t{PpSsIi}{HhUu} to c{PpSsIi}{HhUu} because of the 't' bind
	"cph":"config-cycle -p -t -u *://{url:host}/* content.plugins ;; reload",
	"cPh":"config-cycle -p    -u *://{url:host}/* content.plugins ;; reload",
	"cpH":"config-cycle -p -t -u *://*.{url:host}/* content.plugins ;; reload",
	"cPH":"config-cycle -p    -u *://*.{url:host}/* content.plugins ;; reload",
	"cpu":"config-cycle -p -t -u {url} content.plugins ;; reload",
	"cPu":"config-cycle -p    -u {url} content.plugins ;; reload",

	"csh":"config-cycle -p -t -u *://{url:host}/* content.javascript.enabled ;; reload",
	"cSh":"config-cycle -p    -u *://{url:host}/* content.javascript.enabled ;; reload",
	"csH":"config-cycle -p -t -u *://*.{url:host}/* content.javascript.enabled ;; reload",
	"cSH":"config-cycle -p    -u *://*.{url:host}/* content.javascript.enabled ;; reload",
	"csu":"config-cycle -p -t -u {url} content.javascript.enabled ;; reload",
	"cSu":"config-cycle -p    -u {url} content.javascript.enabled ;; reload",

	"cih":"config-cycle -p -t -u *://{url:host}/* content.images ;; reload",
	"cIh":"config-cycle -p    -u *://{url:host}/* content.images ;; reload",
	"ciH":"config-cycle -p -t -u *://*.{url:host}/* content.images ;; reload",
	"cIH":"config-cycle -p    -u *://*.{url:host}/* content.images ;; reload",
	"ciu":"config-cycle -p -t -u {url} content.images ;; reload",
	"cIu":"config-cycle -p    -u {url} content.images ;; reload",

    # Other custom stuff (non-John Aslak)
    "e":"spawn firefox {url}",
}

# Bind away <Alt-(num)>
for k in range(1, 9+1):
	c.bindings.commands["normal"]["<Alt-" + str(k) + ">"] = None


c.bindings.commands["insert"] = {
	# Sane binds. See www.github.com/qutebrowser/qutebrowser/issues/68
	"<Ctrl-f>":"fake-key <Right>",
	"<Ctrl-b>":"fake-key <Left>",
	"<Ctrl-n>":"fake-key <Down>",
	"<Ctrl-p>":"fake-key <Up>",
	"<Ctrl-a>":"fake-key <Home>",
	"<Ctrl-e>":"fake-key <End>",
	"<Ctrl-u>":"fake-key <Shift-Home> ;; fake-key <Delete>",
	"<Ctrl-k>":"fake-key <Shift-End> ;; fake-key <Delete>",
	"<Ctrl-w>":"fake-key <Ctrl-Backspace>",
	"<Ctrl-h>":"fake-key <Backspace>",
	"<Ctrl-m>":"fake-key <Enter>",
	"<Ctrl-i>":"edit-text",
#
	"<Ctrl-shift-a>":"fake-key <Ctrl-a>", # If needed
}

# if qutebrowser_version < (2, 0, 0):
# 	# Fix some commands that are being renamed as of 2.0.0
#
# 	c.bindings.commands["normal"]["b"] = "buffer"
# 	c.bindings.commands["normal"]["<Ctrl-i>"] = "open-editor"
# 	c.bindings.commands["insert"]["<Ctrl-i>"] = "open-editor"
# 	c.bindings.commands["normal"]["<Shift-Esc>"] = "enter-mode passthrough"
# 	c.bindings.commands["normal"]["<Insert>"] = "enter-mode passthrough"
# 	c.bindings.commands["passthrough"]["<Shift-Esc>"] = "enter-mode normal"
# 	c.bindings.commands["passthrough"]["<Insert>"] = "enter-mode passthrough"

# Fix commands that are changed in v3.
# This can be removed when v3 is ubiquitous.
# if qutebrowser_version < (3, 0, 0):
# 	config.bind("<Ctrl+i>", "edit-command", mode="command")
# 	c.bindings.commands["normal"]["d"] = "repeat 1 tab-close"
# 	c.bindings.commands["normal"]["u"] = "repeat 1 undo"
# 	c.bindings.commands["normal"]["t"] = "set-cmd-text -s :open -t "
# 	c.bindings.commands["normal"]["O"] = "set-cmd-text :open {url:pretty}"
# 	c.bindings.commands["normal"]["T"] = "set-cmd-text :open -t {url:pretty}"


# Privacy
c.content.headers.do_not_track = True
# c.content.javascript.enabled = False
c.content.xss_auditing = True
# c.content.webgl = False
c.content.headers.accept_language = "en-US;q=0.5"
c.content.headers.custom = {"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}
c.content.cookies.accept = "no-3rdparty"
c.content.canvas_reading = False

adblock_lists = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
if qutebrowser_version >= (2, 0, 0):
	c.content.blocking.hosts.lists = [adblock_lists]
else:
	c.content.host_blocking.lists.append(adblock_lists)

# for k in ["youtube.com", "naob.no", "openstreetmap.org",
#          "docs.python.org"]:
# 	config.set("content.javascript.enabled", True, pattern=f"*://"+k+"/*")
# 	config.set("content.javascript.enabled", True, pattern=f"*://www."+k+"/*")

c.url.searchengines = {

	"DEFAULT" : "https://duckduckgo.com/?q={}",
	"arch"    : "https://wiki.archlinux.org/?search={}",
	"pkg"     : "https://archlinux.org/packages/?q={}",
	"aur"     : "https://aur.archlinux.org/packages/?K={}",
	"o"       : "https://onelook.com/?w={}",
	"yt"      : "https://youtube.com/results?search_query={}",
	"wa"      : "https://wolframalpha.com/input/?i={}",
	"osm"     : "https://openstreetmap.org/search?query={}",
	"gh"      : "https://github.com/search?q={}",
	"naob"    : "https://naob.no/søk/{}",
	"snl"     : "https://snl.no/{}",
	"rplgy"   : "https://repology.org/projects/?search={}",
	"man"     : "https://man.archlinux.org/search?q={}",
	"wayback" : "https://web.archive.org/web/*/{}",
	"ctan"    : "https://ctan.org/search?phrase={}",
	"py"      : "https://docs.python.org/3/search.html?q={}",

	"nlab"    : "https://ncatlab.org/nlab/show/{}",
	"stacks"  :  "https://stacks.math.columbia.edu/search?query={}",

	"w"       : "https://en.wikipedia.org/w/index.php?search={}",
	"wt"      : "https://en.wiktionary.org/w/index.php?search={}",

    "regs"    : "https://wcaregs.netlify.app/#{}",

    "nixpkg"  : "https://search.nixos.org/packages?from=0&size=50&sort=relevance&type=packages&query={}"
}

# explicitly search:
c.url.searchengines["s"] = c.url.searchengines["DEFAULT"]

# wikipedia and wiktionary for various languages
for k in ["en", "no", "nn", "de"]:
	c.url.searchengines["w" + k] = "https://" + k + ".wikipedia.org/w/index.php?search={}"
	c.url.searchengines["wt" + k] = "https://" + k + ".wiktionary.org/w/index.php?search={}"

