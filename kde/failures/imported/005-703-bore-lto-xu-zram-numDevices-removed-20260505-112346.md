# Erro 703 BORE LTO Xu: zramSwap.numDevices removido

Data: 2026-05-05T11:43:07-03:00

O que funcionou:
- A receita 703 foi limpa para trocar somente kernel e NVIDIA.
- Kernel declarado: 7.0.3.
- NVIDIA declarada: 595.71.05.
- Origem do vídeo: Xu.

O que falhou:
- A avaliação da base herdada caiu em `zramSwap.numDevices`.
- Erro do NixOS: essa opção não pode mais ser usada porque foi removida.
- A configuração MochaKde deve manter zramSwap, mas sem `numDevices`.

Correção:
- Procurar arquivos Nix em /etc/nixos e /media/mochafast/MochaKde contendo `zramSwap.numDevices` ou `numDevices = ...;`.
- Ler e salvar backup dos arquivos antes.
- Remover somente a opção `numDevices` ligada ao zram.
- Validar novamente kernel 7.0.3, NVIDIA 595.71.05 e dry-run.
