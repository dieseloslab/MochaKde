# /etc/nixos/flake.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Fonte operacional ativa:
#   /etc/nixos
#
# Regra do projeto:
#   o vmstore/MOCHAFAST e o GitHub são espelho/backup/sincronização;
#   o sistema ativo não deve depender operacionalmente de /mnt/vmstore
#   nem de /media/mochafast.
#
# Modo atual:
#   trilha de teste em nixos-unstable com kernel Zen upstream.

{
  description = "Diesel OS Lab - GNOME Mocha Edition";

  inputs = {
    # Nixpkgs principal / canal principal do Mocha.
    #
    # MODO DE TESTE:
    #   Mocha inteiro apontando para nixos-unstable.
    #
    # Objetivo:
    #   testar kernel, NVIDIA, GNOME, Mesa, systemd, GTK, PipeWire,
    #   Vulkan, Steam stack e demais pacotes antes de decidir se isso
    #   vira base permanente.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Input separado mantido por compatibilidade com a arquitetura atual.
    #
    # Neste modo de teste, ele também aponta para nixos-unstable para evitar
    # mistura entre canal principal e kernel pinado antigo.
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Kernel Zen upstream mais recente para teste.
    #
    # Nao vem do linuxPackages_zen do nixpkgs, porque neste momento o nixpkgs
    # ainda esta atras do upstream do Zen.
    zen-kernel = {
      url = "github:zen-kernel/zen-kernel/v7.0.2-zen1";
      flake = false;
    };

    # Home Manager mínimo.
    # O nixpkgs dele segue exatamente o nixpkgs principal do Mocha.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-kernel,
      zen-kernel,
      home-manager,
      ...
    }:

    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      pkgsKernel = import nixpkgs-kernel {
        inherit system;
        config.allowUnfree = true;
      };

      commonSpecialArgs = {
        mochaRoot = ./.;
        zenKernelSrc = zen-kernel;
        inherit pkgsKernel;
      };
    in
    {
      # Sistema instalado principal.
      #
      # Este é o alvo operacional real da máquina instalada.
      # Não deve importar a ISO.
      nixosConfigurations.diesel-os-lab = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = commonSpecialArgs;

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          ./modules/home-manager.nix
        ];
      };

      # ISO Live do Diesel OS Lab - GNOME Mocha Edition.
      #
      # Importante:
      # - não importa hardware-configuration.nix do desktop;
      # - não importa vmstore.nix;
      # - não importa optional-apps.nix;
      # - não inclui VMware;
      # - usa kernel Zen 7.0.2 no Live;
      # - mantém pt_BR, en_US, es_ES e fr_FR;
      # - aplica o visual Mocha de forma global/system-wide;
      # - deve ser testada primeiro no virt-manager/QEMU-KVM.
      nixosConfigurations.mocha-iso = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = commonSpecialArgs;

        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix")
          ./iso/mocha-iso.nix
        ];
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
