# Erro 703 BORE LTO Xu: nix eval --raw em inteiro

Data: 2026-05-05T11:37:44-03:00

O que funcionou:
- Kernel declarado: 7.0.3
- NVIDIA declarada: 595.71.05
- Origem do vídeo: Xu
- `vm.swappiness` foi herdado do módulo base como inteiro 100.

O que falhou:
- O comando usou `nix eval --raw` em `config.boot.kernel.sysctl."vm.swappiness"`.
- Esse valor é inteiro, não string.
- O Nix retornou: `cannot coerce an integer to a string: 100`.

Correção:
- Ler swappiness com `nix eval --json ... | jq -r tostring`.
- Continuar dry-run/build/boot sem reescrever a receita inteira.

Regra mantida:
- Kernel 7.0.3 BORE LTO via Xu não pode compilar localmente.
- NVIDIA 595.71.05 pode casar/compilar se necessário.
