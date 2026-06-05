#!/usr/bin/env bash

# ~/.config/hypr/scripts/volume-brightness.sh
# Called by Hyprland keybinds with an argument

VOLUME_STEP=2
BRIGHTNESS_STEP=5

notify() {
  local summary="$1"
  local value="$2"
  local icon="$3"
  # Send a notification (requires libnotify / dunst / mako)
  notify-send -h int:value:"$value" -h string:x-canonical-private-synchronous:sys-notify "$summary" "$icon $value%" -t 1500
}

case "$1" in
volume_up)
  pactl set-sink-mute @DEFAULT_SINK@ false
  pactl set-sink-volume @DEFAULT_SINK@ +${VOLUME_STEP}%
  VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
  notify "Volume" "$VOL" "󰕾"
  ;;

volume_down)
  pactl set-sink-mute @DEFAULT_SINK@ false
  pactl set-sink-volume @DEFAULT_SINK@ -${VOLUME_STEP}%
  VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
  notify "Volume" "$VOL" "󰖀"
  ;;

volume_mute)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(?<=Mute: )\w+')
  if [[ "$MUTED" == "yes" ]]; then
    notify-send -h string:x-canonical-private-synchronous:sys-notify "Muted" "󰖁" -t 1500
  else
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    notify "Volume" "$VOL" "󰕾"
  fi
  ;;

audio_mute)
  pactl set-source-mute @DEFAULT_SOURCE@ toggle
  MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -oP '(?<=Mute: )\w+')
  if [[ "$MUTED" == "yes" ]]; then
    notify-send -h string:x-canonical-private-synchronous:sys-notify "Mic Muted" "🎙️❌" -t 1500
  else
    notify-send -h string:x-canonical-private-synchronous:sys-notify "Mic Active" "🎙️" -t 1500
  fi
  ;;

brightness_up)
  brightnessctl set +${BRIGHTNESS_STEP}%
  BRIGHT=$(brightnessctl get)
  MAX=$(brightnessctl max)
  PCT=$((BRIGHT * 100 / MAX))
  notify "Brightness" "$PCT" "☀️"
  ;;

brightness_down)
  brightnessctl set ${BRIGHTNESS_STEP}%-
  BRIGHT=$(brightnessctl get)
  MAX=$(brightnessctl max)
  PCT=$((BRIGHT * 100 / MAX))
  notify "Brightness" "$PCT" "🌑"
  ;;

*)
  echo "Usage: $0 {volume_up|volume_down|volume_mute|audio_mute|brightness_up|brightness_down}"
  exit 1
  ;;
esac
