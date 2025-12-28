{ pkgs, lib, ... }:
{

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";

        modules-left = [ "niri/workspaces" ];
        modules-center = [ "niri/window" ];
        modules-right = [
          "idle_inhibitor"
          "niri/language"
          "pulseaudio"
          "disk"
          "battery"
          "custom/notification"
          "tray"
          "clock"
        ];

        "niri/workspaces" = {
          format = "{icon} {value}";
          format-icons = {
            active = "ï†’";
            default = "ï„‘";
          };
        };

        "niri/window" = {
          icon = true;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "ï®";
            deactivated = "ï°";
          };
        };

        "niri/language" = {
          format = "{short} <sup>{variant}</sup>";
        };
        "pulseaudio" = {
          format = "{icon}";
          format-bluetooth = "{icon} ïŠ”";
          format-muted = "ó°Ÿ";
          format-icons = {
            headphone = "ï€¥";
            default = [
              "ï€§"
              "ï€¨"
            ];
          };
          scroll-step = 1;
          on-click = "${lib.getExe pkgs.pwvucontrol}";
        };

        clock = {
          format = "{:%H:%M} ï€— ";
          format-alt = "{:%A; %B %d, %Y (%R)} ï—¯ ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        battery = {
          format = "{icon}";

          format-icons = [
            "ó°º"
            "ó°»"
            "ó°¼"
            "ó°½"
            "ó°¾"
            "ó°¿"
            "ó°‚€"
            "ó°‚"
            "ó°‚‚"
            "ó°¹"
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

          format-plugged = "ó°š¥";
          format-charging-battery-10 = "ó°¢œ";
          format-charging-battery-20 = "ó°‚†";
          format-charging-battery-30 = "ó°‚‡";
          format-charging-battery-40 = "ó°‚ˆ";
          format-charging-battery-50 = "ó°¢";
          format-charging-battery-60 = "ó°‚‰";
          format-charging-battery-70 = "ó°¢ž";
          format-charging-battery-80 = "ó°‚Š";
          format-charging-battery-90 = "ó°‚‹";
          format-charging-battery-100 = "ó°‚…";
          tooltip-format = "{capacity}% {timeTo}";
        };

        "custom/notification" = {
          format = "{icon}  {}  ";
          tooltip-format = "Left: Open Notification Center\nRight: Toggle Do not Disturb\nMiddle: Clear Notifications";
          format-icons = {
            notification = "ï‚¢<span foreground='red'><sup>ï‘„</sup></span>";
            none = "ï‚¢";
            dnd-notification = "ï‡·<span foreground='red'><sup>ï‘„</sup></span>";
            dnd-none = "ï‡·";
            inhibited-notification = "ï‚¢<span foreground='red'><sup>ï‘„</sup></span>";
            inhibited-none = "ï‚¢";
            dnd-inhibited-notification = "ï‡·<span foreground='red'><sup>ï‘„</sup></span>";
            dnd-inhibited-none = "ï‡·";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          on-click-middle = "swaync-client -C";
          escape = true;
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };
      }
    ];
    style = ''
      #workspaces button {
          color: @base05;
      }
    '';
  };
}
