# Índice de reprodutibilidade MochaKde

Atualizado em: `20260504-025048`

## Relatório desta auditoria

- Diretório: `/media/mochafast/MochaKde/audits/auditoria-reprodutibilidade-20260504-025048`
- Log principal: `/media/mochafast/MochaKde/audits/auditoria-reprodutibilidade-20260504-025048/auditoria.log`

## Regra operacional

Antes de qualquer rebuild, tema, kernel, NVIDIA, Discover, Steam ou limpeza:

1. Ler `ERROS-E-LICOES.md`.
2. Ler este índice.
3. Ler os manifestos encontrados em `audits/*/00-md-manifestos-erros-existentes.txt`.
4. Validar kernel e NVIDIA reais.
5. Validar kernel e NVIDIA declarados pelo flake.
6. Se o dry-build tentar reconstruir kernel/NVIDIA sem intenção explícita, parar.

## Arquivos desta auditoria

- `00-md-manifestos-erros-existentes.txt`: MDs, manifestos e registros encontrados.
- `01-headings-md-importantes.txt`: headings dos MDs existentes.
- `02-estado-real-sistema.txt`: kernel real, NVIDIA real, geração, sessão, swap/zram, display manager.
- `03-git-flake.txt`: Git, flake metadata e configurações NixOS.
- `04-kernel-nvidia-declarados.txt`: kernel/NVIDIA declarados por config.
- `05-origens-caninana-cachy-nvidia.txt`: grep das origens Caninana/Cachy/NVIDIA.
- `06-artefatos-mochafast.txt`: caches, logs, diretórios e duplicatas prováveis.
- `07-estrutura-repo-etc.txt`: árvore relevante do repo e de `/etc/nixos`.

## Estado real capturado

Ver: `/media/mochafast/MochaKde/audits/auditoria-reprodutibilidade-20260504-025048/02-estado-real-sistema.txt`

## Kernel/NVIDIA declarados

Ver: `/media/mochafast/MochaKde/audits/auditoria-reprodutibilidade-20260504-025048/04-kernel-nvidia-declarados.txt`

## Origem provável do kernel/driver

Ver: `/media/mochafast/MochaKde/audits/auditoria-reprodutibilidade-20260504-025048/05-origens-caninana-cachy-nvidia.txt`

A hipótese operacional conhecida é:

- Kernel alvo: Caninana baseado no Cachy/CachyOS kernel 7.0.1, preservando identificadores funcionais necessários ao build quando existirem.
- Driver NVIDIA alvo: `595.71.05`, pinado via configuração Nix.
- Não trocar kernel/driver junto com KDE/tema/Discover.
- Não transformar pasta solta do MOCHAFAST em fonte canônica sem manifesto.

## Pendências de consolidação

- Escolher uma única árvore canônica para Caninana/NVIDIA dentro do MochaKde.
- Mesclar referências boas que hoje estejam espalhadas em Mocha, MochaKde, cachycomp-logs e nix-cache.
- Marcar explicitamente artefatos ruins ou não validados.
- Criar manifesto final para o estado bom antes de qualquer novo boot/rebuild.
