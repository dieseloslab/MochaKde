# Receita boa MochaKde — Caninana 7.0.1 + NVIDIA 595.71.05 Open + Cloudflare DoT

Data de registro: 2026-05-05T20:19:26-03:00  
Host: mocha-kde-hal  
Usuário: hal  
Fonte ativa autoritativa no momento do registro: `/etc/nixos`  
Diretório de evidências: `/media/mochafast/MochaKde/kde/caninana-reference/good/caninana701-nvidia595-open-dot-20260505-201924`  
Log da execução: `/media/mochafast/cachycomp-logs/mocha-registrar-receita-boa-caninana701-nvidia-open-20260505-201924/run.log`

## Veredito

Esta é a receita boa atualmente bootada e validada:

- Kernel: `7.0.1-cachyos`
- Sistema bootado: `/nix/store/nckxjsccwsbip57am59fpg2v8cf33mr6-nixos-system-mocha-kde-hal-caninana701-good-recipe-mochakde-nvidia595-26.05.20260430.15f4ee4`
- Sistema atual: `/nix/store/nckxjsccwsbip57am59fpg2v8cf33mr6-nixos-system-mocha-kde-hal-caninana701-good-recipe-mochakde-nvidia595-26.05.20260430.15f4ee4`
- Driver NVIDIA: `595.71.05`
- Módulo de kernel NVIDIA: **open**
- Licença do módulo: `Dual MIT/GPL`
- Store path do módulo: `/nix/store/w4bbdv2qjni4y6g3dq53sci12yipysv4-nvidia-open-7.0.1-595.71.05`
- Deriver do módulo: `/nix/store/zv8a4p5q6igw63z89c8l18z4kri73bm9-nvidia-open-7.0.1-595.71.05.drv`
- DNS criptografado: **Cloudflare DNS-over-TLS via systemd-resolved**
- Servidores DNS globais esperados:
  - `1.1.1.1#one.one.one.one`
  - `1.0.0.1#one.one.one.one`
  - `2606:4700:4700::1111#one.one.one.one`
  - `2606:4700:4700::1001#one.one.one.one`

## Nome curto da receita

```text
Caninana 7.0.1 + NVIDIA 595.71.05 open kernel modules + Cloudflare DoT
```

## Regra essencial da NVIDIA

Esta receita **não** usa nouveau e **não** usa o módulo fechado/proprietário do kernel NVIDIA.

Ela usa:

```nix
hardware.nvidia.open = true;
hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  version = "595.71.05";
  # hashes definidos no módulo ativo
};
```

O userspace NVIDIA continua sendo binário/proprietário, por exemplo:

```text
nvidia-x11-595.71.05-7.0.1
nvidia-x11-595.71.05-7.0.1-bin
nvidia-x11-595.71.05-7.0.1-lib32
nvidia-x11-595.71.05-7.0.1-firmware
nvidia-settings-595.71.05
```

Mas o módulo de kernel carregado é:

```text
nvidia-open-7.0.1-595.71.05
```

## Origem upstream registrada

- Driver NVIDIA 595.71.05:
  - `https://download.nvidia.com/XFree86/Linux-x86_64/595.71.05/`
  - `https://download.nvidia.com/XFree86/Linux-x86_64/595.71.05/NVIDIA-Linux-x86_64-595.71.05.run`

- Fonte dos módulos abertos NVIDIA:
  - `https://github.com/NVIDIA/open-gpu-kernel-modules`
  - `https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/`

## Evidência runtime

```text
NVRM version: NVIDIA UNIX Open Kernel Module for x86_64 595.71.05 Release Build (nixbld@) 
GCC version: gcc version 15.2.0 (GCC) 
```

```text
modinfo nvidia:
  version: 595.71.05
  license: Dual MIT/GPL
  file: /run/booted-system/kernel-modules/lib/modules/7.0.1-cachyos/kernel/drivers/video/nvidia.ko.xz
  real: /nix/store/w4bbdv2qjni4y6g3dq53sci12yipysv4-nvidia-open-7.0.1-595.71.05/lib/modules/7.0.1-cachyos/kernel/drivers/video/nvidia.ko.xz
```

## DNS / Cloudflare DoT

O módulo ativo é:

```text
/etc/nixos/kde/modules/mocha-dns-cloudflare-dot.nix
```

A configuração esperada é systemd-resolved com DNS-over-TLS:

```nix
services.resolved = {
  enable = true;
  extraConfig = ''
    DNS=1.1.1.1#one.one.one.one 1.0.0.1#one.one.one.one 2606:4700:4700::1111#one.one.one.one 2606:4700:4700::1001#one.one.one.one
    Domains=~.
    DNSOverTLS=yes
  '';
};
```

## Arquivos copiados da fonte ativa boa

- `nvidia-pinned.FONTE-ATIVA-BOA.nix`
- `mocha-dns-cloudflare-dot.FONTE-ATIVA-BOA.nix`
- `caninana-kernel.FONTE-ATIVA-BOA.nix`
- `configuration.FONTE-ATIVA-BOA.nix`

## Arquivos raw de prova

- `raw/uname-a.txt`
- `raw/nvidia-smi-query.csv`
- `raw/nvidia-smi-full.txt`
- `raw/proc-driver-nvidia-version.txt`
- `raw/modinfo-nvidia.txt`
- `raw/modinfo-nvidia_modeset.txt`
- `raw/modinfo-nvidia_uvm.txt`
- `raw/modinfo-nvidia_drm.txt`
- `raw/nvidia-open-drv-derivation-show.json`
- `raw/nix-store-nvidia-kernel-closure.txt`
- `raw/dns-cloudflare-dot-runtime.txt`

## Regra para não perder de novo

1. `/etc/nixos` é a fonte ativa da máquina instalada.
2. `/media/mochafast/MochaKde` é repo/backup/cache/receita, não import operacional direto.
3. Se houver divergência entre FAST e `/etc/nixos`, a geração boa atual vence.
4. Para reproduzir esta receita, copiar os módulos bons para `/etc/nixos`, validar, fazer `nixos-rebuild build`/dry-build, e só depois `nixos-rebuild boot`.
5. Não usar `nixos-rebuild switch` por padrão.
6. Antes de qualquer nova tentativa NVIDIA/kernel:
   - validar `uname -r`;
   - validar `nvidia-smi`;
   - validar `modinfo -F license nvidia`;
   - validar store path `nvidia-open-7.0.1-595.71.05`;
   - abortar se o dry-build quiser recompilar/trocar kernel/NVIDIA sem autorização.

## Status

**BOM / CANÔNICO para MochaKde no momento deste registro.**

