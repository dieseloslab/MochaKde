# Tentativa falha - Zen 7.0.2 no nixpkgs atual

A tentativa de usar o Zen 7.0.2-zen1 via override sobre o nixpkgs atual falhou.

Erro observado:
- inconsistent kernel versions: 6.12.83
- 7.0.2-zen1

Conclusão:
- Não usar esse override em cima do nixpkgs atual.
- Próxima tentativa deve usar a combinação exata antiga do commit 7f028eaa9:
  - nixpkgs rev: 0726a0ecb6d4e08f6adced58726b95db924cef57
  - zen-kernel rev: 98afbf0506fe33739ea71de65f0c625f97d34ef4

Objetivo:
- testar Zen 7 em specialisation separada ou build isolado
- não mexer no driver NVIDIA principal
