# Erro 703 BORE LTO Xu: vm.vfs_cache_pressure duplicado

Data: 2026-05-05T11:40:24-03:00

O que funcionou antes do erro:
- Kernel declarado: 7.0.3
- NVIDIA declarada: 595.71.05
- Origem do vídeo: Xu
- Swappiness herdado da base: 100

O que falhou:
- O dry-run morreu em `boot.kernel.sysctl."vm.vfs_cache_pressure"`.
- A receita experimental declarava `vm.vfs_cache_pressure = 50`.
- O módulo base `kde/modules/mocha-zram-hibernate.nix` também já declarava `vm.vfs_cache_pressure = 50`.
- Mesmo valor duplicado ainda é conflito para essa opção.

Correção:
- A receita experimental 703 não deve declarar sysctl/zram/THP agressivos.
- A receita experimental 703 deve trocar apenas kernel + NVIDIA.
- A fórmula agressiva deve ser herdada e validada da base MochaKde.

Regra mantida:
- Kernel Xu 7.0.3 BORE LTO não pode compilar localmente.
- NVIDIA 595.71.05 pode casar/compilar se necessário.
