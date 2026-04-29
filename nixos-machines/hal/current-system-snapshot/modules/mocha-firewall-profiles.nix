# /etc/nixos/modules/mocha-firewall-profiles.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Camada declarativa de perfis do firewall.
# O arquivo de estado e gerado pelo Mocha Firewall Center.

{ ... }:

let
  firewallState = import ./mocha-firewall-state.nix;
in
{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = firewallState.allowedTCPPorts or [];
    allowedUDPPorts = firewallState.allowedUDPPorts or [];

    allowedTCPPortRanges = firewallState.allowedTCPPortRanges or [];
    allowedUDPPortRanges = firewallState.allowedUDPPortRanges or [];
  };
}
