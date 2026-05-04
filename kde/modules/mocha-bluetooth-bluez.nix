{ lib, pkgs, ... }:

{
  # MochaKde / Caninana 7.0.1:
  #
  # O adaptador Bluetooth TP-Link UB5A ja e reconhecido pelo kernel:
  # - USB ID 2357:0604
  # - driver btusb
  # - firmware Realtek rtl8761bu carregado
  # - rfkill hci0 desbloqueado
  #
  # Este modulo habilita a pilha de usuario BlueZ e a integracao grafica.

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;

    settings = {
      General = {
        ControllerMode = "dual";
        FastConnectable = true;
      };

      Policy = {
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  environment.systemPackages =
    with pkgs; [
      bluez
      blueman
    ]
    ++ lib.optionals (pkgs ? kdePackages && pkgs.kdePackages ? bluedevil) [
      pkgs.kdePackages.bluedevil
    ];
}
