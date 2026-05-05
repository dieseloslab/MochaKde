# Yuhui Xu — `xddxdd/nix-cachyos-kernel`

Status: authorized by upstream maintainer  
License: GPLv2  
Preferred credit name: **Yuhui Xu**

## Repository

- Project: `xddxdd/nix-cachyos-kernel`
- URL: https://github.com/xddxdd/nix-cachyos-kernel
- Maintainer credit: **Yuhui Xu**
- GitHub user: `xddxdd`

## Role in MochaKde / Caninana

MochaKde/Caninana uses and studies `xddxdd/nix-cachyos-kernel` because it provides a Nix/NixOS packaging bridge for CachyOS kernel variants.

This matters because MochaKde relies on reproducible kernel and NVIDIA pairings. The known-good recipe has used:

- kernel line: `7.0.1-cachyos`
- NVIDIA driver: `595.71.05`

The project is also used to study newer CachyOS kernel variants without importing raw Arch/CachyOS packages into NixOS.

## Upstream clarification

License clarification was requested here:

- https://github.com/xddxdd/nix-cachyos-kernel/issues/74

Response received from Yuhui Xu:

> Hi, I have added GPLv2 license to this repo. All the use cases you stated are okay. Please refer to me as "Yuhui Xu".

## Allowed use cases

Based on the upstream response, MochaKde may:

1. use `xddxdd/nix-cachyos-kernel` as a pinned flake input;
2. reference it in documentation with credit;
3. study the packaging approach;
4. create derivative Nix packaging code with proper attribution.

## Required attribution

Use:

> Yuhui Xu

Do not replace this with informal guesses about nationality or identity.  
`xddxdd` may be mentioned as the GitHub handle, but the preferred public credit name is **Yuhui Xu**.

## Credit text

MochaKde/Caninana uses and studies the community Nix project `xddxdd/nix-cachyos-kernel`, maintained by **Yuhui Xu**, which provides CachyOS kernel variants as Nix/NixOS packages with Hydra/cache support.

MochaKde/Caninana does not claim authorship of this Nix/NixOS packaging bridge.
