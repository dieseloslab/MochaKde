# Consumidor KDE — Caninana compartilhado

- Data: 2026-05-05T08:18:25-03:00
- Status: experimental / desativado
- Repo: /media/mochafast/MochaKde
- Fonte canônica compartilhada: /media/mochafast/CaninanaMatrix
- Log de criação: /media/mochafast/cachycomp-logs/criar-consumidor-kde-shared-caninana-20260505-081825/run.log

## Intenção

Este diretório cria o primeiro consumidor KDE da camada compartilhada Caninana/NVIDIA.

Ele **não ativa nada** ainda.

## Regras

- Não foi importado em `flake.nix`.
- Não foi importado em `configuration.nix`.
- Não altera `/etc/nixos`.
- Não faz rebuild.
- Não muda kernel.
- Não muda driver NVIDIA.
- Não muda bootloader.
- Não ativa tweaks agressivos.

## Fonte canônica

O KDE deve consumir:

```text
/media/mochafast/CaninanaMatrix
```

e não duplicar kernel/NVIDIA dentro do repo KDE.

## Referências

```text
item	caminho
matrix_root	/media/mochafast/CaninanaMatrix
recipe	recipes/shared-kernel-video/caninana701-bin-lto-nao-agressiva/RECEITA-COMPARTILHADA-CANINANA701-BIN-LTO-NAO-AGRESSIVA.md
contract	contracts/shared-kernel-video/CONTRATO-CONSUMO-CANINANA-SHARED.md
artifacts_index	artifacts-index/shared-kernel-video/INDEX-SHARED-KERNEL-VIDEO-CURRENT.md
review_index	artifacts-index/shared-kernel-video-review/INDEX-SHARED-KERNEL-VIDEO-REVIEW-CURRENT.md
legacy_index	artifacts-index/legacy-quarantine-mochakde/INDEX-LEGACY-QUARANTINE-MOCHAKDE-CURRENT.md
shared_701	/media/mochafast/shared-kernel-video/caninana-7.0.1
shared_703_candidates	/media/mochafast/shared-kernel-video/candidates/caninana-7.0.3
shared_review	/media/mochafast/shared-kernel-video/review
expected_kernel	7.0.1
expected_nvidia	595.71.05
mode	non-aggressive
```

## Próxima etapa futura

Apenas depois de auditoria:

1. criar módulo real de seleção kernel/NVIDIA;
2. validar eval/outPath;
3. validar se não há build inesperado de kernel/NVIDIA;
4. rodar dry-build/build;
5. só depois considerar `nixos-rebuild boot`;
6. nunca usar `switch` como padrão.
