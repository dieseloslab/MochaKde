# MochaKde visual state

Data: 20260504-160000

## Estado confirmado pelo usuário

- KDE geral: paleta Mocha correta.
- Konsole: fundo e fontes corretos.
- Moldura/titlebar: correta.
- Barra do sistema: correta.
- Menu iniciar: correto.
- Dolphin: ícones marrons um pouco laranja, aceitos por enquanto.
- Firefox: visual Mocha funcionando perfeitamente via userChrome/userContent no perfil real.
- Wallpaper Mocha KDE sem referências sutis ao GNOME: salvo como `kde/wallpapers/mocha/wall.png`.

## Pendências

- Discos internos estrangeiros ainda aparecem no Dolphin; validar após reboot.
- Firefox final de distro ainda precisa solução sistêmica reprodutível.
- XPI local unsigned não deve ser usado como solução final sem assinatura.

## Wallpaper

Origem local:

```
/home/hal/Downloads/Wall.png
```

Destino no repo:

```
kde/wallpapers/mocha/wall.png
```

SHA256:

```
114a45b9b5b8e0d24b2f02154a3bc2f89e36d3c749517deb0a2bd55a292bf2a3  /media/mochafast/MochaKde/kde/wallpapers/mocha/wall.png
```

## Sistema atual no momento do registro

```
Host: mocha-kde-hal
Kernel: 7.0.1-cachyos
Current system: /nix/store/qh4d0lcfnas8xdix9jbnwif23zjmj8v5-nixos-system-mocha-kde-hal-26.05.20260430.15f4ee4
```

## Observação

Este commit registra avanço visual/operacional parcial. Não marcar como release final.
