# /etc/nixos/modules/mocha-hide-windows-disks.nix
#
# Diesel OS Lab / Mocha KDE
#
# Padrao de seguranca:
# esconder discos/particoes Windows do Dolphin/Nautilus/udisks2.
#
# Nao apaga, nao formata, nao monta e nao altera dados.
# Nao impede boot pelo Windows.
#
# SSD Windows desta maquina:
# KINGSTON SA400S37240G
# Serial: 50026B7783D827EA
#
# Particoes:
# /dev/sda1 - Microsoft reserved partition
# /dev/sda2 - NTFS - Basic data partition - UUID 4A90438C90437E07
# /dev/sda3 - NTFS - Windows Recovery       - UUID 7A04671A0466D8A1

{ ... }:

{
  services.udev.extraRules = ''
    # Particao principal Windows por UUID.
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="4A90438C90437E07", ENV{UDISKS_IGNORE}="1"

    # Particao recovery Windows por UUID.
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="7A04671A0466D8A1", ENV{UDISKS_IGNORE}="1"

    # Microsoft Basic Data Partition no SSD Windows.
    SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}=="50026B7783D827EA", ENV{ID_PART_ENTRY_TYPE}=="ebd0a0a2-b9e5-4433-87c0-68b6b72699c7", ENV{UDISKS_IGNORE}="1"

    # Microsoft Reserved Partition no SSD Windows.
    SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}=="50026B7783D827EA", ENV{ID_PART_ENTRY_TYPE}=="e3c9e316-0b5c-4db8-817d-f92df00215ae", ENV{UDISKS_IGNORE}="1"

    # Windows Recovery Partition no SSD Windows.
    SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}=="50026B7783D827EA", ENV{ID_PART_ENTRY_TYPE}=="de94bba4-06d1-4d40-a16a-bfd50179d6ac", ENV{UDISKS_IGNORE}="1"
  '';
}
