{ config, lib, ... }:

{
  # MochaKde: esconder SSD interno estrangeiro do Dolphin/udisks/Solid.
  # Preserva MOCHAFAST, NVME ativo, swap e USB/Ventoy.
  services.udev.extraRules = ''
    ACTION=="remove", GOTO="mocha_hide_foreign_end"

    # Disco pai: KINGSTON SA400S37480G em /dev/sda.
    SUBSYSTEM=="block", KERNEL=="sda", ENV{ID_MODEL}=="KINGSTON_SA400S37480G", ENV{UDISKS_IGNORE}:="1", ENV{UDISKS_PRESENTATION_HIDE}:="1", ENV{UDISKS_AUTO}:="0"

    # Partições estrangeiras por UUID.
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="1716-3A10", ENV{UDISKS_IGNORE}:="1", ENV{UDISKS_PRESENTATION_HIDE}:="1", ENV{UDISKS_AUTO}:="0"
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="2dac5934-b52a-48c8-abcc-bbc0732eb8c9", ENV{UDISKS_IGNORE}:="1", ENV{UDISKS_PRESENTATION_HIDE}:="1", ENV{UDISKS_AUTO}:="0"

    LABEL="mocha_hide_foreign_end"
  '';
}
