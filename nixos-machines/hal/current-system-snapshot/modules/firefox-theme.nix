# /etc/nixos/modules/firefox-theme.nix
#
# Firefox global do sistema.
#
# O serviço de aplicação do tema no perfil do usuário foi movido para:
#   /etc/nixos/modules/home-manager.nix

{ ... }:

{
  programs.firefox = {
    enable = true;

    policies = {
      Preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = {
          Value = true;
          Status = "user";
          Type = "boolean";
        };
      };
    };
  };
}
