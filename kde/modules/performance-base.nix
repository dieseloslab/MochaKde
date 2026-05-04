{ pkgs, ... }:

{
  services.tuned.enable = true;

  environment.systemPackages = with pkgs; [
    tuned
  ];

  systemd.services.mocha-tuned-latency-performance = {
    description = "Mocha KDE TuneD latency-performance profile";
    wantedBy = [ "multi-user.target" ];
    after = [ "tuned.service" ];
    wants = [ "tuned.service" ];
    path = [ pkgs.tuned pkgs.gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if tuned-adm list | grep -q 'latency-performance'; then
        tuned-adm profile latency-performance
      else
        tuned-adm profile throughput-performance || true
      fi
    '';
  };
}
