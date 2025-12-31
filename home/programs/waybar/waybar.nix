{ pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    settings = [
      {
        "layer" = "top"; # Waybar at top layer
        "position" = "top"; # Waybar position (top|bottom|left|right)
        "modules-left" = [
          "niri/workspaces"
          "niri/language"
          "keyboard-state"
          "custom/pacman"
        ];
        "modules-center" = [
          "clock"
          "custom/weather"
        ];
        "modules-right" = [
          "cpu"
          "temperature"
          "pulseaudio"
          "bluetooth"
          "network"
          "battery"
          "tray"
          "custom/wlogout"
        ];
        # Modules configuration
        "niri/workspaces" = {
          "all-outputs" = true;
          "format" = "{icon}";
          "format-icons" = {
            "1" = "<span color=\"#D8DEE9\"></span>";
            "2" = "<span color=\"#88C0D0\"></span>";
            "3" = "<span color=\"#A3BE8C\"></span>";
            "4" = "<span color=\"#D8DEE9\"></span>";
            "urgent" = "";
            "focused" = "";
            "default" = "<span color=\"#5E81AC\"></span>";
          };
        };
        "niri/window" = {
          "format" = "{}";
          "max-length" = 50;
          "tooltip" = false;
        };
        "niri/language" = {
          "format" = "<big>󰌌</big>  {}";
        };
        "keyboard-state" = {
          "capslock" = true;
          "format" = "{icon}";
          "format-icons" = {
            "locked" = "<big>󰪛</big>";
            "unlocked" = "";
          };
        };
        "custom/pacman" = {
          "format" = "<big>󰏖</big>  {}";
          "interval" = 3600; # every hour
          "exec" = "checkupdates | wc -l"; # # of updates
          "exec-if" = "exit 0"; # always run; consider advanced run conditions
          "on-click" = "ghostty -e 'yay'; pkill -SIGRTMIN+8 waybar"; # update system
          "signal" = 8;
          "max-length" = 5;
          "min-length" = 3;
        };
        "clock" = {
          "format" = "<big>󰥔</big>  {:%a, %d %b, %H:%M}";
          "format-alt" = "<big>󰥔</big>  {:%A; %B %d, %Y (%R)}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "mode" = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ecc6d9'><b>{}</b></span>";
              "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
              "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };
        "custom/weather" = {
          "exec" = "curl -s 'https://wttr.in/?format=1' 2>/dev/null || echo ''";
          "interval" = 3600;
        };
        "cpu" = {
          "interval" = "1";
          "format" = "  {max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>";
          # "max-length" = 13;
          # "min-length" = 13;
          "on-click" = "ghostty -e htop --sort-key PERCENT_CPU";
          "tooltip" = false;
        };
        "temperature" = {
          #"thermal-zone" = 1;
          "interval" = "4";
          "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          "critical-threshold" = 74;
          "format-critical" = "  {temperatureC}°C";
          "format" = "{icon}  {temperatureC}°C";
          "format-icons" = [
            ""
            ""
            ""
          ];
        };
        "pulseaudio" = {
          "scroll-step" = 3; # %, can be a float
          "format" = "{icon} {volume}%";
          "format-bluetooth" = "{volume}% {icon}";
          "format-bluetooth-muted" = "󰝟 {icon}";
          "format-muted" = "󰝟";
          "format-icons" = {
            "headphone" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              ""
              ""
              ""
            ];
            "max-length" = 5;
            "min-length" = 3;
          };
          "on-click" = "pavucontrol";
          "on-click-right" = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };
        "bluetooth" = {
          "interval" = 30;
          "format" = "{icon}";
          # "format-alt" = "{status}";
          "format-icons" = {
            "enabled" = "";
          };
          "on-click" = "blueberry";
        };
        battery = {
          format = "{icon}";

          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          states = {
            battery-10 = 10;
            battery-20 = 20;
            battery-30 = 30;
            battery-40 = 40;
            battery-50 = 50;
            battery-60 = 60;
            battery-70 = 70;
            battery-80 = 80;
            battery-90 = 90;
            battery-100 = 100;
          };

          format-plugged = "󰚥";
          format-charging-battery-10 = "󰢜";
          format-charging-battery-20 = "󰂆";
          format-charging-battery-30 = "󰂇";
          format-charging-battery-40 = "󰂈";
          format-charging-battery-50 = "󰢝";
          format-charging-battery-60 = "󰂉";
          format-charging-battery-70 = "󰢞";
          format-charging-battery-80 = "󰂊";
          format-charging-battery-90 = "󰂋";
          format-charging-battery-100 = "󰂅";
          tooltip-format = "{capacity}% {timeTo}";
        };
        "network" = {
          # "interface" = "wlan0", # (Optional) To force the use of this interface;
          "format-wifi" = "  {essid}";
          "format-ethernet" = "{ifname} = {ipaddr}/{cidr}";
          "format-disconnected" = "󰖪";
          "format-alt" = "{ifname} = {ipaddr}/{cidr}";
          "family" = "ipv4";
          "tooltip-format-wifi" =
            "  {ifname} @ {essid}\nIP = {ipaddr}\nStrength = {signalStrength}%\nFreq = {frequency}MHz\n󰶣 {bandwidthUpBits} 󰶡 {bandwidthDownBits}";
          "tooltip-format-ethernet" = "{ifname}\nIP = {ipaddr}\n󰶣 {bandwidthUpBits} 󰶡 {bandwidthDownBits}";
        };
        "tray" = {
          #"icon-size" = 11;
          "spacing" = 5;
        };
        "custom/wlogout" = {
          "format" = "<big>󰐥</big>";
          "on-click" = "wlogout";
          "tooltip" = false;
        };
      }
    ];
    style = ./style.css;
  };
}
