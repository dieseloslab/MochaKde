# /etc/nixos/iso/mocha-iso.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# ISO Live do Mocha.
#
# Objetivos desta fase:
# - bootar no virt-manager/QEMU-KVM e em hardware real;
# - entrar no GNOME;
# - exibir Calamares de forma clara no Live;
# - manter terminal gráfico opaco e legível;
# - validar teclado br-abnt2;
# - validar idiomas pt_BR, en_US, es_ES e fr_FR;
# - validar kernel Zen 7.0.2;
# - aplicar identidade visual Mocha sem quebrar apps GTK do Live;
# - evitar dependência de hardware-configuration.nix, vmstore e VMware;
# - fazer o Calamares instalar uma configuração Mocha real, não NixOS genérico;
# - preservar o hardware-configuration.nix gerado para a máquina de destino;
# - habilitar suporte QEMU/SPICE para testes com copiar/colar em VM.
#
# Observação:
# esta ISO Live é separada do sistema instalado pessoal do host.
# O sistema instalado pessoal continua usando /etc/nixos/configuration.nix.
# O alvo instalado pela ISO usa uma configuração Mocha genérica, sem vmstore
# e sem NVIDIA fixa, para funcionar em VM e em hardware variado.

{
  pkgs,
  lib,
  config,
  modulesPath,
  zenKernelSrc,
  mochaRoot ? /etc/nixos,
  ...
}:

let
  zenVersion = "7.0.2";
  zenSuffix = "zen1";

  # Mesma ideia usada no sistema instalado:
  # manter PREEMPT full e ajustes principais do Zen, mas sem PREEMPT_VOLUNTARY,
  # que não existe mais no alvo Linux 7.0 usado aqui.
  mkKernelOverride = lib.mkOverride 90;

  linuxZenUpstream = pkgs.linuxKernel.kernels.linux_zen.override {
    argsOverride = rec {
      version = zenVersion;
      modDirVersion = lib.versions.pad 3 "${version}-${zenSuffix}";
      src = zenKernelSrc;

      structuredExtraConfig = with lib.kernel; {
        # Zen Interactive tuning.
        ZEN_INTERACTIVE = yes;

        # FQ-Codel Packet Scheduling.
        NET_SCH_DEFAULT = yes;
        DEFAULT_FQ_CODEL = yes;

        # Preempt low-latency.
        PREEMPT = mkKernelOverride yes;
        PREEMPT_LAZY = mkKernelOverride no;

        # Preemptible tree-based hierarchical RCU.
        TREE_RCU = yes;
        PREEMPT_RCU = yes;
        RCU_EXPERT = yes;
        TREE_SRCU = yes;
        TASKS_RCU_GENERIC = yes;
        TASKS_RCU = yes;
        TASKS_RUDE_RCU = yes;
        TASKS_TRACE_RCU = yes;
        RCU_STALL_COMMON = yes;
        RCU_NEED_SEGCBLIST = yes;
        RCU_FANOUT = freeform "64";
        RCU_FANOUT_LEAF = freeform "16";
        RCU_BOOST = yes;
        RCU_BOOST_DELAY = option (freeform "500");
        RCU_NOCB_CPU = yes;
        RCU_LAZY = yes;
        RCU_DOUBLE_CHECK_CB_TIME = yes;

        # BFQ I/O scheduler.
        IOSCHED_BFQ = mkKernelOverride yes;

        # Wine / Proton.
        FUTEX = yes;
        FUTEX_PI = yes;
        NTSYNC = yes;

        # 1000Hz.
        HZ = freeform "1000";
        HZ_1000 = yes;
      };
    };
  };

  themeName = "Mocha";

  # No Live, GTK precisa ser conservador e legível.
  # O tema Mocha completo continua sendo empacotado e usado no GNOME Shell,
  # mas apps GTK críticos como terminal e Calamares ficam em Adwaita-dark.
  liveGtkTheme = "Adwaita-dark";

  iconTheme = "Tela-circle-brown";
  cursorTheme = "Bibata-Modern-Mocha";
  cursorSize = 24;

  # Cópia filtrada de /etc/nixos para ser embutida na ISO.
  #
  # Não levamos:
  # - result;
  # - .git;
  # - backups .bak;
  # - hardware-configuration.nix do host.
  #
  # O hardware-configuration.nix correto será o gerado pelo Calamares /
  # nixos-generate-config para a máquina de destino.
  mochaSource = builtins.path {
    name = "mocha-install-source";
    path = mochaRoot;
    filter =
      path: type:
      let
        name = baseNameOf path;
      in
      !(
        name == "result"
        || name == ".git"
        || name == "hardware-configuration.nix"
        || lib.hasInfix ".bak" name
      );
  };

  mochaAssets = pkgs.stdenvNoCC.mkDerivation {
    pname = "mocha-live-assets";
    version = "1";

    src = mochaRoot + "/assets";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/icons"
      cp -a "$src/cursors/${cursorTheme}" "$out/share/icons/"

      mkdir -p "$out/share/backgrounds/diesel-os-lab"
      cp -a "$src/branding/wallpaper/wallpaper.png" \
        "$out/share/backgrounds/diesel-os-lab/wallpaper.png"

      mkdir -p "$out/share/diesel-os-lab/branding/logo"
      cp -a "$src/branding/logo/diesel-os-lab-icon.png" \
        "$out/share/diesel-os-lab/branding/logo/diesel-os-lab-icon.png"

      mkdir -p "$out/share/icons/hicolor/256x256/apps"
      cp -a "$src/branding/logo/diesel-os-lab-icon.png" \
        "$out/share/icons/hicolor/256x256/apps/diesel-os-lab.png"

      mkdir -p "$out/share/pixmaps"
      cp -a "$src/branding/logo/diesel-os-lab-icon.png" \
        "$out/share/pixmaps/diesel-os-lab.png"

      mkdir -p "$out/share/themes/${themeName}/gtk-3.0"
      mkdir -p "$out/share/themes/${themeName}/gtk-4.0"
      mkdir -p "$out/share/themes/${themeName}/gnome-shell"

      cp -a "$src/theme/gtk/gtk-3.0.css" \
        "$out/share/themes/${themeName}/gtk-3.0/gtk.css"
      cp -a "$src/theme/gtk/gtk-4.0.css" \
        "$out/share/themes/${themeName}/gtk-4.0/gtk.css"

      cp -a "$src/theme/gtk/gtk-3.0.settings.ini" \
        "$out/share/themes/${themeName}/gtk-3.0/settings.ini"
      cp -a "$src/theme/gtk/gtk-4.0.settings.ini" \
        "$out/share/themes/${themeName}/gtk-4.0/settings.ini"

      cp -a "$src/theme/gnome-shell/gnome-shell.css" \
        "$out/share/themes/${themeName}/gnome-shell/gnome-shell.css"
      cp -a "$src/theme/mocha-palette.css" \
        "$out/share/themes/${themeName}/gnome-shell/mocha-palette.css"
      cp -a "$src/theme/mocha-role-map.css" \
        "$out/share/themes/${themeName}/gnome-shell/mocha-role-map.css"

      cat > "$out/share/themes/${themeName}/index.theme" <<EOF_THEME
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=${themeName}
Comment=Diesel OS Lab - GNOME Mocha Edition

[X-GNOME-Metatheme]
GtkTheme=${liveGtkTheme}
MetacityTheme=Adwaita
IconTheme=${iconTheme}
CursorTheme=${cursorTheme}
ButtonLayout=:minimize,maximize,close
EOF_THEME

      runHook postInstall
    '';
  };

  mochaInstallSource = pkgs.stdenvNoCC.mkDerivation {
    pname = "mocha-install-source";
    version = "1";

    src = mochaSource;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/diesel-os-lab/mocha-install-source"

      shopt -s dotglob nullglob
      cp -a ./* "$out/share/diesel-os-lab/mocha-install-source/"

      runHook postInstall
    '';
  };

  # Configuração que será usada no sistema instalado pela ISO.
  #
  # Ela substitui o configuration.nix copiado para /mnt/etc/nixos antes do
  # nixos-install. Assim o flake #diesel-os-lab continua sendo usado, mas com
  # uma configuração genérica apropriada para instalação pública/VM.
  #
  # Diferenças principais contra o host pessoal:
  # - não importa hardware-nvidia.nix;
  # - não importa vmstore.nix;
  # - habilita qemuGuest e spice-vdagentd;
  # - usa vídeo modesetting/fbdev por padrão;
  # - preserva hardware-configuration.nix gerado para a máquina alvo.
  mochaInstalledConfiguration = pkgs.writeText "mocha-installed-configuration.nix" ''
    # /etc/nixos/configuration.nix
    #
    # Diesel OS Lab - GNOME Mocha Edition
    #
    # Configuração instalada pela ISO.
    # Este arquivo é gerado pelo instalador da ISO Mocha.
    # Não depende do vmstore e não fixa NVIDIA do host pessoal.

    { lib, ... }:

    {
      imports = [
    ../modules/mocha-vm-managers.nix
        ./hardware-configuration.nix
        ./modules/boot.nix
        ./modules/locale.nix
        ./modules/networking.nix
        ./modules/mocha-firewall-profiles.nix
        ./modules/mocha-firewall-center.nix
        ./modules/desktop-gnome.nix
        ./modules/branding.nix
        ./modules/mocha-boot-branding.nix
        ./modules/mocha-flatpak-theme-bridge.nix
        ./modules/gaming.nix
        ./modules/maintenance.nix
        ./modules/packages.nix
        ./modules/optional-apps.nix
        ./modules/mocha-app-picker-gtk.nix
        ./modules/mocha-welcome.nix
        ./modules/mocha-donation-reminder.nix
        ./modules/mocha-update-center.nix
        ./modules/user-hal.nix
        ./modules/tuned.nix
        ./modules/system76-scheduler-test.nix
        ./modules/local-gnome-extensions.nix
        ./modules/firefox-theme.nix
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;

      # Sistema instalado pela ISO: não herdar swap/resumeDevice do host pessoal.
      swapDevices = lib.mkForce [ ];
      boot.resumeDevice = lib.mkForce "";

      services.xserver.videoDrivers = lib.mkForce [
        "modesetting"
        "fbdev"
      ];

      services.qemuGuest.enable = true;
      services.spice-vdagentd.enable = true;

      system.stateVersion = "25.11";
    }
  '';

  wallpaperUri = "file://${mochaAssets}/share/backgrounds/diesel-os-lab/wallpaper.png";

  # Wrapper usado pelo Calamares.
  #
  # O módulo nixos do Calamares chama:
  #   pkexec nixos-install ...
  #
  # O wrapper faz três coisas:
  # 1. força flakes;
  # 2. copia a árvore Mocha embutida na ISO para /mnt/etc/nixos;
  # 3. força a instalação do flake /mnt/etc/nixos#diesel-os-lab.
  #
  # Isso impede que o Calamares instale uma configuração genérica do NixOS.
  nixosInstallWithFlakes = pkgs.writeShellScriptBin "nixos-install" ''
    set -euo pipefail

    if [ -n "''${NIX_CONFIG:-}" ]; then
      export NIX_CONFIG="$NIX_CONFIG
experimental-features = nix-command flakes"
    else
      export NIX_CONFIG="experimental-features = nix-command flakes"
    fi

    targetRoot="/mnt"
    nextIsRoot=0

    for arg in "$@"; do
      if [ "$nextIsRoot" = 1 ]; then
        targetRoot="$arg"
        nextIsRoot=0
        continue
      fi

      case "$arg" in
        --root)
          nextIsRoot=1
          ;;
        --root=*)
          targetRoot="''${arg#--root=}"
          ;;
      esac
    done

    targetEtc="$targetRoot/etc/nixos"
    tmpDir="$(mktemp -d)"

    echo "===== Diesel OS Lab - GNOME Mocha Edition ====="
    echo "Preparando configuração Mocha instalada em: $targetEtc"

    mkdir -p "$targetEtc"

    if [ -f "$targetEtc/hardware-configuration.nix" ]; then
      cp -a "$targetEtc/hardware-configuration.nix" "$tmpDir/hardware-configuration.nix"
    fi

    rm -rf "$targetEtc"
    mkdir -p "$targetEtc"

    cp -a ${mochaInstallSource}/share/diesel-os-lab/mocha-install-source/. "$targetEtc/"

    if [ -f "$tmpDir/hardware-configuration.nix" ]; then
      cp -a "$tmpDir/hardware-configuration.nix" "$targetEtc/hardware-configuration.nix"
    else
      echo "hardware-configuration.nix ainda não existe; tentando gerar com nixos-generate-config."
      if command -v nixos-generate-config >/dev/null 2>&1; then
        nixos-generate-config --root "$targetRoot"
      else
        echo "ERRO: nixos-generate-config não encontrado no Live."
        exit 1
      fi
    fi

    cp -f ${mochaInstalledConfiguration} "$targetEtc/configuration.nix"

    chmod -R u+rwX "$targetEtc"

    echo
    echo "===== CONFIGURAÇÃO MOCHA DO ALVO ====="
    echo "Flake: $targetEtc#diesel-os-lab"
    echo "Hardware: $targetEtc/hardware-configuration.nix"
    echo

    exec ${config.system.build.nixos-install}/bin/nixos-install \
      --option experimental-features "nix-command flakes" \
      --flake "$targetEtc#diesel-os-lab" \
      "$@"
  '';
in
{
  imports = [
    ../modules/mocha-vm-managers.nix
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    ../modules/locale.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Necessário para o Calamares/nixos-install avaliar configurações que usam flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Kernel principal da ISO Live.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # A ISO Live usa kernel Zen 7.0.2.
  # O módulo gráfico padrão do NixOS pode puxar ZFS para o initrd,
  # mas zfs-kernel-2.4.1 não avalia com o kernel Zen 7.0.2 neste nixpkgs.
  # Como o Mocha não usa ZFS como alvo desta ISO, removemos ZFS da lista.
  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "ext4"
    "xfs"
    "vfat"
    "exfat"
    "ntfs"
  ];

  boot.initrd.supportedFilesystems = lib.mkForce [
    "btrfs"
    "ext4"
    "xfs"
    "vfat"
  ];

  # Parâmetros NVIDIA mantidos como compatibilidade quando a ISO for testada
  # em hardware real NVIDIA. A ISO não força driver NVIDIA como único caminho,
  # para continuar bootável em VM/QEMU.
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services.xserver.videoDrivers = [
    "modesetting"
    "fbdev"
    "nvidia"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';

  networking.hostName = "mocha-live";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-initial-setup.enable = false;

  console.keyMap = lib.mkForce "br-abnt2";

  services.xserver.xkb = lib.mkForce {
    layout = "br";
    model = "abnt2";
    variant = "";
    options = "";
  };

  programs.dconf.enable = true;

  programs.dconf.profiles.user.databases = lib.mkAfter [
    {
      settings = {
        "org/gnome/desktop/input-sources" = {
          sources = [ (lib.gvariant.mkTuple [ "xkb" "br" ]) ];
          mru-sources = [ (lib.gvariant.mkTuple [ "xkb" "br" ]) ];
          xkb-options = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
        };

        "org/gnome/desktop/background" = {
          picture-uri = wallpaperUri;
          picture-uri-dark = wallpaperUri;
          picture-options = "zoom";
          primary-color = "#2A1B14";
          secondary-color = "#35231A";
        };

        "org/gnome/desktop/screensaver" = {
          picture-uri = wallpaperUri;
          primary-color = "#2A1B14";
          secondary-color = "#35231A";
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = liveGtkTheme;
          icon-theme = iconTheme;
          cursor-theme = cursorTheme;
          cursor-size = lib.gvariant.mkInt32 cursorSize;
          monospace-font-name = "Monospace 13";
        };

        "org/gnome/shell" = {
          enabled-extensions = [
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "apps-menu@gnome-shell-extensions.gcampax.github.com"
          ];
        };

        "org/gnome/shell/extensions/user-theme" = {
          name = themeName;
        };
      };
    }
  ];

  # Defaults globais GTK para qualquer usuário da ISO.
  # No Live, apps críticos precisam abrir opacos e legíveis.
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=${liveGtkTheme}
    gtk-icon-theme-name=${iconTheme}
    gtk-cursor-theme-name=${cursorTheme}
    gtk-cursor-theme-size=${toString cursorSize}
    gtk-application-prefer-dark-theme=1
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=${liveGtkTheme}
    gtk-icon-theme-name=${iconTheme}
    gtk-cursor-theme-name=${cursorTheme}
    gtk-cursor-theme-size=${toString cursorSize}
    gtk-application-prefer-dark-theme=1
  '';

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gvfs.enable = true;
  services.flatpak.enable = true;

  programs.firefox.enable = true;

  users.users.nixos.extraGroups = [
    "networkmanager"
    "wheel"
      "libvirtd"
    "kvm"
];

  security.sudo.wheelNeedsPassword = false;

  # ISO pública/VM: nunca herdar swap ou resumeDevice do host pessoal.
  swapDevices = lib.mkForce [ ];
  boot.resumeDevice = lib.mkForce "";

  environment.sessionVariables = {
    XCURSOR_THEME = cursorTheme;
    XCURSOR_SIZE = toString cursorSize;

    # Não usar GTK_THEME=Mocha no Live: isso quebrou a legibilidade do terminal.
    GTK_THEME = liveGtkTheme;
  };

  environment.systemPackages = with pkgs; [
    (lib.hiPrio nixosInstallWithFlakes)

    mochaAssets
    mochaInstallSource

    git
    curl
    wget
    micro
    htop
    pciutils
    usbutils

    mesa-demos
    vulkan-tools

    gnome-tweaks
    gnome-console
    gnome-terminal

    gnomeExtensions.applications-menu
    gnomeExtensions.user-themes

    mangohud
    goverlay

    (tela-circle-icon-theme.override {
      colorVariants = [ "brown" ];
      circularFolder = true;
    })
  ];

  isoImage.appendToMenuLabel = " - Diesel OS Lab GNOME Mocha Edition";

  system.nixos.label = "Diesel-OS-Lab-GNOME-Mocha-Live";

  system.stateVersion = "25.11";


}
