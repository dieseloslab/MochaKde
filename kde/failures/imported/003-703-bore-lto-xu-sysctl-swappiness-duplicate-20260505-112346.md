# Erro 703 BORE LTO Xu: sysctl swappiness duplicado

Data: 2026-05-05T11:35:30-03:00

O que funcionou:
- Kernel Xu declarado: 7.0.3
- NVIDIA declarado: 595.71.05
- Hashes NVIDIA 595.71.05 foram encontrados na receita local.

O que falhou:
- O dry-build morreu em `boot.kernel.sysctl."vm.swappiness"`.
- A receita experimental definia `vm.swappiness = 10`.
- O módulo `kde/modules/mocha-zram-hibernate.nix` já definia `vm.swappiness = 100`.
- Esse módulo deve continuar sendo dono do swappiness agressivo.

Correção aplicada:
- Remover `vm.swappiness` da receita experimental 703 BORE LTO.
- Deixar `mocha-zram-hibernate.nix` controlar o swappiness.
- Substituir uso de `pkgs.system` por `pkgs.stdenv.hostPlatform.system`.
- Usar `--accept-flake-config` nos comandos Nix que leem o flake do Xu.

Regra mantida:
- Kernel Xu 7.0.3 BORE LTO não pode compilar localmente.
- NVIDIA 595.71.05 pode casar/compilar se necessário.
