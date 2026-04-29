# /etc/nixos/modules/maintenance.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Manutencao e pequenos ajustes operacionais do sistema.
#
# Regra importante:
# o sistema ativo no SSD nao deve depender operacionalmente de vmstore,
# MOCHAFAST ou qualquer disco externo.
#
# Cache externo:
# quando MOCHAFAST/vmstore estiver montado e for desejado usar o cache
# local, usar NIX_CONFIG temporario no comando de build/rebuild, por exemplo:
#
#   sudo env NIX_CONFIG='
#   experimental-features = nix-command flakes
#   substituters = file:///media/mochafast/nix-cache https://cache.nixos.org/
#   trusted-substituters = file:///media/mochafast/nix-cache https://cache.nixos.org/
#   require-sigs = false
#   fallback = true
#   ' nixos-rebuild build --flake /etc/nixos#diesel-os-lab --show-trace
#
# Isso preserva a eficiencia quando o cache esta disponivel,
# sem criar dependencia permanente de disco externo.

{ pkgs, ... }:

let
  badUsbPort = "/sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb6/6-0:1.0/usb6-port2/disable";
in
{
  services.fstrim.enable = true;
  services.fprintd.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Corrige porta USB defeituosa / instavel que segura o udev no initrd:
  #
  # Sintoma observado:
  #   usb usb6-port2: Cannot enable. Maybe the USB cable is bad?
  #   usb usb6-port2: config error
  #
  # Efeito:
  #   o systemd-udevd do initrd fica vivo ate perto de 26s,
  #   atrasando o switch-root.
  #
  # Estrategia:
  #   desativar a porta ainda no initrd, depois do coldplug inicial,
  #   antes do cleanup/switch-root.
  boot.initrd.systemd.services.mocha-disable-bad-usb-port-initrd = {
    description = "Disable unstable USB6 port2 early in initrd";

    wantedBy = [ "initrd.target" ];
    after = [ "systemd-udev-trigger.service" ];
    before = [
      "initrd-cleanup.service"
      "initrd-switch-root.target"
    ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      port="${badUsbPort}"

      for i in 1 2 3 4 5; do
        if [ -e "$port" ]; then
          echo 1 > "$port" || true
          echo "Mocha initrd: usb6-port2 desativada."
          exit 0
        fi
        sleep 0.2
      done

      echo "Mocha initrd: usb6-port2 nao encontrada; nada a fazer."
      exit 0
    '';
  };

  # Fallback no sistema normal, caso o kernel recrie a porta apos o switch-root
  # ou apos algum evento de energia.
  systemd.services.mocha-disable-bad-usb-port = {
    description = "Disable unstable USB6 port2 on Diesel OS Lab Mocha";

    wantedBy = [ "multi-user.target" ];
    after = [ "sysinit.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      port="${badUsbPort}"

      if [ -e "$port" ]; then
        echo 1 > "$port"
        echo "Mocha: usb6-port2 desativada."
      else
        echo "Mocha: usb6-port2 nao encontrada neste boot; nada a fazer."
      fi
    '';
  };

  # Reaplica a correcao depois de suspensao/hibernacao, caso o kernel reavalie
  # a porta USB no retorno da energia.
  powerManagement.resumeCommands = ''
    port="${badUsbPort}"

    if [ -e "$port" ]; then
      echo 1 > "$port"
      echo "Mocha: usb6-port2 redesativada apos resume."
    fi
  '';
}
