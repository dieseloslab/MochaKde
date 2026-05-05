# Credits

MochaKde / Caninana is built on top of free software and community research.  
This project does not claim authorship of upstream kernel patchsets, kernel packaging bridges, desktop environments, drivers, or tools developed by their respective maintainers.

## Kernel and NixOS packaging

### Yuhui Xu — `xddxdd/nix-cachyos-kernel`

MochaKde/Caninana uses and studies the community Nix project [`xddxdd/nix-cachyos-kernel`](https://github.com/xddxdd/nix-cachyos-kernel), maintained by **Yuhui Xu**.

This project is important to MochaKde because it provides CachyOS kernel variants as Nix/NixOS packages, including `linuxPackages-*` outputs that allow NixOS systems to pair a CachyOS kernel with external kernel modules such as NVIDIA in a reproducible way.

License clarification was requested upstream:

- https://github.com/xddxdd/nix-cachyos-kernel/issues/74

Upstream response from Yuhui Xu:

> Hi, I have added GPLv2 license to this repo. All the use cases you stated are okay. Please refer to me as "Yuhui Xu".

Accordingly, MochaKde credits this Nix/NixOS packaging bridge to **Yuhui Xu** and respects the GPLv2 license.

### CachyOS Team and contributors

The upstream CachyOS kernel patchset, tuning work, kernel variants, and related performance-oriented work come from the CachyOS project and its contributors.

MochaKde/Caninana does not claim authorship of CachyOS kernel patches or tuning work. Our role is integration, testing, pinning, documentation, NVIDIA pairing, desktop/gaming configuration, and reproducibility work for the MochaKde system.

References:

- CachyOS: https://cachyos.org/
- CachyOS Linux kernel sources and packaging references: https://github.com/CachyOS/linux-cachyos
- CachyOS kernel patches: https://github.com/CachyOS/kernel-patches
- Nix/NixOS bridge by Yuhui Xu: https://github.com/xddxdd/nix-cachyos-kernel

## MochaKde / Caninana scope

MochaKde/Caninana integrates and documents a reproducible gaming-oriented NixOS setup.  
It combines upstream work with Mocha-specific choices such as:

- pinned kernel and NVIDIA pairings;
- reproducible NixOS generations;
- local cache and manifest discipline;
- KDE/Plasma Mocha visual integration;
- gaming tools and performance validation;
- logs and dry-build/build/boot validation instead of unsafe live switching.

## Social purpose

MochaKde / Diesel OS Lab has a nonprofit/beneficial purpose.

One broader goal is to support social and educational initiatives, including helping children with Down syndrome and their families have better access to technology, learning resources, digital inclusion, and, where possible, treatment/support programs.

The technical goal is to build a reproducible, high-performance Linux gaming system that can help people who cannot afford expensive Windows licenses, paid tuning tools, or high-end hardware upgrades.
