{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  system.stateVersion = "25.05";

  nixpkgs.overlays = [
    (final: prev: {
      unstable = inputs.unstable.legacyPackages.${prev.system};
      mopidy = inputs.unstable.legacyPackages.${prev.system}.mopidy;
    })
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-substituters = [
    "https://nabam-nixos-rockchip.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nabam-nixos-rockchip.cachix.org-1:BQDltcnV8GS/G86tdvjLwLFz1WeFqSk7O9yl+DR0AVM"
  ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  networking.hostName = "rock4se";
  zramSwap.enable = true;

  age.secrets.wifi.file = ./secrets/wifi.age;
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      PLAMPER_SQ36.pskRaw = "ext:psk_home";
    };
    secretsFile = config.age.secrets.wifi.path;
  };

  hardware.enableAllFirmware = true;
  hardware.deviceTree.enable = true;

  services.openssh.enable = true;
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    alsa-utils
    cifs-utils
    helix
    tmux
  ];

  fileSystems."/mnt/music" = {
    device = "//Diener-F2/music";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users,ro";

      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets,uid=130,gid=130" ];
    # or if you have specified `uid` and `gid` explicitly through NixOS configuration,
    # you can refer to them rather than hard-coding the values:
    # in ["${automount_opts},credentials=/etc/nixos/smb-secrets,${config.users.users.<username>.uid},gid=${config.users.groups.<group>.gid}"];
  };

  users.users.admin = {
    isNormalUser = true;
    home = "/home/admin";
    description = "Admin user";
    extraGroups = [
      "wheel"
      "networkmanager"
      "pipewire"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKqykgN7RuOz+6YCDWYTeXfGKRHT5VXG/LJWGN1zFro felix@pc"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs.unstable; [
      mopidy-iris
      mopidy-jellyfin
      mopidy-tidal
      mopidy-tunein
      mopidy-local
    ];
    settings = {
      tidal.quality = "HI_RES_LOSSLESS";
      http = {
        port = 8080;
        hostname = "0.0.0.0";
      };
      iris = {
        locale = "de_DE";
        country = "de";
      };
      audio.output = "alsasink device=hw:2,0";
      jellyfin = {
        hostname = "192.168.178.141";
        username = "Mopidy";
        password = "";
      };
      local.media_dir = "/mnt/music";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
