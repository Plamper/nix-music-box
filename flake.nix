{
  description = "Music Box on Rock4SE";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    rockchip = {
      url = "github:Plamper/nixos-rockchip/newer-uboot";
    };

    deploy-rs.url = "github:serokell/deploy-rs";

    agenix.url = "github:ryantm/agenix";
  };

  # Use cache with packages from nabam/nixos-rockchip CI.
  nixConfig = {
    extra-substituters = [ "https://nabam-nixos-rockchip.cachix.org" ];
    extra-trusted-public-keys = [
      "nabam-nixos-rockchip.cachix.org-1:BQDltcnV8GS/G86tdvjLwLFz1WeFqSk7O9yl+DR0AVM"
    ];
  };

  outputs =
    {
      self,
      deploy-rs,
      nixpkgs,
      rockchip,
      agenix,
      ...
    }@inputs:
    let

      osConfig =
        buildPlatform:
        nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            rockchip.nixosModules.sdImageRockchip
            agenix.nixosModules.default
            ./config.nix
            {
              # Use cross-compilation for uBoot and Kernel.
              rockchip.uBoot = rockchip.packages.${buildPlatform}.uBootRadxaRock4SE;
              boot.kernelPackages = rockchip.legacyPackages.${buildPlatform}.kernel_linux_6_12_rockchip;
              # nixpkgs.crossSystem = {
              #   # target platform
              #   system = "aarch64-linux";
              # };
            }
          ];
        };
    in
    {
      # Set buildPlatform to "x86_64-linux" to benefit from cross-compiled packages in the cache.
      nixosConfigurations.rock4se = osConfig "x86_64-linux";

      # Or use configuration below to compile kernel and uBoot on device.
      # nixosConfigurations.rock4se = osConfig "aarch64-linux";
       
      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      deploy.nodes.rock4se = {
        hostname = "rock4se";
        sshUser = "admin";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rock4se;
        };
      };

    }
    // inputs.utils.lib.eachDefaultSystem (system: {
      # Set buildPlatform to "x86_64-linux" to benefit from cross-compiled packages in the cache.
      # packages.image = (osConfig "x86_64-linux").config.system.build.sdImage;

      # Or use configuration below to cross-compile kernel and uBoot on the current platform.
      packages.image = (osConfig system).config.system.build.sdImage;

      packages.default = self.packages.${system}.image;

      devShell = (
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nix
            agenix.packages.${system}.default
            nixd
            git
            deploy-rs.packages.${system}.default
          ];
        }
      );
    });
}
