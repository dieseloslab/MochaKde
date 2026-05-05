# MochaKde shared Caninana consumer
#
# STATUS:
# - Experimental.
# - Not imported by flake.nix.
# - Not active.
# - Does not change kernel, NVIDIA, bootloader, or /etc/nixos by itself.
#
# Purpose:
# This module is a consumer contract stub for the shared CaninanaMatrix
# kernel/NVIDIA layer. It records the intended shared source of truth and
# exposes options for a future, audited activation step.

{ config, lib, pkgs, ... }:

let
  cfg = config.mocha.sharedCaninanaConsumer;
in
{
  options.mocha.sharedCaninanaConsumer = {
    enable = lib.mkEnableOption "Mocha shared Caninana consumer contract stub";

    matrixRoot = lib.mkOption {
      type = lib.types.str;
      default = "/media/mochafast/CaninanaMatrix";
      description = "Shared CaninanaMatrix root. This is the canonical kernel/NVIDIA reference layer.";
    };

    sharedArtifactsRoot = lib.mkOption {
      type = lib.types.str;
      default = "/media/mochafast/shared-kernel-video";
      description = "External heavy artifact store for shared kernel/video caches.";
    };

    kernelVersion = lib.mkOption {
      type = lib.types.str;
      default = "7.0.1";
      description = "Expected Caninana kernel version for the non-aggressive consumer path.";
    };

    nvidiaVersion = lib.mkOption {
      type = lib.types.str;
      default = "595.71.05";
      description = "Expected NVIDIA driver version for the shared recipe contract.";
    };

    profile = lib.mkOption {
      type = lib.types.enum [ "non-aggressive-701" "comparison-703" "aggressive-703" ];
      default = "non-aggressive-701";
      description = "Consumer profile. This stub defaults to the non-aggressive 7.0.1 recipe.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.profile == "non-aggressive-701";
        message = "Only non-aggressive-701 is allowed by this initial consumer stub. Do not enable 703/aggressive here.";
      }
      {
        assertion = cfg.kernelVersion == "7.0.1";
        message = "Initial MochaKde shared Caninana consumer must stay on kernel 7.0.1.";
      }
      {
        assertion = cfg.nvidiaVersion == "595.71.05";
        message = "Initial MochaKde shared Caninana consumer expects NVIDIA 595.71.05.";
      }
    ];

    environment.etc."mocha-kde/shared-caninana-consumer.txt".text = ''
      MochaKde shared Caninana consumer contract

      STATUS:
      - This marker exists only if the module is explicitly imported and enabled.
      - The initial stub does not select or build a kernel by itself.
      - Kernel/NVIDIA activation still requires a separate audited module.

      matrixRoot=${cfg.matrixRoot}
      sharedArtifactsRoot=${cfg.sharedArtifactsRoot}
      profile=${cfg.profile}
      kernelVersion=${cfg.kernelVersion}
      nvidiaVersion=${cfg.nvidiaVersion}

      Required contract:
      ${cfg.matrixRoot}/contracts/shared-kernel-video/CONTRATO-CONSUMO-CANINANA-SHARED.md

      Required recipe:
      ${cfg.matrixRoot}/recipes/shared-kernel-video/caninana701-bin-lto-nao-agressiva/RECEITA-COMPARTILHADA-CANINANA701-BIN-LTO-NAO-AGRESSIVA.md

      Required artifacts index:
      ${cfg.matrixRoot}/artifacts-index/shared-kernel-video/INDEX-SHARED-KERNEL-VIDEO-CURRENT.md
    '';
  };
}
