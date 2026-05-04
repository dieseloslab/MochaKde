# /etc/nixos/modules/kernel-caninana-701-recompiled.nix
#
# Caninana 7.0.1 experimental.
#
# Recompila a base técnica linux-cachyos-latest 7.0.1 como linux-caninana.
# Os nomes cachyosKernels/linux-cachyos são identificadores funcionais do build Nix.
# A identidade pública/técnica do experimento é Caninana.
#
# Referências estudadas:
# Gentoo flags/compilação; kernel Cachy/CachyOS; Garuda; Manjaro;
# Fedora/Nobara/Bazzite; SteamOS/ChimeraOS; Ubuntu Studio/Ubuntu GamePack;
# e outras bases gamer/multimídia.
#
# As melhores ideias são adaptadas, modificadas e recompiladas para o Mocha
# em base Nix/NixOS reprodutível.

{ config, lib, pkgs, ... }:

let
  caninanaBuildId = "20260503-160942";

  baseKernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  baseKernel = baseKernelPackages.kernel;

  caninanaKernel = baseKernel.overrideAttrs (old: {
    pname = "linux-caninana";
    name = "linux-caninana-7.0.1-20260503-160942";

    passthru = (old.passthru or {}) // {
      caninana = true;
      caninanaBuildId = caninanaBuildId;
      caninanaDescription = "Caninana 7.0.1 recompilado para Mocha/CachyComp";
    };

    meta = (old.meta or {}) // {
      description = "Caninana 7.0.1 kernel for Mocha/CachyComp";
    };
  });

  caninanaPackages = pkgs.linuxPackagesFor caninanaKernel;
in
{
  system.nixos.tags = [ "caninana701-final-20260503-160942" ];

  # Prioridade 1 vence o kernel-cachycomp.nix, que usa mkOverride 30.
  boot.kernelPackages = lib.mkOverride 1 caninanaPackages;

  assertions = [
    {
      assertion = config.boot.kernelPackages.kernel.version == "7.0.1";
      message = "Caninana abortado: kernel não é 7.0.1.";
    }
    {
      assertion = config.boot.kernelPackages.kernel.pname == "linux-caninana";
      message = "Caninana abortado: pname do kernel não é linux-caninana.";
    }
    {
      assertion = config.hardware.nvidia.package.version == "595.71.05";
      message = "Caninana abortado: NVIDIA não é 595.71.05.";
    }
  ];
}
