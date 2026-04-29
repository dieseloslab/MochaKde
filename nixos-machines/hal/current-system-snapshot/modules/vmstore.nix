# /etc/nixos/modules/vmstore.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# O vmstore/MOCHAFAST é armazenamento auxiliar:
# - espelho do repositório;
# - backup;
# - cache local;
# - mídia de restauração.
#
# Decisão operacional atual:
# o MOCHAFAST deve montar automaticamente no boot quando estiver conectado.
#
# Proteção:
# a montagem usa nofail e timeout curto para evitar que o sistema fique preso
# caso o disco/pendrive MOCHAFAST não esteja conectado em algum boot futuro.

{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /mnt/vmstore 0755 root root -"
    "d /media/mochafast 0755 root root -"
  ];

  fileSystems."/media/mochafast" = {
    device = "/dev/disk/by-label/MOCHAFAST";
    fsType = "xfs";

    options = [
      "nofail"
      "x-systemd.device-timeout=2s"
    ];
  };
}
