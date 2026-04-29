# Mocha KDE

Repositório separado do Diesel OS Lab / Mocha KDE.

Este projeto existe separado do Mocha GNOME para evitar mistura entre:

- GNOME / GDM
- KDE Plasma / SDDM
- temas GTK/GNOME
- temas Qt/KDE
- scripts de sessão
- backups visuais
- módulos NixOS específicos de cada desktop

## Caminhos principais

- `nixos-machines/hal/` — configuração NixOS da máquina Hal para Mocha KDE
- `nixos-machines/hal/modules/` — módulos NixOS específicos do Mocha KDE
- `kde/state/` — backups visuais e estados bons do Plasma
- `kde/scripts/` — scripts específicos do KDE/Plasma
- `kde/themes/` — temas, cores, ícones e ajustes visuais KDE
- `kde/docs/` — documentação específica do KDE
- `docs/` — documentação geral do projeto
