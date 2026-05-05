{ config, lib, pkgs, ... }:

{
  # MochaKde Caninana 7.0.1 — receita boa validada.
  #
  # IMPORTANTE:
  # A receita boa encontrada em 2026-05-03 NÃO era o kernel renomeado
  # como linux-caninana. Era o linux-cachyos-latest 7.0.1 funcional/cacheado,
  # com identidade pública/técnica Caninana no projeto Mocha.
  #
  # Fonte:
  # /media/mochafast/Caninana/caninana-701-cacheado-nvidia595-good-20260503-182353
  #
  # Não importar kernel-caninana-701-recompiled.nix para esta receita.
  # Não mudar pname para linux-caninana.
  # Não recompilar kernel só para mudar nome.

  system.nixos.tags = [
    "mochakde"
    "caninana701-good-recipe"
    "nvidia595"
  ];

  boot.kernelPackages =
    lib.mkOverride 30 pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  assertions = [
    {
      assertion = config.boot.kernelPackages.kernel.version == "7.0.1";
      message = ''
        MochaKde abortado: a receita boa esperava kernel 7.0.1,
        mas o kernel avaliado foi ${config.boot.kernelPackages.kernel.version}.
      '';
    }
    {
      assertion = config.boot.kernelPackages.kernel.pname == "linux-cachyos-latest";
      message = ''
        MochaKde abortado: a receita boa esperava pname linux-cachyos-latest,
        sem renomear/recompilar para linux-caninana.

        pname avaliado: ${config.boot.kernelPackages.kernel.pname}
      '';
    }
    {
      assertion = config.hardware.nvidia.package.version == "595.71.05";
      message = ''
        MochaKde abortado: Caninana 7.0.1 precisa de NVIDIA 595.71.05,
        mas a versão avaliada foi ${config.hardware.nvidia.package.version}.
      '';
    }
  ];

  environment.etc."mocha-kde/caninana-good-recipe.txt".text = ''
    identity = Caninana
    functional_kernel = linux-cachyos-latest
    expected_kernel_version = 7.0.1
    expected_uname_pattern = 7.0.1-cachyos
    expected_nvidia_version = 595.71.05

    source_good_state = /media/mochafast/Caninana/caninana-701-cacheado-nvidia595-good-20260503-182353
    source_rooted_state = /media/mochafast/Caninana/caninana-701-nvidia595-rooted-20260503-222345

    rule = do not rename pname; do not import kernel-caninana-701-recompiled.nix for the good recipe.
  '';
}
