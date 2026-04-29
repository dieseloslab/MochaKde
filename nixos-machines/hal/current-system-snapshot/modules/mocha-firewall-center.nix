# /etc/nixos/modules/mocha-firewall-center.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Interface grafica simples para perfis de firewall do Mocha.

{ pkgs, ... }:

let
  applyScript = pkgs.writeShellScript "mocha-firewall-center-apply" ''
    set -euo pipefail

    profile="''${1:-normal}"
    tcp_raw="''${2:-}"
    udp_raw="''${3:-}"

    state_file="/etc/nixos/modules/mocha-firewall-state.nix"
    flake_target="/etc/nixos#diesel-os-lab"

    normalize_ports() {
      local raw="''${1:-}"
      raw="''${raw// /}"

      if [ -z "$raw" ]; then
        echo ""
        return 0
      fi

      local IFS=','
      local -a parts
      read -ra parts <<< "$raw"

      local out=""
      local p=""

      for p in "''${parts[@]}"; do
        if ! [[ "$p" =~ ^[0-9]+$ ]]; then
          echo "Porta invalida: $p" >&2
          return 1
        fi

        if [ "$p" -lt 1 ] || [ "$p" -gt 65535 ]; then
          echo "Porta fora do intervalo permitido: $p" >&2
          return 1
        fi

        out="$out $p"
      done

      echo "$out"
    }

    case "$profile" in
      normal)
        profile_name="normal"
        tcp_ports=""
        udp_ports=""
        tcp_ranges=""
        udp_ranges=""
        ;;

      steam-remote-play)
        profile_name="steam-remote-play"
        tcp_ports="27036 27037"
        udp_ports="27031 27036"
        tcp_ranges=""
        udp_ranges=""
        ;;

      steam-source-server)
        profile_name="steam-source-server"
        tcp_ports="27015"
        udp_ports="27005 27015 27020"
        tcp_ranges=""
        udp_ranges=""
        ;;

      steam-wide-diagnostic)
        profile_name="steam-wide-diagnostic"
        tcp_ports=""
        udp_ports=""
        tcp_ranges="{ from = 27015; to = 27030; } { from = 27036; to = 27037; }"
        udp_ranges="{ from = 27000; to = 27036; }"
        ;;

      host-custom)
        profile_name="host-custom"
        tcp_ports="$(normalize_ports "$tcp_raw")"
        udp_ports="$(normalize_ports "$udp_raw")"
        tcp_ranges=""
        udp_ranges=""
        ;;

      *)
        echo "Perfil desconhecido: $profile" >&2
        exit 1
        ;;
    esac

    mkdir -p /etc/nixos/modules

    if [ -f "$state_file" ]; then
      cp -a "$state_file" "$state_file.bak-$(date +%Y%m%d-%H%M%S)"
    fi

    cat > "$state_file" <<STATE_EOF
# /etc/nixos/modules/mocha-firewall-state.nix
#
# Gerado pelo Mocha Firewall Center.
# Edicao manual permitida, mas prefira usar a interface grafica.

{
  profileName = "$profile_name";
  allowedTCPPorts = [ $tcp_ports ];
  allowedUDPPorts = [ $udp_ports ];
  allowedTCPPortRanges = [ $tcp_ranges ];
  allowedUDPPortRanges = [ $udp_ranges ];
}
STATE_EOF

    env NIX_CONFIG='experimental-features = nix-command flakes' \
      /run/current-system/sw/bin/nixos-rebuild test --flake "$flake_target" --show-trace

    env NIX_CONFIG='experimental-features = nix-command flakes' \
      /run/current-system/sw/bin/nixos-rebuild switch --flake "$flake_target" --show-trace
  '';

  mochaFirewallCenter = pkgs.writeShellScriptBin "mocha-firewall-center" ''
    set -euo pipefail

    ZENITY="${pkgs.zenity}/bin/zenity"
    PKEXEC="/run/wrappers/bin/pkexec"
    APPLY="${applyScript}"

    profile="$("$ZENITY" \
      --list \
      --title="Mocha Firewall Center" \
      --width=900 \
      --height=460 \
      --column="Perfil" \
      --column="Descricao" \
      "normal" "Modo normal: firewall ativo sem portas extras abertas" \
      "steam-remote-play" "Steam Remote Play / Steam Link: abre portas de streaming local" \
      "steam-source-server" "Servidor Steam Source/GoldSrc: CS, TF2, Garry's Mod, Left 4 Dead etc." \
      "steam-wide-diagnostic" "Steam amplo / diagnostico temporario: abre faixas Steam comuns" \
      "host-custom" "Host manual: abrir portas TCP/UDP escolhidas por voce" \
    )" || exit 0

    case "$profile" in
      normal)
        tcp_ports=""
        udp_ports=""
        confirm_text="Aplicar Modo normal?\n\nIsso fecha portas extras abertas pelos perfis do Mocha Firewall Center."
        ;;

      steam-remote-play)
        tcp_ports=""
        udp_ports=""
        confirm_text="Aplicar perfil Steam Remote Play / Steam Link?\n\nTCP: 27036, 27037\nUDP: 27031, 27036\n\nUse quando este PC for o host do Remote Play."
        ;;

      steam-source-server)
        tcp_ports=""
        udp_ports=""
        confirm_text="Aplicar perfil Servidor Steam Source/GoldSrc?\n\nTCP: 27015\nUDP: 27005, 27015, 27020\n\nUse para hospedar servidores Source/GoldSrc ou jogos compatíveis."
        ;;

      steam-wide-diagnostic)
        tcp_ports=""
        udp_ports=""
        confirm_text="Aplicar perfil Steam amplo / diagnostico?\n\nTCP: 27015-27030 e 27036-27037\nUDP: 27000-27036\n\nUse temporariamente para diagnosticar problemas de host, Remote Play ou jogos Steam.\nNao e recomendado como modo normal permanente."
        ;;

      host-custom)
        tcp_ports="$("$ZENITY" \
          --entry \
          --title="Mocha Firewall Center - TCP" \
          --width=620 \
          --text="Digite portas TCP separadas por virgula. Exemplo: 27015,27036\nDeixe vazio se nao quiser abrir TCP.")" || exit 0

        udp_ports="$("$ZENITY" \
          --entry \
          --title="Mocha Firewall Center - UDP" \
          --width=620 \
          --text="Digite portas UDP separadas por virgula. Exemplo: 27015,27031,27036\nDeixe vazio se nao quiser abrir UDP.")" || exit 0

        confirm_text="Aplicar perfil manual?\n\nTCP: ''${tcp_ports:-nenhuma}\nUDP: ''${udp_ports:-nenhuma}"
        ;;

      *)
        exit 0
        ;;
    esac

    "$ZENITY" \
      --question \
      --title="Mocha Firewall Center" \
      --width=720 \
      --text="$confirm_text" || exit 0

    if "$PKEXEC" "$APPLY" "$profile" "$tcp_ports" "$udp_ports"; then
      "$ZENITY" \
        --info \
        --title="Mocha Firewall Center" \
        --width=560 \
        --text="Perfil de firewall aplicado com sucesso."
    else
      "$ZENITY" \
        --error \
        --title="Mocha Firewall Center" \
        --width=680 \
        --text="Falha ao aplicar o perfil de firewall.\n\nNenhuma mudanca foi considerada segura.\nRode pelo terminal para ver o log detalhado."
      exit 1
    fi
  '';

  desktopItem = pkgs.makeDesktopItem {
    name = "mocha-firewall-center";
    desktopName = "Mocha Firewall Center";
    comment = "Gerenciar perfis de firewall do Mocha";
    exec = "mocha-firewall-center";
    icon = "security-high";
    categories = [
      "System"
      "Settings"
    ];
  };
in
{
  environment.systemPackages = [
    mochaFirewallCenter
    desktopItem
    pkgs.nftables
  ];
}
