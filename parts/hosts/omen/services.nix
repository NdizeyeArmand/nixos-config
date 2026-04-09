{ pkgs, ... }:

{
  # services.nextcloud = {
  #  enable = true;
  #  hostName = "nextcloud.tld";
  #  database.createLocally = true;
  #  config = {
  #    dbtype = "pgsql";
  #    adminpassFile = "/path/to/admin-pass-file";
  #  };
  # };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 5432 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "armand" ];
    };
  };

  services.gnome.gcr-ssh-agent.enable = false;
  programs.ssh = {
    startAgent = true;
  };
  programs.ssh.knownHosts = {
    "gitlab.com" = {
      hostNames = [ "gitlab.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.blueman.enable = true;

  systemd.services.bluetooth-off-on-resume = {
    description = "Turn Bluetooth off after resume";
    after = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block bluetooth";
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}
