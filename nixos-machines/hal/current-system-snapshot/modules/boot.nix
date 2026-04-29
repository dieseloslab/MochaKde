# /etc/nixos/modules/boot.nix

{ pkgs, lib, zenKernelSrc, ... }:

let
  zenVersion = "7.0.2";
  zenSuffix = "zen1";

  # Mesma prioridade usada pelo linux_zen do nixpkgs.
  # Serve para manter os ajustes Zen acima do common-config,
  # mas ainda permitir override manual futuro com mkForce.
  mkKernelOverride = lib.mkOverride 90;

  linuxZenUpstream = pkgs.linuxKernel.kernels.linux_zen.override {
    argsOverride = rec {
      version = zenVersion;
      modDirVersion = lib.versions.pad 3 "${version}-${zenSuffix}";
      src = zenKernelSrc;

      # Diesel OS Lab - GNOME Mocha Edition
      #
      # Adaptação experimental do linux_zen do nixpkgs para Zen/Linux 7.0.2.
      #
      # Motivo:
      #   O linux_zen atual do nixpkgs ainda define PREEMPT_VOLUNTARY = no.
      #   No Linux 7.0 essa opção não existe mais para o nosso alvo x86_64
      #   moderno, então o gerador de configuração aborta com:
      #
      #     error: unused option: PREEMPT_VOLUNTARY
      #
      # Estratégia:
      #   copiar os ajustes principais do linux_zen do nixpkgs,
      #   remover PREEMPT_VOLUNTARY,
      #   manter PREEMPT full e desativar PREEMPT_LAZY para baixa latência.
      structuredExtraConfig = with lib.kernel; {
        # Zen Interactive tuning
        ZEN_INTERACTIVE = yes;

        # FQ-Codel Packet Scheduling
        NET_SCH_DEFAULT = yes;
        DEFAULT_FQ_CODEL = yes;

        # Preempt low-latency.
        #
        # No Linux 7.0, nao declarar PREEMPT_VOLUNTARY.
        PREEMPT = mkKernelOverride yes;
        PREEMPT_LAZY = mkKernelOverride no;

        # Preemptible tree-based hierarchical RCU
        TREE_RCU = yes;
        PREEMPT_RCU = yes;
        RCU_EXPERT = yes;
        TREE_SRCU = yes;
        TASKS_RCU_GENERIC = yes;
        TASKS_RCU = yes;
        TASKS_RUDE_RCU = yes;
        TASKS_TRACE_RCU = yes;
        RCU_STALL_COMMON = yes;
        RCU_NEED_SEGCBLIST = yes;
        RCU_FANOUT = freeform "64";
        RCU_FANOUT_LEAF = freeform "16";
        RCU_BOOST = yes;
        RCU_BOOST_DELAY = option (freeform "500");
        RCU_NOCB_CPU = yes;
        RCU_LAZY = yes;
        RCU_DOUBLE_CHECK_CB_TIME = yes;

        # BFQ I/O scheduler
        IOSCHED_BFQ = mkKernelOverride yes;

        # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
        FUTEX = yes;
        FUTEX_PI = yes;

        # NT synchronization primitive emulation
        NTSYNC = yes;

        # Preemptive Full Tickless Kernel at 1000Hz
        HZ = freeform "1000";
        HZ_1000 = yes;
      };
    };
  };
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel principal do Mocha.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Fallback conservador para o sistema instalado.
  #
  # Objetivo:
  #   manter o Zen 7.0.2 como padrão, mas oferecer uma opção de boot
  #   com kernel 6.12 caso algum hardware, driver NVIDIA ou regressão
  #   futura tenha problema com o kernel principal.
  #
  # Avaliado neste flake:
  #   pkgs.linuxPackages_6_12.kernel.version = 6.12.83
  #   pkgs.linuxPackages_6_12.nvidiaPackages.production.version = 595.58.03
  specialisation.mocha-lts-fallback.configuration = {
    system.nixos.tags = [ "mocha-lts-fallback" ];

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;

    hardware.nvidia.package =
      lib.mkForce pkgs.linuxPackages_6_12.nvidiaPackages.production;
  };

  boot.resumeDevice = "/dev/disk/by-uuid/84b307a9-d28a-44a8-8f86-9346f717d73d";

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 40;
    priority = 100;
  };

  hardware.enableRedistributableFirmware = true;
}
