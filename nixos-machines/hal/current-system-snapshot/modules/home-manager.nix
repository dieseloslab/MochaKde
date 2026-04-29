# /etc/nixos/modules/home-manager.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Este módulo declara o ambiente do usuário hal.
#
# Responsabilidade do Home Manager:
#   - Git do usuário
#   - GNOME Terminal do usuário
#   - serviço de aplicação do tema Firefox no perfil do usuário
#
# Responsabilidade que continua no NixOS:
#   - kernel
#   - NVIDIA
#   - GDM/GNOME base
#   - pacotes globais
#   - zram/swap/hibernação
#   - assets do sistema
#   - Firefox instalado e policies globais
#
# Regra importante do Firefox Mocha:
#   - userChrome.css controla apenas a moldura/interface do Firefox.
#   - userContent.css não deve ser aplicado, para não interferir em páginas,
#     Dark Reader, formulários, fundos e detecção de tema dos sites.

{ pkgs, ... }:

let
  userName = "hal";
  userHome = "/home/${userName}";

  terminalProfile = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
  firefoxThemeDir = "/etc/nixos/assets/theme/firefox";

  applyFirefoxMochaTheme = pkgs.writeShellScript "apply-firefox-mocha-theme" ''
    set -euo pipefail

    THEME_DIR="${firefoxThemeDir}"

    [ -d "$THEME_DIR" ] || exit 0
    [ -f "$THEME_DIR/userChrome.css" ] || exit 0

    PROFILE_ROOTS=(
      "$HOME/.mozilla/firefox"
      "$HOME/.config/mozilla/firefox"
    )

    PROFILES=()

    for PROFILE_ROOT in "''${PROFILE_ROOTS[@]}"; do
      [ -d "$PROFILE_ROOT" ] || continue

      while IFS= read -r -d "" PROFILE_DIR; do
        PROFILES+=("$PROFILE_DIR")
      done < <(
        find "$PROFILE_ROOT" -maxdepth 1 -mindepth 1 -type d \
          \( -name '*.default' -o -name '*.default-*' -o -name '*.default-release' -o -name '*.default-esr' -o -name '*.default-nightly' \) \
          -print0 | sort -z
      )
    done

    [ "''${#PROFILES[@]}" -gt 0 ] || exit 0

    for PROFILE_DIR in "''${PROFILES[@]}"; do
      mkdir -p "$PROFILE_DIR/chrome"

      install -m 0644 "$THEME_DIR/userChrome.css" "$PROFILE_DIR/chrome/userChrome.css"

      # Não aplicar CSS ao conteúdo das páginas.
      # Isso preserva Dark Reader e evita páginas cinzas/claras quebradas.
      rm -f "$PROFILE_DIR/chrome/userContent.css"
    done
  '';
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "hm-backup";

    users.${userName} = { ... }: {
      home = {
        username = userName;
        homeDirectory = userHome;
        stateVersion = "25.11";
      };

      programs.home-manager.enable = true;

      programs.git = {
        enable = true;

        settings = {
          user = {
            name = "Ricardo Diesel";
            email = "ricardo.diesel@gmail.com";
          };

          init = {
            defaultBranch = "main";
          };

          pull = {
            rebase = false;
          };

          credential = {
            helper = "store";
          };
        };
      };

      dconf.settings = {
        "org/gnome/terminal/legacy/profiles:" = {
          default = terminalProfile;
          list = [ terminalProfile ];
        };

        "org/gnome/terminal/legacy/profiles:/:${terminalProfile}" = {
          visible-name = "Mocha";
          use-theme-colors = false;
          bold-color-same-as-fg = false;
          background-color = "rgb(42,27,20)";
          foreground-color = "rgb(214,184,154)";
          bold-color = "rgb(255,244,235)";
          palette = [
            "rgb(42,27,20)"
            "rgb(107,79,62)"
            "rgb(90,64,51)"
            "rgb(198,169,141)"
            "rgb(184,156,132)"
            "rgb(214,184,154)"
            "rgb(242,231,221)"
            "rgb(255,244,235)"
            "rgb(53,35,26)"
            "rgb(107,79,62)"
            "rgb(90,64,51)"
            "rgb(198,169,141)"
            "rgb(184,156,132)"
            "rgb(214,184,154)"
            "rgb(242,231,221)"
            "rgb(255,244,235)"
          ];
        };

        "org/gnome/terminal/legacy/keybindings" = {
          select-all = "<Primary><Shift>a";
        };
      };

      systemd.user.services.firefox-mocha-theme = {
        Unit = {
          Description = "Apply Mocha Firefox chrome theme to local Firefox profiles";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${applyFirefoxMochaTheme}";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
