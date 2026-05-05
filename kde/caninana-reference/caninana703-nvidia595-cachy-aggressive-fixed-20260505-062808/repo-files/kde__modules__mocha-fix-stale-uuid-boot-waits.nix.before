{ lib, ... }:

{
  # MochaKde - correcao de boot para UUID fantasma / swap antigo.
  #
  # Motivo:
  #   impedir systemd/initrd de ficar esperando /dev/disk/by-uuid/*
  #   que nao existe mais, como visto no boot com "A start job is running".
  #
  # Este modulo nao apaga disco, nao formata, nao monta nada manualmente.
  # Ele corrige declaracoes Nix para apontarem para UUIDs reais ou
  # para tornar mounts antigos nao-bloqueantes.

  # Swap fisico real detectado para manter hibernate/resume.
  boot.resumeDevice = lib.mkForce "/dev/disk/by-uuid/4f20952d-3696-40ee-bd26-61b0a090ee7d";

  swapDevices = lib.mkForce [
    {
      device = "/dev/disk/by-uuid/4f20952d-3696-40ee-bd26-61b0a090ee7d";
      priority = 5;
    }
  ];

  boot.kernelParams = lib.mkForce [
    "loglevel=4"
    "lsm=landlock,yama,bpf"
    "nvidia-drm.fbdev=1"
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "root=fstab"
    "resume=/dev/disk/by-uuid/4f20952d-3696-40ee-bd26-61b0a090ee7d"
  ];

  # UUID fantasma detectado:
  # mountpoint = /
  # declared_device = /dev/disk/by-uuid/5eaf95da-11ab-487a-bed7-34d77e9368f6
  # current_source = /dev/nvme0n1p2
  # current_uuid = 61448713-bb1b-43c3-9ffe-98f6421c0658
  fileSystems."/".device = lib.mkForce "/dev/disk/by-uuid/61448713-bb1b-43c3-9ffe-98f6421c0658";
  fileSystems."/".options = lib.mkAfter [ "x-systemd.device-timeout=10s" ];

  # UUID fantasma detectado:
  # mountpoint = /boot
  # declared_device = /dev/disk/by-uuid/1504-BC3A
  # current_source = /dev/nvme0n1p1
  # current_uuid = 4254-8B81
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/4254-8B81";
  fileSystems."/boot".options = lib.mkAfter [ "x-systemd.device-timeout=10s" ];

  # UUID fantasma detectado:
  # mountpoint = /home
  # declared_device = /dev/disk/by-uuid/3b7da2bd-f197-42c0-90a4-da99fe10eebc
  # current_source = /dev/nvme0n1p3
  # current_uuid = 5ec8653a-3539-403d-83b0-ac8ab4fc5b70
  fileSystems."/home".device = lib.mkForce "/dev/disk/by-uuid/5ec8653a-3539-403d-83b0-ac8ab4fc5b70";
  fileSystems."/home".options = lib.mkAfter [ "x-systemd.device-timeout=10s" ];

  environment.etc."mocha-kde/stale-uuid-boot-fix.txt".text = ''
    fix = stale UUID boot waits
    physical_swap_dev = /dev/nvme0n1p4
    physical_swap_uuid = 4f20952d-3696-40ee-bd26-61b0a090ee7d
    reason = avoid start job for missing /dev/disk/by-uuid paths
  '';
}
