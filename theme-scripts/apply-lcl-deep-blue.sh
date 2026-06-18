#!/usr/bin/env bash
# ── LCL Deep Blue — Rei Ayanami ───────────────────────────────────────────────

THEME_DIR="$HOME/.config/hypr/themes"
WALLPAPER_DIR="$HOME/.config/hypr"
NOCTALIA_THEME_FILE="$HOME/.config/noctalia/theme-override.json"
CHROME_DIR="$HOME/.config/mozilla/firefox/i5woyid6.default-release/chrome"
MON1="HDMI-A-1"
MON2="DP-2"

# ── 1. Hyprland colours ───────────────────────────────────────────────────────
mkdir -p "$THEME_DIR"
cp "$THEME_DIR/lcl-deep-blue.lua" "$THEME_DIR/active.lua"
hyprctl reload

# ── 2. GTK theme ──────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.interface gtk-theme    "LCL-Deep-Blue"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme   "Papirus-Dark"

# ── 3. Noctalia colorscheme ───────────────────────────────────────────────────
SETTINGS="$HOME/.config/noctalia/settings.json"
jq '.colorSchemes.predefinedScheme = "NervRei"' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
qs -c noctalia-shell ipc call colorScheme set "NervRei"

# ── 4. Wallpaper via awww ─────────────────────────────────────────────────────
WP1="$WALLPAPER_DIR/rei_city.jpg"
WP2="$WALLPAPER_DIR/rei-ayanami-2.png"
awww img --outputs "$MON1" --transition-type fade --transition-duration 1 "$WP1"
awww img --outputs "$MON2" --transition-type fade --transition-duration 1 "$WP2"

# ── 5. Firefox userChrome.css ─────────────────────────────────────────────────
mkdir -p "$CHROME_DIR"
cat > "$CHROME_DIR/userChrome.css" << 'CSS'
/* ── LCL Deep Blue — Rei Ayanami ── Firefox 150 ── */
:root {
  --toolbar-bgcolor:               #060d14 !important;
  --toolbar-color:                 #daeef0 !important;
  --toolbarbutton-icon-fill:       #7ecfcf !important;
  --lwt-accent-color:              #060d14 !important;
  --lwt-text-color:                #daeef0 !important;
  --lwt-toolbar-field-background-color: #0b1c23 !important;
  --lwt-toolbar-field-color:       #daeef0 !important;
  --lwt-toolbar-field-border-color: #1f3d55 !important;
  --urlbar-box-bgcolor:            #0b1c23 !important;
  --urlbar-box-text-color:         #daeef0 !important;
}
#navigator-toolbox {
  background-color: #060d14 !important;
  border-bottom: 1px solid #1f3d55 !important;
}
#TabsToolbar { background-color: #0b1c23 !important; }
.tabbrowser-tab .tab-background { background-color: transparent !important; }
.tabbrowser-tab[selected] .tab-background {
  background-color: #060d14 !important;
  box-shadow: inset 0 2px 0 #7ecfcf !important;
}
.tabbrowser-tab:hover:not([selected]) .tab-background { background-color: #0f2535 !important; }
.tab-label { color: #a8d8db !important; }
.tabbrowser-tab[selected] .tab-label { color: #daeef0 !important; }
#nav-bar { background-color: #060d14 !important; border-top: 1px solid #1f3d55 !important; }
#urlbar-background {
  background-color: #0b1c23 !important;
  border: 1px solid #1f3d55 !important;
  border-radius: 8px !important;
}
#urlbar[focused] #urlbar-background {
  border-color: #7ecfcf !important;
  box-shadow: 0 0 0 1px #7ecfcf !important;
}
#urlbar-input { color: #daeef0 !important; }
.toolbarbutton-1 { color: #a8d8db !important; fill: #a8d8db !important; }
.toolbarbutton-1:hover > .toolbarbutton-icon {
  color: #7ecfcf !important; fill: #7ecfcf !important;
  background-color: #1f3d55 !important; border-radius: 6px !important;
}
#PersonalToolbar { background-color: #060d14 !important; border-bottom: 1px solid #1f3d55 !important; }
#sidebar-box { background-color: #060d14 !important; }
#FindToolbar { background-color: #0b1c23 !important; border-top: 1px solid #1f3d55 !important; color: #daeef0 !important; }
CSS

pkill -x firefox; sleep 1; firefox &

# ── 6. Write active theme marker ──────────────────────────────────────────────
echo '{"active":"lcl-deep-blue"}' > "$NOCTALIA_THEME_FILE"
notify-send -i dialog-information "Theme Switcher" "LCL Deep Blue activated" --expire-time=2000
