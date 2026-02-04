{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.myConfig.wallpaper;

  wallpaperScript = pkgs.writeScriptBin "wallpaper-cycler" ''
    #!${pkgs.nushell}/bin/nu

    def main [
      --interval: string = "1.5hr"
      --num_images: int = 16
    ] {
      let image_dir = "${cfg.imageDir}"
      cd $image_dir

      mut loop_count = 0

      loop {
        $loop_count = $loop_count + 1
        #print $"Loop iteration: ($loop_count)"
        
        # Calculate which image to show
        let now = (date now)
        let seconds_today = (
                            ($now | format date '%H' | into int) * 3600 +
                            ($now | format date '%M' | into int) * 60 +
                            ($now | format date '%S' | into int)
        )

        let interval_duration = ($interval | into duration) 
        let interval_seconds = ($interval_duration / 1sec) # Convert duration from nanoseconds to seconds
        let division_result = ($seconds_today / $interval_seconds)
        let mod_result = (($division_result | math floor) mod $num_images)
        let image_num = (
          ($mod_result + 1)
          | into string
          | fill --alignment right --character "0" --width 3
        )

        #print $"Debug: current_time=($now), interval=($interval_seconds), division=($division_result), mod=($mod_result), image_num=($image_num)"

        let image_path = $"($image_dir)/($image_num).png"
      
        if not ($image_path | path exists) {
          #print $"ERROR: Image not found: ($image_path)"
        } else {
          #print $"Setting wallpaper: ($image_path)"
          
          ^${pkgs.bash}/bin/bash -c $"${pkgs.swaybg}/bin/swaybg -i '($image_path)' -m fill & disown"

          sleep 1sec

          let all_pids = (ps | where name =~ swaybg | get pid)
          let old_pids = ($all_pids | drop)
          for pid in $old_pids {
            try { ^kill $pid } catch { }
          }
        }
        sleep 1min
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
      };

      Service = {
        Type = "simple";
        ExecStart = "${wallpaperScript}/bin/wallpaper-cycler --interval ${cfg.interval} --num_images ${toString cfg.numImages}";
        Restart = "always";
        RestartSec = "10s";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
