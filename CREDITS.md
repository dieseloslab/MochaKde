# Credits

This project stands on the work of many upstream free software projects and contributors.


## Kernel and NixOS packaging credits

MochaKde/Caninana uses and studies the community Nix project `xddxdd/nix-cachyos-kernel`, maintained by **Yuhui Xu**, which provides CachyOS kernel variants as Nix/NixOS packages with Hydra/cache support.

The upstream CachyOS kernel patchset, tuning work, and kernel variants come from the CachyOS `linux-cachyos` project and its contributors.

MochaKde/Caninana does not claim authorship of the CachyOS kernel patchset or the Nix packaging bridge. This project integrates, tests, pins, documents, and combines these components with Mocha-specific NVIDIA, desktop, gaming, and reproducibility work.

Reference:

- `xddxdd/nix-cachyos-kernel`: https://github.com/xddxdd/nix-cachyos-kernel
- License clarification issue: https://github.com/xddxdd/nix-cachyos-kernel/issues/74
- Upstream clarification received: GPLv2 license; stated use cases permitted; preferred credit name: **Yuhui Xu**
