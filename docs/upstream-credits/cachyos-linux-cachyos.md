# CachyOS kernel work

## Upstream project

CachyOS provides the upstream kernel patchset, tuning work, and kernel variants studied and used by MochaKde/Caninana.

References:

- CachyOS website: https://cachyos.org/
- CachyOS Linux kernel repository: https://github.com/CachyOS/linux-cachyos
- CachyOS kernel patches: https://github.com/CachyOS/kernel-patches

## Role in MochaKde / Caninana

MochaKde/Caninana studies and integrates CachyOS kernel work through Nix/NixOS packaging, especially via Yuhui Xu's `xddxdd/nix-cachyos-kernel`.

The upstream patchset, scheduling variants, kernel tuning decisions, and CachyOS kernel work belong to the CachyOS project and its contributors.

MochaKde/Caninana does not claim authorship of:

- CachyOS kernel patches;
- CachyOS kernel tunings;
- CachyOS kernel variants;
- CachyOS upstream release work.

## MochaKde contribution layer

MochaKde/Caninana contributes its own integration and validation layer:

- NixOS system integration;
- pinned kernel/NVIDIA pairings;
- local cache and GC-root discipline;
- dry-build/build/boot validation;
- KDE/Plasma Mocha desktop integration;
- gaming performance testing;
- reproducibility logs and manifests.

## Credit text

The upstream CachyOS kernel patchset, tuning work, and kernel variants come from the **CachyOS Team and contributors**.

MochaKde/Caninana integrates, tests, pins, documents, and combines these components with Mocha-specific NVIDIA, desktop, gaming, and reproducibility work.
