# MochaKde

Repositório separado para reconstrução do Mocha KDE.

## Regras

- `/etc/nixos` do Mocha GNOME ativo não deve ser tocado por este repo.
- Nunca importar módulo KDE dentro do Mocha GNOME ativo.
- CachyOS KDE serve como laboratório de ideias, não como fonte para cópia cega.
- MochaKde usa repo próprio em `/media/mochafast/MochaKde`.

## Prioridades técnicas

1. Caninana pinado.
2. NVIDIA pinado.
3. `nixos-unstable` para Plasma/KDE novo.
4. MOCHAFAST montado no boot.
5. Discos internos estrangeiros escondidos/protegidos.
6. SDDM/Wayland validado antes de confiar no login.
7. Steam, MangoHud e tuned.
8. `nixos-rebuild boot`, nunca `switch` na fase experimental.
