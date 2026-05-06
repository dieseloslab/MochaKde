# 703 BORE LTO Xu — mismatch de módulos NVIDIA/kernel

Data: 2026-05-05T12:06:57-03:00

Sintoma:
- Kernel 7.0.3 e módulos principais foram baixados do cache Xu.
- O build falhou em linux-cachyos-latest-7.0.3-modules.drv.
- Erro: inconsistent kernel versions:
  - 7.0.3-cachyos
  - 7.0.3-cachyos-lto

Causa provável:
- O driver/módulo NVIDIA selecionado via Xu trouxe diretório de módulo não-LTO.
- O kernel selecionado é LTO.
- Misturar módulos 7.0.3-cachyos e 7.0.3-cachyos-lto quebra o empacotamento de modules.

Correção:
- Manter kernel 703 BORE LTO via Xu.
- Forçar NVIDIA direto via mkDriver contra xuKernelPackages.
- Isso permite build/casamento do vídeo, mas continua proibindo build local do kernel.
