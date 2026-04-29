# Estado estável do GNOME Shell — Diesel OS Lab / Gnome Mocha Edition

Este ponto foi congelado como estado bom o bastante para seguir o projeto Mocha.

## Inclui

- Tema GNOME Shell aplicado ao Quick Settings.
- Visual geral Mocha escuro/quente.
- Menu rápido funcional.
- Paleta Mocha atual.
- Estado aceitável para servir como base segura.

## Regra para ajustes futuros

Não mexer no Firefox para corrigir GNOME Shell.

Não mexer em `userContent.css` para corrigir menu, painel, Quick Settings ou GNOME Shell.

Para Quick Settings, painel, menus e diálogos do GNOME, o arquivo principal é:

`/etc/nixos/assets/theme/gnome-shell/gnome-shell.css`

Espelho salvo no repositório:

`nixos-machines/hal/assets/theme/gnome-shell/gnome-shell.css`

O Firefox tem checkpoint próprio em `assets/theme/firefox`.
