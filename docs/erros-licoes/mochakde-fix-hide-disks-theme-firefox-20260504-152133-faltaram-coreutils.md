# Erro registrado - comando anterior falhou antes de aplicar regra/tema

Data: 20260504-152133

## Sintoma

O comando anterior parou com:

- head: comando não encontrado
- column: comando não encontrado
- cat: comando não encontrado

## Causa

A instalação NixOS KDE limpa ainda não tinha ferramentas básicas disponíveis no PATH do usuário.
O script anterior presumiu coreutils/column/cat/head disponíveis e falhou antes de criar a regra udev e antes de aplicar a paleta.

## Lição

Antes de usar scripts auxiliares em instalação limpa, garantir explicitamente as ferramentas com:

nix profile add nixpkgs#coreutils nixpkgs#util-linux nixpkgs#systemd ...

Não usar esse erro como estado canônico.
