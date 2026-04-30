# Mocha KDE - build isolado do Linux Zen 7.0.2-zen1
#
# Nao altera o sistema.
# Testa:
# - Linux Zen 7.0.2-zen1
# - NVIDIA 595.71.05 com os hashes usados no /etc/nixos atual

{ system ? "x86_64-linux" }:

let
  oldNixpkgsSrc = builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "0726a0ecb6d4e08f6adced58726b95db924cef57";
    narHash = "sha256-EHq1/OX139R1RvBzOJ0aMRT3xnWyqtHBRUBuO1gFzjI=";
  };

  pkgs = import oldNixpkgsSrc {
    inherit system;
    config.allowUnfree = true;
  };

  lib = pkgs.lib;

  zenVersion = "7.0.2";
  zenSuffix = "zen1";

  mkKernelOverride = lib.mkOverride 90;

  # Usar builtins.path em vez de pkgs.fetchurl file://.
  # Motivo: fetchurl roda em builder isolado e pode nao conseguir abrir /media/mochafast.
  # builtins.path copia o tarball local para a Nix store antes do build.
  zenKernelSrc = builtins.path {
    path = /media/mochafast/MochaKde/kde/kernel/zen-7.0.2-upstream/tarballs/zen-kernel-v7.0.2-zen1-source.tar.xz;
    name = "zen-kernel-v7.0.2-zen1-source.tar.xz";
  };

  linuxZenUpstream = pkgs.linuxKernel.kernels.linux_zen.override {
    argsOverride = rec {
      version = zenVersion;
      modDirVersion = lib.versions.pad 3 "${version}-${zenSuffix}";
      src = zenKernelSrc;

      structuredExtraConfig = with lib.kernel; {
        ZEN_INTERACTIVE = yes;

        NET_SCH_DEFAULT = yes;
        DEFAULT_FQ_CODEL = yes;

        PREEMPT = mkKernelOverride yes;
        PREEMPT_LAZY = mkKernelOverride no;

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

        IOSCHED_BFQ = mkKernelOverride yes;

        FUTEX = yes;
        FUTEX_PI = yes;

        NTSYNC = yes;

        HZ = freeform "1000";
        HZ_1000 = yes;
      };
    };
  };

  linuxPackagesZen7 = pkgs.linuxPackagesFor linuxZenUpstream;

  nvidia595 = linuxPackagesZen7.nvidiaPackages.mkDriver {
    version = "595.71.05";

    sha256_64bit = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";

    # Ignorado em x86_64. Mantido fake apenas para satisfazer a assinatura do mkDriver.
    sha256_aarch64 = lib.fakeHash;

    openSha256 = "sha256-Lfz71QWKM6x/jD2B22SWpUi7/og30HRlXg1kL3EWzEw=";
    settingsSha256 = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
    persistencedSha256 = "sha256-Z/6IvEEa/XfZ5F5qoSIPvXJLGtscYVqjFxHZaN/M2Ts=";
  };
in
{
  kernel = linuxPackagesZen7.kernel;
  kernelPackages = linuxPackagesZen7;

  nvidia595 = nvidia595;

  kernelVersion = linuxPackagesZen7.kernel.version;
  nvidiaProductionVersion = linuxPackagesZen7.nvidiaPackages.production.version;
  nvidia595Version = nvidia595.version;
}
