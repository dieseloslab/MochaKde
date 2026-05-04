{
  description = "Mocha KDE - repo separado do Mocha GNOME";

  inputs = {
    # Sistema inteiro no unstable para Plasma/KDE novo.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Caninana funcional: kernel Cachy/CachyOS como base técnica estudada.
    # Identidade pública/técnica no Mocha: Caninana.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/0f7e2bea4088227a80502557f6c0e3b74949d6b5";
  };

  outputs = inputs@{ self, nixpkgs, nix-cachyos-kernel, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.mocha-kde-hal = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { nix-cachyos-kernel = inputs.nix-cachyos-kernel;
        inherit inputs;
      };

      modules = [
        # O nix-cachyos-kernel não expõe nixosModules.default.
        # Ele expõe overlays; pinned usa os legacyPackages do próprio flake lock.
        ({ ... }: {
          nixpkgs.overlays = [
            nix-cachyos-kernel.overlays.pinned
          ];
        })

        ./nixos-machines/hal/configuration.nix
      ];
    };
  };
}
