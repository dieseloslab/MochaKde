# caninana-703-bore-lto-xu-native-nvidia5957105-open

Data: 20260505-093743

Estado: candidato para dry-build/build/boot.

Base:
- kernel attr: pkgs.cachyosKernels."linuxPackages-cachyos-bore-lto"
- kernel version: 7.0.3
- kernel pname: linux-cachyos-bore-lto
- kernel modDirVersion: 7.0.3-cachyos-lto
- kernel outPath: /nix/store/s4pyafch4vwvks1kri4pjk697giwhwr2-linux-cachyos-bore-lto-7.0.3
- NVIDIA version: 595.71.05
- NVIDIA name: nvidia-x11-595.71.05
- NVIDIA open: true
- NVIDIA outPath: /nix/store/q8rj9ijy7hgyxqh5fkpf54jjmkb98jxl-nvidia-x11-595.71.05

Regra:
- Xu-native;
- sem mkDriver manual;
- sem 701;
- sem 595.58.03;
- perfil não agressivo;
- não compilar kernel; só aceitar fetch/cache.
