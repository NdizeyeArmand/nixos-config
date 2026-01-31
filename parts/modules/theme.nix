{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.myConfig.wallpaper;

  wallpaperScript = pkgs.writeScriptBin "wallpaper-cycler" ''
    IMAGE_DIR="${cfg.imageDir}"

    cd "$IMAGE_DIR"
    while true; do
        PID=$(pidof swaybg)
        IMAGE_NUM=$(printf "%03d" $((($(date -u +%s) / 5400) % 16 + 1)))

        if [ -f "./$IMAGE_NUM.png" ]; then
            ${pkgs.swaybg}/bin/swaybg -i "$IMAGE_DIR/$IMAGE_NUM.png" -m fill &
            sleep 1
            kill $PID 2>/dev/null
        fi
        sleep 5399
    done

    def main [
      --interval: duration = 1.5hr
      --num-images: int = 16
    ] {
      let image_dir = "${cfg.imageDir}"

      cd $image_dir
      loop {
        let pid = (^pidof swaybg | complete | get stdout | str trim)

        let image_num = (
          (date now | format date "%s" | into int)
          / ($interval | into int)
          | math floor
          | $in mod $num-images
          | $in + 1
          | into string
          | fill --alignment right --character "0" --width 3
        )

        let image_path = $"./($image_num).png"

        if ($image_path | path exists) {
        ^${pkgs.swaybg}/bin/swaybg -i $"($image_dir)/($image_num).png" -m fill &
        sleep 1sec
          if ($pid != "") {
            ^kill $pid
          }
        }

        sleep ($interval - 1sec)
      }
    }
  '';
in
{
  options.myConfig.wallpaper = {
    enable = lib.mkEnableOption "time-based wallpaper cycling";

    imageDir = lib.mkOption {
      type = lib.types.path;
      default = ./img;
      description = "Directory containing equidistant images (001.png - 016.png)";
    };
    interval = lib.mkOption {
      type = lib.types.str;
      default = "1.5hr";
      description = "How long to show each wallpaper";
    };
    numImages = lib.mkOption {
      type = lib.types.int;
      default = 16;
      description = "Number of images to cycle through";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaybg ];

    systemd.user.services.wallpaper-cycler = {
      Unit = {
        Description = "Time-based wallpaper cycling";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${wallpaperScript} --interval ${cfg.interval} --num-images ${toString cfg.numImages}";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
