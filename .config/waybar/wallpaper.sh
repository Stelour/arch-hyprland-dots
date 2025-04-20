#!/usr/bin/env bash
# ~/.config/waybar/wallpaper.sh

WALLPAPER_DIR="$HOME/.config/Wallpapers"
STATE_FILE="$HOME/.config/waybar/current_wallpaper"
SWWW_CMD="swww img"
TRANS_OPTS="--transition-type random --transition-step 6"

mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" \
    -o -iname "*.png" \
    -o -iname "*.gif" \
    -o -iname "*.pnm" -o -iname "*.ppm" -o -iname "*.pgm" -o -iname "*.pbm" \
    -o -iname "*.tga" \
    -o -iname "*.tiff" -o -iname "*.tif" \
    -o -iname "*.webp" \
    -o -iname "*.bmp" \
    -o -iname "*.ff" -o -iname "*.farbfeld" \
\) | sort)

[ ${#WALLS[@]} -gt 0 ] || { 
  echo "No wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
}

set_wallpaper() {
  local file="$1"
  $SWWW_CMD "$file" $TRANS_OPTS
  echo "$file" > "$STATE_FILE"
}

if [ ! -f "$STATE_FILE" ] || [ -z "$( < "$STATE_FILE" )" ]; then
  echo "${WALLS[0]}" > "$STATE_FILE"
fi

current_file="$( < "$STATE_FILE" )"

case "$1" in
  restore)
    set_wallpaper "$current_file"
    ;;

  select)
    choices=()
    for i in "${!WALLS[@]}"; do
      path="${WALLS[$i]}"
      name="${path##*/}"
      choices+=("$i: $name\0icon\x1fthumbnail://$path")
    done

    choice=$(printf '%b\n' "${choices[@]}" \
      | rofi -dmenu \
             -theme ~/.config/rofi/config-wallpaper.rasi \
             -p "Wallpapers:" \
             -show-icons)

    if [[ "$choice" =~ ^([0-9]+): ]]; then
      idx="${BASH_REMATCH[1]}"
      set_wallpaper "${WALLS[$idx]}"
    fi
    ;;

  *)
    idx=0
    for i in "${!WALLS[@]}"; do
      [[ "${WALLS[$i]}" == "$current_file" ]] && idx=$i && break
    done
    next=$(( (idx + 1) % ${#WALLS[@]} ))
    set_wallpaper "${WALLS[$next]}"
    ;;
esac
