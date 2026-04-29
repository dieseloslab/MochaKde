# /etc/nixos/modules/desktop-gnome.nix

{ pkgs, lib, ... }:

{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-initial-setup.enable = false;

  services.xserver.xkb = {
    layout = "br";
    model = "abnt2";
    variant = "";
    options = "";
  };

  programs.dconf.enable = true;

  programs.dconf.profiles.user.databases = lib.mkAfter [
    {
      settings."org/gnome/desktop/input-sources" = {
        sources = [ (lib.gvariant.mkTuple [ "xkb" "br" ]) ];
        mru-sources = [ (lib.gvariant.mkTuple [ "xkb" "br" ]) ];
        xkb-options = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
      };

      # Travar esta base evita o GNOME iniciar em layout errado após instalação limpa.
      # Se o usuário quiser outro layout depois, removemos este lock declarativamente.
      lockAll = true;
    }
  ];

  services.printing.enable = true;

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
  services.gnome.gnome-software.enable = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.applications-menu
  ];

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "yes";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.logind.settings.Login = {
    HandleSuspendKey = "hibernate";
    HandleSuspendKeyLongPress = "hibernate";
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.services.flatpak-repo = {
    description = "Configurar repositório Flathub global";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "NetworkManager.service" "network-online.target" ];
    path = [ pkgs.flatpak pkgs.gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = ''
      if flatpak remotes --system --columns=name | grep -qx 'flathub'; then
        exit 0
      fi

      flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
