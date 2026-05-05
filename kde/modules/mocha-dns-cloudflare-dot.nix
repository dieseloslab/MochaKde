# MochaKde - DNS Cloudflare DNS-over-TLS
#
# Regra:
# - altera somente DNS;
# - nao mexe em kernel, NVIDIA, Steam, KDE, tema ou performance;
# - nao depende de /media/mochafast;
# - usa systemd-resolved + NetworkManager;
# - isto nao e VPN: criptografa consultas DNS, mas nao oculta todo o trafego.

{ ... }:

{
  networking.networkmanager.dns = "systemd-resolved";

  services.resolved = {
    enable = true;

    settings.Resolve = {
      DNS = "1.1.1.1#one.one.one.one 1.0.0.1#one.one.one.one 2606:4700:4700::1111#one.one.one.one 2606:4700:4700::1001#one.one.one.one";
      Domains = "~.";
      DNSOverTLS = "yes";
      DNSSEC = "no";
      FallbackDNS = "";
      Cache = "yes";
      DNSStubListener = "yes";
      LLMNR = "no";
      MulticastDNS = "no";
    };
  };
}
