# Lição - validação de swapDevices

Data: 20260505-103432

O erro anterior não indicou swap errada. A validação tentou avaliar config.swapDevices inteiro em JSON.
Isso força o Nix a acessar subopções opcionais como label, que podem não ter valor definido.

Correção:
- validar apenas os campos necessários: device e priority;
- preservar o módulo existente;
- preservar sysctls do módulo mocha-zram-hibernate.nix;
- manter zram com prioridade máxima;
- deixar swap física com prioridade baixa;
- boot.resumeDevice aponta somente para a swap real por UUID.
