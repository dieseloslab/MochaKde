# Reproduzir receita boa — Caninana 7.0.1 + NVIDIA 595.71.05 Open + Cloudflare DoT

Receita validada:

- Kernel: 7.0.1-cachyos / Caninana
- NVIDIA: 595.71.05
- Módulo de kernel NVIDIA: open
- Opção NixOS: hardware.nvidia.open = true
- DNS: Cloudflare DNS-over-TLS via systemd-resolved

Arquivos canônicos:

- kde/caninana-reference/RECEITA-BOA-CANINANA701-NVIDIA595-OPEN-DOT.md
- kde/caninana-reference/good/caninana701-nvidia595-open-dot-20260505-201924/MANIFEST.md
- kde/caninana-reference/good/caninana701-nvidia595-open-dot-20260505-201924/nvidia-pinned.FONTE-ATIVA-BOA.nix
- kde/caninana-reference/good/caninana701-nvidia595-open-dot-20260505-201924/caninana-kernel.FONTE-ATIVA-BOA.nix
- kde/caninana-reference/good/caninana701-nvidia595-open-dot-20260505-201924/mocha-dns-cloudflare-dot.FONTE-ATIVA-BOA.nix

Como reproduzir no MochaKde:

1. Copiar os três módulos bons para /etc/nixos/kde/modules.
2. Validar que nvidia-pinned.nix contém open = true e 595.71.05.
3. Validar que mocha-dns-cloudflare-dot.nix contém DNSOverTLS e Cloudflare.
4. Fazer dry-build/build antes de qualquer boot.
5. Usar nixos-rebuild boot, não switch, salvo autorização explícita.

Checks pós-boot esperados:

- uname -r deve mostrar 7.0.1-cachyos
- nvidia-smi deve mostrar driver 595.71.05
- cat /proc/driver/nvidia/version deve conter NVIDIA UNIX Open Kernel Module
- modinfo -F license nvidia deve mostrar Dual MIT/GPL
- modinfo -F filename nvidia deve apontar para nvidia-open-7.0.1-595.71.05
- resolvectl status deve mostrar DNSOverTLS e one.one.one.one
- ss deve mostrar conexão para 1.1.1.1:853 ou 1.0.0.1:853

Regra:

/etc/nixos é a fonte ativa do sistema instalado. /media/mochafast/MochaKde guarda a receita, evidências e fonte de cópia. Não importar módulos KDE diretamente no Mocha GNOME.
