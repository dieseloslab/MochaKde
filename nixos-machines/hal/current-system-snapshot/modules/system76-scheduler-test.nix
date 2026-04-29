# /etc/nixos/modules/system76-scheduler-test.nix
#
# Teste controlado do System76 Scheduler no Diesel OS Lab - GNOME Mocha Edition.
# Não commitar até validar ganho real em jogo/desktop.

{ ... }:

{
  services.system76-scheduler = {
    enable = true;

    # Usar a configuração padrão do pacote primeiro.
    # Assim testamos o comportamento upstream sem customização nossa.
    useStockConfig = true;
  };
}
