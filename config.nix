{
  config,
  pkgs,
  lib,
  ...
}:
{
  system.stateVersion = "25.05";

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
  nix.settings.trusted-users = ["root" "@wheel"];

  networking.hostName = "rock4se";
  zramSwap.enable = true;

  networking.wireless = {
    enable = true;
    userControlled.enable = true;
  };

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.admin = {
    isNormalUser = true;
    home = "/home/admin";
    description = "Admin user";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKqykgN7RuOz+6YCDWYTeXfGKRHT5VXG/LJWGN1zFro felix@pc"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire."10-clock-rate"."context.properties" = {
      "default.clock.rate" = 44100;
      "default.clock.allowed-rates" = [
        44100
        48000
        88200
        96000
        176400
        192000
        352800
        384000
        705600
        768000
      ];
    };
  };

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-iris
      mopidy-jellyfin
      mopidy-tidal
      mopidy-tunein
      mopidy-local
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
