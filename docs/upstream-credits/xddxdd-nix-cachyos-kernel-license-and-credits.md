# Upstream credit and license status: xddxdd/nix-cachyos-kernel

Status: authorized by upstream maintainer  
License: GPLv2  
Preferred credit name: Yuhui Xu

## Repository

Upstream repository:

- `xddxdd/nix-cachyos-kernel`
- GitHub: https://github.com/xddxdd/nix-cachyos-kernel

Maintainer/public identity:

- Preferred credit name: Yuhui Xu
- GitHub user: `xddxdd`
- Also known as: Lan Tian

## License clarification

We opened an upstream issue asking for license clarification and preferred credit wording:

- https://github.com/xddxdd/nix-cachyos-kernel/issues/74

Upstream response received from Yuhui Xu:

> Hi, I have added GPLv2 license to this repo. All the use cases you stated are okay. Please refer to me as "Yuhui Xu".

## Meaning for MochaKde

The following use cases are authorized according to the upstream response:

1. use `xddxdd/nix-cachyos-kernel` as a pinned flake input;
2. reference it in documentation with credit;
3. study the packaging approach;
4. create derivative Nix packaging code with proper attribution.

## Why this matters to MochaKde

MochaKde is studying and testing `nix-cachyos-kernel` because it provides a Nix/NixOS bridge for CachyOS kernel variants.

This is technically important to us because the known-good MochaKde performance recipe uses a CachyOS kernel line with a pinned NVIDIA driver pairing:

- known-good kernel line: `7.0.1-cachyos`
- known-good NVIDIA driver: `595.71.05`

The current study is to determine whether newer CachyOS kernel packages can be used in the same safe pattern:

- use CachyOS kernel as Nix/NixOS package;
- do not import raw Arch/CachyOS packages into NixOS;
- do not rename/recompile the kernel as the default experiment path;
- keep the kernel and NVIDIA pairing reproducible;
- prefer binary cache/substituter paths when available;
- preserve the known-good generation and only test new generations through dry-build/build/boot.

## Credit text

MochaKde/Caninana uses and studies the community Nix project `xddxdd/nix-cachyos-kernel`, maintained by Yuhui Xu, which provides CachyOS kernel variants as Nix/NixOS packages with Hydra/cache support.

The upstream CachyOS kernel patchset, tuning work, and kernel variants come from the CachyOS `linux-cachyos` project and its contributors.

MochaKde/Caninana does not claim authorship of the CachyOS kernel patchset or the Nix packaging bridge; it integrates, tests, pins, documents, and combines these components with Mocha-specific NVIDIA, desktop, gaming, and reproducibility work.

## Project purpose note

MochaKde / Diesel OS Lab has a nonprofit/beneficial purpose.

One broader goal is to support social and educational initiatives, including helping children with Down syndrome and their families have better access to technology, learning resources, digital inclusion, and, where possible, treatment/support programs.

The technical goal is to build a reproducible, high-performance Linux gaming system that can help people who cannot afford expensive Windows licenses, paid tuning tools, or high-end hardware upgrades.

## Current rule

Allowed:

- use `xddxdd/nix-cachyos-kernel` as a pinned external flake input;
- keep local study notes;
- keep logs, manifests, commit IDs, drvPaths, outPaths and closures;
- credit Yuhui Xu and upstream CachyOS projects;
- create derivative Nix packaging work under GPLv2-compatible terms with proper attribution.

Still required:

- preserve credits;
- preserve license notices;
- avoid pretending MochaKde authored CachyOS kernel patches or Yuhui Xu's Nix packaging bridge;
- keep experimental kernel work isolated from the known-good MochaKde generation.
