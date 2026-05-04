# Caninana 7.0.1 — receita certa encontrada

Data: 2026-05-03T18:23:53-03:00
Diretório canônico: /media/mochafast/Caninana/caninana-701-cacheado-nvidia595-good-20260503-182353

## Status

Este é o estado marcado como BOM após teste real de jogo em 2026-05-03.

Resultado observado pelo usuário:
- FPS altos recuperados.
- Travadas pequenas observadas apenas no Dirt em pista não testada antes.
- Receita considerada recuperada, ainda sujeita a refinamentos futuros.

## Identidade técnica

Nome público/técnico do estado: Caninana 7.0.1
Implementação funcional atual: kernel Cachy upstream/cacheado via nix-cachyos-kernel.
Não é o módulo recompilado/renomeado linux-caninana.

## Validação real pós-boot

```text
uname -r: 7.0.1-cachyos
GPU/driver: NVIDIA GeForce RTX 5060 Ti, 595.71.05
kernel pname declarado: linux-cachyos-latest
kernel version declarado: 7.0.1
nvidia version declarada: 595.71.05
```

## Receita declarativa essencial

```nix
./modules/kernel-cachycomp.nix
boot.kernelPackages = lib.mkOverride 30 pkgs.cachyosKernels.linuxPackages-cachyos-latest;

./modules/hardware-nvidia.nix
hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  version = "595.71.05";
  # hashes conforme arquivo atual
};
```

## O que NÃO faz parte da receita boa

- Não importar ./modules/kernel-caninana-701-recompiled.nix.
- Não forçar pname linux-caninana neste estado.
- Não recompilar o kernel para testar esta receita.
- Não trocar Proton, Xwayland, MangoHud, tuned ou GameMode junto com este teste.

## Logs do teste

- Log principal: /media/mochafast/mocha-backups/game-monitor-cachy701-20260503-180318.log
- Log kernel: /media/mochafast/mocha-backups/game-monitor-kernel-cachy701-20260503-180318.log

Resumo automático:

```text
Resumo automático do teste de jogo

Log principal: /media/mochafast/mocha-backups/game-monitor-cachy701-20260503-180318.log
Primeira amostra: 2026-05-03 18:03:21
Última amostra: 2026-05-03 18:19:25
Amostras GPU parseadas: 906
GPU util max: 100.0%
GPU temp max: 65.0 C
GPU clock max: 2827.0 MHz
VRAM clock max: 14001.0 MHz
VRAM usada max: 15765.0 MiB
Power draw max: 147.4 W
Observação: o campo RAM do monitor ficou vazio; corrigir script depois para locale pt_BR.

Log kernel: /media/mochafast/mocha-backups/game-monitor-kernel-cachy701-20260503-180318.log
Contagem rápida de sinais no kernel:
NVRM: 0
Xid: 0
GPU has fallen: 0
segfault: 0
error: 0
failed: 0
```

## Origens preservadas

- /etc/nixos atual copiado para: /media/mochafast/Caninana/caninana-701-cacheado-nvidia595-good-20260503-182353/etc-nixos
- Receita original 20260501 referenciada/copiada em: /media/mochafast/Caninana/caninana-701-cacheado-nvidia595-good-20260503-182353/source-reference
- Cache 7.0.1 preservado em: /media/mochafast/Caninana/caninana-701-cacheado-nvidia595-good-20260503-182353/cache-reference

## Próximo refinamento permitido

Criar uma nova geração de boot com identidade visual/nome Caninana sem mudar o storepath do kernel.
Evitar renomear o derivation/pname do kernel até termos certeza de que isso não força rebuild.
