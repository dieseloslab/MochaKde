# /etc/nixos/modules/tuned.nix

{ ... }:

{
  services.tuned = {
    enable = true;
    ppdSupport = true;
  };
}
