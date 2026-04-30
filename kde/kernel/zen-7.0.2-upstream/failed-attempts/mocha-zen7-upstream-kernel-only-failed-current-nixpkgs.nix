#
# Mocha KDE / Diesel OS Lab
# Teste temporario: Linux Zen 7.0.2-zen1 upstream.
#
# IMPORTANTE:
# Este modulo mexe somente em boot.kernelPackages.
# Nao altera hardware.nvidia.package, versao do driver NVIDIA,
# opcoes NVIDIA, modesetting, power management, zram, resumeDevice ou sysctl.

{ pkgs, lib, ... }:

let
  zenVersion = "7.0.2";
  zenSuffix = "zen1";

  # Fonte exata do commit antigo:
  # github:zen-kernel/zen-kernel/v7.0.2-zen1
  zenKernelSrc = builtins.fetchTree {
    type = "github";
    owner = "zen-kernel";
    repo = "zen-kernel";
    rev = "98afbf0506fe33739ea71de65f0c625f97d34ef4";
    narHash = "sha256-LOrMcvSV2JPcjmSTukFz4cNiCAvgL/dBJ4JbebJ+VUY=";
  };

  mkKernelOverride = lib.mkOverride 90;

  linuxZenUpstream = pkgs.linuxKernel.kernels.linux_zen.override {
    argsOverride = rec {
      version = zenVersion;
      modDirVersion = lib.versions.pad 3 "${version}-${zenSuffix}";
      src = zenKernelSrc;

      structuredExtraConfig = with lib.kernel; {
        # Zen Interactive tuning
        ZEN_INTERACTIVE = yes;

        # FQ-Codel Packet Scheduling
        NET_SCH_DEFAULT = yes;
        DEFAULT_FQ_CODEL = yes;

        # Preempt low-latency.
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
  boot.kernelPackages = lib.mkOverride 10 (pkgs.linuxPackagesFor linuxZenUpstream);
}
