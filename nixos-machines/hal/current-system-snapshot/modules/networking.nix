# /etc/nixos/modules/networking.nix

{
  networking.hostName = "diesel-os-lab";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
}
