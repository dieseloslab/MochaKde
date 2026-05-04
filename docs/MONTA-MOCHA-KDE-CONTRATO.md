# Contrato — "monta o Mocha KDE"

Quando o pedido for **"monta o Mocha KDE"**, a base canônica deve vir do repo `/media/mochafast/MochaKde`.

## Bluetooth é obrigatório na base

Bluetooth/BlueZ não é ajuste pós-instalação. Toda montagem padrão do MochaKde precisa incluir `kde/modules/mocha-bluetooth-bluez.nix` e importar esse módulo em `nixos-machines/hal/configuration.nix`.

O módulo precisa avaliar como:

```nix
hardware.bluetooth.enable = true;
hardware.bluetooth.powerOnBoot = true;
services.blueman.enable = true;
```

## Validação obrigatória antes de rebuild/boot

Antes de qualquer `nixos-rebuild build` ou `nixos-rebuild boot` no fluxo de montagem, rodar:

```bash
/media/mochafast/MochaKde/kde/scripts/validate-monta-mocha-kde-base.sh
```

Se essa validação falhar, parar. Não montar um MochaKde sem Bluetooth padrão.

## Motivo

No teste real, o kernel Caninana 7.0.1 já reconhecia o TP-Link UB5A via `btusb`, mas BlueZ/Blueman estavam desabilitados na configuração NixOS. A solução correta foi promover Bluetooth para base da distro, não tratar como remendo manual.
