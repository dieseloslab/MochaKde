{ config, pkgs, lib, nordvpnPkg ? null, ... }:

let
  mochaUser = "hal";

  cloudflareWarpPkgs =
    lib.optionals (lib.hasAttrByPath [ "cloudflare-warp" ] pkgs) [
      pkgs."cloudflare-warp"
    ];

  nordvpnPkgs =
    lib.optionals (nordvpnPkg != null) [
      nordvpnPkg
    ];

  kdialogPkgs =
    lib.optionals (lib.hasAttrByPath [ "kdePackages" "kdialog" ] pkgs) [
      pkgs.kdePackages.kdialog
    ]
    ++ lib.optionals (lib.hasAttrByPath [ "kdialog" ] pkgs) [
      pkgs.kdialog
    ];

  commonPath = lib.makeBinPath (
    [
      pkgs.coreutils
      pkgs.curl
      pkgs.gnugrep
      pkgs.gnused
      pkgs.gawk
      pkgs.iproute2
      pkgs.systemd
      pkgs.sudo
      pkgs.openvpn
    ]
    ++ lib.optionals (lib.hasAttrByPath [ "wireguard-tools" ] pkgs) [
      pkgs.wireguard-tools
    ]
    ++ cloudflareWarpPkgs
    ++ nordvpnPkgs
    ++ kdialogPkgs
  );

  mochaVpn = pkgs.writeShellScriptBin "mocha-vpn" ''
    set -euo pipefail
    export PATH=${commonPath}:$PATH

    have() { command -v "$1" >/dev/null 2>&1; }
    fail() { echo "ERRO: $*" >&2; exit 1; }
    need() { have "$1" || fail "$1 nao encontrado nesta geracao. Reinicie na geracao VPN."; }

    # Padrao novo: modo que realmente conectou no teste.
    # NordLynx = implementacao WireGuard da Nord. O protocolo aparece como UDP porque WireGuard usa UDP.
    mode="''${1:-wireguard}"
    NORD_TARGET="''${MOCHA_NORD_TARGET:-Brazil}"

    start_warp_svc() {
      sudo systemctl start warp-svc.service >/dev/null 2>&1 \
        || sudo systemctl start cloudflare-warp.service >/dev/null 2>&1 \
        || true
    }

    start_nord_svc() {
      sudo systemctl start nordvpnd.service >/dev/null 2>&1 || true
    }

    stop_cloudflare() {
      if have warp-cli; then
        warp-cli disconnect >/dev/null 2>&1 || true
      fi
    }

    stop_nord() {
      if have nordvpn; then
        nordvpn disconnect >/dev/null 2>&1 || true
      fi
    }

    status_all() {
      echo
      echo "===== NORDVPN ====="
      if have nordvpn; then nordvpn status || true; else echo "nordvpn nao encontrado"; fi

      echo
      echo "===== CLOUDFLARE WARP ====="
      if have warp-cli; then warp-cli status || true; else echo "warp-cli nao encontrado"; fi

      echo
      echo "===== ROTA PADRAO ====="
      ip route get 1.1.1.1 2>/dev/null || true

      echo
      echo "===== TRACE CLOUDFLARE ====="
      curl -fsS https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | grep -E '^(ip|loc|warp)=' || true
    }

    connect_nord_openvpn() {
      proto="$1"
      proto_up="$(printf '%s' "$proto" | tr '[:lower:]' '[:upper:]')"

      need nordvpn
      echo "Ativando NordVPN OpenVPN $proto_up..."
      stop_cloudflare
      start_nord_svc
      nordvpn disconnect >/dev/null 2>&1 || true
      nordvpn set technology openvpn || true
      nordvpn set protocol "$proto" || nordvpn set protocol "$proto_up" || true

      if nordvpn connect "$NORD_TARGET" || nordvpn connect; then
        status_all
      else
        echo "ERRO: NordVPN OpenVPN $proto_up nao conectou."
        status_all
        exit 1
      fi
    }

    connect_nord_wireguard() {
      need nordvpn
      echo "Ativando NordVPN NordLynx/WireGuard..."
      echo "Obs: o status pode mostrar protocolo UDP; isso e normal no WireGuard."
      stop_cloudflare
      start_nord_svc
      nordvpn disconnect >/dev/null 2>&1 || true
      nordvpn set technology nordlynx || true

      if nordvpn connect "$NORD_TARGET" || nordvpn connect; then
        status_all
      else
        echo "ERRO: NordVPN NordLynx/WireGuard nao conectou."
        status_all
        exit 1
      fi
    }

    case "$mode" in
      menu)
        exec mocha-vpn-menu
        ;;

      status)
        status_all
        ;;

      off|disconnect|desligar)
        echo "Desconectando NordVPN e Cloudflare WARP..."
        stop_nord
        stop_cloudflare
        status_all
        ;;

      nord|default|padrao|padrão|nord-default|nord-lynx|nordlynx|nord-wireguard|nord-wg|wireguard|wg|funcionando|ok)
        connect_nord_wireguard
        ;;

      nord-udp|udp|openvpn-udp)
        connect_nord_openvpn udp
        ;;

      nord-tcp|tcp|tpc|openvpn-tcp)
        connect_nord_openvpn tcp
        ;;

      cloudflare-wg|cloudflare-wireguard|cf-wg|warp-wg)
        need warp-cli
        echo "Ativando Cloudflare WARP em WireGuard + DoH..."
        stop_nord
        start_warp_svc
        warp-cli registration show >/dev/null 2>&1 || warp-cli registration new || true
        warp-cli mode warp+doh
        warp-cli tunnel protocol set WireGuard
        warp-cli connect
        status_all
        ;;

      cloudflare-doh|cf-doh|doh)
        need warp-cli
        echo "Ativando Cloudflare em DNS-only DoH..."
        stop_nord
        start_warp_svc
        warp-cli registration show >/dev/null 2>&1 || warp-cli registration new || true
        warp-cli mode doh
        warp-cli connect || true
        status_all
        ;;

      *)
        cat >&2 <<EOF
Uso:
  mocha-vpn                  # padrao novo: NordLynx/WireGuard, o modo que funcionou
  mocha-vpn funcionando      # NordLynx/WireGuard
  mocha-vpn wireguard        # NordLynx/WireGuard
  mocha-vpn udp              # OpenVPN UDP antigo, falhou no teste atual
  mocha-vpn tcp              # OpenVPN TCP antigo, falhou no teste atual
  mocha-vpn tpc              # alias para TCP
  mocha-vpn cloudflare-wg    # Cloudflare WARP WireGuard + DoH
  mocha-vpn off              # desliga VPNs
  mocha-vpn status           # status
  mocha-vpn menu             # menu KDE/terminal
EOF
        exit 2
        ;;
    esac
  '';

  mochaNordLogin = pkgs.writeShellScriptBin "mocha-nord-login" ''
    set -euo pipefail
    export PATH=${commonPath}:$PATH

    if ! command -v nordvpn >/dev/null 2>&1; then
      echo "ERRO: nordvpn nao encontrado nesta geracao."
      exit 1
    fi

    sudo systemctl start nordvpnd.service >/dev/null 2>&1 || true

    echo "Cole o token da NordVPN abaixo."
    echo "Ele NAO sera exibido na tela e NAO sera salvo por este script."
    printf "Token NordVPN: " >&2
    IFS= read -r -s NORD_TOKEN
    echo >&2

    if [ -z "$NORD_TOKEN" ]; then
      echo "ERRO: token vazio."
      exit 1
    fi

    nordvpn login --token "$NORD_TOKEN"
    unset NORD_TOKEN

    echo
    echo "Definindo padrao NordVPN como NordLynx/WireGuard..."
    nordvpn set technology nordlynx || true

    echo
    echo "===== CONTA / STATUS ====="
    nordvpn account || true
    nordvpn status || true
  '';

  mochaVpnMenu = pkgs.writeShellScriptBin "mocha-vpn-menu" ''
    set -euo pipefail
    export PATH=${commonPath}:$PATH

    if command -v kdialog >/dev/null 2>&1; then
      choice="$(kdialog --title "Mocha VPN" --menu "Escolha o modo de VPN" \
        wireguard "FUNCIONANDO - NordVPN NordLynx / WireGuard" \
        udp "Alternativa - NordVPN OpenVPN UDP" \
        tcp "Alternativa - NordVPN OpenVPN TCP" \
        cloudflare-wg "Cloudflare WARP - WireGuard + DoH" \
        off "Desligar VPNs" \
        status "Mostrar status" \
      )" || exit 0
      exec mocha-vpn "$choice"
    fi

    echo "===== MOCHA VPN ====="
    echo "1) FUNCIONANDO - NordVPN NordLynx / WireGuard"
    echo "2) Alternativa - NordVPN OpenVPN UDP"
    echo "3) Alternativa - NordVPN OpenVPN TCP"
    echo "4) Cloudflare WARP WireGuard + DoH"
    echo "5) Desligar VPNs"
    echo "6) Status"
    printf "Escolha: "
    read -r n

    case "$n" in
      1) exec mocha-vpn wireguard ;;
      2) exec mocha-vpn udp ;;
      3) exec mocha-vpn tcp ;;
      4) exec mocha-vpn cloudflare-wg ;;
      5) exec mocha-vpn off ;;
      6) exec mocha-vpn status ;;
      *) echo "Opcao invalida"; exit 2 ;;
    esac
  '';

  mkDesktop = fileName: appName: execCmd:
    pkgs.writeTextFile {
      name = fileName;
      destination = "/share/applications/${fileName}.desktop";
      text = ''
        [Desktop Entry]
        Type=Application
        Name=${appName}
        Exec=${execCmd}
        Icon=network-vpn
        Terminal=true
        Categories=Network;Security;
      '';
    };

  desktopEntries = [
    (mkDesktop "mocha-vpn-nord-funcionando" "Mocha VPN - FUNCIONANDO NordLynx" "mocha-vpn wireguard")
    (mkDesktop "mocha-vpn-menu" "Mocha VPN - Menu" "mocha-vpn-menu")
    (mkDesktop "mocha-vpn-nord-wireguard" "Mocha VPN - Nord WireGuard" "mocha-vpn wireguard")
    (mkDesktop "mocha-vpn-nord-udp-openvpn" "Mocha VPN - Nord OpenVPN UDP" "mocha-vpn udp")
    (mkDesktop "mocha-vpn-nord-tcp-openvpn" "Mocha VPN - Nord OpenVPN TCP" "mocha-vpn tcp")
    (mkDesktop "mocha-vpn-cloudflare-wireguard" "Mocha VPN - Cloudflare WireGuard" "mocha-vpn cloudflare-wg")
    (mkDesktop "mocha-vpn-off" "Mocha VPN - Desligar VPN" "mocha-vpn off")
  ];
in
{
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  networking.networkmanager.enable = lib.mkDefault true;
  networking.firewall.checkReversePath = lib.mkDefault false;

  users.groups.nordvpn = { };
  users.users.${mochaUser}.extraGroups = lib.mkAfter [ "networkmanager" "nordvpn" ];

  environment.systemPackages =
    [
      mochaVpn
      mochaNordLogin
      mochaVpnMenu
      pkgs.curl
      pkgs.openvpn
    ]
    ++ lib.optionals (lib.hasAttrByPath [ "wireguard-tools" ] pkgs) [ pkgs.wireguard-tools ]
    ++ cloudflareWarpPkgs
    ++ nordvpnPkgs
    ++ kdialogPkgs
    ++ desktopEntries;

  systemd.packages = cloudflareWarpPkgs ++ nordvpnPkgs;

  systemd.services.nordvpnd = lib.mkIf (nordvpnPkg != null) {
    description = "NordVPN daemon";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path =
      [
        pkgs.coreutils
        pkgs.iproute2
        pkgs.procps
        pkgs.openvpn
      ]
      ++ lib.optionals (lib.hasAttrByPath [ "wireguard-tools" ] pkgs) [ pkgs.wireguard-tools ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${nordvpnPkg}/bin/nordvpnd";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    postStart = ''
      for i in $(seq 1 80); do
        if [ -S /run/nordvpn/nordvpnd.sock ]; then
          chgrp nordvpn /run/nordvpn/nordvpnd.sock || true
          chmod 660 /run/nordvpn/nordvpnd.sock || true
          break
        fi
        sleep 0.25
      done
    '';
  };

  systemd.tmpfiles.rules = [
    "d /run/nordvpn 0770 root nordvpn - -"
    "d /var/lib/nordvpn 0750 root nordvpn - -"
  ];

  environment.etc."mocha-vpn/README.md".text = ''
    # Mocha VPN modes

    Padrao novo:
    - mocha-vpn
    - mocha-vpn funcionando
    - mocha-vpn wireguard

    Todos acima ativam NordVPN NordLynx/WireGuard, que foi o modo validado em teste real.

    Observacao:
    - O status da Nord mostra protocolo UDP em NordLynx porque WireGuard usa UDP.
    - Isso nao e o mesmo que OpenVPN UDP.

    Alternativas:
    - mocha-vpn udp
    - mocha-vpn tcp
    - mocha-vpn tpc
    - mocha-vpn cloudflare-wg
    - mocha-vpn off
    - mocha-vpn status
    - mocha-vpn menu

    Token NordVPN:
    - usar mocha-nord-login
    - nao salvar em Git
    - nao salvar em log
    - nao colar em chat
  '';
}
