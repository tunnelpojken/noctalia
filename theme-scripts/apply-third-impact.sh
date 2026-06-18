#!/usr/bin/env bash
# ── Third Impact — Dark Purple ────────────────────────────────────────────────

THEME_DIR="$HOME/.config/hypr/themes"
WALLPAPER_DIR="$HOME/.config/hypr"
NOCTALIA_THEME_FILE="$HOME/.config/noctalia/theme-override.json"
CHROME_DIR="$HOME/.config/mozilla/firefox/i5woyid6.default-release/chrome"
MON1="HDMI-A-1"
MON2="DP-2"

mkdir -p "$THEME_DIR"
cp "$THEME_DIR/third-impact.lua" "$THEME_DIR/active.lua"
hyprctl reload

gsettings set org.gnome.desktop.interface gtk-theme    "LCL-Deep-Blue"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme   "Papirus-Dark"

SETTINGS="$HOME/.config/noctalia/settings.json"
jq '.colorSchemes.predefinedScheme = "ThirdImpact"' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
qs -c noctalia-shell ipc call colorScheme set "ThirdImpact"

WP1="$WALLPAPER_DIR/third-impact.png"
WP2="$WALLPAPER_DIR/third-impact-2.png"
[ ! -f "$WP2" ] && WP2="$WP1"
awww img --outputs "$MON1" --transition-type fade --transition-duration 1 "$WP1"
awww img --outputs "$MON2" --transition-type fade --transition-duration 1 "$WP2"

mkdir -p "$CHROME_DIR"
cat > "$CHROME_DIR/userChrome.css" << 'CSS'
/* ── Third Impact — Dark Purple ── Firefox 150 ── */
:root {
  --toolbar-bgcolor:               #0d0814 !important;
  --toolbar-color:                 #f0d8ff !important;
  --toolbarbutton-icon-fill:       #b07fff !important;
  --lwt-accent-color:              #0d0814 !important;
  --lwt-text-color:                #f0d8ff !important;
  --lwt-toolbar-field-background-color: #180f2e !important;
  --lwt-toolbar-field-color:       #f0d8ff !important;
  --lwt-toolbar-field-border-color: #3a1f5a !important;
  --urlbar-box-bgcolor:            #180f2e !important;
  --urlbar-box-text-color:         #f0d8ff !important;
}
#navigator-toolbox { background-color: #0d0814 !important; border-bottom: 1px solid #3a1f5a !important; }
#TabsToolbar { background-color: #180f2e !important; }
.tabbrowser-tab .tab-background { background-color: transparent !important; }
.tabbrowser-tab[selected] .tab-background {
  background-color: #0d0814 !important;
  box-shadow: inset 0 2px 0 #b07fff !important;
}
.tabbrowser-tab:hover:not([selected]) .tab-background { background-color: #1e1030 !important; }
.tab-label { color: #c8a8e8 !important; }
.tabbrowser-tab[selected] .tab-label { color: #f0d8ff !important; }
#nav-bar { background-color: #0d0814 !important; border-top: 1px solid #3a1f5a !important; }
#urlbar-background {
  background-color: #180f2e !important;
  border: 1px solid #3a1f5a !important;
  border-radius: 8px !important;
}
#urlbar[focused] #urlbar-background {
  border-color: #b07fff !important;
  box-shadow: 0 0 0 1px #b07fff !important;
}
#urlbar-input { color: #f0d8ff !important; }
.toolbarbutton-1 { color: #c8a8e8 !important; fill: #c8a8e8 !important; }
.toolbarbutton-1:hover > .toolbarbutton-icon {
  color: #b07fff !important; fill: #b07fff !important;
  background-color: #3a1f5a !important; border-radius: 6px !important;
}
#PersonalToolbar { background-color: #0d0814 !important; border-bottom: 1px solid #3a1f5a !important; }
#sidebar-box { background-color: #0d0814 !important; }
#FindToolbar { background-color: #180f2e !important; border-top: 1px solid #3a1f5a !important; color: #f0d8ff !important; }
CSS

pkill -x firefox; sleep 1; firefox &

echo '{"active":"third-impact"}' > "$NOCTALIA_THEME_FILE"
notify-send -i dialog-information "Theme Switcher" "Third Impact activated" --expire-time=2000
