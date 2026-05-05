{ config, lib, pkgs, ... }:

{
  # MochaKde / Caninana - ajustes conservadores de desempenho para jogos.
  #
  # Objetivo:
  #   manter o casamento Caninana 7.0.3 + NVIDIA 595.71.05 aprovado por jogabilidade
  #   e aplicar ajustes próprios inspirados em práticas gamer/Cachy, sem trocar kernel,
  #   sem trocar driver NVIDIA e sem mexer no tema KDE.
  #
  # Escopo:
  #   - tuned como dono do perfil de performance;
  #   - sysctl seguro para jogos;
  #   - limites de arquivo/mapas para jogos e Proton;
  #   - THP em madvise;
  #   - scheduler de IO sem forçar em dispositivo inexistente.
  #
  # Fora do escopo:
  #   - nada de LTO;
  #   - nada de renomear kernel para linux-caninana;
  #   - nada de trocar NVIDIA 595.71.05 neste experimento;
  #   - nada de switch.

  system.nixos.tags = [
    "caninana-performance-tweaks"
  ];

  # Tuned continua sendo o dono do perfil de performance do Mocha.
  services.tuned.enable = true;
  power-profiles-daemon.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    tuned
    pciutils
    usbutils
    lm_sensors
  ];

  # Perfil padrão esperado para jogos.
  systemd.services.mocha-tuned-latency-performance = {
    description = "Mocha: set tuned latency-performance profile";
    wantedBy = [ "multi-user.target" ];
    after = [ "tuned.service" ];
    wants = [ "tuned.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tuned}/bin/tuned-adm profile latency-performance";
    };
  };

  # Ajustes conservadores para jogos/Proton.
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "vm.swappiness" = lib.mkDefault 10;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
    "fs.file-max" = 2097152;
    "kernel.nmi_watchdog" = lib.mkDefault 0;
    "kernel.sched_autogroup_enabled" = lib.mkDefault 0;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  userborn.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  # THP em madvise: menos agressivo que always, mas disponível para workloads que pedirem.
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise"
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - madvise"
  ];

  # Scheduler de IO:
  # - NVMe geralmente fica melhor em none;
  # - SATA/rotacional ou USB pode usar mq-deadline quando disponível;
  # - regra ignora erro se scheduler não existir.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';

  environment.etc."mocha-kde/caninana-performance-tweaks.txt".text = ''
    profile = caninana-cachy-performance-tweaks
    tuned = latency-performance
    vm.max_map_count = 2147483642
    vm.swappiness = 10
    vm.vfs_cache_pressure = 50
    nofile = 1048576
    thp = madvise
    nvme_scheduler = none
    sata_usb_scheduler = mq-deadline
    rule = keep Caninana 7.0.3
    rule = keep NVIDIA 595.71.05 unless explicitly testing another marriage
  '';

  assertions = [
    {
      assertion = config.boot.kernelPackages.kernel.version == "7.0.3";
      message = "Caninana performance tweaks abortado: kernel esperado 7.0.3.";
    }
    {
      assertion = config.boot.kernelPackages.kernel.pname == "linux-cachyos-latest";
      message = "Caninana performance tweaks abortado: pname esperado linux-cachyos-latest.";
    }
    {
      assertion = config.hardware.nvidia.package.version == "595.71.05";
      message = "Caninana performance tweaks abortado: NVIDIA esperada 595.71.05.";
    }
  ];
}
