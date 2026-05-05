{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    # MochaKde: esconder discos internos estrangeiros do Dolphin/udisks.
    # NÃO esconder MOCHAFAST.
    # NÃO esconder Ventoy/USB/adaptadores externos.

    # KINGSTON SA400S37480G /dev/sda1 vfat
    ENV{ID_FS_UUID}=="1716-3A10", ENV{UDISKS_IGNORE}="1", ENV{UDISKS_PRESENTATION_HIDE}="1"

    # KINGSTON SA400S37480G /dev/sda2 btrfs
    ENV{ID_FS_UUID}=="2dac5934-b52a-48c8-abcc-bbc0732eb8c9", ENV{UDISKS_IGNORE}="1", ENV{UDISKS_PRESENTATION_HIDE}="1"
  '';
}
