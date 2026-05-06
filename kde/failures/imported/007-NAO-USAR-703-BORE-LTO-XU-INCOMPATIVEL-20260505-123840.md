# NÃO USAR — 703 BORE LTO Xu incompatível no Mocha

Data: 2026-05-05T12:38:40-03:00

## Resultado

O experimento **Caninana 7.0.3 BORE LTO via Xu** não gera uma geração NixOS bootável no Mocha neste momento.

## O que funcionou

- Kernel declarado: 7.0.3
- NVIDIA declarada: 595.71.05
- Kernel principal veio do cache Xu
- Módulos principais apareceram como cache/fetch em tentativa anterior
- NVIDIA via Xu e NVIDIA direto foram testados

## Falha final

Mesmo forçando NVIDIA direto com:

- `pkgs.linuxPackagesFor xuKernelPackages.kernel`
- `mkDriver`
- `version = 595.71.05`

o build falhou em:

```
linux-cachyos-latest-7.0.3-modules.drv
```

com:

```
inconsistent kernel versions:
7.0.3-cachyos
7.0.3-cachyos-lto
```

## Conclusão

A falha não é mais do driver NVIDIA escolhido.  
A inconsistência está no conjunto de módulos/kernel do **703 BORE LTO** exposto pelo Xu/Nix para esta combinação.

## Decisão

- Não usar 703 BORE LTO Xu como receita Mocha.
- Não gastar mais tentativas nessa variante sem mudança upstream.
- Manter como receita boa:

```
Caninana 7.0.1 BORE + NVIDIA 595.71.05
```

## Próximo teste possível

Se for testar 703 novamente, testar em receita separada:

```
703 BORE sem LTO
```

Nunca substituir a receita boa 701 BORE por 703 LTO.
