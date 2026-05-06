{
  description = "Mocha KDE - repo separado do Mocha GNOME";

  inputs = {
    # Sistema inteiro no unstable para Plasma/KDE novo.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # NordVPN ainda nao esta no nixpkgs usado pelo MochaKde.
    # Input isolado somente para o pacote nordvpn.
    nixpkgs-nordvpn.url = "github:NixOS/nixpkgs/pull/406725/head";

    # Caninana funcional: kernel Cachy/CachyOS como base técnica estudada.
    # Identidade pública/técnica no Mocha: Caninana.
    #
    # Para o casamento 7.0.3, usamos a branch release do nix-cachyos-kernel:
    # - tende a acompanhar o kernel mais novo ja buildado na Hydra/cache do mantenedor;
    # - evita ficar preso em commit antigo;
    # - o modulo caninana-703-kernel.nix ainda valida obrigatoriamente version == 7.0.3.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = inputs@{ self, nixpkgs, nix-cachyos-kernel, nixpkgs-nordvpn, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.mocha-kde-hal = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        nix-cachyos-kernel = inputs.nix-cachyos-kernel;
        inherit inputs;
        nordvpnPkg = (import nixpkgs-nordvpn { inherit system; config.allowUnfree = true; }).nordvpn;
      };

      modules = [
        ./modules/mocha-vpn-modes.nix
        # O nix-cachyos-kernel nao expoe nixosModules.default.
        # Ele expoe overlays; pinned usa os legacyPackages do proprio flake lock.
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
