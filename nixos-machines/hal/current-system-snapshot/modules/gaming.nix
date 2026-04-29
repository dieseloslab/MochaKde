# /etc/nixos/modules/gaming.nix

{ pkgs, ... }:

let
  mochaGameOnRoot = pkgs.writeShellScriptBin "mocha-game-on-root" ''
    set -euo pipefail

    state_dir="/run/mocha-game-mode"
    previous_file="$state_dir/previous-tuned-profile"

    mkdir -p "$state_dir"
    chmod 0755 "$state_dir"

    current="$(${pkgs.tuned}/bin/tuned-adm active 2>/dev/null | sed -n 's/^Current active profile: //p' | head -n 1)"
    if [ -z "$current" ]; then
      current="balanced"
    fi

    if [ "$current" != "latency-performance" ]; then
      printf '%s\n' "$current" > "$previous_file"
    elif [ ! -s "$previous_file" ]; then
      printf '%s\n' "balanced" > "$previous_file"
    fi

    ${pkgs.tuned}/bin/tuned-adm profile latency-performance
  '';

  mochaGameOffRoot = pkgs.writeShellScriptBin "mocha-game-off-root" ''
    set -euo pipefail

    state_dir="/run/mocha-game-mode"
    previous_file="$state_dir/previous-tuned-profile"

    previous="balanced"
    if [ -s "$previous_file" ]; then
      previous="$(head -n 1 "$previous_file" | tr -d '[:space:]')"
    fi

    case "$previous" in
      balanced|latency-performance|throughput-performance|accelerator-performance|desktop|powersave|virtual-guest|virtual-host)
        ${pkgs.tuned}/bin/tuned-adm profile "$previous"
        ;;
      *)
        echo "Perfil tuned anterior inválido ou desconhecido: $previous" >&2
        echo "Restaurando balanced por segurança." >&2
        ${pkgs.tuned}/bin/tuned-adm profile balanced
        ;;
    esac

    rm -f "$previous_file"
  '';

  mochaGameOn = pkgs.writeShellScriptBin "mocha-game-on" ''
    set -euo pipefail

    previous="$(${pkgs.tuned}/bin/tuned-adm active 2>/dev/null | sed -n 's/^Current active profile: //p' | head -n 1)"
    [ -n "$previous" ] || previous="desconhecido"

    if /run/wrappers/bin/sudo -n ${mochaGameOnRoot}/bin/mocha-game-on-root; then
      ${pkgs.libnotify}/bin/notify-send "Mocha Game Mode" "latency-performance ativado; anterior: $previous" 2>/dev/null || true
      echo "Mocha Game Mode: ON"
      echo "Perfil anterior: $previous"
      echo "Perfil atual: latency-performance"
      echo "Modo recomendado:"
      echo "  Use o launcher: Steam - Mocha Game Session"
    else
      echo "ERRO: não foi possível ativar o Mocha Game Mode."
      echo "Verifique a regra sudo NOPASSWD para mocha-game-on-root."
      exit 1
    fi
  '';

  mochaGameOff = pkgs.writeShellScriptBin "mocha-game-off" ''
    set -euo pipefail

    previous="balanced"
    if [ -s /run/mocha-game-mode/previous-tuned-profile ]; then
      previous="$(head -n 1 /run/mocha-game-mode/previous-tuned-profile | tr -d '[:space:]')"
    fi

    if /run/wrappers/bin/sudo -n ${mochaGameOffRoot}/bin/mocha-game-off-root; then
      ${pkgs.libnotify}/bin/notify-send "Mocha Game Mode" "perfil restaurado: $previous" 2>/dev/null || true
      echo "Mocha Game Mode: OFF"
      echo "Perfil restaurado: $previous"
    else
      echo "ERRO: não foi possível desativar o Mocha Game Mode."
      echo "Verifique a regra sudo NOPASSWD para mocha-game-off-root."
      exit 1
    fi
  '';

  mochaSteamRun = pkgs.writeShellScriptBin "mocha-steam-run" ''
    # Wrapper oficial do Mocha para Steam.
    #
    # Linha recomendada na Steam:
    #   /run/current-system/sw/bin/mocha-steam-run %command%
    #
    # Este wrapper aplica no JOGO:
    #   - Mocha Game Mode / tuned latency-performance;
    #   - MangoHud;
    #   - Feral GameMode via gamemoderun.
    #
    # Importante:
    #   Não use gamemoderun na Steam inteira. Isso pode quebrar steamwebhelper.
    #
    # Por que este wrapper existe:
    #   A Steam/Proton pode retornar do %command% antes do jogo realmente fechar.
    #   Então o wrapper tenta manter o Mocha Game Mode ativo enquanto detectar
    #   processos com SteamAppId/SteamGameId/STEAM_COMPAT_APP_ID.

    set +e

    if [ "$#" -eq 0 ]; then
      echo "Uso: mocha-steam-run <comando-do-jogo>"
      echo "Na Steam use:"
      echo "  /run/current-system/sw/bin/mocha-steam-run %command%"
      exit 1
    fi

    cache_dir="$HOME/.cache/mocha"
    log_file="$cache_dir/steam-run.log"
    mkdir -p "$cache_dir"

    appid="''${SteamAppId:-''${SteamGameId:-''${STEAM_COMPAT_APP_ID:-}}}"

    {
      echo
      echo "===== mocha-steam-run $(date '+%Y-%m-%d %H:%M:%S %z') ====="
      echo "argv: $*"
      echo "SteamAppId=''${SteamAppId:-}"
      echo "SteamGameId=''${SteamGameId:-}"
      echo "STEAM_COMPAT_APP_ID=''${STEAM_COMPAT_APP_ID:-}"
      echo "appid_detectado=$appid"
      ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
    } >> "$log_file" 2>&1

    has_app_process() {
      [ -n "$appid" ] || return 1

      for envfile in /proc/[0-9]*/environ; do
        pid="$(basename "$(dirname "$envfile")")"

        # Não contar o próprio wrapper, senão ele espera a si mesmo para sempre.
        [ "$pid" = "$$" ] && continue

        tr '\0' '\n' < "$envfile" 2>/dev/null | grep -Eq           "^(SteamAppId|SteamGameId|STEAM_COMPAT_APP_ID)=$appid$" && return 0
      done

      return 1
    }

    ${mochaGameOn}/bin/mocha-game-on >> "$log_file" 2>&1

    {
      echo "perfil apos mocha-game-on:"
      ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
    } >> "$log_file" 2>&1

    MANGOHUD=1 \
    MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf" \
      ${pkgs.gamemode}/bin/gamemoderun "$@" &
    game_pid=$!

    echo "game_pid=$game_pid" >> "$log_file"

    wait "$game_pid"
    game_status=$?

    {
      echo "comando principal retornou status=$game_status em $(date '+%Y-%m-%d %H:%M:%S %z')"
      echo "checando processos restantes do appid=$appid"
    } >> "$log_file" 2>&1

    if [ -n "$appid" ]; then
      idle_count=0
      loops=0

      # Espera no máximo 6 horas. Desliga quando não detectar processo do AppID
      # por 5 checagens seguidas.
      while [ "$loops" -lt 21600 ]; do
        if has_app_process; then
          idle_count=0
        else
          idle_count=$((idle_count + 1))
        fi

        [ "$idle_count" -ge 5 ] && break

        sleep 1
        loops=$((loops + 1))
      done

      echo "fim da espera appid=$appid loops=$loops idle_count=$idle_count" >> "$log_file"
    fi

    ${mochaGameOff}/bin/mocha-game-off >> "$log_file" 2>&1

    {
      echo "perfil apos mocha-game-off:"
      ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
      echo "===== fim mocha-steam-run ====="
    } >> "$log_file" 2>&1

    exit "$game_status"
  '';

  mochaGamingStatus = pkgs.writeShellScriptBin "mocha-gaming-status" ''
    set +e

    echo "===== MOCHA GAMING STATUS ====="
    echo

    echo "===== TUNED ====="
    ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true

    echo
    echo "===== PERFIL ANTERIOR SALVO ====="
    if [ -s /run/mocha-game-mode/previous-tuned-profile ]; then
      cat /run/mocha-game-mode/previous-tuned-profile
    else
      echo "nenhum"
    fi

    echo
    echo "===== CPU GOVERNOR ====="
    grep -H . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sed -n '1,24p' || true

    echo
    echo "===== CPU EPP ====="
    grep -H . /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference 2>/dev/null | sed -n '1,24p' || true

    echo
    echo "===== NVIDIA ====="
    if command -v nvidia-smi >/dev/null 2>&1; then
      nvidia-smi --query-gpu=driver_version,name,pstate,temperature.gpu,power.draw --format=csv,noheader,nounits 2>/dev/null || true
    else
      echo "nvidia-smi indisponível"
    fi

    echo
    echo "===== GAMEMODE ====="
    ${pkgs.gamemode}/bin/gamemoded -s 2>/dev/null || true
    systemctl --user status gamemoded --no-pager -l 2>/dev/null | sed -n '1,40p' || true

    echo
    echo "===== MANGOHUD ====="
    if [ -f "$HOME/.config/MangoHud/MangoHud.conf" ]; then
      echo "MangoHud.conf: $HOME/.config/MangoHud/MangoHud.conf"
    else
      echo "MangoHud.conf: ausente"
    fi

    echo
    echo "===== MODO STEAM RECOMENDADO ====="
    echo "Steam - Mocha Game Session"
    echo
    echo "===== LINHA RECOMENDADA POR JOGO ====="
    echo "/run/current-system/sw/bin/mocha-steam-run %command%"
  '';

  steamMochaSession = pkgs.writeShellScriptBin "steam-mocha-session" ''
    # Sessão gamer oficial do Mocha.
    #
    # Uso recomendado:
    #   1. Fechar a Steam, se já estiver aberta.
    #   2. Abrir pelo menu: "Steam - Mocha Game Session".
    #   3. Jogar normalmente.
    #   4. Encerrar pelo menu "Mocha Game Session OFF" ou sair da Steam.
    #
    # Durante a sessão gamer:
    #   - ativa Mocha Game Mode / tuned latency-performance;
    #   - exporta MANGOHUD=1;
    #   - não mexe no Dash to Dock.
    #
    # Importante:
    #   A Steam faz bootstrap/reexec: o primeiro processo pode terminar
    #   enquanto a Steam real continua aberta via steam/steamwebhelper.
    #   Por isso este launcher monitora os processos reais da Steam antes
    #   de restaurar o perfil tuned.

    set +e

    cache_dir="$HOME/.cache/mocha"
    log_file="$cache_dir/steam-session.log"
    session_off_handled_file="$cache_dir/session-off-handled"

    mkdir -p "$cache_dir"

    # Steam usa bwrap/sandbox e pode falhar se for chamada a partir de /etc/nixos.
    # Sempre iniciar a sessão Steam a partir do HOME.
    cd "$HOME"

    steam_is_running() {
      pgrep -u "$USER" -x steam >/dev/null 2>&1 && return 0
      pgrep -u "$USER" -f steamwebhelper >/dev/null 2>&1 && return 0
      return 1
    }

    show_steam_interface() {
      {
        echo "Solicitando abertura da interface principal da Steam."
        ${pkgs.steam}/bin/steam steam://open/main
        sleep 2
        ${pkgs.steam}/bin/steam steam://open/games
      } >> "$log_file" 2>&1 &
    }

    wait_for_steam_to_appear() {
      i=0

      while ! steam_is_running && [ "$i" -lt 60 ]; do
        sleep 1
        i=$((i + 1))
      done

      {
        echo "Steam appear wait loops=$i"
      } >> "$log_file" 2>&1
    }

    wait_for_steam_to_exit() {
      i=0

      while steam_is_running; do
        sleep 2
        i=$((i + 1))

        if [ $((i % 30)) -eq 0 ]; then
          {
            echo "Steam ainda aberta; wait loops=$i"
          } >> "$log_file" 2>&1
        fi
      done

      {
        echo "Steam exit wait loops=$i"
      } >> "$log_file" 2>&1
    }

    {
      echo
      echo "===== steam-mocha-session $(date '+%Y-%m-%d %H:%M:%S %z') ====="
      echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
      echo "perfil antes:"
      ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
    } >> "$log_file" 2>&1

    ${mochaGameOn}/bin/mocha-game-on >> "$log_file" 2>&1

    cleanup() {
      if [ -f "$session_off_handled_file" ]; then
        {
          echo "Sessao encerrada pelo atalho OFF; cleanup automatico ignorado."
          echo "perfil depois:"
          ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
          echo "===== fim steam-mocha-session ====="
        } >> "$log_file" 2>&1

        rm -f "$session_off_handled_file"
        return 0
      fi

      ${mochaGameOff}/bin/mocha-game-off >> "$log_file" 2>&1

      {
        echo "perfil depois:"
        ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
        echo "===== fim steam-mocha-session ====="
      } >> "$log_file" 2>&1
    }

    trap cleanup EXIT INT TERM

    export MANGOHUD=1
    export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"

    if steam_is_running; then
      {
        echo "Steam já estava aberta antes do launcher."
        echo "Mocha Game Mode ativado; monitorando steam/steamwebhelper até a saída real."
        echo "Aviso: para MangoHud herdar corretamente, prefira abrir a Steam pelo launcher antes do jogo."
      } >> "$log_file" 2>&1

      ${pkgs.libnotify}/bin/notify-send \
        "Steam - Mocha Game Session" \
        "Steam já estava aberta. Mocha Game Mode ativado; abrindo interface da Steam." \
        2>/dev/null || true

      show_steam_interface
    else
      ${pkgs.libnotify}/bin/notify-send \
        "Steam - Mocha Game Session" \
        "Mocha Game Mode ativado. Steam será monitorada até sair de verdade." \
        2>/dev/null || true

      MANGOHUD=1 ${pkgs.steam}/bin/steam "$@" >> "$log_file" 2>&1 &
      steam_launcher_pid=$!

      {
        echo "Steam launcher pid=$steam_launcher_pid"
      } >> "$log_file" 2>&1

      wait_for_steam_to_appear
      show_steam_interface
    fi

    wait_for_steam_to_exit

    if [ -n "$steam_launcher_pid" ]; then
      wait "$steam_launcher_pid" 2>/dev/null || true
    fi

    exit 0
  '';

  steamMochaSessionOff = pkgs.writeShellScriptBin "steam-mocha-session-off" ''
    # Encerrador oficial da sessão gamer do Mocha.
    #
    # Faz o pacote completo da sessão:
    #   - fecha a Steam;
    #   - desativa Mocha Game Mode;
    #   - restaura o perfil tuned anterior.
    #
    # Não mexe no Dash to Dock.
    # O Dash deve obedecer autohide/intellihide normalmente.

    set +e

    cache_dir="$HOME/.cache/mocha"
    log_file="$cache_dir/steam-session.log"
    session_off_handled_file="$cache_dir/session-off-handled"

    mkdir -p "$cache_dir"

    # Steam usa bwrap/sandbox e pode falhar se for chamada a partir de /etc/nixos.
    # O encerrador também deve rodar a partir do HOME.
    cd "$HOME"

    {
      echo
      echo "===== steam-mocha-session-off $(date '+%Y-%m-%d %H:%M:%S %z') ====="
      echo "Encerrando Steam e restaurando sessao gamer."
    } >> "$log_file" 2>&1

    # Marca para o cleanup do steam-mocha-session não restaurar tuned duas vezes.
    printf '%s\n' "handled" > "$session_off_handled_file"

    ${pkgs.steam}/bin/steam -shutdown >> "$log_file" 2>&1 || true

    i=0
    while { pgrep -u "$USER" -x steam >/dev/null 2>&1 || pgrep -u "$USER" -f steamwebhelper >/dev/null 2>&1; } && [ "$i" -lt 25 ]; do
      sleep 1
      i=$((i + 1))
    done

    {
      echo "Steam shutdown wait loops=$i"
    } >> "$log_file" 2>&1

    ${mochaGameOff}/bin/mocha-game-off >> "$log_file" 2>&1 || true

    {
      echo "perfil depois do OFF:"
      ${pkgs.tuned}/bin/tuned-adm active 2>/dev/null || true
      echo "===== fim steam-mocha-session-off ====="
    } >> "$log_file" 2>&1

    ${pkgs.libnotify}/bin/notify-send \
      "Mocha Game Session OFF" \
      "Steam encerrada e perfil tuned restaurado." \
      2>/dev/null || true
  '';

  steamMochaSessionDesktop = pkgs.makeDesktopItem {
    name = "steam-mocha-session";
    desktopName = "Steam - Mocha Game Session";
    genericName = "Mocha Gaming Session";
    comment = "Open Steam with Mocha Game Mode and MangoHud enabled";
    exec = "steam-mocha-session";
    icon = "steam";
    terminal = false;
    categories = [
      "Game"
    ];
  };

  mochaGameModeOnDesktop = pkgs.makeDesktopItem {
    name = "mocha-game-mode-on";
    desktopName = "Mocha Game Mode ON";
    genericName = "Enable Mocha Game Mode";
    comment = "Enable tuned latency-performance for gaming";
    exec = "mocha-game-on";
    icon = "applications-games";
    terminal = false;
    categories = [
      "Game"
      "Utility"
    ];
  };

  mochaGameModeOffDesktop = pkgs.makeDesktopItem {
    name = "mocha-game-session-off";
    desktopName = "Mocha Game Session OFF";
    genericName = "End Mocha Game Session";
    comment = "Close Steam and restore the previous tuned profile";
    exec = "steam-mocha-session-off";
    icon = "process-stop";
    terminal = false;
    categories = [
      "Game"
      "Utility"
    ];
  };


in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;

    settings = {
      general = {
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;

        # O Mocha usa tuned latency-performance para governor/EPP.
        # GameMode continua útil para integração por jogo, MangoHud e scripts.
        softrealtime = "auto";
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'Mocha GameMode' 'GameMode ativado'";
        end = "${pkgs.libnotify}/bin/notify-send 'Mocha GameMode' 'GameMode desativado'";
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    libnotify
    tuned

    mochaGameOn
    mochaGameOff
    mochaSteamRun
    mochaGamingStatus
    mochaGameOnRoot
    mochaGameOffRoot
  
    steamMochaSession
    steamMochaSessionDesktop
    mochaGameModeOnDesktop
    mochaGameModeOffDesktop

    steamMochaSessionOff
  ];

  security.sudo.extraRules = [
    {
      users = [ "hal" ];
      commands = [
        {
          command = "${mochaGameOnRoot}/bin/mocha-game-on-root";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${mochaGameOffRoot}/bin/mocha-game-off-root";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  system.activationScripts.mochaMangoHud.text = ''
    install -d -m 0755 -o hal -g users /home/hal/.config/MangoHud

    cat > /home/hal/.config/MangoHud/MangoHud.conf <<'EOF_MANGOHUD'
# Diesel OS Lab - GNOME Mocha Edition
# MangoHud preset compacto do Mocha
#
# Linha visual pretendida:
#   FPS | ms | GPU % MHz VRAM | CPU % MHz | RAM | Mocha/tuned
#
# Linha Steam por jogo:
#   Experimental. Preferir mocha-game-on/off manual ou sessão Steam Mocha.
#
# Modo manual estável:
#   mocha-game-on
#   abrir jogo pela Steam
#   mocha-game-off ao terminar

legacy_layout=false
horizontal
position=top-left
font_size=14
round_corners=6
background_alpha=0.35
background_color=2A1B14
text_color=D6B89A
text_outline=1
text_outline_color=1E1815
table_columns=20
hud_no_margin

toggle_hud=Shift_R+F12
toggle_logging=Shift_L+F2

fps
frametime

gpu_stats
gpu_text=GPU
gpu_core_clock
vram

cpu_stats
cpu_text=CPU
cpu_mhz
ram

custom_text=Mocha
exec=/run/current-system/sw/bin/tuned-adm active 2>/dev/null | sed 's/Current active profile: //'

gamemode

time
time_format=%H:%M

no_small_font
EOF_MANGOHUD

    chown hal:users /home/hal/.config/MangoHud/MangoHud.conf
    chmod 0644 /home/hal/.config/MangoHud/MangoHud.conf
  '';
}
