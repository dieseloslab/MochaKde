# MochaKde - Caninana 7.0.3 + NVIDIA 595.71.05 + Cachy aggressive tweaks fixed

Data: 2026-05-05T06:36:49-03:00

## Identidade

- Repo: /media/mochafast/MochaKde
- Host: mocha-kde-hal
- Log: /media/mochafast/cachycomp-logs/mochakde-caninana703-cachy-aggressive-fixed-20260505-062808
- Experimento: /media/mochafast/MochaKde/kde/caninana-reference/caninana703-nvidia595-cachy-aggressive-fixed-20260505-062808
- Cache: /media/mochafast/nix-cache-mochakde-caninana703-nvidia595-cachy-aggressive-fixed-20260505-062808
- Cache current symlink: /media/mochafast/nix-cache-mochakde-caninana703-nvidia595-cachy-aggressive-current
- GC root: /nix/var/nix/gcroots/mocha/mochakde-caninana703-nvidia595-cachy-aggressive

## Base antes

- Kernel real antes: 7.0.3-cachyos
- NVIDIA real antes: 595.71.05
- Toplevel antes: /nix/store/b7yrgrw8r6k72sxkp8v63zm6na7sh5ij-nixos-system-mocha-kde-hal-caninana703-experiment-mochakde-nixos-unstable-nvidia-latest-26.05.20260430.15f4ee4

## Build novo

- Kernel avaliado: linux-cachyos-latest-7.0.3
- Kernel modDirVersion: 7.0.3-cachyos
- Kernel pname: linux-cachyos-latest
- NVIDIA avaliado: nvidia-x11-595.71.05 / 595.71.05
- Plasma: 6.6.4
- Toplevel novo: /nix/store/jgznfagr6l2f4gcjf9adwpmgpmzdrp2d-nixos-system-mocha-kde-hal-caninana703-cachy-aggressive-caninana703-experiment-mochakde-nixos-unstable-nvidia-latest-nvidia595-playability-test-26.05.20260430.15f4ee4
- nixos-rebuild boot: sim
- nixos-rebuild switch: nao

## Tweaks agressivos aplicados

- vm.max_map_count = 2147483642
- vm.swappiness = 180
- vm.page-cluster = 0
- vm.vfs_cache_pressure = 50
- vm.watermark_boost_factor = 0
- vm.watermark_scale_factor = 125
- vm.dirty_bytes = 268435456
- vm.dirty_background_bytes = 134217728
- vm.dirty_writeback_centisecs = 1500
- fs.file-max = 2097152
- fs.inotify.max_user_instances = mantido do NixOS atual
- kernel.nmi_watchdog = 0
- kernel.sched_autogroup_enabled = 0
- nofile = 1048576
- memlock = unlimited
- THP = madvise
- NVMe scheduler = none
- SSD sd* scheduler = mq-deadline
- HDD sd* scheduler = bfq
- SATA LPM = max_performance
- snd_hda_intel power_save = 0

## Cache

- cache status: nix-copy-ok
- cache dir: /media/mochafast/nix-cache-mochakde-caninana703-nvidia595-cachy-aggressive-fixed-20260505-062808
- closure list: /media/mochafast/MochaKde/kde/caninana-reference/caninana703-nvidia595-cachy-aggressive-fixed-20260505-062808/cache-info/aggressive-closure.txt

## Regras

- Este e teste agressivo em geracao separada.
- Se ficar pior, voltar para a geracao anterior 7.0.3 aprovada.
- Nao registrar como receita final sem teste em Dirt 2 e Sniper Elite Resistance.
- USB/Bluetooth tardio segue atribuido ao hub/porta/adaptador com defeito.
