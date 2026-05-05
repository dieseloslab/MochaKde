# Receita CachyOS kernel -> NixOS - estudo inicial

Data: 2026-05-04T21:05:35-03:00

Fonte estudada:
- xddxdd/nix-cachyos-kernel
- Branch: release
- Commit release: 2a54d924dd2267f7f3aecf2ab317f6972aed0963

Objetivo:
- Entender como o kernel CachyOS é exposto como pacote Nix/NixOS.
- Entender como surgem os atributos linuxPackages-cachyos-*.
- Preservar crédito ao mantenedor xddxdd / Yuhui Xu / Lan Tian e ao upstream CachyOS.
- Não recompilar kernel no sistema gamer como método padrão.
- Usar este estudo para documentar a receita do MochaKde/Caninana.

Regras MochaKde:
- Não importar KDE/GNOME misturado.
- Não mexer em /etc/nixos neste estudo.
- Não usar pacote Arch/CachyOS cru dentro do NixOS.
- Preferir release/cache.
- Se dry-build pedir compilação pesada de kernel/NVIDIA, abortar.
- Manter 7.0.1-cachyos bom como referência.

Logs:
/media/mochafast/cachycomp-logs/mochakde-estudo-xddxdd-nix-cachyos-20260504-210530
