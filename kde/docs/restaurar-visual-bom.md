# Restaurar visual bom do Mocha KDE

Este procedimento restaura o estado visual KDE/Plasma considerado bom.

Ele não roda nixos-rebuild.
Ele não troca display manager.
Ele não mexe em GDM/GNOME.

## Comando

cd /media/mochafast/MochaKde
./kde/scripts/apply-mocha-kde-visual-good.sh --restart-plasma

## Estado salvo

O backup visual usado fica em:

kde/state/plasma-visual-bom-20260429-184141/

Esse estado contém arquivos como:

- kdeglobals
- plasmarc
- kwinrc
- dolphinrc
- plasma-org.kde.plasma.desktop-appletsrc
- configs GTK auxiliares
