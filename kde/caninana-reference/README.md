# Caninana 7.0.1 + NVIDIA 595.71.05 — referência correta

A receita boa validada em jogo NÃO é o kernel renomeado/recompilado como `linux-caninana`.

Receita boa:

- identidade pública/técnica: Caninana;
- implementação funcional: `linux-cachyos-latest`;
- versão: `7.0.1`;
- `uname -r`: `7.0.1-cachyos`;
- NVIDIA: `595.71.05`;
- não renomear `pname`;
- não importar `kernel-caninana-701-recompiled.nix`;
- não recompilar kernel só para mudar nome.

O módulo `kernel-caninana-701-recompiled.NAO-USAR-PARA-RECEITA-BOA.nix`
fica preservado apenas como referência histórica.
