# NÃO USAR — 703 BORE sem LTO + NVIDIA proprietário

Data: 2026-05-05T18:39:05-03:00

## Resultado

A tentativa com 703 BORE sem LTO e NVIDIA proprietário/fechado não é segura.

## Sintoma

Ao tentar hibernar, houve kernel panic.

Trecho observado na tela:

```
RIP: os_get_euid+0x18/0x30 [nvidia]
note: shutdown[1] exited with irqs disabled
note: shutdown[1] exited with preempt_count 1
Kernel panic - not syncing: Attempted to kill init!
```

## Conclusão

O problema não ficou limitado ao nvidia-open.

A combinação 703 BORE + NVIDIA 595.71.05 também falha com o módulo proprietário no caminho de hibernação/shutdown.

## Decisão

- Não aprovar.
- Não usar como receita Mocha.
- Não substituir a receita boa.
- Receita boa preservada: Caninana 7.0.1 BORE + NVIDIA 595.71.05.

Logs:
- /media/mochafast/cachycomp-logs/703-proprietary-hibernate-panic-20260505-183905
