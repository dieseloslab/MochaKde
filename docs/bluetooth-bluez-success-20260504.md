# MochaKde — Bluetooth BlueZ funcionando

Data: 2026-05-04 20:04:15 -0300  
Host: mocha-kde-hal  
Kernel validado: 7.0.1-cachyos

## Resultado

Bluetooth funcionando no MochaKde.

Validação prática:
- Blueman abriu corretamente.
- Adaptador Bluetooth ativo.
- Fone QCY Crossky Link2 listado/conectado.
- BlueZ ativo no sistema.

## Causa

O problema não era falta de módulo compatível com o kernel 7.0.1.

Antes da correção, o kernel já reconhecia o adaptador TP-Link UB5A:

- USB ID `2357:0604`
- driver `btusb`
- pilha `bluetooth` carregada
- `hci0/hci1` presente no sistema
- `rfkill` sem bloqueio
- firmware Realtek carregado

A falha real era de configuração NixOS:

- `hardware.bluetooth.enable = false`
- `services.blueman.enable = false`
- `bluetooth.service` não existia
- `bluetoothctl`/Blueman não estavam disponíveis como stack funcional

## Solução

Foi criado:

```text
kde/modules/mocha-bluetooth-bluez.nix
```

O módulo habilita:

```nix
hardware.bluetooth.enable = true;
hardware.bluetooth.powerOnBoot = true;
hardware.bluetooth.package = pkgs.bluez;
services.blueman.enable = true;
```

Também adiciona ferramentas de usuário:

```nix
bluez
blueman
kdePackages.bluedevil, quando disponível
```

Foi importado em:

```text
nixos-machines/hal/configuration.nix
```

## Validação correta

A validação não deve depender só de um comando isolado. Critérios úteis:

```bash
systemctl status bluetooth --no-pager
pgrep -a bluetoothd
busctl --system list | grep org.bluez
rfkill list
find /sys/class/bluetooth -maxdepth 1 -name 'hci*'
blueman-manager
bluetoothctl show
```

No caso validado, o Blueman mostrou dispositivos e conexão funcional.

## Lição

Se o kernel já mostra `btusb` + `hci*`, não procurar outro módulo de kernel primeiro.

No NixOS, validar antes:

```bash
nix eval --json .#nixosConfigurations.mocha-kde-hal.config.hardware.bluetooth.enable
nix eval --json .#nixosConfigurations.mocha-kde-hal.config.services.blueman.enable
```

Para o MochaKde, Bluetooth deve fazer parte da base do sistema.
