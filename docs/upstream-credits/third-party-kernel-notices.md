# Third-party kernel notices for MochaKde / Caninana

## Core rule

MochaKde/Caninana must clearly separate:

1. upstream CachyOS kernel work;
2. Yuhui Xu's Nix/NixOS packaging bridge;
3. MochaKde-specific integration, validation, pinning, desktop, NVIDIA and gaming work.

## Do not claim

MochaKde/Caninana must not claim authorship of:

- CachyOS kernel patches;
- CachyOS kernel tunings;
- CachyOS kernel variants;
- `xddxdd/nix-cachyos-kernel`;
- Yuhui Xu's Hydra/cache/packaging work.

## Safe public wording

Use this wording when documenting kernel work:

> MochaKde/Caninana uses and studies CachyOS kernel work through the community Nix project `xddxdd/nix-cachyos-kernel`, maintained by Yuhui Xu. CachyOS provides the upstream kernel patchset and tuning work; Yuhui Xu provides the Nix/NixOS packaging bridge; MochaKde integrates, pins, tests, documents, and combines these components with Mocha-specific NVIDIA, KDE, gaming, cache and reproducibility work.

## Practical build rule

For experimental kernels:

- prefer pinned flake inputs;
- prefer `release`/cache paths when available;
- do not import raw Arch/CachyOS packages into NixOS;
- do not rename/recompile CachyOS kernels as the default experiment path;
- validate with dry-build/build/boot;
- never use `nixos-rebuild switch` as the default;
- preserve known-good generations and manifests.
