{ config, lib, pkgs, ... }:

{
  imports = [
    ../../kde/modules/mocha-bluetooth-bluez.nix
    
    ../../kde/modules/mocha-zram-hibernate.nix
    ./hardware-configuration.nix
    ../../kde/modules/mocha-kde-apps-discover-firefox.nix

    ../../kde/modules/mochafast-mount.nix
    ../../kde/modules/protect-foreign-internal-disks.nix

    ../../kde/modules/caninana-kernel.nix
    ../../kde/modules/nvidia-pinned.nix

    ../../kde/modules/plasma-base.nix
    ../../kde/modules/mocha-kde-theme-system.nix
    ../../kde/modules/mocha-firefox-force-theme-policy.nix
    ../../kde/modules/gaming-base.nix
    ../../kde/modules/performance-base.nix
  ];

  networking.hostName = "mocha-kde-hal";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.auto-optimise-store = true;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "br-abnt2";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  users.users.hal = {
    isNormalUser = true;
    description = "Hal";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "gamemode"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    nano
    wget
    curl
    file
    pciutils
    usbutils
    lsof
    strace
    btop
    htop
  ];

  system.stateVersion = "25.11";
}
