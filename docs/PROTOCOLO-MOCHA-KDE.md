# Protocolo Mocha KDE

1. Instalar/auditar CachyOS KDE no SSD de teste.
2. Não mexer no Mocha NixOS GNOME atual.
3. Auditar visual, Steam, NVIDIA, KDE Wayland, FPS e frametime.
4. Copiar só ideias boas, não arquivos cegamente.
5. Reconstruir Mocha KDE em repo separado.
6. Nunca importar módulo KDE dentro do Mocha GNOME ativo.

## Regra de build

- Primeiro gerar repo.
- Depois validar eval.
- Depois dry-build.
- Depois build.
- Depois boot.
- Não usar switch direto.
