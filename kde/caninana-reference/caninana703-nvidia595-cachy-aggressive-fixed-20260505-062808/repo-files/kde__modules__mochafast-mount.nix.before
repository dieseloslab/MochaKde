{ config, lib, pkgs, ... }:

{
  fileSystems."/media/mochafast" = {
    device = "/dev/disk/by-uuid/2f9237e4-e958-462b-a322-0552265ea23a";
    fsType = "xfs";
    options = [
      "rw"
      "relatime"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };
}
