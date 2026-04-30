# Mocha KDE - Linux Zen 7.0.2 upstream

Fonte guardada permanentemente no MOCHAFAST para testes de desempenho do Mocha KDE.

Origem:
- repo: https://github.com/zen-kernel/zen-kernel
- tag: v7.0.2-zen1
- rev: 98afbf0506fe33739ea71de65f0c625f97d34ef4

Objetivo:
- testar desempenho/responsividade em jogos
- comparar contra linux-zen 6.19.12 do nixpkgs atual
- preservar fonte e build para não depender de memória/chat novamente

Arquivos locais importantes:
- source/zen-kernel-v7.0.2-zen1/
- tarballs/zen-kernel-v7.0.2-zen1-source.tar.xz
- tarballs/zen-kernel-v7.0.2-zen1.git.bundle
- tarballs/SHA256SUMS

Importante:
- não compilar com make install direto no sistema
- compilar via Nix para manter kernel, módulos, initrd, bootloader e NVIDIA consistentes
- não alterar versão do driver NVIDIA principal sem intenção explícita

Erro da tentativa antiga:
- inconsistent kernel versions: 6.12.83 / 7.0.2-zen1
- conclusão: não usar override antigo sobre o nixpkgs atual
