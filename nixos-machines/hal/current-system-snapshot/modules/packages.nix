# /etc/nixos/modules/packages.nix

{ pkgs, ... }:

let
  onlyofficeMocha = pkgs.writeShellScriptBin "onlyoffice-desktopeditors" ''
    # O pacote oficial do ONLYOFFICE usa bwrap e tenta iniciar no diretório atual.
    # Se o terminal estiver em /etc/nixos ou outro caminho que o sandbox não enxerga,
    # o app falha com: bwrap: Can't chdir.
    cd "$HOME"

    # Renderização segura para o Mocha:
    # - evita erro ANGLE/libGL.so.1 no ONLYOFFICE 9.1.0 em GNOME Wayland/NVIDIA;
    # - preserva abertura normal do app;
    # - deixa apenas avisos QXcbConnection BadMatch, que não impediram uso no teste.
    export QT_OPENGL=software
    export QT_QUICK_BACKEND=software
    export LIBGL_ALWAYS_SOFTWARE=1
    export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu --disable-gpu-compositing --disable-gpu-rasterization --disable-accelerated-2d-canvas --disable-accelerated-video-decode --disable-software-rasterizer --use-gl=disabled"

    exec ${pkgs.onlyoffice-desktopeditors}/bin/onlyoffice-desktopeditors \
      --force-scale=1.25 \
      --disable-gpu \
      --disable-gpu-compositing \
      --disable-gpu-rasterization \
      --disable-accelerated-2d-canvas \
      --disable-accelerated-video-decode \
      --disable-software-rasterizer \
      --use-gl=disabled \
      "$@"
  '';

  onlyofficeMochaDesktop = pkgs.makeDesktopItem {
    name = "onlyoffice-desktopeditors";
    desktopName = "ONLYOFFICE Desktop Editors";
    genericName = "Office Suite";
    comment = "Edit office documents with ONLYOFFICE Desktop Editors using Mocha-safe rendering";
    exec = "onlyoffice-desktopeditors %U";
    icon = "onlyoffice-desktopeditors";
    terminal = false;
    categories = [
      "Office"
      "WordProcessor"
      "Spreadsheet"
      "Presentation"
    ];
  };
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Base e manutenção
    git
    curl
    wget
    python3
    vim
    nano
    micro
    htop
    pciutils
    usbutils

    # Diagnóstico gráfico / vídeo / Vulkan
    mesa-demos
    vulkan-tools

    # GNOME e ajustes
    gnome-tweaks
    gnome-terminal

    # Aplicativos padrão do Mocha
    bitwarden-desktop
    onlyofficeMocha
    onlyofficeMochaDesktop

    # Ferramentas gamer base
    mangohud
    goverlay
    heroic
    vkbasalt

    # Tema / ícones / extensões
    (tela-circle-icon-theme.override {
      colorVariants = [ "brown" ];
      circularFolder = true;
    })

    gnomeExtensions.user-themes
    gnomeExtensions.dash-to-dock
    gnomeExtensions.caffeine

    # Biométrico
    fprintd
  ];
}
