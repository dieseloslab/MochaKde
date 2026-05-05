{ config, lib, pkgs, ... }:

let
  expectedKernelVersion = "7.0.3";
  expectedKernelPname = "linux-cachyos-latest";
in
{
  # MochaKde / Caninana 7.0.3 — primeiro casamento moderno.
  #
  # Objetivo:
  #   testar o kernel Cachy/Caninana 7.0.3,
  #   mantendo MochaKde em nixos-unstable e casando com NVIDIA latest.
  #
  # Regras:
  #   - isto e experimento separado da receita boa 7.0.1;
  #   - nao tratar 7.0.2 como 7.0.3;
  #   - nao renomear pname para linux-caninana;
  #   - validar por assertions antes de build/boot;
  #   - boot somente depois de dry-build e build passarem;
  #   - nunca usar switch como padrao.

  system.nixos.tags = [
    "mochakde"
    "caninana703-experiment"
    "nvidia-latest"
    "nixos-unstable"
  ];

  boot.kernelPackages =
    lib.mkOverride 30 pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  specialisation = lib.mkForce { };

  assertions = [
    {
      assertion = config.boot.kernelPackages.kernel.version == expectedKernelVersion;
      message = ''
        MochaKde Caninana 7.0.3 abortado:
        o kernel avaliado deveria ser ${expectedKernelVersion},
        mas foi ${config.boot.kernelPackages.kernel.version}.

        Isso significa que o input nix-cachyos-kernel/release ainda nao entrega 7.0.3,
        ou que linuxPackages-cachyos-latest mudou para outra versao.
      '';
    }
    {
      assertion = config.boot.kernelPackages.kernel.pname == expectedKernelPname;
      message = ''
        MochaKde Caninana 7.0.3 abortado:
        o pname esperado era ${expectedKernelPname},
        mas foi ${config.boot.kernelPackages.kernel.pname}.

        Nao renomear para linux-caninana neste experimento.
      '';
    }
    {
      assertion = config.hardware.nvidia.package.version == config.boot.kernelPackages.nvidiaPackages.latest.version;
      message = ''
        MochaKde Caninana 7.0.3 abortado:
        NVIDIA deveria ser kernelPackages.nvidiaPackages.latest.

        NVIDIA avaliado:
          ${config.hardware.nvidia.package.version}

        latest disponivel:
          ${config.boot.kernelPackages.nvidiaPackages.latest.version}
      '';
    }
  ];

  environment.etc."mocha-kde/caninana-703-experiment.txt".text = ''
    identity = Caninana
    experiment = caninana-703-nvidia-latest
    expected_kernel_version = ${expectedKernelVersion}
    expected_kernel_pname = ${expectedKernelPname}
    expected_nvidia_source = config.boot.kernelPackages.nvidiaPackages.latest
    nixpkgs_channel = nixos-unstable
    nix_cachyos_kernel_branch = release
    rule = dry-build, build, then boot; never switch by default
    rule = do not treat 7.0.2 as 7.0.3
    rule = do not rename pname to linux-caninana
  '';
}
