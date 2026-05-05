# MochaKde — toplevel buildado com Caninana 7.0.1 + NVIDIA 595

Data: 2026-05-04T11:32:18-03:00

Toplevel:
- /nix/store/s3csn4mncjy6r41310bc2zxk38qwmfy1-nixos-system-mocha-kde-hal-26.05.20260430.15f4ee4

GC root:
- /nix/var/nix/gcroots/mocha/mochakde-toplevel-caninana701-nvidia595-20260504-113217

Log:
- /media/mochafast/cachycomp-logs/mocha-fase7-registrar-toplevel-kde-20260504-113217

Estado:
- Build completo do toplevel concluído.
- Dry-build final não listou kernel/NVIDIA/initrd crítico.
- Ainda não foi feito boot.
- Ainda não foi feito switch.

Kernel/NVIDIA/initrd na closure:
/nix/store/1535fic6yqmb2krhdv27hmlskx6fmwli-initrd-linux-cachyos-latest-7.0.1
/nix/store/4aglh7hp95iiccnsj31xfh53prnwclrs-nvidia-egl-external-platforms
/nix/store/4hpxnbns9gd210895aixhq1vc6v789j0-nvidia-x11-595.71.05-7.0.1-bin
/nix/store/f8jdvw3pd3rljvk35lrni2pp10p61arc-nvidia-vaapi-driver-0.0.16
/nix/store/j6xqs4g6555y5xr6jv011a9x8nfc3yk3-nvidia-x11-595.71.05-7.0.1-lib32
/nix/store/jh351kri3ilabwkirrk17z7ia5fc7c26-linux-cachyos-latest-7.0.1-modules
/nix/store/qfnlgsgn9ik88lk5l44fjrl7jidx0wm3-nvidia-settings-595.71.05
/nix/store/r1lk9g1bzpdhvsz1j013b802gzfaccyn-linux-cachyos-latest-7.0.1
/nix/store/r77b8jn42mgimc3vd7bkhw6klfd9nxjf-nvidia-egl-external-platforms-x32
/nix/store/sf4azw8w2vriicjk3jb0ypshgy3dk43m-linux-cachyos-latest-7.0.1-modules
/nix/store/w4bbdv2qjni4y6g3dq53sci12yipysv4-nvidia-open-7.0.1-595.71.05
/nix/store/x029wnpcy6y2ysbffa9mj16krivcnr2l-nvidia-x11-595.71.05-7.0.1
/nix/store/zca2ywr16p0lz0xy7cgf1b04cby52rq9-nvidia-x11-595.71.05-7.0.1-firmware

Regras:
- Não remover nada.
- Não mexer no Firefox.
- Não usar switch como padrão.
- Próximo passo permitido: nixos-rebuild boot --flake /etc/nixos#mocha-kde-hal
- Depois reiniciar e validar kernel, NVIDIA, Plasma/KDE, SDDM, MOCHAFAST, proteção dos discos e Firefox.
